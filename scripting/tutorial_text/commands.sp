
public Action Cmd_TestTest(int client, int args)
{
    if(!IsValidClient(client))  return Plugin_Continue;

    DisplayTextMenu(client);

    return Plugin_Continue;
}


public Action:Listener_Say(int client, const char[] command, int argc)
{
    if(!IsValidClient(client))	return Plugin_Continue;

    char chat[150];
    bool start=false;
    GetCmdArgString(chat, sizeof(chat));
    // in chat: 테스트 텍스트
    // in this function: "테스트 텍스트"

    if(strlen(chat)<3)	return Plugin_Continue;

    if(chat[1]=='!' || chat[1]=='/') start=true; // start++;
    chat[strlen(chat)-1]='\0'; // // in this function: "테스트 텍스트

    if(!start) return Plugin_Continue;

    if(IsConVarCommand("tutotial_text_commands", chat[1]))
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}
