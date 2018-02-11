#include <sourcemod>
#include <stocksoup/tf/annotations>
#include <tutorial_text>
#include <morecolors>

#include "tutorial_text/commands.sp"
#include "tutorial_text/stocks.sp"
#include "tutorial_text/menu.sp"

public Plugin myinfo =
{
	name = "[TF2] Tutorial Text",
	author = "Nopied v2.0",
	description = "This will help server noobs.",
	version = "In Process",
	url = "https://github.com/TeamPotry/tutorial_text"
};

public void OnPluginStart()
{
	RegAdminCmd("testtext", Cmd_TestTest, ADMFLAG_GENERIC);

	LoadTranslations("tutorial_text");
}

public void OnMapStart()
{
	// 사운드 캐시

	PrecacheAllTextSound();
}

void PrecacheAllTextSound()
{
	KeyValues kv = new KeyValues("tutorial_text");

	if(!ImportConfigKeyValues(kv))
    {
        LogError("%t", "menu_cached_id_message_error");
		return;
    }

	char messageId[64];
	char path[PLATFORM_MAX_PATH];
	char soundPath[PLATFORM_MAX_PATH];
	kv.Rewind();

	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(messageId, sizeof(messageId));
			GetConfigValue(messageId, "play_sound", soundPath, sizeof(soundPath));

			if(soundPath[0] == '\0') continue;

			Format(path, sizeof(path), "sound/%s", soundPath);
			if(!FileExists(path)) {
				LogError("%t", "sound_not_found");
				continue;
			}

			if(!IsSoundPrecached(soundPath))
				PrecacheSound(soundPath);
		}
		while(kv.GotoNextKey());
	}
}
