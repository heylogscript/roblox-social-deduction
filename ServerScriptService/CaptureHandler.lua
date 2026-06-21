local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CaptureHandler = {}

function CaptureHandler.Initialize()
    Remotes.RequestCapture.OnServerEvent:Connect(function(player, targetPlayer)
        HandleCapture(player, targetPlayer)
    end)
end

function HandleCapture(inspector, targetPlayer)
    local RoleManager = require(script.Parent.RoleManager)
    if RoleManager.GetRole(inspector) ~= "Inspector" then return end

    if not targetPlayer or not Players:FindFirstChild(targetPlayer.Name) then return end

    local inspectorChar = inspector.Character
    local targetChar = targetPlayer.Character
    if not inspectorChar or not targetChar then return end
    if not inspectorChar:FindFirstChild("HumanoidRootPart") or not targetChar:FindFirstChild("HumanoidRootPart") then return end

    local dist = (inspectorChar.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Magnitude
    if dist > GameConfig.CAPTURE_DISTANCE then
        Remotes.GameMessage:FireClient(inspector, "Too far away to capture!")
        return
    end

    local targetRole = RoleManager.GetRole(targetPlayer)
    local infiltrator = RoleManager.GetInfiltrator()

    if targetPlayer == infiltrator then
        Remotes.GameMessage:FireAllClients(inspector.Name .. " captured the Infiltrator! Good job!")
        local RoundManager = require(script.Parent.RoundManager)
        RoundManager.EndRound("capture")
    else
        Remotes.GameMessage:FireAllClients(inspector.Name .. " captured an innocent student! The Infiltrator wins!")
        local RoundManager = require(script.Parent.RoundManager)
        RoundManager.EndRound("objectives")
    end
end

return CaptureHandler
