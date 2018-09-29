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

	public bool GetValue(const char[] messageId, const char[] key, char[] value, const int buffer, const int client = 0)
	{
		char langId[4];

		if(client > 0 && IsClientInGame(client))
		    GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
		else
		    Format(langId, sizeof(langId), "en");

		TTextKeyValue cloned = view_as<TTextKeyValue>(new KeyValues("tutorial_text"));

		if(messageId[0] != '\0')
		{
			int id;

			this.GetSectionSymbol(id);
			this.Rewind();

			cloned.Import(this);

			this.JumpToKeySymbol(id);

			if(!cloned.JumpToKey(key))
			{
				LogError("[TT] not found keyName in config ''%s''", messageId);
				delete cloned;
				return false;
			}
		}
		else {
			cloned.Import(this);
		}

		if(!StrEqual(langId, "en"))
		{
		    if(!cloned.JumpToKey(langId))
		    {
		        LogError("[TT] not found languageId in ''%s'' ''%s''", messageId, langId);
		        // 이 경우에는 그냥 영어로 변경.
		    }
		}

		cloned.GetString(key, value, buffer);
		delete cloned;

		return true;
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

	public bool CheckRuleForClient(const char[] filename, const char[] messageId, const int client, const ShowMessageCookieRule customCookieRule = Type_None)
	{
		char temp[80];
		TTSettingCookie settingCookie = new TTSettingCookie();
		ShowMessageCookieRule rule;

		if(customCookieRule != Type_None) {
			rule = customCookieRule;
		}
		else {
			TTextKeyValue kv = new TTextKeyValue(filename);
			kv.GetValue(messageId, "cookie_rule", temp, sizeof(temp));
			rule = view_as<ShowMessageCookieRule>(StringToInt(temp));
			delete kv;
		}

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

methodmap TTextEvent < TFAnnotationEvent {
	public TTextEvent() {
		return view_as<TTextEvent>(new TFAnnotationEvent());
	}

	public void ChangeTextLanguage(const char[] filename = "", const char[] messageId, const int client, ArrayList parameterArray = null) // FIXME: How about any ... ?
	{
		if(!IsClientInGame(client) || IsFakeClient(client)) return;

		TTextKeyValue temp = new TTextKeyValue(filename);
		char text[255], formattingStyle[128], tempNumberStr[8];
		int formatCount = 0;

		temp.GetValue(messageId, "text", text, sizeof(text), client);
		temp.GetValue(messageId, "#format", formattingStyle, sizeof(formattingStyle));

		for(int loop = 0; ; loop++) // 포맷 카운트 확보
		{
			Format(tempNumberStr, sizeof(tempNumberStr), "%i", loop + 1);
			if(StrContains(formattingStyle, tempNumberStr) == -1)
				break;

			formatCount++;
		}

		if(formatCount > 0 && formatCount < 16)
		{
			if(parameterArray == null || formatCount != parameterArray.Length)
			{
				ThrowError("#format key is exist. But parameterArray doesn't match! (%d / %d)", parameterArray == null ? 0 : parameterArray.Length, formatCount);
			}

			char formatting[16][8];
			char tempString[255];

			if(ExplodeString(formattingStyle, ",", formatting, 16, 8) <= 0)
				strcopy(formatting[0], sizeof(formatting[]), formattingStyle);

			for(int loop = 1; loop <= formatCount; loop++)
			{
				int seIndex = FindCharInString(formatting[loop - 1], ':');
				// 포맷 스타일 확보
				if(formatting[loop][seIndex + 1] == 's') // 문자열
				{
					parameterArray.GetString(loop - 1, tempString, sizeof(tempString));
				}
				else
				{
					char tempItem[2];
					tempItem[0] = '%';
					tempItem[1] = formatting[loop - 1][seIndex + 1];

					Format(tempString, sizeof(tempString), tempItem, parameterArray.Get(loop - 1));
				}
				Format(tempNumberStr, sizeof(tempNumberStr), "{%i}", loop);
				ReplaceString(text, sizeof(text), tempNumberStr, tempString);
			}
		}

		delete temp;

		this.SetText(text);
	}

	public bool FireTutorialText(const char[] filename = "", const char[] messageId, const int client, const ShowMessageCookieRule customCookieRule = Type_None)
	{
		/*
		This function will fire annotation after rule checking.
		And it will set Viewed Cookie.
		*/
		TTCookie cookie = new TTCookie(filename, messageId);
		TTextKeyValue tempKeyValues = null;

		if(IsFakeClient(client) || !cookie.CheckRuleForClient(filename, messageId, client, customCookieRule))
		{
			delete cookie;
			delete tempKeyValues;

			return false;
		}

		this.VisibilityBits = (1 << client);
		cookie.SetClientViewed(client, true);

		this.Fire();
		delete cookie;
		delete tempKeyValues;

		return true;
	}

	public void FireTutorialTextAll(const char[] filename = "", const char[] messageId, ArrayList parameterArray = null, const ShowMessageCookieRule customCookieRule = Type_None)
	{
		TTextEvent tempEvent;
		for(int target = 1; target <= MaxClients; target++)
		{
			if(!IsClientInGame(target) || IsFakeClient(target)) continue;

			tempEvent = new TTextEvent();
			CopyMessageEvent(this, tempEvent);

			tempEvent.ChangeTextLanguage(filename, messageId, target, parameterArray);
			tempEvent.FireTutorialText(filename, messageId, target, customCookieRule);
		}

		this.Cancel();
	}
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
/*
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
*/
