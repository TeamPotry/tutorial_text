stock TTextEvent LoadMessageID(char[] filename, char[] messageId)
{
    char values[PLATFORM_MAX_PATH];
    TTextKeyValue kv;
    TTextEvent event = new TTextEvent();
    LoadTutorialText(filename, kv);

    kv.GetValue(messageId, "show_effect", values, sizeof(values));
    event.ShowEffect = StringToInt(values) > 0 ? true : false;

    kv.GetValue(messageId, "show_distance", values, sizeof(values));
    event.ShowDistance = StringToInt(values) > 0 ? true : false;

    kv.GetValue(messageId, "id", values, sizeof(values));
    event.ID = StringToInt(values);

    kv.GetValue(messageId, "play_sound", values, sizeof(values));
    event.SetSound(values);

    event.SetText(messageId);

    return event;
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

#define PLUGIN_TEST_CONFIG_FILE_PATH "configs/tutorial_text.cfg"

public bool ImportTestConfigKeyValues(KeyValues victim)
{
    char config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), PLUGIN_TEST_CONFIG_FILE_PATH);

    KeyValues configKv = new KeyValues("tutorial_text");

    if(!FileExists(config) || !configKv.ImportFromFile(config))
    {
        SetFailState("[TT] \"%s\" is broken?!", PLUGIN_TEST_CONFIG_FILE_PATH); // 플러그인 정지
        victim = null;
        return false;
    }

    configKv.Rewind();
    victim.Import(configKv);

    delete configKv;

    return true;
}

public bool LoadTutorialText(const char[] filename, TTextKeyValue victim)
{
    TTextKeyValue temp;

    if(filename[0] != '\0')
    {
        temp = GetTextKeyValues(filename);
    }
    else
    {
        ImportTestConfigKeyValues(temp);
    }

    if(temp == null)
        return false;

    victim.Import(temp);
    delete temp;

    return true;
}

/*
    Default languageId is English.

    return = false: 오류, value 변동 없음
*/
stock bool GetConfigValue(char[] messageId, char[] key, char[] value, int buffer, int client = 0)
{
    KeyValues kv = new KeyValues("tutorial_text");
    ImportConfigKeyValues(kv);

    char langId[4];
    if(IsValidClient(client))
        GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
    else
        Format(langId, sizeof(langId), "en");


    if(!kv.JumpToKey(messageId))
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

    kv.GetString(key, value, buffer);
    delete kv;

    return true;
}

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
