# Project Rules for Google Jules AI

## Tech Stack
- Engine: Godot Engine 4.2.7 (Strictly 4.x syntax, NEVER Godot 3)
- Language: GDScript 2.0 with strict static typing
- Unit Testing: GUT (Godot Unit Test)

## Critical GDScript Rules
1. NEVER use the 'yield' keyword. ALWAYS use 'await' for coroutines and signals.
2. Use 'CharacterBody2D', NEVER 'KinematicBody2D'.
3. Always use Godot 4 annotations: `@export`, `@onready`, `@signal`.
4. Enforce strict static typing on ALL variables, function parameters, and return types.
5. Use "Call down, signal up" paradigm. Connect all signals dynamically in `_ready()`.
6. Access nested child nodes using Scene Unique Nodes (`%NodeName`).

## Verification Commands
- Headless Compilation Check: `godot --headless --quit`
- GUT Unit Tests: `godot --headless -s res://addons/gut/gut_cmdln.gd`
- Linting: `gdlint res/`
- Formatting: `gdformat res/`
- 
