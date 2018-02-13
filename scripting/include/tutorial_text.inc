#if defined __tutotial_text_included
	#endinput
#endif

#define __tutotial_text_included

/*

enum TestTextDisplayType
{
    Type_ShowAll = 0,
    Type_ShowClient, // Only for client who called menu.
};

enum TestTextPositionType
{
    Type_FollowClient = 0, // Follow client who called menu.
    Type_FollowAim, // Seeing spot
	Type_FollowAimTarget // follow entity in client's seeing spot.
};

*/

enum ShowMessageCookieRule
{
	Type_Normal = 0, // text is no longer ignore rules. (But first message is will ignore SETTING.)
	Type_OnlyOne, // only show when first time. (SETTING ignored.)
	Type_EveryTime, // if text following this rule, always show text. (SETTING ignored.)
	Type_NormalEvenFirst // text is no longer ignore rules.
};

native TFAnnotationEvent TT_LoadMessageID(const char[] messageId);

native void TT_FireTutorialText(TFAnnotationEvent annotation, const char[] messageId);

public SharedPlugin:__pl_TUTORIAL_TEXT=
{
	name="tutorial_text",
	file="tutorial_text.smx",
	#if defined REQUIRE_PLUGIN
		required=1,
	#else
		required=0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_TUTORIAL_TEXT_SetNTVOptional()
{
	MarkNativeAsOptional("TT_LoadMessageID");
	MarkNativeAsOptional("TT_FireTutorialText");
}
#endif
