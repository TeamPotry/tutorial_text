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
            char infoBuf[64], message[128]];
            menu.GetItem(item, infoBuf, sizeof(infoBuf));

            TFAnnotationEvent event = LoadMessageID(meassageId);

            static float endPos[3];
            GetClientEyeEndPos(client, endPos);

            event.vecPosition(endPos);
            annotation.Fire(annotation);

            // DisplayTextSettingMenu(client, infoBuf); DECA
            // TF2_ShowFollowingAnnotationToAll(client, message); // FIXME: TODO
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// 딱히 메리트가 없어서 중단.

/*
void DisplayTextSettingMenu(int client, char[] meassageId)
{
    SetGlobalTransTarget(client);

    Menu menu = new Menu(OnTextSettingMenu);
    TFAnnotationEvent event = LoadMessageID(meassageId);

    char message[128];
    menu.SetTitle("%t", "menu_cached_id_message_setting_title");

    Format(message, sizeof(message), "%t", "setting_show_text", "");
    menu.AddItem("0", message); // view_as<TestTextDisplayType>(StringToInt(infoBuf)) == Type_ShowAll

    Format(message, sizeof(message), "%t", "setting_follow_text", "");
    menu.AddItem("0", message); // view_as<TestTextDisplayType>(StringToInt(infoBuf)) == Type_FollowClient

    Format(message, sizeof(message), "%t", "setting_show_effect", event.ShowEffect ? "ON" : "OFF");
    menu.AddItem("show_effect", message);

    Format(message, sizeof(message), "%t", "setting_show_distance", event.ShowDistance ? "ON" : "OFF");
    menu.AddItem("show_distance", message);



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
            char infoBuf[64], message[128];
            menu.GetItem(item, infoBuf, sizeof(infoBuf));

            GetConfigValue(infoBuf, "text", message, sizeof(message), client);

            // TF2_ShowFollowingAnnotationToAll(client, message); // FIXME: TODO
        }
    }
}
*/
