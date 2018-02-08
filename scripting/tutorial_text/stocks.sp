TFAnnotationEvent LoadMessageID(char[] messageId)
{
    char values[PLATFORM_MAX_PATH];
    TFAnnotationEvent annotation = new TFAnnotationEvent();

    GetConfigValue(messageId, "show_effect", values, sizeof(values));
    annotation.ShowEffect = StringToInt(values) > 0 ? true : false;

    GetConfigValue(messageId, "show_distance", values, sizeof(values));
    annotation.ShowDistance = StringToInt(values) > 0 ? true : false;

    GetConfigValue(messageId, "id", values, sizeof(values));
    annotation.ID = StringToInt(values);

    GetConfigValue(messageId, "play_sound", values, sizeof(values));
    annotation.SetSound(values);

    GetConfigValue(messageId, "text", values, sizeof(values));
    annotation.SetText(values);

    return annotation;
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
