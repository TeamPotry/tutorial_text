TTDBData g_DBData;

methodmap TTPlayerData < KeyValues {
	public TTPlayerData(int client) {
		char authId[25], queryStr[256], dataFile[PLATFORM_MAX_PATH], timeStr[64];
		GetClientAuthId(client, AuthId_SteamID64, authId, 25);
		BuildPath(Path_SM, dataFile, sizeof(dataFile), "data/tutorial_text/%s.txt", authId);
		FormatTime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S");
		TTPlayerData playerData = view_as<TTPlayerData>(new KeyValues("player_data", "authid", authId));

		if(g_DBData != null)	{
			Format(queryStr, sizeof(queryStr), "SELECT * FROM `tutorial_text_view` WHERE `steam_id` = '%s'", authId);
			g_DBData.Query(ReadResult, queryStr, client);
		}
		else	{
			playerData.ImportFromFile(dataFile);
		}

		return playerData;
	}

	// NOTE: 값을 수정하려면 update로 true로 바꿔야 해당 키에 'need_update' 서브 키가 생김.
	public native bool GoToTextData(const char[] messageId, bool update = false, bool willDelete = false);

	// SQL 서버나 데이터 파일에 모든 데이터를 저장
	public native void Update();

	public native bool GetMessageView(const char[] messageId);
    public native void SetMessageView(const char[] messageId, bool value);
}
TTPlayerData LoadedPlayerData[MAXPLAYERS+1];

enum
{
	Data_SteamId = 0,
	Data_MessageId,
	Data_LastSavedTime,

    DataCount_Max
};

static const char g_QueryColumn[][] = {
	"steam_id",
	"message_id",
	"last_saved_time"
}

void Data_Native_Init()
{
	CreateNative("TTPlayerData.GoToTextData", Native_TTPlayerData_GoToTextData);
	CreateNative("TTPlayerData.Update", Native_TTPlayerData_Update);

	CreateNative("TTPlayerData.GetMessageView", Native_TTPlayerData_GetMessageView);
	CreateNative("TTPlayerData.SetMessageView", Native_TTPlayerData_SetMessageView);
}

public void ReadResult(Database db, DBResultSet results, const char[] error, int client)
{
	char temp[120], timeStr[64];
	FormatTime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S");

	for(int loop = 0; loop < results.RowCount; loop++)
	{
		if(!results.FetchRow()) {
			if(results.MoreRows) {
				loop--;
				continue;
			}
			break;
		}

		LoadedPlayerData[client].Rewind();

		results.FetchString(Data_MessageId, temp, 120);

		// 서버에 등록된 도전과제만 로드
		if(!LoadedPlayerData[client].JumpToKey(temp)) continue;

		// Initializing PlayerData
		results.FetchString(Data_LastSavedTime, temp, 120);
		LoadedPlayerData[client].SetString("last_saved_time", temp);
	}
}

public int Native_TTPlayerData_GoToTextData(Handle plugin, int numParams)
{
	TTPlayerData playerData = GetNativeCell(1);

	char messageId[80], timeStr[64];
	bool needUpdate = GetNativeCell(3);
	bool willDelete = GetNativeCell(4);

	playerData.Rewind();
	GetNativeString(2, messageId, sizeof(messageId));

	if(playerData.JumpToKey(messageId, needUpdate) && needUpdate)
	{
		FormatTime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S");
		playerData.SetString("last_saved_time", timeStr);

		playerData.SetNum("need_update", 1);
		playerData.SetNum("need_delete", willDelete ? 1 : 0);

		return true;
	}

	return false;
}

public int Native_TTPlayerData_GetMessageView(Handle plugin, int numParams)
{
	TTPlayerData playerData = GetNativeCell(1);

	char messageId[80];
	GetNativeString(2, messageId, sizeof(messageId));

	if(playerData.GoToTextData(messageId))
		return true;

	return false;
}

public int Native_TTPlayerData_SetMessageView(Handle plugin, int numParams)
{
	TTPlayerData playerData = GetNativeCell(1);

	char messageId[80];
	GetNativeString(2, messageId, sizeof(messageId));

	playerData.GoToTextData(messageId, GetNativeCell(3), GetNativeCell(3));
}

public int Native_TTPlayerData_Update(Handle plugin, int numParams)
{
	TTPlayerData playerData = GetNativeCell(1);
	char messageId[80], queryStr[512], authId[25], temp[120], dataFile[PLATFORM_MAX_PATH];
	Transaction transaction = new Transaction();

	playerData.Rewind();
	if(g_DBData != null)
	{
		playerData.GetString("authid", authId, sizeof(authId));
		if(playerData.GotoFirstSubKey())
		{
			do
			{
				playerData.GetSectionName(messageId, sizeof(messageId));

				if(playerData.GetNum("need_delete", 0) > 0)
				{
					Format(queryStr, sizeof(queryStr),
					"DELETE FROM `tutorial_text_view` WHERE `steam_id` = '%s' AND `message_id` = '%s'",
					authId, messageId);

					transaction.AddQuery(queryStr);
					playerData.DeleteKey("need_delete");
				}
				else if(playerData.GetNum("need_update", 0) > 0)
				{
					for(int loop = Data_LastSavedTime; loop < DataCount_Max; loop++)
					{
						playerData.GetString(g_QueryColumn[loop], temp, sizeof(temp), "");

						if(temp[0] == '\0') continue;

						Format(queryStr, sizeof(queryStr),
						"INSERT INTO `tutorial_text_view` (`steam_id`, `message_id`, `%s`) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE `steam_id` = '%s',  `message_id` = '%s', `%s` = '%s'",
						g_QueryColumn[loop], authId, messageId, temp,
						authId, messageId, g_QueryColumn[loop], temp);

						transaction.AddQuery(queryStr);
					}
					playerData.DeleteKey("need_update");
				}
			}
			while(playerData.GotoNextKey());
		}

		g_DBData.Execute(transaction, _, OnTransactionError);
	}
	else
	{
		BuildPath(Path_SM, dataFile, sizeof(dataFile), "data/tutorial_text/%s.txt", authId);

		playerData.Rewind();
		playerData.ExportToFile(dataFile);
	}
}

public void OnTransactionError(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("Something is Error while saving data. \n%s", error);
}
