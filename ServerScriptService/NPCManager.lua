local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local NPCManager = {}

local npcs = {}

function NPCManager.Initialize()
end

function NPCManager.SpawnNPCs()
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then
        npcFolder = Instance.new("Folder")
        npcFolder.Name = "NPCs"
        npcFolder.Parent = Workspace
    end

    for i = 1, GameConfig.NPC_COUNT do
        local npc = CreateNPC(i)
        table.insert(npcs, npc)
    end
end

function CreateNPC(index)
    local model = Instance.new("Model")
    model.Name = "NPC_" .. index

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.Anchored = false
    rootPart.CanCollide = true
    rootPart.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Anchored = false
    head.CanCollide = true
    head.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "Humanoid"
    humanoid.Parent = model
    humanoid.WalkSpeed = math.random(GameConfig.NPC.WALK_SPEED.min, GameConfig.NPC.WALK_SPEED.max)
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local npcTemplate = Workspace:FindFirstChild("NPCTemplate")
    if npcTemplate and npcTemplate:IsA("Model") then
        local clone = npcTemplate:Clone()
        clone.Parent = model
        clone:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
    end

    model.Parent = Workspace.NPCs
    rootPart.CFrame = CFrame.new(GetRandomSpawnPosition())

    local npcData = {
        model = model,
        humanoid = humanoid,
        rootPart = rootPart,
        state = "idle",
        idleTimer = 0,
        sitting = false,
    }

    task.spawn(function()
        NPCBehaviorLoop(npcData)
    end)

    return npcData
end

function GetRandomSpawnPosition()
    local spawnFolder = Workspace:FindFirstChild("NPCSpawnLocations")
    if spawnFolder then
        local spawns = spawnFolder:GetChildren()
        if #spawns > 0 then
            local spawnPart = spawns[math.random(1, #spawns)]
            return spawnPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
        end
    end
    return Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
end

function NPCBehaviorLoop(npcData)
    while npcData.model and npcData.model.Parent do
        npcData.humanoid.WalkSpeed = math.random(GameConfig.NPC.WALK_SPEED.min, GameConfig.NPC.WALK_SPEED.max)

        local behavior = math.random()

        if behavior < 0.5 then
            local targetRoom = GameConfig.ROOMS[math.random(1, #GameConfig.ROOMS)]
            local roomPart = Workspace:FindFirstChild(targetRoom)
            if roomPart then
                local targetPos = roomPart.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                WalkToPosition(npcData, targetPos)
            end
        elseif behavior < 0.7 then
            Idle(npcData, math.random(GameConfig.NPC.IDLE_TIME.min, GameConfig.NPC.IDLE_TIME.max))
        elseif behavior < 0.85 then
            local offset = Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
            local targetPos = npcData.rootPart.Position + offset
            WalkToPosition(npcData, targetPos)
        else
            Interact(npcData)
        end

        if math.random() < GameConfig.NPC.DIRECTION_CHANGE_CHANCE and npcData.state == "walking" then
            local offset = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
            WalkToPosition(npcData, npcData.rootPart.Position + offset)
        end
    end
end

function WalkToPosition(npcData, targetPos)
    npcData.state = "walking"

    local path = PathfindingService:CreatePath()
    local success = pcall(function()
        path:ComputeAsync(npcData.rootPart.Position, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not npcData.model or not npcData.model.Parent then break end
            npcData.humanoid:MoveTo(waypoint.Position)
            npcData.humanoid.MoveToFinished:Wait()
        end
    else
        npcData.humanoid:MoveTo(targetPos)
        npcData.humanoid.MoveToFinished:Wait(3)
    end
end

function Idle(npcData, duration)
    npcData.state = "idle"
    npcData.humanoid:MoveTo(npcData.rootPart.Position)
    task.wait(duration)
end

function Interact(npcData)
    npcData.state = "interacting"
    npcData.humanoid:MoveTo(npcData.rootPart.Position)
    task.wait(math.random(2, 5))
    npcData.state = "idle"
end

function NPCManager.DespawnNPCs()
    for _, npcData in ipairs(npcs) do
        if npcData.model and npcData.model.Parent then
            npcData.model:Destroy()
        end
    end
    npcs = {}
end

function NPCManager.GetNPCs()
    return npcs
end

function NPCManager.GetNPCModels()
    local models = {}
    for _, npcData in ipairs(npcs) do
        table.insert(models, npcData.model)
    end
    return models
end

return NPCManager
