public int Native_LoadMessageID(Handle plugin, int numParams)
{
    char temp[64];
    GetNativeString(1, temp, sizeof(temp));
    return view_as<int>(LoadMessageID(temp, GetNativeCell(2)));
}

public int Native_FireTutorialText(Handle plugin, int numParams)
{
    char temp[64];
    GetNativeString(2, temp, sizeof(temp));
    FireTutorialText(GetNativeCell(1), temp);
}
