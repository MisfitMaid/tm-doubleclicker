using System;
using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Nodes;
using Websocket.Client;

public class Doubleclicker
{
    public Uri OpenplanetURL = new Uri("ws://127.0.0.1:1312"); // only listen on loopback
    public WebsocketClient client;
    public string[] argv;
    static void Main(string[] args)
    {
        if (args.Count() < 1)
        {
            Console.WriteLine("Usage: Doubleclicker.exe path/to/map.Map.gbx");
            Environment.Exit(0);
        }
        Console.WriteLine("Starting");
        Doubleclicker doubleclicker = new Doubleclicker(args);

    }

    public Doubleclicker(string[] args)
    {
        argv = args;
        var exitEvent = new ManualResetEvent(false);

        // get the path from the settings json
        JsonNode settings = JsonNode.Parse(File.ReadAllText("tmPath.json"));


        if (!isTrackmaniaOpen(settings!["tmBinary"].ToString()))
        {
            Console.WriteLine("Trackmania wasn't open, launching now. Please wait.");
            openTrackmania(settings!["tmBinary"].ToString());
        }

        client = new WebsocketClient(OpenplanetURL);
        client.ReconnectTimeout = null;
        client.ErrorReconnectTimeout = TimeSpan.FromSeconds(5);
        client.MessageReceived.Subscribe(rx);
        client.Start();

        Task.Run(() => client.Send("{\"type\": 0}"));

        exitEvent.WaitOne();

    }

    protected void rx(ResponseMessage msg)
    {
        Console.WriteLine($"Message received: {msg}");
        JsonNode rec = JsonNode.Parse(msg.ToString());

        uint type;
        try
        {
            type = (uint)rec!["type"];
        }
        catch (NullReferenceException)
        {
            Console.WriteLine("Malformed payload: " + msg.ToString());
            return;
        }

        Console.WriteLine(type);

        switch (type)
        {
            case 0: // status
                if (!(bool)rec!["hasPerms"])
                {
                    // we check this in the plugin but an error message is nice to have
                    Console.WriteLine("No permission to play local maps, this program won't do anything.");
                    break;
                }


                // now that we're loaded, tell openplanet to tell trackmania to play the map
                JsonObject response = new JsonObject();
                response!["type"] = 1;
                response!["map"] = argv[0];

                client.Send(response.ToJsonString());

                break;
            case 1: // play map
                // we should never receive this
                break;
            case 2: // acknowledge
                Console.WriteLine("my job here is done");
                Environment.Exit(0);
                break;
            default:
                Console.WriteLine("Unknown packet type: " + msg.ToString());
                break;
        }
    }

    public bool isTrackmaniaOpen(string tmPath)
    {
        Process[] processes = Process.GetProcessesByName("Trackmania");
        foreach (Process process in processes)
        {
            if (process.MainModule.FileName == tmPath) return true;
        }
        return false;
    }

    public void openTrackmania(string tmPath)
    {
        Process.Start(tmPath);
    }
}
