void Native_Init()
{
    CreateNative("TT_LoadTutorialText", Native_LoadTutorialText);
    CreateNative("TT_LoadMessageID", Native_LoadMessageID);

    CreateNative("TTSettingCookie.GetTTSettingCookie", Native_TTSettingCookie_GetTTSettingCookie);
    CreateNative("TTSettingCookie.GetClientTextViewSetting", Native_TTSettingCookie_GetClientTextViewSetting);
    CreateNative("TTSettingCookie.SetClientTextViewSetting", Native_TTSettingCookie_SetClientTextViewSetting);

    CreateNative("TTextKeyValue.GetValue", Native_TTextKeyValue_GetValue);

    CreateNative("TTextEvent.InitTTextEvent", Native_TTextEvent_InitTTextEvent);
    CreateNative("TTextEvent.ChangeTextLanguage", Native_TTextEvent_ChangeTextLanguage);
    CreateNative("TTextEvent.FireTutorialText", Native_TTextEvent_FireTutorialText);
    // CreateNative("TTextEvent.FireTutorialTextAll", Native_TTextEvent_FireTutorialTextAll);
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
    int id;

    char messageId[80], key[80], langId[4], text[256];
    GetNativeString(2, messageId, sizeof(messageId));
    GetNativeString(3, key, sizeof(key));

    if(client > 0 && IsClientInGame(client))
        GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
    else
        Format(langId, sizeof(langId), "en");

    if(messageId[0] == '\0')
        return false;

    kv.GetSectionSymbol(id);
    kv.Rewind();

    if(!kv.JumpToKey(messageId))
    {
        kv.GetSectionName(text, sizeof(text));
        LogError("[TT] not found keyName in config ''%s'' (%s > %s)", messageId, text, messageId);
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

    kv.GetString(key, text, buffer);
    SetNativeString(4, text, buffer);
    kv.JumpToKeySymbol(id);

    return true;
}

public int Native_TTextEvent_InitTTextEvent(Handle plugin, int numParams)
{
    return view_as<int>(new TFAnnotationEvent());
}

public int Native_TTextEvent_ChangeTextLanguage(Handle plugin, int numParams)
{
    int client = GetNativeCell(4); // NOTE: 마지막 매개변수
    if(!IsClientInGame(client) || IsFakeClient(client)) return;

    TTextEvent textKv = GetNativeCell(1);
    char filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(2, filename, sizeof(filename));
    GetNativeString(3, messageId, sizeof(messageId));

    TTextKeyValue temp = new TTextKeyValue(filename);
    char text[255], formattingStyle[128], tempNumberStr[8];
    int formatCount = 0;

    temp.GetValue(messageId, "text", text, sizeof(text), client);
    temp.GetValue(messageId, "#format", formattingStyle, sizeof(formattingStyle));

    for(int loop = 0; ; loop++) // 포맷 카운트 확보 == {1:d},{2:s}...
    {
        Format(tempNumberStr, sizeof(tempNumberStr), "%i", loop + 1);
        if(StrContains(formattingStyle, tempNumberStr) == -1)
            break;

        formatCount++;
    }
    // NOTE: IN PROCESS.

    if(formatCount > 0 && formatCount < 12)
    {
        if(formatCount != numParams - 4)
        {
            ThrowError("#format key is exist. But parameter count doesn't match! (%d / %d)", numParams, formatCount);
        }

        char formatting[12][8];
        char tempString[255];

        if(ExplodeString(formattingStyle, ",", formatting, 12, 8) <= 0)
            strcopy(formatting[0], sizeof(formatting[]), formattingStyle);

        for(int loop = 0; loop < formatCount; loop++)
        {
            int seIndex = FindCharInString(formatting[loop], ':');
            formatting[loop][strlen(formatting[loop]) - 1] = '\0';
            // 포맷 스타일 확보
            if(formatting[loop][seIndex + 1] == 's') // 문자열
            {
                GetNativeString(4 + (loop + 1), tempString, sizeof(tempString));
            }
            else
            {
                char tempItem[8];

                strcopy(tempItem, sizeof(tempItem), formatting[loop][seIndex + 1]);
                Format(tempItem, sizeof(tempItem), "%c%s", '%', tempItem);
                Format(tempString, sizeof(tempString), tempItem, GetNativeCellRef(4 + (loop + 1)));
            }
            Format(tempNumberStr, sizeof(tempNumberStr), "{%i}", (loop + 1));
            ReplaceString(text, sizeof(text), tempNumberStr, tempString);
        }
    }

    delete temp;

    textKv.SetText(text);
}

public int Native_TTextEvent_FireTutorialText(Handle plugin, int numParams)
{
    /*
    This function will fire annotation after rule checking.
    And it will set Viewed Cookie.
    */
    TTextEvent textKv = GetNativeCell(1);
    char filename[PLATFORM_MAX_PATH], messageId[80], authId[25];
    GetNativeString(2, filename, sizeof(filename));
    GetNativeString(3, messageId, sizeof(messageId));
    int client = GetNativeCell(4);
    ShowMessageCookieRule customCookieRule = GetNativeCell(5);

    if(IsFakeClient(client) || !CheckTextRule(filename, messageId, client, customCookieRule))
    {
        return false;
    }

    textKv.VisibilityBits = (1 << client);
    GetClientAuthId(client, AuthId_SteamID64, authId, 25);
    LoadedPlayerData[client].SetMessageView(messageId, true);

    textKv.Fire();
    return true;
}
/*
public int Native_TTextEvent_FireTutorialTextAll(Handle plugin, int numParams)
{
    TTextEvent textEvent = GetNativeCell(1), tempEvent;
    char filename[PLATFORM_MAX_PATH], messageId[80];
    GetNativeString(2, filename, sizeof(filename));
    GetNativeString(3, messageId, sizeof(messageId));

    for(int target = 1; target <= MaxClients; target++)
    {
        if(!IsClientInGame(target) || IsFakeClient(target)) continue;

        tempEvent = new TTextEvent();
        CopyMessageEvent(this, tempEvent);

        tempEvent.ChangeTextLanguage(filename, messageId, target, ...);
        tempEvent.FireTutorialText(filename, messageId, target, customCookieRule);
    }

    this.Cancel();
}
*/
