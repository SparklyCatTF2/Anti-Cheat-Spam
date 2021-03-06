#include <sourcemod>
#include <events>
//#include <sourcebanspp>
#include <morecolors>

Handle adt_array;
bool bBeenWarned[MAXPLAYERS+1] = {false, ...};

public OnPluginStart()
{
	char path[256];
	BuildPath(Path_SM, path, sizeof(path), "configs/anti_lmaobox/list.txt");
	if(FileExists(path))
	{
		InitAntiSpam(path);
	}
	else
	{
		SetFailState("Could not find a cheat spam messages file.");
	}
}

public OnClientAuthorized(int client)
{
	bBeenWarned[client] = false;
}

public OnClientDisconnect(int client)
{
	bBeenWarned[client] = false;
}

void InitAntiSpam(char[] path)
{
	HookEvent("player_say", OnPlayerSay, EventHookMode_Post);

	adt_array = CreateArray(186);

	char line[186];
	Handle file = OpenFile(path, "r");
	
	if(file != INVALID_HANDLE)
	{
		while(!IsEndOfFile(file) && ReadFileLine(file, line, sizeof(line)))
		{
			TrimString(line);
			PushArrayString(adt_array, line);
		}
		
		CloseHandle(file);
		PrintToServer("Loaded all cheat spam messages into 'Handle adt_array'");
	}
	else
	{
		SetFailState("The cheat spam file couldn't be found in the 'void InitAntiSpam(char[] path)' function for some reason");
	}
	
}

public void OnPlayerSay(Handle event, char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int caClient = GetClientOfUserId(userid);
	char msg[186];
	GetEventString(event, "text", msg, sizeof(msg));
	
	for(int i = 0; i < GetArraySize(adt_array); ++i)
	{
			char arrayString[186];
			GetArrayString(adt_array, i, arrayString, sizeof(arrayString));
		
			if(StrEqual(msg, arrayString, false))
			{
				if(!bBeenWarned[caClient])
				{
					CPrintToChat(caClient, "{red}WARNING: {white}The message you sent above is considered cheat spam. If you send it again, you will be banned.");
					bBeenWarned[caClient] = true;
				}
				else
				{
					ServerCommand("sm_ban #%i 40320 Cheat spam", userid);
		
					char name2[128];
					GetClientName(caClient, name2, sizeof(name2));
			
					CPrintToChatAll("{red}THE BAN HAMMER HAS BANISHED %s!", name2);
					CPrintToChatAll("{red}THE BAN HAMMER HAS BANISHED %s!", name2);
					CPrintToChatAll("{red}THE BAN HAMMER HAS BANISHED %s!", name2);
					CPrintToChatAll("{red}THE BAN HAMMER HAS BANISHED %s!", name2);
				}
			}
	}
}
