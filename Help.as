[SettingsTab name="Setup"]
void RenderHelp()
{
	UI::TextWrapped("Doubleclicker allows you to open Map.Gbx files by simply double-clicking them in Windows Explorer. While Trackmania *technically* supports this, it has several downsides: First and foremost, online services won't be available, so things like leaderboards won't work. In addition, Openplanet doesn't load.");
	
	UI::TextWrapped("This plugin solves both those problems through the use of a thin wrapper program, which will launch Trackmania, wait for Openplanet to load, then tell the Doubleclicker plugin to load the map in question. This allows you to enjoy your trusty Openplanet plugins as well as Nadeo online services.");
	
	UI::Separator();
	
	UI::TextWrapped("Note that in order for this to function, you must manually install a registry entry to associate .Gbx files with the wrapper program. In order to do so, follow these steps:");
	
	UI::TextWrapped(Icons::Circle + " Click the 'Open Storage Folder' button below.");
	UI::TextWrapped(Icons::Circle + " In the Explorer window that appears, right-click the associate_gbx.reg file, and choose 'Merge'. You will require Administrator permissions.");
	UI::TextWrapped(Icons::Circle + " Click the 'Go to Github' button below, and download the Doubleclicker.exe file given in the assets. Place this file in the same folder as associate_gbx.reg.");
	UI::TextWrapped(Icons::Circle + " Verify functionality by checking a .Map.Gbx file. It should have a green TM icon and when double-clicked it should open in Trackmania.");
	
	if (UI::Button("Open Storage Folder")) {
		OpenExplorerPath(IO::FromStorageFolder(""));
	}
	
	if (UI::Button("Go to Github")) {
		OpenBrowserURL("https://github.com/sylae/tm-doubleclicker/releases/tag/v" + Meta::ExecutingPlugin().Version);
	}
	
	UI::Separator();
	
	UI::TextWrapped("If you are interested in supporting this project or just want to say hi, please consider taking a look at the below links "+Icons::Heart);
	
	UI::Markdown(Icons::Patreon + " [https://patreon.com/MisfitMaid](https://patreon.com/MisfitMaid)");
	UI::Markdown(Icons::Paypal + " [https://paypal.me/MisfitMaid](https://paypal.me/MisfitMaid)");
	UI::Markdown(Icons::Github + " [https://github.com/sylae/tm-doubleclicker](https://github.com/sylae/tm-doubleclicker)");
	UI::Markdown(Icons::Discord + " [https://discord.gg/BdKpuFcYzG](https://discord.gg/BdKpuFcYzG)");
	UI::Markdown(Icons::Twitch + " [https://twitch.tv/MisfitMaid](https://twitch.tv/MisfitMaid)");
}
