public int Native_LoadMessageID(Handle plugin, int numParams)
{
    char temp[64], temp_id[64];
    GetNativeString(2, temp, sizeof(temp));
    GetNativeString(3, temp_id, sizeof(temp_id));
    return view_as<int>(LoadMessageID(GetNativeCellRef(1), temp, temp_id));
}

public int Native_LoadTutorialText(Handle plugin, int numParams)
{
    char temp[64];
    GetNativeString(1, temp, sizeof(temp));
    return view_as<int>(new TTextKeyValue(temp));
}
