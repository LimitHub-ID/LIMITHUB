local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local placeId = 126884695634066 -- Example Place ID

local function hop()
    local servers = HttpService:JSONDecode(HttpService:GetAsync(
        "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    ))

    for _, server in pairs(servers.data) do
