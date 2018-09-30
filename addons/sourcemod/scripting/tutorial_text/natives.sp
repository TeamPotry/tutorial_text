void Native_Init()
{
    CreateNative("TT_LoadTutorialText", Native_LoadTutorialText);
    CreateNative("TT_LoadMessageID", Native_LoadMessageID);

    CreateNative("TTSettingCookie.GetTTSettingCookie", Native_TTSettingCookie_GetTTSettingCookie);
    CreateNative("TTSettingCookie.GetClientTextViewSetting", Native_TTSettingCookie_GetClientTextViewSetting);
    CreateNative("TTSettingCookie.SetClientTextViewSetting", Native_TTSettingCookie_SetClientTextViewSetting);

    CreateNative("TTextKeyValue.GetValue", Native_TTextKeyValue_GetValue);
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
