#if defined __tutotial_text_included
	#endinput
#endif

#define __tutotial_text_included


enum TestTextDisplayType
{
    Type_ShowAll = 0,
    Type_ShowClient, // Only for client who called menu.
};

enum TestTextPositionType
{
    Type_FollowClient = 0, // Follow client who called menu.
    Type_FollowAim, // Seeing spot
};
