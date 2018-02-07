/*
    TODO: 디테일한 메세지 효과 설정
*/
void DisplayTextMenu(int client)
{
    SetGlobalTransTarget(client);
    Menu menu = new Menu(OnSelectTextMenu);
    KeyValues kv = GetConfigKeyValues();

    char message[128];
    menu.SetTitle("%t", "menu_cached_id_message_title");

    if(kv == null)
    {
        Format(message, sizeof(message), "%t", "menu_cached_id_message_error");
        menu.AddItem("The error text.", message);
    }
    else
    {
        char temp[64];

        kv.Rewind();
        if(kv.GotoFirstSubKey())
        {
            do
            {
                kv.GetSectionName(temp, sizeof(temp));
                GetConfigValue(temp, "text", message, sizeof(message), client);
                menu.AddItem(temp, message);
            }
            while(kv.GotoNextKey());
        }
    }

    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    delete kv;
    SetGlobalTransTarget(LANG_SERVER);
}

////////////////////////////////////////////////////////////////////////////////

public int OnSelectTextMenu(Menu menu, MenuAction action, int client, int item)
{
    switch(action)
    {
      case MenuAction_End:
      {
          menu.Close();
      }
      case MenuAction_Select:
      {
          char infoBuf[64], message[128], langId[4];
          menu.GetItem(item, infoBuf, sizeof(infoBuf));

          GetLanguageInfo(GetClientLanguage(client), langId, sizeof(langId));
          GetConfigValue(infoBuf, "text", message, sizeof(message), client);

          TF2_ShowFollowingAnnotationToAll(client, message); // FIXME: TODO
      }
    }
}
