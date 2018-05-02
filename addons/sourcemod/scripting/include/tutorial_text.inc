#if defined __tutotial_text_included
	#endinput
#endif

#define __tutotial_text_included

/*

enum TestTextDisplayType
{
    Type_ShowAll = 0,
    Type_ShowClient, // Only for client who called menu.
};

enum TestTextPositionType
{
    Type_FollowClient = 0, // Follow client who called menu.
    Type_FollowAim, // Seeing spot
	Type_FollowAimTarget // follow entity in client's seeing spot.
};

*/

enum TextFireType
{
    FireType_Test = 0, // Fire from tutorial_text.sp test menu.
    FireType_ConfigId, // Fire from ID in config file.
	FireType_SubPlugin // Fire from another plugin using TT_FireTutorialText Function. (Can use Custom MEssageID.)
};

enum ShowMessageCookieRule
{
	Type_Normal = 0, // text is no longer ignore rules. (But first message is will ignore SETTING.)
	Type_OnlyOne, // only show when first time. (SETTING ignored.)
	Type_EveryTime, // if text following this rule, always show text. (SETTING ignored.)
	Type_NormalEvenFirst // text is no longer ignore rules.
};


methodmap TTSettingCookie < Handle {
	public TTSettingCookie() {
		char temp[40];
		Format(temp, sizeof(temp), "tutorial_text_setting");
		return view_as<TTSettingCookie>(FindCookieEx(temp));
	}

	public bool GetClientTextViewSetting(const int client) {
		char temp[80];
		GetClientCookie(client, this, temp, sizeof(temp));

		return StringToInt(temp) > 0;
	}

	public void SetClientTextViewSetting(const int client, bool setting) {
		char temp[2];
		Format(temp, sizeof(temp), "%s", setting ? "1" : "0");
		SetClientCookie(client, this, temp);
	}

}

methodmap TTCookie < Handle {
	public TTCookie(const char[] filename, const char[] messageId) {
		char temp[80];
		Format(temp, sizeof(temp), "tutorial_text_id:%s_%s", filename, messageId);
		return view_as<TTCookie>(FindCookieEx(temp));
	}

	public bool GetClientViewed(const int client)
	{
		char temp[2];
		GetClientCookie(client, this, temp, sizeof(temp));
		return StringToInt(temp) > 0;
	}

	public void SetClientViewed(const int client, bool value)
	{
		char temp[2];
		Format(temp, sizeof(temp), "%s", value ? "1" : "0");
		SetClientCookie(client, this, temp);
	}

	public bool CheckRuleForClient(const int client)
	{	// FIXME: OH MY GOD
		char temp[80];
		char exst[2][64]; // exst[1] is answer! wuaaaa
		TTSettingCookie settingCookie = new TTSettingCookie();
		CookieAccess access;
		ReadCookieIterator(this, temp, sizeof(temp), access); // FIXME: access is no needed.
		ExplodeString(temp, ":", exst, sizeof(exst), sizeof(exst[]))

		if(access == CookieAccess_Private)
			return false; // FIXME: access is no needed.

		GetConfigValue(exst[1], "cookie_rule", temp, sizeof(temp));
		ShowMessageCookieRule rule = view_as<ShowMessageCookieRule>(StringToInt(temp));

		GetClientCookie(client, this, temp, sizeof(temp));
		bool firstViewed = StringToInt(temp) > 0;

		bool viewSetting = settingCookie.GetClientTextViewSetting(client);

		switch(rule)
		{
		    case Type_Normal:
		    {
		        if(!viewSetting)
		        {
		            if(!firstViewed)
		                return true;
		            return false;
		        }
		    }

		    case Type_OnlyOne:
		    {
		        if(firstViewed)
		            return true;
		        return false;
		    }

		    case Type_EveryTime:
		    {
		        return true;
		    }

		    case Type_NormalEvenFirst:
		    {
		        return viewSetting;
		    }
		}

		return true;
	}
}

methodmap TTextKeyValue < KeyValues {
	public TTextKeyValue(const char[] filename = "") {
		TTextKeyValue kv = view_as<TTextKeyValue>(new KeyValues("tutorial_text"));

		char config[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, config, sizeof(config), "configs/tutorial_text/%s", filename);

		if(!FileExists(config) || !kv.ImportFromFile(config))
			return null;

		return kv;
	}

	public bool GetValue(const char[] messageId, const char[] key, char[] value, const int buffer, const int client = 0)
	{
	    char langId[4];
	    if(client > 0 && IsClientInGame(client))
	        GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
	    else
	        Format(langId, sizeof(langId), "en");


	    if(!this.JumpToKey(messageId))
	    {
	        LogError("[TT] not found messageId in config ''%s''", messageId);
	        return false;
	    }

	    if(!StrEqual(langId, "en"))
	    {
	        if(!kv.JumpToKey(langId))
	        {
	            LogError("[TT] not found languageId in ''%s'' ''%s''", messageId, langId);
	            // 이 경우에는 그냥 영어로 변경.
	        }
	    }

	    this.GetString(key, value, buffer);

	    return true;
	}
}

methodmap TTextEvent < TFAnnotationEvent {
	public TTextEvent() {
		return view_as<TTextEvent>(new TFAnnotationEvent());
	}

	public void ChangeTextLanguage(const char[] filename, const char[] messageId, const int client)
	{
		if(!IsClientInGame(client) || IsFakeClient(client)) return;

		TTextKeyValue kv = new TTextKeyValue(filename);
		char text[128];
		kv.GetValue(messageId, "text", text, sizeof(text), client);

		this.SetText(text);
	}

	public bool FireTutorialText(const char[] filename, const char[] messageId, const int client)
	{
	    /*
	        This function will fire annotation after rule checking.
	        And it will set Viewed Cookie.
	    */
	    TTCookie cookie = new TTCookie(filename, messageId);

	    if(IsFakeClient(client) || !cookie.CheckRuleForClient(client))
	        return false;

	    this.VisibilityBits = (1 << client);
	    cookie.SetClientViewed(client, true);

	    this.Fire();
	    return true;
	}
}

/*
	Load message text from id in config.

	@param filename : if this string is empty, this returns test config TTextKeyValue.

	@return TTextKeyValue
*/
native TTextKeyValue TT_LoadTutorialText(const char[] filename = "");

/*
	Load message text from id in config.

	@param messageId ; First, This is event's Text.
	@param client : if this value is not 0, will set language to client's language.

	@return
*/
native TTextEvent TT_LoadMessageID(const char[] filename, const char[] messageId);

public SharedPlugin __pl_TUTORIAL_TEXT=
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
public __pl_TUTORIAL_TEXT_SetNTVOptional()
{
	MarkNativeAsOptional("TT_LoadMessageID");
	MarkNativeAsOptional("TT_FireTutorialText");
}
#endif
