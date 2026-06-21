local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local role = "Unknown"
local objectives = {}
local completedObjectives = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SchoolHuntUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local roleLabel = Instance.new("TextLabel")
roleLabel.Name = "RoleLabel"
roleLabel.Size = UDim2.new(0, 200, 0, 40)
roleLabel.Position = UDim2.new(0.5, -100, 0, 10)
roleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
roleLabel.BackgroundTransparency = 0.5
roleLabel.TextColor3 = Color3.new(1, 1, 1)
roleLabel.TextScaled = true
roleLabel.Font = Enum.Font.GothamBold
roleLabel.Text = ""
roleLabel.Parent = screenGui

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 100, 0, 30)
timerLabel.Position = UDim2.new(1, -110, 0, 10)
timerLabel.BackgroundColor3 = Color3.new(0, 0, 0)
timerLabel.BackgroundTransparency = 0.5
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "Waiting..."
timerLabel.Parent = screenGui

local objectiveFrame = Instance.new("Frame")
objectiveFrame.Name = "ObjectiveFrame"
objectiveFrame.Size = UDim2.new(0, 250, 0, 250)
objectiveFrame.Position = UDim2.new(0, 10, 0.5, -125)
objectiveFrame.BackgroundColor3 = Color3.new(0, 0, 0)
objectiveFrame.BackgroundTransparency = 0.6
objectiveFrame.Visible = false
objectiveFrame.Parent = screenGui

local objectiveTitle = Instance.new("TextLabel")
objectiveTitle.Name = "ObjectiveTitle"
objectiveTitle.Size = UDim2.new(1, 0, 0, 30)
objectiveTitle.BackgroundTransparency = 1
objectiveTitle.TextColor3 = Color3.new(1, 0.8, 0)
objectiveTitle.Text = "OBJECTIVES"
objectiveTitle.Font = Enum.Font.GothamBold
objectiveTitle.TextScaled = true
objectiveTitle.Parent = objectiveFrame

local objectiveList = Instance.new("UIListLayout")
objectiveList.Name = "ObjectiveList"
objectiveList.Padding = UDim.new(0, 4)
objectiveList.Parent = objectiveFrame

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(0, 400, 0, 50)
messageLabel.Position = UDim2.new(0.5, -200, 0.5, -25)
messageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
messageLabel.BackgroundTransparency = 0.7
messageLabel.TextColor3 = Color3.new(1, 1, 1)
messageLabel.TextScaled = true
messageLabel.Font = Enum.Font.GothamBold
messageLabel.Text = ""
messageLabel.Visible = false
messageLabel.Parent = screenGui

local captureButton = Instance.new("TextButton")
captureButton.Name = "CaptureButton"
captureButton.Size = UDim2.new(0, 150, 0, 50)
captureButton.Position = UDim2.new(0.5, -75, 1, -70)
captureButton.BackgroundColor3 = Color3.new(1, 0, 0)
captureButton.TextColor3 = Color3.new(1, 1, 1)
captureButton.Text = "CAPTURE"
captureButton.Font = Enum.Font.GothamBold
captureButton.TextScaled = true
captureButton.Visible = false
captureButton.Parent = screenGui

local suspicionFrame = Instance.new("Frame")
suspicionFrame.Name = "SuspicionFrame"
suspicionFrame.Size = UDim2.new(0, 200, 0, 30)
suspicionFrame.Position = UDim2.new(0.5, -100, 0, 60)
suspicionFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
suspicionFrame.BackgroundTransparency = 0.5
suspicionFrame.Visible = false
suspicionFrame.Parent = screenGui

local suspicionBar = Instance.new("Frame")
suspicionBar.Name = "SuspicionBar"
suspicionBar.Size = UDim2.new(0, 0, 1, 0)
suspicionBar.BackgroundColor3 = Color3.new(1, 0, 0)
suspicionBar.BorderSizePixel = 0
suspicionBar.Parent = suspicionFrame

local suspicionLabel = Instance.new("TextLabel")
suspicionLabel.Name = "SuspicionLabel"
suspicionLabel.Size = UDim2.new(1, 0, 1, 0)
suspicionLabel.BackgroundTransparency = 1
suspicionLabel.TextColor3 = Color3.new(1, 1, 1)
suspicionLabel.Text = "SUSPICION: 0%"
suspicionLabel.Font = Enum.Font.GothamBold
suspicionLabel.TextScaled = true
suspicionLabel.Parent = suspicionFrame

local spectatorLabel = Instance.new("TextLabel")
spectatorLabel.Name = "SpectatorLabel"
spectatorLabel.Size = UDim2.new(1, 0, 0, 40)
spectatorLabel.Position = UDim2.new(0, 0, 0.5, -20)
spectatorLabel.BackgroundTransparency = 0.5
spectatorLabel.BackgroundColor3 = Color3.new(0, 0, 0)
spectatorLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
spectatorLabel.Text = "SPECTATOR - Watch the game!"
spectatorLabel.Font = Enum.Font.GothamBold
spectatorLabel.TextScaled = true
spectatorLabel.Visible = false
spectatorLabel.Parent = screenGui

local interactLabel = Instance.new("TextLabel")
interactLabel.Name = "InteractLabel"
interactLabel.Size = UDim2.new(0, 200, 0, 30)
interactLabel.Position = UDim2.new(0.5, -100, 1, -120)
interactLabel.BackgroundTransparency = 0.5
interactLabel.BackgroundColor3 = Color3.new(0, 0, 0)
interactLabel.TextColor3 = Color3.new(1, 1, 0)
interactLabel.Text = "[E] Interact"
interactLabel.Font = Enum.Font.GothamBold
interactLabel.TextScaled = true
interactLabel.Visible = false
interactLabel.Parent = screenGui

Remotes.RoleAssigned.OnClientEvent:Connect(function(assignedRole)
    role = assignedRole
    roleLabel.Text = role

    if role == "Infiltrator" then
        roleLabel.TextColor3 = Color3.new(1, 0.5, 0)
        objectiveFrame.Visible = true
        interactLabel.Visible = true
    elseif role == "Inspector" then
        roleLabel.TextColor3 = Color3.new(0.3, 0.7, 1)
        captureButton.Visible = true
        suspicionFrame.Visible = true
    else
        roleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        spectatorLabel.Visible = true
    end
end)

Remotes.RoundStateChanged.OnClientEvent:Connect(function(state, timeLeft)
    if state == "Playing" then
        timerLabel.Text = FormatTime(timeLeft)
    elseif state == "Waiting" then
        timerLabel.Text = "Waiting for players..."
    end
end)

Remotes.ObjectiveProgress.OnClientEvent:Connect(function(objList)
    objectives = objList or {}
    UpdateObjectiveUI()
end)

Remotes.ObjectiveCompleted.OnClientEvent:Connect(function(objId, progress, total)
    table.insert(completedObjectives, objId)
    UpdateObjectiveUI()
end)

Remotes.SuspicionUpdate.OnClientEvent:Connect(function(level)
    local percent = (level / GameConfig.SUSPICION.MAX_SUSPICION) * 100
    suspicionBar:TweenSize(UDim2.new(percent / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3)
    suspicionLabel.Text = "SUSPICION: " .. math.floor(percent) .. "%"
end)

Remotes.GameMessage.OnClientEvent:Connect(function(message)
    ShowMessage(message)
end)

Remotes.RoundEnded.OnClientEvent:Connect(function(result)
    roleLabel.Text = result
    ShowMessage(result)
    timerLabel.Text = "Round Over"

    objectiveFrame.Visible = false
    captureButton.Visible = false
    suspicionFrame.Visible = false
    interactLabel.Visible = false
    spectatorLabel.Visible = false
end)

function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

function UpdateObjectiveUI()
    for _, child in ipairs(objectiveFrame:GetChildren()) do
        if child.Name ~= "ObjectiveTitle" and child.Name ~= "ObjectiveList" then
            child:Destroy()
        end
    end

    for _, objId in ipairs(objectives) do
        local isCompleted = false
        for _, completedId in ipairs(completedObjectives) do
            if completedId == objId then
                isCompleted = true
                break
            end
        end

        local taskInfo = GameConfig.TASKS[objId]
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = (isCompleted and "CHECK" or "O ") .. (taskInfo and taskInfo.name or objId)
        label.TextColor3 = isCompleted and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextScaled = true
        label.Parent = objectiveFrame
    end
end

function ShowMessage(message)
    messageLabel.Text = message
    messageLabel.Visible = true
    task.spawn(function()
        task.wait(4)
        messageLabel.Visible = false
    end)
end

captureButton.MouseButton1Click:Connect(function()
    local mouse = player:GetMouse()
    local target = mouse.Target
    if target then
        local character = target:FindFirstAncestorOfClass("Model")
        if character and character:FindFirstChild("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(character)
            if targetPlayer then
                Remotes.RequestCapture:FireServer(targetPlayer)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.E then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position

            for taskId, objData in pairs(GameConfig.OBJECTIVES) do
                local part = Workspace:FindFirstChild(objData.partName, true)
                if part then
                    local dist = (pos - part.Position).Magnitude
                    if dist <= GameConfig.INTERACT_DISTANCE then
                        Remotes.InteractWithObjective:FireServer(taskId)
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local success, stateData = pcall(function()
            return Remotes.GetRoundState:InvokeServer()
        end)
        if success and stateData and stateData.state == "Playing" then
            timerLabel.Text = FormatTime(stateData.timeLeft)
        end
    end
end)
