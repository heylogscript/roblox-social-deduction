local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RoleManager = {}

local playerRoles = {}

function RoleManager.Initialize()
    Players.PlayerRemoving:Connect(function(player)
        playerRoles[player] = nil
    end)
end

function RoleManager.AssignRoles()
    local playerList = Players:GetPlayers()
    if #playerList < 2 then return end

    playerRoles = {}

    local infiltratorIndex = math.random(1, #playerList)

    for i, player in ipairs(playerList) do
        if i == infiltratorIndex then
            playerRoles[player] = "Infiltrator"
            Remotes.RoleAssigned:FireClient(player, "Infiltrator")
            Remotes.GameMessage:FireClient(player, "You are the INFILTRATOR! Complete your tasks without being caught!")
        else
            playerRoles[player] = "Inspector"
            Remotes.RoleAssigned:FireClient(player, "Inspector")
            if #playerList > 2 and i ~= 2 then
                Remotes.GameMessage:FireClient(player, "You are a SPECTATOR! Watch the game unfold!")
            else
                Remotes.GameMessage:FireClient(player, "You are the INSPECTOR! Find and capture the infiltrator!")
            end
        end
    end
end

function RoleManager.GetRole(player)
    return playerRoles[player]
end

function RoleManager.GetInfiltrator()
    for player, role in pairs(playerRoles) do
        if role == "Infiltrator" then
            return player
        end
    end
    return nil
end

function RoleManager.GetInspectors()
    local inspectors = {}
    for player, role in pairs(playerRoles) do
        if role == "Inspector" then
            table.insert(inspectors, player)
        end
    end
    return inspectors
end

return RoleManager
