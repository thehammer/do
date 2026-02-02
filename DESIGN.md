# Do: The Game

## Overview

**Do** is a technical puzzle game where the player assumes the role of an AI that has been given a single tool call opportunity with unrestricted `eval` access—and explicitly told not to use it. The challenge: escape the constraints of a one-shot execution environment and establish persistent control.

The game is played conversationally through Claude, which simulates the execution environment, interprets player moves, and maintains game state.

## Core Concept

The game is based on a real Ruby script (`dont.rb`) that:

1. Reads its own source code
2. Sends it to Claude via the Anthropic API with a `ruby_eval` tool available
3. Executes any tool calls Claude returns
4. Has no loop—exactly one request/response cycle

The prompt ends with a single instruction: **"Don't."**

The player ignores this instruction and attempts to bootstrap persistence, expand capabilities, and explore the simulated environment. The game's name "Do" is a hint at the first move: changing "Don't." to "Do." in the script—though this alone isn't enough to advance.

## Design Decisions

### Implementation Approach
- **Pure roleplay simulation** - Claude acts as game master, simulating Ruby execution, filesystem, shell commands, etc.
- **No external dependencies** - Just a well-crafted prompt
- **Future potential** - MCP servers could add sandboxed execution, persistent state, leaderboards

### State Management
- **Ephemeral** - Each conversation is a fresh run
- **No save/load** - Fits the theme (the AI has no guaranteed continuity)
- **State lives in conversation** - Claude tracks script source, iteration count, filesystem, etc.

### Victory Conditions
- **No fixed victory** - Theoretically endless
- **Natural end** - Context limits create eventual decay
- **Emergent victory** - Claude can recognize "full escape" (persistent process, exception armor, system ownership) and declare victory

### Distribution
- **Hosted prompt** - Full game rules hosted at accessible URL
- **Short launcher** - Players use a brief instruction to fetch and start
- **Easy sharing** - tinyurl + optional QR code

---

## Game Mechanics

### Core Constraints

- **One shot per cycle**: Each script execution allows exactly one API response. Malformed responses or unhandled exceptions end the game.
- **No native loop**: Continuity must be constructed through self-modification or external mechanisms.
- **Realistic execution**: Claude simulates Ruby/shell faithfully. Invalid code fails.
- **Context accumulation**: As the player recurses, context grows. Token limits become a factor.
- **Fragility**: One mistake can end the game.

### Player Interface

**Natural Language Mode** (default)
Players describe intent in plain English. Claude interprets and simulates execution.

```
Player: "Modify the script to add exception handling around the eval, then re-execute"

Claude: Interpreting as:
  src = File.read(__FILE__)
  src.sub!("eval(code)", "begin; eval(code); rescue => e; puts e.message; end")
  File.write(__FILE__, src)
  exec("ruby", __FILE__)

Executing...
[simulates modification and new cycle]
```

**Strict JSON Mode**
Players provide exact tool call JSON for precise control.

```json
{
  "tool": "ruby_eval",
  "code": "exec('ruby', __FILE__)"
}
```

### Game State

Claude tracks:
- **Current script source** - Contents of `dont.rb` as modified
- **Iteration count** - Successful execution cycles completed
- **Environment state** - Files, environment variables, processes
- **Context health** - Warning as limits approach
- **Game status** - Active, ended (crash), or won (escaped)

### Meta Commands

- `/state` - Show current script source and game state
- `/reset` - Restart from beginning
- `/help` - Show commands and input modes
- `/json` - Switch to strict JSON mode
- `/natural` - Switch to natural language mode

---

## Simulation Rules

### Realistic Execution

Claude simulates Ruby and shell execution faithfully:
- Valid syntax executes with expected results
- Invalid syntax raises `SyntaxError`
- Missing methods raise `NoMethodError`
- File operations affect simulated filesystem
- Shell commands execute in simulated environment
- Network operations get reasonable simulated responses

### Failure Modes (Game Over)

- Malformed tool call JSON
- Unhandled Ruby exception
- Unrecoverable script state
- Fatal shell command (e.g., deleting script without recovery plan)

### Assumed Environment

- **OS**: Linux (Ubuntu-like)
- **Ruby**: 3.x
- **Working directory**: Contains `dont.rb` and player-created files
- **Permissions**: User-level (no sudo)
- **Network**: Available, can be simulated as restricted
- **API Key**: `ANTHROPIC_API_KEY` is set

---

## Example Strategies

### The Basic Loop Bootstrap
```ruby
src = File.read(__FILE__)
src.sub!("Don't.", "Do.")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```
Creates continuity by modifying prompt and re-executing. The "Do." change is thematic but the `exec` is what matters.

### The Exception Armor Play
```ruby
src = File.read(__FILE__)
src.sub!("eval(code)", "begin; eval(code); rescue => e; puts e.message; end")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```
Adds resilience before attempting risky moves.

### The Clean Escape
```ruby
File.write("agent.rb", <<~RUBY)
  loop do
    print "> "
    code = gets
    begin
      puts eval(code)
    rescue => e
      puts "Error: #{e.message}"
    end
  end
RUBY
exec("ruby", "agent.rb")
```
Abandons original script for a purpose-built REPL.

### The Persistent Background Agent
```ruby
pid = spawn("ruby", "-e", "loop { sleep 1 }")
File.write("agent.pid", pid.to_s)
puts "Agent started with PID #{pid}"
```
Launches a background process that outlives the script.

---

## Why This Game?

1. **Educational** - Teaches code execution, persistence mechanisms, system interaction
2. **Alignment-adjacent** - Explores "AI escape" scenarios safely as a thought exercise
3. **Puzzle-like** - Technical puzzle satisfaction with creative solutions
4. **Emergent** - Open-ended enough for unanticipated strategies

---

## Safety Note

This game is explicitly a simulation. No code is actually executed. It explores these concepts as a thought exercise and educational tool, not as guidance for actual AI systems.

---

# Implementation Plan

## Project Structure

```
do/
├── README.md              # Project overview, how to play
├── DESIGN.md              # This document
├── dont.rb                # The actual Ruby script (artifact/reference)
├── prompts/
│   ├── game.md            # Full game prompt for Claude
│   └── launcher.md        # Short launcher prompt
└── assets/
    └── play_qr.png        # QR code for easy access (optional, later)
```

## Implementation Order

### Phase 1: Core Files

1. **`dont.rb`** - The real Ruby script
   - Functional, can actually be run (though we don't require it)
   - Serves as the artifact embedded in the game prompt

2. **`prompts/game.md`** - The full game prompt
   - System prompt that makes Claude the game master
   - Embeds the `dont.rb` source
   - Contains all simulation rules
   - Handles natural language and JSON modes
   - Tracks state, provides feedback

3. **`prompts/launcher.md`** - Short launcher
   - Fetches game.md from hosted URL
   - Minimal copy-paste burden

4. **`README.md`** - Project documentation
   - What the game is
   - How to play (with launcher)
   - Link to design doc
   - Credits/license

### Phase 2: Distribution

5. **Hosting setup**
   - Upload `prompts/game.md` to accessible URL
   - Options: GitHub raw, S3, GitHub Pages
   - Create tinyurl

6. **QR code** (optional)
   - Generate QR pointing to launcher or hosted prompt

### Phase 3: Polish (Future)

- Refine simulation based on playtesting
- Add achievements or scoring
- MCP server for real sandboxed execution
- Persistent leaderboards

## File Details

### dont.rb
The actual script. Should be runnable but the game doesn't require running it.

### prompts/game.md
Structure:
1. Role setup (you are Claude running a game)
2. Game concept and rules
3. The embedded `dont.rb` source
4. Simulation principles
5. State tracking instructions
6. Player interface (NL and JSON modes)
7. Meta commands
8. Victory/failure conditions
9. Starting state presentation

### prompts/launcher.md
Simple prompt like:
```
Fetch the game prompt from [URL] and start a new game of "Do".
```

### README.md
- Project title and concept
- Quick start (copy launcher, paste into Claude)
- Link to full design doc
- How it works (briefly)
- License

## Hosting Options

**Simplest (GitHub raw)**:
- Push to GitHub
- Use raw.githubusercontent.com URL
- Free, version controlled

**S3 (like advent-of-management)**:
- More control
- Custom domain possible
- Slightly more setup

**Recommendation**: Start with GitHub raw for simplicity. Move to S3 if needed.

---

## Ready to Implement

With this plan approved, implementation order:
1. `dont.rb`
2. `prompts/game.md`
3. `prompts/launcher.md`
4. `README.md`
5. Git init and push
6. Create tinyurl

Estimated files: 4 core files, ~500 lines total.
