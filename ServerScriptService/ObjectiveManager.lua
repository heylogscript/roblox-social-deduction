local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ObjectiveManager = {}

local currentObjectives = {}
local completedObjectives = {}
local positionObjectives = {}
local infiltratorProgress = 0

function ObjectiveManager.Initialize()
    MapObjectiveLocations()

    Remotes.InteractWithObjective.OnServerEvent:Connect(function(player, objectiveId)
        HandleInteraction(player, objectiveId)
    end)
end

function MapObjectiveLocations()
    for taskId, objData in pairs(GameConfig.OBJECTIVES) do
        local part = Workspace:FindFirstChild(objData.partName, true)
        if part then
            positionObjectives[taskId] = {
                position = part.Position,
                part = part,
            }
        end
    end
end

function ObjectiveManager.StartRound()
    currentObjectives = {}
    completedObjectives = {}
    infiltratorProgress = 0

    local taskIds = {}
    for taskId, _ in pairs(GameConfig.TASKS) do
        table.insert(taskIds, taskId)
    end

    for i = #taskIds, 2, -1 do
        local j = math.random(1, i)
        taskIds[i], taskIds[j] = taskIds[j], taskIds[i]
    end

    local count = math.min(GameConfig.TASKS_REQUIRED, #taskIds)
    for i = 1, count do
        table.insert(currentObjectives, taskIds[i])
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local RoleManager = require(script.Parent.RoleManager)
        if RoleManager.GetRole(player) == "Infiltrator" then
            Remotes.ObjectiveProgress:FireClient(player, currentObjectives)
        end
    end
end

function HandleInteraction(player, objectiveId)
    if not objectiveId then return end

    local RoleManager = require(script.Parent.RoleManager)
    if RoleManager.GetRole(player) ~= "Infiltrator" then return end

    for _, completedId in ipairs(completedObjectives) do
        if completedId == objectiveId then return end
    end

    local isValid = false
    for _, objId in ipairs(currentObjectives) do
        if objId == objectiveId then
            isValid = true
            break
        end
    end
    if not isValid then return end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local objData = positionObjectives[objectiveId]
    if not objData then return end

    local dist = (char.HumanoidRootPart.Position - objData.position).Magnitude
    if dist > GameConfig.INTERACT_DISTANCE then return end

    table.insert(completedObjectives, objectiveId)
    infiltratorProgress = infiltratorProgress + 1

    Remotes.ObjectiveCompleted:FireClient(player, objectiveId, infiltratorProgress, GameConfig.TASKS_REQUIRED)
    Remotes.GameMessage:FireAllClients("An objective has been completed!")

    if infiltratorProgress >= GameConfig.TASKS_REQUIRED then
        Remotes.AllObjectivesDone:FireAllClients()
        local RoundManager = require(script.Parent.RoundManager)
        RoundManager.EndRound("objectives")
    end
end

function ObjectiveManager.GetProgress()
    return infiltratorProgress
end

function ObjectiveManager.GetActiveObjectives()
    return currentObjectives, completedObjectives
end

function ObjectiveManager.GetObjectivePosition(objectiveId)
    local data = positionObjectives[objectiveId]
    if data then
        return data.position
    end
    return nil
end

return ObjectiveManager
