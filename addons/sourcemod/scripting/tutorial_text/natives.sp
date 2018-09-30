void Native_Init()
{
    CreateNative("TT_LoadTutorialText", Native_LoadTutorialText);
    CreateNative("TT_LoadMessageID", Native_LoadMessageID);

    CreateNative("TTSettingCookie.GetTTSettingCookie", Native_TTSettingCookie_GetTTSettingCookie);
    CreateNative("TTSettingCookie.GetClientTextViewSetting", Native_TTSettingCookie_GetClientTextViewSetting);
    CreateNative("TTSettingCookie.SetClientTextViewSetting", Native_TTSettingCookie_SetClientTextViewSetting);
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
