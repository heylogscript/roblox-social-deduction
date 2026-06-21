local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SuspicionManager = {}

local playerSuspicion = {}
local suspicionTimers = {}

function SuspicionManager.Initialize()
    Players.PlayerRemoving:Connect(function(player)
        playerSuspicion[player] = nil
        if suspicionTimers[player] then
            suspicionTimers[player]:Cancel()
            suspicionTimers[player] = nil
        end
    end)

    Remotes.PlayerStartedRunning.OnServerEvent:Connect(function(player)
        StartRunningSuspicion(player)
    end)

    Remotes.PlayerStoppedRunning.OnServerEvent:Connect(function(player)
        StopRunningSuspicion(player)
    end)
end

function SuspicionManager.Reset()
    playerSuspicion = {}
    for player, timer in pairs(suspicionTimers) do
        timer:Cancel()
    end
    suspicionTimers = {}
end

function StartRunningSuspicion(player)
    if suspicionTimers[player] then
        suspicionTimers[player]:Cancel()
    end

    suspicionTimers[player] = task.spawn(function()
        while true do
            task.wait(1)
            AddSuspicion(player, GameConfig.SUSPICION.RUNNING_PER_SECOND)
        end
    end)
end

function StopRunningSuspicion(player)
    if suspicionTimers[player] then
        suspicionTimers[player]:Cancel()
        suspicionTimers[player] = nil
    end
end

function AddSuspicion(player, amount)
    if not playerSuspicion[player] then
        playerSuspicion[player] = 0
    end

    playerSuspicion[player] = math.min(playerSuspicion[player] + amount, GameConfig.SUSPICION.MAX_SUSPICION)

    if playerSuspicion[player] >= GameConfig.SUSPICION.INSPECTOR_ALERT_THRESHOLD then
        local RoleManager = require(script.Parent.RoleManager)
        for _, inspector in ipairs(RoleManager.GetInspectors()) do
            Remotes.SuspicionUpdate:FireClient(inspector, playerSuspicion[player])
        end
    end
end

function SuspicionManager.AddSuspicion(player, amount)
    AddSuspicion(player, amount)
end

function SuspicionManager.GetSuspicion(player)
    return playerSuspicion[player] or 0
end

return SuspicionManager
