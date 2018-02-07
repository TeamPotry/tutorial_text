#include <sourcemod>
#include <stocksoup/tf/annotations>

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
