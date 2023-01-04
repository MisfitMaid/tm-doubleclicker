void Main() {
	
	string helperExecFilePath = IO::FromStorageFolder("Doubleclicker.exe");
	
	// save the location of Trackmania so the helper program can open us.
	string helperDataFilePath = IO::FromStorageFolder("tmPath.json");
	Json::Value helperData = Json::Object();
	helperData["tmBinary"] = IO::FromAppFolder("Trackmania.exe");
	Json::ToFile(helperDataFilePath, helperData);
	
	// copy the binary out and verify its checksum

    // We can only start a unsecure websockets server
    Net::WebSocket@ websocket = Net::WebSocket();

    if (!websocket.Listen("127.0.0.1", 1312)) {
        print("unable to start websocket server");
        return;
    }

    while (true) {
        // Clients is an array of websocket connections accepted by the server
        for (uint i = 0; i < websocket.Clients.Length; i++) {
            auto wsc = websocket.Clients[i];
            auto data = wsc.GetMessage();
            if (data.Exists("message")){
				print("RX: "+string(data["message"]));
				handleRequest(string(data["message"]), wsc);
            }
        }
        yield();
    }

    // Good practice to close clients first before server
    for (uint i = 0; i < websocket.Clients.Length; i++) {
        auto wsc = websocket.Clients[i];
        wsc.Close();
    }

    // Close websockets server when finished
    websocket.Close();
}

void handleRequest(const string &in payload, Net::WebSocketClient@ wsc) {
	Json::Value req;
	Json::Value resp = Json::Object();
	resp["version"] = Meta::ExecutingPlugin().Version;
	uint packetType;
	try {
		req = Json::Parse(payload);
		packetType = req["type"];
	} catch {
		warn("Malformed payload: "+payload);
		resp["error"] = "Malformed payload: "+payload;
			sendMessage(resp, wsc);
		return;
	}
	
	switch(packetType) {
		case 0: // status
			resp["type"] = 0;
			resp["hasPerms"] = Permissions::PlayLocalMap();
			// resp["mapDirectory"] = IO::FromUserGameFolder("Maps");
			// resp["inGame"] = GetApp().RootMap !is null && GetApp().CurrentPlayground !is null;
			sendMessage(resp, wsc);
			break;
		case 1: // play map
			playMap(req["map"]);
			resp["type"] = 2;
			sendMessage(resp, wsc);
			break;
		case 2: // acknowledge
			break;
		default:
			resp["error"] = "Unknown packet type";
			sendMessage(resp, wsc);
			break;
	}
}

void sendMessage(Json::Value@ resp, Net::WebSocketClient@ wsc) {
	trace("TX: "+Json::Write(resp));
	wsc.SendMessage(Json::Write(resp));
}

void playMap(const string &in filename) {
	if (!(filename.EndsWith(".Map.Gbx") || filename.EndsWith(".map.gbx"))) {
		warn("This does not appear to be a Map.gbx file.");
		return;
	}
	
	string finalLocation = importMap(filename);
	trace(finalLocation);
	auto app = cast<CGameManiaPlanet>(GetApp());
	app.ManiaTitleControlScriptAPI.PlayMap(finalLocation, "", "");
}

string importMap(const string &in filename) {
	string mapsFolder = IO::FromUserGameFolder("Maps");
	
	if (filename.StartsWith(mapsFolder)) {
		// already in TM maps dir, just return the relative filename
		return filename.Replace(mapsFolder+"\\", "");
	} else {
		string[] fileBits = filename.Split("\\"); // todo: im assuming openplanet always gets windows-style separators
		string baseName = fileBits[fileBits.Length-1];
		
		if (!IO::FolderExists(IO::FromUserGameFolder("Maps/Doubleclicked"))) {
			IO::CreateFolder(IO::FromUserGameFolder("Maps/Doubleclicked"));
		}
		
		string newName = IO::FromUserGameFolder("Maps/Doubleclicked/"+baseName);
		
		IO::File oldFile(filename, IO::FileMode::Read);
		IO::File newFile(IO::FromUserGameFolder("Maps/Doubleclicked/"+baseName), IO::FileMode::Write);
		newFile.Write(oldFile.Read(oldFile.Size()));
		newFile.Flush();
		oldFile.Close();
		newFile.Close();
		
		auto app = cast<CTrackMania>(GetApp());
		auto dfm = app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr;
		dfm.Map_RefreshFromDisk();
		
		return "Doubleclicked/"+baseName;
	}
}