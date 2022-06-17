global function ChatFlairsInit

string path = "../R2Northstar/mods/Takyon.ChatFlairs/mod/scripts/vscripts/takyon_cgf.nut" // where the config is stored
string liveCfg = ""
array<string> adminUIDs = []
array<string> colorChangeUIDs = []

table<string, vector> flairColorTable = {
    Owner = <0, 220, 30>
    Manager = <220, 0, 30>
    SrAdmin = <0, 220, 0>
    Admin = <220, 0, 0>
    Mod = <0, 179, 254>
    Developer = <0, 30, 254>
    VIP = <255, 218, 185>,
    DJM = <100, 24, 30>
}

void function ChatFlairsInit(){
	AddCallback_OnReceivedSayTextMessage(ChatCallback)

	LoadCfg()
	UpdateConvarLists()
	thread ChatFlairsMain()
}

void function ChatFlairsMain(){
	
}

ClServer_MessageStruct function ChatCallback(ClServer_MessageStruct message) {
    string msg = message.message.tolower()
	
	if (format("%c", msg[0]) == "/" && (adminUIDs.contains(message.player.GetUID()) || colorChangeUIDs.contains(message.player.GetUID()))) {
        // command
        msg = msg.slice(1) // remove /
        array<string> msgArr = split(msg, " ") // split at space, [0] = command
        string cmd
        
        try{
            cmd = msgArr[0] // save command
        }
        catch(e){
            return message
        }

        msgArr.remove(0) // remove command from args

        // command logic
		printl(cmd.slice(3))
        if(cmd.slice(0,3) == "col"){
			try{
				array<string> rawVals = split(cmd.slice(4, cmd.len()-1), ",")
				string r = rawVals[0]
				string g = rawVals[1]
				string b = rawVals[2]

				string colTag = "\x1b[38;2;" + r + ";" + g + ";" + b + "m"
				
				message.message = message.message.slice(cmd.len()+1)
				message.message = colTag + message.message
			}catch(e){ printl("ERROR")}
		}
    }

	// flairs

	array<string> uids = split(liveCfg, "\n") // change
	array<string> flairs = []

	bool playerInCfg = false
	foreach(string uidCombo in uids){
		printl(uidCombo)
		array<string> splitUidCombo = split(uidCombo, ":")
		if(splitUidCombo[0] == message.player.GetUID()){
			printl("player found")
			flairs = split(splitUidCombo[1], ",")
			playerInCfg = true
		}
	}

	if(!playerInCfg){
		// doesnt have flairs
	}

	string flairstring = ""
	foreach(string flair in flairs){
		string flairColor = ""
		try{
			vector flairColorV = flairColorTable[flair.slice(1,flair.len()-1)]
			flairColor = "\x1b[38;2;" + flairColorV.x + ";" + flairColorV.y + ";" + flairColorV.z + "m" 
			
		} catch(e){print("asdsadasdasd")}
		flairstring += (flairColor + flair)
	}

	message.message = flairstring +  "\x1b[0m: " + message.message

    return message
}

void function UpdateConvarLists()
{
	// admin uids
    string cvar = GetConVarString( "cf_admin_uids" )
    array<string> dirtyUIDs = split( cvar, "," )
    foreach (string uid in dirtyUIDs)
        adminUIDs.append(strip(uid))

	// color change uids
	cvar = GetConVarString( "cf_admin_uids" )
    dirtyUIDs = split( cvar, "," )
    foreach (string uid in dirtyUIDs)
        colorChangeUIDs.append(strip(uid))
}

/*void function SaveCfg(){
	DevTextBufferClear()

	DevTextBufferWrite("global string cf_cfgString = @\"")
    DevTextBufferWrite(liveCfg)
	DevTextBufferWrite("\"")

	DevP4Checkout(path)
    DevTextBufferDumpToFile(path)
    DevP4Add(path)

	LoadCfg()
	printl("[ChatFlairs] saved config")
}*/

void function LoadCfg(){
	liveCfg = cf_cfgString
}

/*void function EditLiveCfg(){
	print("EDITING CFG")
	liveCfg = @"1009099551543:[Admin]
1006527769252:[Mod]
1003204785491:[Mod]
1006880507304:[Moddd],[Deveee]"
	SaveCfg()
}*/
