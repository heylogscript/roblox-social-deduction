# School Hunt

A **social deduction** game where one infiltrator blends in with NPCs while inspectors hunt them. Complete tasks to reveal the impostor.

## Systems

- **Role System** — Infiltrator vs Inspectors with hidden identity
- **NPC System** — Patrol routes, pathfinding, schedule-based behavior
- **Task Objectives** — Spawnable task locations with progress tracking
- **Suspicion Mechanic** — Running/suspicion meter, reveal triggers
- **Capture System** — Inspector capture mechanics for the infiltrator
- **Round Management** — Queue system, timer, round end conditions
- **Centralized Networking** — Single remote definitions module

## Architecture

| Component | Role |
|---|---|
| `RoleManager` | Role assignment and identity hiding |
| `RoundManager` | Queue, timer, round end conditions |
| `CaptureHandler` | Inspector → Infiltrator capture logic |
| `ObjectiveManager` | Task spawning, assignment, progress |
| `NPCManager` | NPC spawning, patrol routes, pathfinding |
| `SuspicionManager` | Running/suspicion tracking |

## Tech

- **Language:** Luau
- **Engine:** Roblox
- **Pattern:** Modular, centralized remotes, server-authoritative
