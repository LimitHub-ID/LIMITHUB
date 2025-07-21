local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

print("🟩 Script running")
print("🧾 PrivateServerId: " .. tostring(game.PrivateServerId))
print("🧾 PrivateServerOwnerId: " .. tostring(game.PrivateServerOwnerId))

if game.PrivateServerId == "" or game.PrivateServerOwnerId == 0 then
    print("🟨 Not in private server. Teleporting now...")
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
else
    print("✅ Already inside private server. No need to teleport.")
end
