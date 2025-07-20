local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

if game.JobId == "" then
    TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
else
    print("✅ Nasa private server ka na")
end
