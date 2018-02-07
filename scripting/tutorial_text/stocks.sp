#define PLUGIN_CONFIG_FILE_PATH "configs/tutorial_text.cfg"

stock KeyValues GetConfigKeyValues()
{
    char config[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, config, sizeof(config), PLUGIN_CONFIG_FILE_PATH);

    KeyValues configKv = new KeyValues("tutorial_text");

    if(!FileExists(config) && !configKv.ImportFromFile(config))
    {
        SetFailState("[TT] \"%s\" is broken?!", PLUGIN_CONFIG_FILE_PATH); // 플러그인 정지
        return null;
    }

    configKv.Rewind();

    return configKv;
}

/*
    Default languageId is English.

    return = false: 오류, value 변동 없음
*/
public bool GetConfigValue(char[] meassageId, char[] key, char[] value, int buffer, char[] languageId)
{
    KeyValues kv = GetConfigKeyValues();

    if(!kv.JumpToKey(meassageId))
    {
        LogError("[TT] not found achievementId in config ''%s''", meassageId);
        return false;
    }

    if(!StrEqual(languageId, "")) //
    {
        if(!kv.JumpToKey(languageId))
        {
            LogError("[TT] not found languageId in ''%s'' ''%s''", meassageId, languageId);
            // 이 경우에는 그냥 영어로 변경.
        }
    }

    kv.GetString(key, value, buffer);
    delete kv;

    return true;
}

/////////////////////////////////////////////////////////////////////////////////

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
