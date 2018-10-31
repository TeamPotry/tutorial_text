#define TT_CONFIG_NAME "tutorial_text"

methodmap TTDBData < Database {
    public TTDBData()
    {
        Database database;
        DBDriver driver;
        char driverString[10];
        char errorMessage[64];

        database = SQL_Connect(TT_CONFIG_NAME, true, errorMessage, sizeof(errorMessage));
        if(database == null)
        {
            SetFailState("Can't connect to DB! Error: %s", errorMessage);
        }

        driver = database.Driver;
        driver.GetIdentifier(driverString, sizeof(driverString));

        if(!StrEqual("mysql", driverString))
        {
            SetFailState("This plugin is only allowed to use mysql!");
        }

        database.SetCharset("utf8");

        return view_as<TTDBData>(database);
    }

    public native void InitializePlayerData(const char[] authid);

    // public native int GetValue(const char[] authid, const char[] settingid, char[] value = "", int buffer = 0);
    // public native void SetValue(const char[] authid, const char[] settingid, const char[] value);

    public native bool GetMessageView(const char[] authid, const char[] messageId);
    public native void SetMessageView(const char[] authid, const char[] messageId, bool value);
}

public void QueryErrorCheck(Database db, DBResultSet results, const char[] error, any data)
{
    if(results == null || error[0] != '\0')
    {
        SetFailState("Ahh.. Something is wrong in QueryErrorCheck. check your DB. ERROR: %s", error);
    }
}

void DB_Native_Init()
{
    CreateNative("TTDBData.GetMessageView", Native_TTDBData_GetMessageView);
    CreateNative("TTDBData.SetMessageView", Native_TTDBData_SetMessageView);
}

public int Native_TTDBData_GetMessageView(Handle plugin, int numParams)
{
    TTDBData thisDB = GetNativeCell(1);

    char authId[24], messageId[160], queryStr[256];
    GetNativeString(2, authId, 24);
    GetNativeString(3, messageId, 80);

    thisDB.Escape(messageId, messageId, 80);
    Format(queryStr, sizeof(queryStr), "SELECT * FROM `tutorial_text_view` WHERE `steam_id` = '%s' AND `message_id` = '%s'", authId, messageId);

    DBResultSet query = SQL_Query(thisDB, queryStr);
    if(query.RowCount <= 0) return false;

    delete query;
    return true;
}

public int Native_TTDBData_SetMessageView(Handle plugin, int numParams)
{
    TTDBData thisDB = GetNativeCell(1);

    char authId[24], messageId[160], queryStr[256], timeStr[64];
    GetNativeString(2, authId, 24);
    GetNativeString(3, messageId, 80);
    int value = GetNativeCell(4);

    bool hasMessage = thisDB.GetMessageView(authId, messageId);
    if((hasMessage && value) || (!hasMessage && !value))
        return;

    thisDB.Escape(messageId, messageId, 80);
    if(value)
    {
        FormatTime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S");

        Format(queryStr, sizeof(queryStr), "INSERT INTO `tutorial_text_view`(`steam_id`, `message_id`, `last_saved_time`) VALUES('%s', '%s', '%s')", authId, messageId, timeStr);
    }
    else
    {
        Format(queryStr, sizeof(queryStr), "DELETE FROM `tutorial_text_view` WHERE `steam_id` = '%s' AND `message_id` = '%s'", authId, messageId);
    }

    thisDB.Query(QueryErrorCheck, queryStr);
}
