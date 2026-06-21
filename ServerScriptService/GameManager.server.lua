local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local RoundManager = require(script.RoundManager)
local RoleManager = require(script.RoleManager)
local NPCManager = require(script.NPCManager)
local ObjectiveManager = require(script.ObjectiveManager)
local SuspicionManager = require(script.SuspicionManager)
local CaptureHandler = require(script.CaptureHandler)

RoundManager.Initialize()
RoleManager.Initialize()
NPCManager.Initialize()
ObjectiveManager.Initialize()
SuspicionManager.Initialize()
CaptureHandler.Initialize()

RoundManager.StartQueue()
