local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local player = Players.LocalPlayer
local isRunning = false
local shiftHeld = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        shiftHeld = true
        if not isRunning then
            isRunning = true
            Remotes.PlayerStartedRunning:FireServer()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        shiftHeld = false
        if isRunning then
            isRunning = false
            Remotes.PlayerStoppedRunning:FireServer()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then
        if isRunning then
            isRunning = false
            Remotes.PlayerStoppedRunning:FireServer()
        end
        return
    end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then
        if isRunning then
            isRunning = false
            Remotes.PlayerStoppedRunning:FireServer()
        end
        return
    end

    local currentRunning = shiftHeld
    if currentRunning ~= isRunning then
        isRunning = currentRunning
        if isRunning then
            Remotes.PlayerStartedRunning:FireServer()
        else
            Remotes.PlayerStoppedRunning:FireServer()
        end
    end
end)
