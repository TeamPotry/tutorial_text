#include <sourcemod>
#include <clientprefs>
#include <tutorial_text>
#include <morecolors>
#include <sdktools>
#include <sdkhooks>

#include "tutorial_text/database.sp"
#include "tutorial_text/global_var.sp"

#include "tutorial_text/commands.sp"
#include "tutorial_text/stocks.sp"
#include "tutorial_text/menu.sp"
#include "tutorial_text/natives.sp"

public Plugin myinfo =
{
	name = "[TF2] Tutorial Text",
	author = "Nopied",
	description = "This will help server noobs.",
	version = "0.91",
	url = "https://github.com/TeamPotry/tutorial_text"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	Native_Init();

	// tutorial_text/database.sp
	DB_Native_Init();

	// tutorial_text/global_var.sp
	Data_Native_Init();
}

public void OnPluginStart()
{
	RegAdminCmd("testtext", Cmd_TestTest, ADMFLAG_GENERIC);
	CreateConVar("tutotial_text_commands", "textset", "Commands for tutorial text setting menu.")

	AddCommandListener(Listener_Say, "say");
	AddCommandListener(Listener_Say, "say_team");

	LoadTranslations("tutorial_text");
	RegPluginLibrary("tutorial_text");
}

public void OnMapStart()
{
	PrecacheTestConfig();
	PrecacheAllText();

	g_DBData = new TTDBData();
}

public void OnClientAuthorized(int client, const char[] auth)
{
	if(IsFakeClient(client))	return;

	LoadedPlayerData[client] = new TTPlayerData(client);
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))	return;

	LoadedPlayerData[client].Update();
	delete LoadedPlayerData[client];
}

void PrecacheTestConfig()
{
	TTextKeyValue testKv = new TTextKeyValue();

	if(testKv == null)
    {
		LogError("%t", "menu_cached_id_message_error");
		return;
    }

	char messageId[64];
	char path[PLATFORM_MAX_PATH];
	char soundPath[PLATFORM_MAX_PATH];
	testKv.Rewind();

	if(testKv.GotoFirstSubKey())
	{
		do
		{
			testKv.GetSectionName(messageId, sizeof(messageId));
			testKv.GetString("play_sound", soundPath, sizeof(soundPath));

			if(soundPath[0] == '\0') continue;

			if(testKv.GetNum("sound_download", 0) > 0)
			{
				Format(path, sizeof(path), "sound/%s", soundPath);
				if(!FileExists(path)) {
					LogError("%t", "sound_not_found", soundPath);
					continue;
				}
			}

			if(!IsSoundPrecached(soundPath))
				PrecacheSound(soundPath);
		}
		while(testKv.GotoNextKey());
	}
}

void PrecacheAllText()
{
	TTextKeyValue fileKv;
	char path[PLATFORM_MAX_PATH];
	char soundPath[PLATFORM_MAX_PATH];
	char foldername[PLATFORM_MAX_PATH];
	char filename[PLATFORM_MAX_PATH];

	BuildPath(Path_SM, foldername, sizeof(foldername), "configs/tutorial_text");
	Handle dir = OpenDirectory(foldername);
	FileType filetype;

	if(!DirExists(foldername))
		SetFailState("no folder?");

	while(ReadDirEntry(dir, filename, PLATFORM_MAX_PATH, filetype))
	{
		if(filetype == FileType_File)
		{
			fileKv = new TTextKeyValue(filename);
			if(fileKv == null) continue;

			if(fileKv.GotoFirstSubKey())
			{
				do
				{
					fileKv.GetString("play_sound", soundPath, sizeof(soundPath));

					if(soundPath[0] == '\0') continue;

					Format(path, sizeof(path), "sound/%s", soundPath);
					if(!FileExists(path)) {
						LogError("%t", "sound_not_found", soundPath);
						continue;
					}

					if(!IsSoundPrecached(soundPath))
						PrecacheSound(soundPath);
				}
				while(fileKv.GotoNextKey());
			}

			delete fileKv;
		}
	}
}
