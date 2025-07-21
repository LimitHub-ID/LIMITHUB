local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local placeId = 126884695634066

local loadingScript = [[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local bg = Instance.new("Frame", screenGui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.3

local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(0, 400, 0, 50)
title.Position = UDim2.new(0.5, -200, 0.5, -150)
title.BackgroundTransparency = 1
title.Text = "SERVER HOPPED"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.Fantasy
title.TextScaled = true
]]

local function serverHop()
    local cursor = ""
    local smallestServer = nil

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

    if smallestServer then
        queue_on_teleport(loadingScript)
        TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, LocalPlayer)
    else
        queue_on_teleport(loadingScript)
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

serverHop()
