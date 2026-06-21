local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RoundManager = {}

local roundState = "Waiting"
local roundTimeLeft = 0
local roundTimer = nil
local currentRound = 0

function RoundManager.Initialize()
    roundState = "Waiting"

    Players.PlayerAdded:Connect(function(player)
        if roundState == "Waiting" then
            Remotes.GameMessage:FireAllClients(player.Name .. " joined the game!")
        end
    end)

    Remotes.GetRoundState.OnServerInvoke = function(player)
        return {
            state = roundState,
            timeLeft = roundTimeLeft,
            round = currentRound,
        }
    end
end

function RoundManager.StartQueue()
    while true do
        local playerCount = #Players:GetPlayers()
        if playerCount >= GameConfig.MIN_PLAYERS and roundState == "Waiting" then
            task.wait(3)
            if #Players:GetPlayers() >= GameConfig.MIN_PLAYERS then
                StartRound()
            end
        end
        task.wait(1)
    end
end

function StartRound()
    if roundState ~= "Waiting" then return end

    currentRound = currentRound + 1
    roundState = "Playing"
    roundTimeLeft = GameConfig.ROUND_TIME

    local RoleManager = require(script.Parent.RoleManager)
    RoleManager.AssignRoles()

    local NPCManager = require(script.Parent.NPCManager)
    NPCManager.SpawnNPCs()

    local ObjectiveManager = require(script.Parent.ObjectiveManager)
    ObjectiveManager.StartRound()

    Remotes.RoundStateChanged:FireAllClients("Playing", roundTimeLeft)
    Remotes.GameMessage:FireAllClients("Round started! Infiltrator, complete your objectives!")

    roundTimer = task.spawn(function()
        while roundTimeLeft > 0 and roundState == "Playing" do
            task.wait(1)
            roundTimeLeft = roundTimeLeft - 1

            if roundTimeLeft % 10 == 0 then
                Remotes.RoundStateChanged:FireAllClients("Playing", roundTimeLeft)
            end
        end

        if roundState == "Playing" then
            EndRound("timeout")
        end
    end)
end

function RoundManager.EndRound(reason)
    if roundState ~= "Playing" then return end
    roundState = "Ended"

    if roundTimer then
        task.cancel(roundTimer)
    end

    local NPCManager = require(script.Parent.NPCManager)
    NPCManager.DespawnNPCs()

    local SuspicionManager = require(script.Parent.SuspicionManager)
    SuspicionManager.Reset()

    local result = ""
    if reason == "capture" then
        result = "Inspector Wins! Infiltrator was captured!"
    elseif reason == "objectives" then
        result = "Infiltrator Wins! All objectives completed!"
    elseif reason == "timeout" then
        local ObjectiveManager = require(script.Parent.ObjectiveManager)
        if ObjectiveManager.GetProgress() >= GameConfig.TASKS_REQUIRED then
            result = "Infiltrator Wins! All objectives completed!"
        else
            result = "Inspector Wins! Time ran out!"
        end
    end

    Remotes.RoundEnded:FireAllClients(result)
    Remotes.GameMessage:FireAllClients(result)

    task.wait(10)
    roundState = "Waiting"
    Remotes.RoundStateChanged:FireAllClients("Waiting", 0)
end

function RoundManager.GetState()
    return roundState, roundTimeLeft
end

return RoundManager
