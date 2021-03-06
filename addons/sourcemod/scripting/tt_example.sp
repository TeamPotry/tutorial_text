#include <sourcemod>
#include <sdktools>
#include <tutorial_text>

public Plugin myinfo =
{
	name = "[TF2] Tutorial Text : TEST",
	author = "POTRY Developer Team",
	description = "This will help server noobs.",
	version = "0.9",
	url = "https://github.com/TeamPotry/tutorial_text"
};

public void OnPluginStart()
{
	RegAdminCmd("givetext", Cmd_TestTest, ADMFLAG_GENERIC);
	RegAdminCmd("givenumtext", Cmd_NumTest, ADMFLAG_GENERIC);
}

public Action Cmd_TestTest(int client, int args)
{
	if(client > 0 && IsClientInGame(client))
	{
		TTextEvent event = TTextEvent.InitTTextEvent();
		float position[3];

		TT_LoadMessageID(event, "the_test_text.cfg", "this_is_text_text");
		GetClientEyePosition(client, position);
		event.SetPosition(position);

		event.ChangeTextLanguage("the_test_text.cfg", "this_is_text_text", client);
		event.FireTutorialText("the_test_text.cfg", "this_is_text_text", client);
	}

	return Plugin_Continue;
}

public Action Cmd_NumTest(int client, int args)
{
	if(client > 0 && IsClientInGame(client))
	{
		TTextEvent event = TTextEvent.InitTTextEvent();
		float position[3];

		TT_LoadMessageID(event, "the_test_text.cfg", "this_is_9");
		GetClientEyePosition(client, position);
		event.SetPosition(position);

		event.ChangeTextLanguage("the_test_text.cfg", "this_is_9", client, 9);
		event.FireTutorialText("the_test_text.cfg", "this_is_9", client);
	}

	return Plugin_Continue;
}
