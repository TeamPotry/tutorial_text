methodmap TTCookie < Handle {
	public TTCookie(const char[] messageId) {
		char temp[80];
		Format(temp, sizeof(temp), "tutorial_text_id:%s", messageId);
		return FindCookieEx(temp);
	}

	public bool CheckRuleForClient(const int client)
	{	// FIXME: OH MY GOD
        char temp[80];
        char exst[2][64]; // exst[1] is answer! wuaaaa
        TTSettingCookie settingCookie = new TTSettingCookie();
        ReadCookieIterator(this, temp, sizeof(temp), CookieAccess_Protected);
        ExplodeString(temp, ":", exst, sizeof(exst), sizeof(exst[]))

        GetConfigValue(exst[1], "cookie_rule", temp, sizeof(temp));
        ShowMessageCookieRule rule = view_as<ShowMessageCookieRule>(StringToInt(temp));

        GetClientCookie(client, this, temp, sizeof(temp));
        bool firstViewed = StringToInt(temp) > 0;

        bool viewSetting = settingCookie.GetClientTextViewSetting(client);

        switch(rule)
        {
            case Type_Normal:
            {
                if(!viewSetting)
                {
                    if(!firstViewed)
                        return true;
                    return false;
                }
            }

            case Type_OnlyOne:
            {
                if(firstViewed)
                    return true;
                return false;
            }

            case Type_EveryTime:
            {
                return true;
            }

            case Type_NormalEvenFirst:
            {
                return viewSetting;
            }
        }

        return true;
	}
}

methodmap TTSettingCookie < Handle {
	public TTSettingCookie() {
		char temp[40];
		Format(temp, sizeof(temp), "tutorial_text_setting");
		return FindCookieEx(temp);
	}

	public bool GetClientTextViewSetting(const int client) {
		char temp[80];
		GetClientCookie(client, this, temp, sizeof(temp));

		return StringToInt(temp) > 0;
	}

	public void SetClientTextViewSetting(const int client, bool setting) {
		char temp[2];
		Format(temp, sizeof(temp), "%s", setting ? "1" : "0");
		SetClientCookie(client, this, temp);
	}

}
