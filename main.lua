local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local placeId = 126884695634066 -- Gamitin yung current game ID
local player = Players.LocalPlayer

local function serverHop()
    local cursor = ""
    local foundServer = false

    repeat
        local success, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync(
                ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
            ))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    foundServer = true
                    return
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end

        wait(0.5)
    until cursor == ""

    if not foundServer then
        TeleportService:Teleport(placeId, player)
    end
end

serverHop()
