local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function CreateRemoteEvent(name)
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = ReplicatedStorage
    Remotes[name] = remote
end

local function CreateRemoteFunction(name)
    local remote = Instance.new("RemoteFunction")
    remote.Name = name
    remote.Parent = ReplicatedStorage
    Remotes[name] = remote
end

CreateRemoteEvent("RoleAssigned")
CreateRemoteEvent("RoundStateChanged")
CreateRemoteEvent("ObjectiveProgress")
CreateRemoteEvent("ObjectiveCompleted")
CreateRemoteEvent("GameMessage")
CreateRemoteEvent("RoundEnded")
CreateRemoteEvent("SuspicionUpdate")
CreateRemoteEvent("AllObjectivesDone")

CreateRemoteEvent("InteractWithObjective")
CreateRemoteEvent("RequestCapture")
CreateRemoteEvent("PlayerStartedRunning")
CreateRemoteEvent("PlayerStoppedRunning")

CreateRemoteFunction("GetRoundState")

return Remotes
