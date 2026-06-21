local GameConfig = {}

GameConfig.ROUND_TIME = 300
GameConfig.MIN_PLAYERS = 2
GameConfig.NPC_COUNT = 30
GameConfig.TASKS_REQUIRED = 5
GameConfig.CAPTURE_DISTANCE = 30
GameConfig.INTERACT_DISTANCE = 10

GameConfig.ROOMS = {
    "MainHallway",
    "Classroom1",
    "Classroom2",
    "Classroom3",
    "Classroom4",
    "Cafeteria",
    "Library",
    "Bathroom",
    "ComputerLab",
}

GameConfig.TASKS = {
    StealExamPapers = { id = "StealExamPapers", name = "Steal Exam Papers", description = "Stay near the teacher's desk for 5 seconds", duration = 5 },
    HackComputer = { id = "HackComputer", name = "Hack School Computer", description = "Interact with a computer terminal", duration = 3 },
    ChangeAnnouncement = { id = "ChangeAnnouncement", name = "Change School Announcement", description = "Interact with the bulletin board", duration = 3 },
    TamperSecurity = { id = "TamperSecurity", name = "Tamper With Security System", description = "Interact with the electrical panel", duration = 4 },
    PlantEvidence = { id = "PlantEvidence", name = "Plant Fake Evidence", description = "Leave an item in a classroom", duration = 2 },
}

GameConfig.OBJECTIVES = {
    StealExamPapers = { room = "Classroom1", partName = "TeacherDesk" },
    HackComputer = { room = "ComputerLab", partName = "ComputerTerminal" },
    ChangeAnnouncement = { room = "MainHallway", partName = "BulletinBoard" },
    TamperSecurity = { room = "MainHallway", partName = "ElectricalPanel" },
    PlantEvidence = { room = "Classroom3", partName = "PlantEvidenceSpot" },
}

GameConfig.NPC = {
    WALK_SPEED = { min = 10, max = 16 },
    IDLE_TIME = { min = 3, max = 10 },
    SIT_CHANCE = 0.25,
    DIRECTION_CHANGE_CHANCE = 0.1,
}

GameConfig.SUSPICION = {
    RUNNING_PER_SECOND = 3,
    DIRECTION_CHANGE = 2,
    OBJECTIVE_VISIT = 4,
    MAX_SUSPICION = 100,
    INSPECTOR_ALERT_THRESHOLD = 60,
    DECAY_RATE = 0.5,
}

return GameConfig
