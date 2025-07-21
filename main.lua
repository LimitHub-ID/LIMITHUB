-- ✅ Basic Teleport Test Script
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ilagay mo dito ang tamang Private Server Details mo
local placeId = 126884695634066
local privateServerCode = "40206718588419987554943106780552"

-- Debug Info
print("✅ Starting teleport test...")
print("🧾 PlaceId:", placeId)
print("🔐 Server Code:", privateServerCode)
print("👤 LocalPlayer:", LocalPlayer.Name)

-- Teleport
TeleportService:TeleportToPrivateServer(placeId, privateServerCode, {LocalPlayer})
