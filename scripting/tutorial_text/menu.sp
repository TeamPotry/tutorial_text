/*
    TODO: 디테일한 메세지 효과 설정
*/
void DisplayTextMenu(int client)
{
    SetGlobalTransTarget(client);
    Menu menu = new Menu(OnSelectTextMenu);
    KeyValues kv = new KeyValues("tutorial_text");

    char message[128];
    menu.SetTitle("%t", "menu_cached_id_message_title");

    if(!ImportConfigKeyValues(kv))
    {
        Format(message, sizeof(message), "%t", "menu_cached_id_message_error");
        menu.AddItem("The error text.", message, ITEMDRAW_DISABLED);
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
            char infoBuf[64];
            menu.GetItem(item, infoBuf, sizeof(infoBuf));

            TFAnnotationEvent event = LoadMessageID(infoBuf, client);

            static float endPos[3];
            GetClientEyeEndPos(client, endPos);

            event.SetPosition(endPos);
            event.Fire();

            // DisplayTextSettingMenu(client, infoBuf); DECA
            // TF2_ShowFollowingAnnotationToAll(client, message); // FIXME: TODO
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void DisplayTextSettingMenu(int client)
{
    SetGlobalTransTarget(client);

    Menu menu = new Menu(OnTextSettingMenu);
    TTSettingCookie settingCookie = new TTSettingCookie();

    menu.SetTitle("%t", "menu_cached_id_message_title");

    menu.AddItem("", settingCookie.GetClientTextViewSetting(client) ? "ON" : "OFF");

    menu.ExitButton = true;
    menu.Display(client, MENU_TIME_FOREVER);

    SetGlobalTransTarget(LANG_SERVER);
}

public int OnTextSettingMenu(Menu menu, MenuAction action, int client, int item)
{
    switch(action)
    {
        case MenuAction_End:
        {
            menu.Close();
        }
        case MenuAction_Select:
        {
            TTSettingCookie settingCookie = new TTSettingCookie();
            SetGlobalTransTarget(client);

            settingCookie.SetClientTextViewSetting(client, !settingCookie.GetClientTextViewSetting(client));
            SetGlobalTransTarget(LANG_SERVER);
        }
    }
}
