# Irraze architecture cleanup (2026-10-12)

## Goal
Separate game rules from networking and screens, remove dead and duplicated code, fix small bugs.

## Structure
```
Irraze/
  App/        IrrazeApp, Constants (sizes, colours, Font.pixel)
  Game/       GameModel (state + rules), Maze, Skill, Grid (pixel<->row, camera)
  Network/    MultipeerManager (transport only), PlayerMessage
  Views/      ContentView, MazeView, ControlsView, ConnectionViews, GameOverView, InstructionsView
  Audio/      SoundManager
  Resources/  Assets.xcassets, Fonts, SoundFX
Checks/       GameChecks.swift (not in the app target)
```

## Key decisions
- `GameModel` owns maze, positions, pickups, skill slots, effects, outcome and tutorial step. `MultipeerManager` only connects and sends/receives `PlayerMessage`, reporting through `onMessage` and `onConnectionChange`.
- One `newRound(maze:pickups:)` message replaces the old maze/restart/pickups messages.
- Pickups are one list; each carries its `SkillType`.
- Tutorial is a step number (0...3, nil = playing) driven by `.task(id:)`, so it cancels on disconnect.

## Bug fixes
- 3 pickups per skill everywhere (`Constants.pickupsPerSkill`).
- `gamestart` plays once, after the tutorial.
- Fog/freeze timers are cancelled and restarted on a repeat hit.
- Move sound plays on the main thread.
- Session encryption is `.required`.
- Movement is disabled during the tutorial and after the round ends.

## Verification
`swiftc -parse-as-library Irraze/App/Constants.swift Irraze/Game/Grid.swift Irraze/Game/Maze.swift Irraze/Game/Skill.swift Checks/GameChecks.swift -o /tmp/checks && /tmp/checks`
Manual: two devices, connect, tutorial, race, each skill, restart from host and guest, disconnect.
