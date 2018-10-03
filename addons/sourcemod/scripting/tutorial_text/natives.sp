void Native_Init()
{
    CreateNative("TT_LoadTutorialText", Native_LoadTutorialText);
    CreateNative("TT_LoadMessageID", Native_LoadMessageID);

    CreateNative("TTSettingCookie.GetTTSettingCookie", Native_TTSettingCookie_GetTTSettingCookie);
    CreateNative("TTSettingCookie.GetClientTextViewSetting", Native_TTSettingCookie_GetClientTextViewSetting);
    CreateNative("TTSettingCookie.SetClientTextViewSetting", Native_TTSettingCookie_SetClientTextViewSetting);

    CreateNative("TTextKeyValue.GetValue", Native_TTextKeyValue_GetValue);

    CreateNative("TTCookie.GetTTCookie", Native_TTCookie_GetTTCookie);
    CreateNative("TTCookie.GetClientViewed", Native_TTCookie_GetClientViewed);
    CreateNative("TTCookie.SetClientViewed", Native_TTCookie_SetClientViewed);
    CreateNative("TTCookie.CheckRuleForClient", Native_TTCookie_CheckRuleForClient);
    CreateNative("TTextEvent.InitTTextEvent", Native_TTextEvent_InitTTextEvent);
}

public int Native_LoadMessageID(Handle plugin, int numParams)
{
    char temp[64], temp_id[64];
    GetNativeString(2, temp, sizeof(temp));
    GetNativeString(3, temp_id, sizeof(temp_id));
    return view_as<int>(LoadMessageID(GetNativeCellRef(1), temp, temp_id));
}

public int Native_LoadTutorialText(Handle plugin, int numParams)
{
    char temp[64];
    GetNativeString(1, temp, sizeof(temp));
    return view_as<int>(new TTextKeyValue(temp));
}

public int Native_TTSettingCookie_GetTTSettingCookie(Handle plugin, int numParams)
{
    char temp[40];
    Format(temp, sizeof(temp), "tutorial_text_setting");
    return view_as<int>(FindCookieEx(temp));
}

public int Native_TTSettingCookie_GetClientTextViewSetting(Handle plugin, int numParams)
{
    Handle settingCookie = TTSettingCookie.GetTTSettingCookie();
    int client = GetNativeCell(1);
    char temp[2];

    GetClientCookie(client, settingCookie, temp, sizeof(temp));
    return StringToInt(temp) > 0;
}

public int Native_TTSettingCookie_SetClientTextViewSetting(Handle plugin, int numParams)
{
    Handle settingCookie = TTSettingCookie.GetTTSettingCookie();
    int client = GetNativeCell(1);
    bool setting = GetNativeCell(2);
    char temp[2];

    Format(temp, sizeof(temp), "%s", setting ? "1" : "0");
    SetClientCookie(client, settingCookie, temp);
}

public int Native_TTextKeyValue_GetValue(Handle plugin, int numParams)
{
    TTextKeyValue kv = GetNativeCell(1);
    int buffer = GetNativeCell(5);
    int client = GetNativeCell(6);

    char messageId[80], key[80], langId[4], text[256];
    GetNativeString(2, messageId, sizeof(messageId));
    GetNativeString(3, key, sizeof(key));

    if(client > 0 && IsClientInGame(client))
        GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
    else
        Format(langId, sizeof(langId), "en");

    TTextKeyValue cloned = view_as<TTextKeyValue>(new KeyValues("tutorial_text"));

    if(messageId[0] != '\0')
    {
        int id;

        kv.GetSectionSymbol(id);
        kv.Rewind();

        cloned.Import(kv);

        kv.JumpToKeySymbol(id);

        if(!cloned.JumpToKey(key))
        {
            LogError("[TT] not found keyName in config ''%s''", messageId);
            delete cloned;
            return false;
        }
    }
    else {
        cloned.Import(kv);
    }

    if(!StrEqual(langId, "en"))
    {
        if(!cloned.JumpToKey(langId))
        {
            LogError("[TT] not found languageId in ''%s'' ''%s''", messageId, langId);
            // 이 경우에는 그냥 영어로 변경.
        }
    }

    cloned.GetString(key, text, buffer);
    delete cloned;

    return true;
}

public int Native_TTCookie_GetTTCookie(Handle plugin, int numParams)
{
    char temp[80], filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(1, filename, sizeof(filename));
    GetNativeString(2, messageId, sizeof(messageId));
    Format(temp, sizeof(temp), "tutorial_text_id:%s_%s", filename, messageId);
    return view_as<int>(FindCookieEx(temp));
}

public int Native_TTCookie_GetClientViewed(Handle plugin, int numParams)
{
    char temp[2], filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(2, filename, sizeof(filename));
    GetNativeString(3, messageId, sizeof(messageId));
    Handle cookie = TTCookie.GetTTCookie(filename, messageId);

    GetClientCookie(GetNativeCell(1), cookie, temp, sizeof(temp));
    return StringToInt(temp) > 0;
}

public int Native_TTCookie_SetClientViewed(Handle plugin, int numParams)
{
    char temp[2], filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(2, filename, sizeof(filename));
    GetNativeString(3, messageId, sizeof(messageId));
    Handle cookie = TTCookie.GetTTCookie(filename, messageId);

    Format(temp, sizeof(temp), "%s", GetNativeCell(4) ? "1" : "0");
    SetClientCookie(GetNativeCell(1), cookie, temp);
}

public int Native_TTCookie_CheckRuleForClient(Handle plugin, int numParams)
{
    char temp[80], filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(1, filename, sizeof(filename));
    GetNativeString(2, messageId, sizeof(messageId));
    int client = GetNativeCell(3);
    ShowMessageCookieRule customCookieRule = GetNativeCell(4);

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

    bool firstViewed = TTCookie.GetClientViewed(client, filename, messageId);
    bool viewSetting = TTSettingCookie.GetClientTextViewSetting(client);

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

public int Native_TTextEvent_InitTTextEvent(Handle plugin, int numParams)
{
    return view_as<int>(new TFAnnotationEvent());
}
