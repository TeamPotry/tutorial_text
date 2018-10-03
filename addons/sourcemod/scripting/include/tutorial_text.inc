#if defined __tutotial_text_included
	#endinput
#endif

#define __tutotial_text_included

#include <stocksoup/tf/annotations>

enum TextFireType
{
    FireType_Test = 0, // Fire from tutorial_text.sp test menu.
    FireType_ConfigId, // Fire from ID in config file.
	FireType_SubPlugin // Fire from another plugin using TT_FireTutorialText Function. (Can use Custom MessageID.)
};

enum ShowMessageCookieRule
{
	Type_None = -1,
	Type_Normal = 0, // text is no longer ignore rules. (But first message is will ignore SETTING.)
	Type_OnlyOne, // only show when first time. (SETTING ignored.)
	Type_EveryTime, // if text following this rule, always show text. (SETTING ignored.)
	Type_NormalEvenFirst // text is no longer ignore rules.
};

methodmap TTSettingCookie {
	public static native Handle GetTTSettingCookie();

	public static native bool GetClientTextViewSetting(const int client);

	public static native void SetClientTextViewSetting(const int client, bool setting);
}

#define PLUGIN_TEST_CONFIG_FILE_PATH "configs/tutorial_text.cfg"

methodmap TTextKeyValue < KeyValues {
	public TTextKeyValue(const char[] filename = "") {
		TTextKeyValue keyValue = view_as<TTextKeyValue>(new KeyValues("tutorial_text"));

		char config[PLATFORM_MAX_PATH];
		if(filename[0] != '\0')
			BuildPath(Path_SM, config, sizeof(config), "configs/tutorial_text/%s", filename);
		else
			BuildPath(Path_SM, config, sizeof(config), PLUGIN_TEST_CONFIG_FILE_PATH);

		if(!FileExists(config) || !keyValue.ImportFromFile(config))
			return null;

		return keyValue;
	}

	public native bool GetValue(const char[] messageId, const char[] key, char[] value, const int buffer, const int client = 0);
}

methodmap TTCookie < Handle {
	public static native Handle GetTTCookie(const char[] filename, const char[] messageId);

	public static native bool GetClientViewed(const int client, const char[] filename, const char[] messageId);

	public static native void SetClientViewed(const int client, const char[] filename, const char[] messageId, bool value);

	public static native bool CheckRuleForClient(const char[] filename, const char[] messageId, const int client, const ShowMessageCookieRule customCookieRule = Type_None);
}

methodmap TTextEvent < TFAnnotationEvent {
	public static native TTextEvent InitTTextEvent();

	public native void ChangeTextLanguage(const char[] filename = "", const char[] messageId, const int client, any ...);

	public native bool FireTutorialText(const char[] filename = "", const char[] messageId, const int client, const ShowMessageCookieRule customCookieRule = Type_None);

	// public native void FireTutorialTextAll(const char[] filename = "", const char[] messageId, const ShowMessageCookieRule customCookieRule = Type_None, any ...);
}

/*
	Load message text from id in config.

	@param filename : if this string is empty, this returns test config TTextKeyValue.
	@param victim : Will be imported.

	@return false = Failed.
*/
native TTextKeyValue TT_LoadTutorialText(const char[] filename = "");

/*
	Load message text from id in config.

	@param messageId ; First, This is event's Text.
	@param client : if this value is not 0, will set language to client's language.

	@return
*/
native bool TT_LoadMessageID(TTextEvent &event, const char[] filename, const char[] messageId);

stock void CopyMessageEvent(TTextEvent event, TTextEvent victim)
{
    if(event == null || victim == null)
    {
        ThrowError("CopyMessageEvent (NullException)");
        return;
    }
    char values[PLATFORM_MAX_PATH];
    float pos[3], normal[3];

    victim.ShowEffect = event.ShowEffect;
    victim.ShowDistance = event.ShowDistance;
    victim.VisibilityBits = event.VisibilityBits;
    victim.FollowEntity = event.FollowEntity;
    victim.ID = event.GetInt("id");
    victim.Lifetime = event.GetFloat("lifetime");

    event.GetString("play_sound", values, sizeof(values));
    victim.SetSound(values);

    event.GetText(values, sizeof(values));
    victim.SetText(values);

    pos[0] = event.GetFloat("worldPosX");
    pos[1] = event.GetFloat("worldPosY");
    pos[2] = event.GetFloat("worldPosZ");

    victim.SetPosition(pos);

    normal[0] = event.GetFloat("worldNormalX");
    normal[1] = event.GetFloat("worldNormalY");
    normal[2] = event.GetFloat("worldNormalZ");

    victim.SetNormal(normal);

    return;
}

public SharedPlugin __pl_tutorial_text=
{
	name="tutorial_text",
	file="tutorial_text.smx",
	#if defined REQUIRE_PLUGIN
		required=1,
	#else
		required=0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_tutorial_text_SetNTVOptional()
{
	MarkNativeAsOptional("TT_LoadMessageID");
	MarkNativeAsOptional("TT_FireTutorialText");
}
#endif
