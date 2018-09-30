void DisplayTextMenu(int client)
{
    SetGlobalTransTarget(client);
    Menu menu = new Menu(OnSelectTextMenu);
    TTextKeyValue kv = new TTextKeyValue();

    char message[128];
    menu.SetTitle("%t", "menu_cached_id_message_title");

    if(kv == null)
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
                kv.GetValue(temp, "text", message, sizeof(message), client);
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

            TTextEvent event = new TTextEvent();
            LoadMessageID(event, _, infoBuf);

            static float endPos[3];
            GetClientEyeEndPos(client, endPos);

            event.SetPosition(endPos);
            event.ChangeTextLanguage(_, infoBuf, client);
            event.FireTutorialText(_, infoBuf, client);

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

    menu.SetTitle("%t", "menu_cached_id_message_title");

    menu.AddItem("", TTSettingCookie.GetClientTextViewSetting(client) ? "ON" : "OFF");

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
            SetGlobalTransTarget(client);

            TTSettingCookie.SetClientTextViewSetting(client, !TTSettingCookie.GetClientTextViewSetting(client));
            CPrintToChat(client, "{orangered}[TT]{default} %t", "now_set_done", TTSettingCookie.GetClientTextViewSetting(client) ? "ON" : "OFF");
            SetGlobalTransTarget(LANG_SERVER);
        }
    }
}
