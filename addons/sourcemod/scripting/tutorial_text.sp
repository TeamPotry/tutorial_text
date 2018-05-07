#include <sourcemod>
#include <tutorial_text>
#include <morecolors>
#include <sdktools>
#include <sdkhooks>

#include "tutorial_text/commands.sp"
#include "tutorial_text/stocks.sp"
#include "tutorial_text/menu.sp"
#include "tutorial_text/natives.sp"

public Plugin myinfo =
{
	name = "[TF2] Tutorial Text",
	author = "Nopied v2.0",
	description = "This will help server noobs.",
	version = "0.9",
	url = "https://github.com/TeamPotry/tutorial_text"
};

StringMap g_hLoadedMap = null;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("TT_LoadTutorialText", Native_LoadTutorialText);
	CreateNative("TT_LoadMessageID", Native_LoadMessageID);
}

public void OnPluginStart()
{
	RegAdminCmd("testtext", Cmd_TestTest, ADMFLAG_GENERIC);
	CreateConVar("tutotial_text_commands", "textset", "Commands for tutorial text setting menu.")

	AddCommandListener(Listener_Say, "say");
	AddCommandListener(Listener_Say, "say_team");

	LoadTranslations("tutorial_text");
	RegPluginLibrary("tutorial_text");

	if(g_hLoadedMap == null)
		g_hLoadedMap = new StringMap();
}

public void OnMapStart()
{
	if(g_hLoadedMap != null)
		delete g_hLoadedMap;

	g_hLoadedMap = new StringMap();

	PrecacheTestConfig();
	PrecacheAllText();
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

			Format(path, sizeof(path), "sound/%s", soundPath);
			if(!FileExists(path)) {
				LogError("%t", "sound_not_found");
				continue;
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
	char messageId[64];
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
			Format(path, sizeof(path), "%s/%s", foldername, filename);

			fileKv = new TTextKeyValue(filename);
			if(fileKv == null) continue;

			fileKv.Rewind();

			AddToStringMap(filename, fileKv);

			if(fileKv.GotoFirstSubKey())
			{
				do
				{
					fileKv.GetSectionName(messageId, sizeof(messageId));
					fileKv.GetString("play_sound", soundPath, sizeof(soundPath));

					if(soundPath[0] == '\0') continue;

					Format(path, sizeof(path), "sound/%s", soundPath);
					if(!FileExists(path)) {
						LogError("%t", "sound_not_found");
						continue;
					}

					if(!IsSoundPrecached(soundPath))
						PrecacheSound(soundPath);
				}
				while(fileKv.GotoNextKey());
			}
		}
	}
}

bool GetTextKeyValues(const char[] filename, TTextKeyValue victim)
{
	TTextKeyValue temp;
	if(!g_hLoadedMap.GetValue(filename, temp) || temp == null)
	{
		return false;
	}
	temp.Rewind();
	victim.Import(temp);
	return true;
}

public bool AddToStringMap(char[] filename, TTextKeyValue victimKv)
{
	TTextKeyValue temp = view_as<TTextKeyValue>(new KeyValues("tutorial_text"));
	temp.Import(view_as<KeyValues>(victimKv));

	return g_hLoadedMap.SetValue(filename, temp, false);
}
