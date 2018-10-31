bool CheckTextRule(char[] filename, char[] messageId, int client, ShowMessageCookieRule customCookieRule = Type_None)
{
    char temp[80], authId[25];
    ShowMessageCookieRule rule;
    GetClientAuthId(client, AuthId_SteamID64, authId, 25);

    if(customCookieRule != Type_None) {
        rule = customCookieRule;
    }
    else {
        TTextKeyValue kv = new TTextKeyValue(filename);
        kv.GetValue(messageId, "cookie_rule", temp, sizeof(temp));
        rule = view_as<ShowMessageCookieRule>(StringToInt(temp));
        delete kv;
    }

    bool firstViewed = g_DBData.GetMessageView(authId, messageId);
    bool viewSetting = TTSettingCookie.GetClientTextViewSetting(client);

    // CPrintToChatAll("firstViewed: %s, viewSetting: %s", firstViewed ? "true" : "false", viewSetting ? "true" : "false");

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
                return false;
            return true;
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

stock bool LoadMessageID(TTextEvent event, char[] filename = "", char[] messageId)
{
    char values[PLATFORM_MAX_PATH];
    TTextKeyValue temp = new TTextKeyValue(filename);

    if(temp == null)
    {
        ThrowError("Can't load text and setting.");
        return false;
    }

    temp.GetValue(messageId, "show_effect", values, sizeof(values));
    event.ShowEffect = StringToInt(values) > 0 ? true : false;

    temp.GetValue(messageId, "show_distance", values, sizeof(values));
    event.ShowDistance = StringToInt(values) > 0 ? true : false;

    temp.GetValue(messageId, "id", values, sizeof(values));
    event.ID = StringToInt(values);

    temp.GetValue(messageId, "play_sound", values, sizeof(values));
    event.SetSound(values);

    event.SetText(messageId);

    delete temp;

    return true;
}

stock Handle FindCookieEx(char[] cookieName)
{
    Handle cookieHandle = FindClientCookie(cookieName);
    if(cookieHandle == null)
    {
        cookieHandle = RegClientCookie(cookieName, "", CookieAccess_Protected);
    }

    return cookieHandle;
}

/////////////////////////////////////////////////////////////////////////////////

stock bool IsConVarCommand(const char[] cvarName, const char[] cmd)
{
    ConVar cvar = FindConVar("tutotial_text_commands");
    char commands[256];
    cvar.GetString(commands, sizeof(commands));
    return StrContains(cmd, commands) > -1;
}

/////////////////////////////////////////////////////////////////////////////////

/*
public bool ImportTestConfigKeyValues(TTextKeyValue victim)
{
    char config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), PLUGIN_TEST_CONFIG_FILE_PATH);

    if(!FileExists(config) || !victim.ImportFromFile(config))
    {
        SetFailState("[TT] \"%s\" is broken?!", PLUGIN_TEST_CONFIG_FILE_PATH); // 플러그인 정지
        victim = null;
        return false;
    }

    return true;
}
*/

/////////////////////////////////////////////////////////////////////////////////

public void GetClientEyeEndPos(const int client, float endPos[3])
{
    static float startPos[3];
    static float eyeAngles[3];

    GetClientEyePosition(client, startPos);
    GetClientEyeAngles(client, eyeAngles);
    TR_TraceRayFilter(startPos, eyeAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceAnything);
    TR_GetEndPosition(endPos);
}

public bool TraceAnything(int entity, int contentsMask)
{
    return false;
}

stock bool IsValidClient(int client, bool replaycheck=true)
{
	if(client <= 0 || client > MaxClients)
	{
		return false;
	}

	if(!IsClientInGame(client))
	{
		return false;
	}

	if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
	{
		return false;
	}

	if(replaycheck)
	{
		if(IsClientSourceTV(client) || IsClientReplay(client))
		{
			return false;
		}
	}
	return true;
}
