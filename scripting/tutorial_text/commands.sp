public Action Cmd_TestTest(int client, int args)
{
    if(!IsValidClient(client))  return Plugin_Continue;

    TF2_ShowFollowingAnnotationToAll(client, "TEST TEXT");

    return Plugin_Continue;
}
