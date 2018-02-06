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
    return = false: 오류, value 변동 없음
*/
public bool GetConfigValue(char[] meassageId, char[] key, char[] value, int buffer, char[] languageId = "en")
{
    KeyValues kv = GetConfigKeyValues();

    if(!kv.JumpToKey(achievementId))
    {
        LogError("[TT] not found achievementId in config ''%s''", achievementId);
        return false;
    }

    if(!StrEqual(languageId, "en")) // 영어가 아닌 타국어일 경우
    {
        if(!kv.JumpToKey(languageId))
        {
            LogError("[TT] not found languageId in ''%s'' ''%s''", achievementId, languageId);
            return false;
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
