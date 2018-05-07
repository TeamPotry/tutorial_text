stock TTextEvent LoadMessageID(char[] filename = "", char[] messageId)
{
    char values[PLATFORM_MAX_PATH];
    TTextKeyValue temp;
    TTextEvent event = new TTextEvent();
    if(StrEqual(filename, ""))
    {
        temp = new TTextKeyValue();
    }
    else if(!LoadTutorialText(filename, temp))
    {
        LogError("Can't load text and setting.");
        return null;
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

    return event;
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

public bool LoadTutorialText(const char[] filename, TTextKeyValue victim)
{
    GetTextKeyValues(filename, victim);

    if(victim == null)
        return false;

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
