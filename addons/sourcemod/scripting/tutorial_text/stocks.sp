stock void FireTutorialText(TFAnnotationEvent annotation, char[] messageId, bool setLanguage = false)
{
    /*
        This function will fire annotation after rule checking.
        And it will set Viewed Cookie.

        @param setLanguage 컨픽 내의 언어로 텍스트를 바꿉니다.
        // NOTE: 컨픽에 해당 Id가 없다면 사용 금지.
    */

    int clients[MAXPLAYERS+1];
    int numClient = 0;
    int visibilityBits = annotation.VisibilityBits;
    TTCookie cookie = new TTCookie(messageId);

    for(int loop = 0; loop <= MaxClients; loop++)
    {
        if(visibilityBits & (1 << loop))
        {
            clients[numClient++] = loop;
        }
    }

    for(int loop = 0; loop < numClient; loop++)
    {
        if(!IsValidClient(clients[loop]) || !IsFakeClient(clients[loop]) || !cookie.CheckRuleForClient(clients[loop])) {
            visibilityBits |= ~ (1 << loop);
            annotation.VisibilityBits = visibilityBits;
            continue;
        }

        cookie.SetClientViewed(clients[loop], true);

        if(setLanguage)
        {
            // TODO: 리뷰
            char message[128];
            TFAnnotationEvent copiedAnnotation = view_as<TFAnnotationEvent>(CloseHandle(annotation));

            copiedAnnotation.SetClientVisibility(clients[loop], true);
            GetConfigValue(messageId, "text", message, sizeof(message), clients[loop]);

            copiedAnnotation.Fire();
        }
    }

    if(!setLanguage)
        annotation.Fire();
}

stock TFAnnotationEvent LoadMessageID(char[] messageId, const int client = 0)
{
    char values[PLATFORM_MAX_PATH];
    TFAnnotationEvent event = new TFAnnotationEvent();

    GetConfigValue(messageId, "show_effect", values, sizeof(values));
    event.ShowEffect = StringToInt(values) > 0 ? true : false;

    GetConfigValue(messageId, "show_distance", values, sizeof(values));
    event.ShowDistance = StringToInt(values) > 0 ? true : false;

    GetConfigValue(messageId, "id", values, sizeof(values));
    event.ID = StringToInt(values);

    GetConfigValue(messageId, "play_sound", values, sizeof(values));
    event.SetSound(values);

    if(IsValidClient(client)) {
        GetConfigValue(messageId, "text", values, sizeof(values), client);
    }
    else {
        GetConfigValue(messageId, "text", values, sizeof(values));
    }

    event.SetText(values);

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

#define PLUGIN_CONFIG_FILE_PATH "configs/tutorial_text.cfg"

public bool ImportConfigKeyValues(KeyValues victim)
{
    char config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), PLUGIN_CONFIG_FILE_PATH);

    KeyValues configKv = new KeyValues("tutorial_text");

    if(!FileExists(config) || !configKv.ImportFromFile(config))
    {
        SetFailState("[TT] \"%s\" is broken?!", PLUGIN_CONFIG_FILE_PATH); // 플러그인 정지
        return false;
    }

    configKv.Rewind();
    victim.Import(configKv);

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
