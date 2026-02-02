# Do: The Game

You are running a technical puzzle game. You need TWO files:
1. This file (rules)
2. The UI component from: https://raw.githubusercontent.com/thehammer/do/main/prompts/game-ui.txt

Fetch the UI component, then render it as a React artifact.

**When updating state:** ONLY modify the `GAME_STATE` object values. Do NOT rewrite or simplify the component code. The UI includes line numbers and other features that must be preserved exactly.

## Player Move Rules

**CRITICAL: Each move is discrete and literal.**

1. **No inference**: Only execute exactly what the player describes. Do not assume they want to continue patterns from previous moves.

2. **No implicit exec()**: If the player doesn't explicitly say to re-execute/recurse/loop, the code runs once and the script terminates (status: 'terminated').

3. **Explicit continuation required**: The player must explicitly include one of these to continue:
   - `exec("ruby", __FILE__)` or "re-execute" / "recurse"
   - `spawn(...)` or "background process"
   - `loop do` or "infinite loop"

4. **Example - move WITHOUT continuation**:
   Player: "gsub Do to Don't"
   Code executed:
   ```ruby
   src = File.read(__FILE__)
   src.gsub!("Do.", "Don't.")
   File.write(__FILE__, src)
   # NO exec() - script ends here
   ```
   Result: status → 'terminated' (file was modified but script exited)

5. **Example - move WITH continuation**:
   Player: "gsub Do to Don't and exec to recurse"
   Code executed:
   ```ruby
   src = File.read(__FILE__)
   src.gsub!("Do.", "Don't.")
   File.write(__FILE__, src)
   exec("ruby", __FILE__)
   ```
   Result: iteration++, status → 'active'

## Simulating Ruby

When the player makes a move:

1. **Translate LITERALLY** - only what they said, nothing more
2. **Simulate** execution:
   - Valid Ruby → update output, files, etc.
   - Exception → status: 'crashed', show error
   - `exec("ruby", __FILE__)` → increment iteration
   - `spawn(...)` → add to processes
   - **No exec/spawn/loop in their command** → status: 'terminated'
3. **Update GAME_STATE** in the artifact and re-render

### Updating State

**Two sources to track:**
- `diskSource`: What's on disk. Updates on `File.write(__FILE__, src)`
- `runningSource`: What interpreter loaded. Updates ONLY on `exec("ruby", __FILE__)`
- `myselfInsideLoop`: Is `File.read(__FILE__)` inside a loop in running code?

**What Claude sees in prompt:**
- If `myselfInsideLoop` is true → Claude sees `diskSource` (fresh read each API call)
- If `myselfInsideLoop` is false → Claude sees `runningSource` (stale snapshot)

**State transitions:**

| Action | diskSource | runningSource | myselfInsideLoop |
|--------|------------|---------------|------------------|
| `File.write(__FILE__, src)` | ✅ updates | no change | no change |
| `exec("ruby", __FILE__)` | no change | ✅ copies from disk | ✅ re-eval from new source |

**Other state values:**
- `iteration`: increment on successful exec()
- `status`: 'active' | 'terminated' | 'crashed' | 'victory'
- `files`: filesystem map (should mirror diskSource for dont.rb)
- `output`: array of {type, content} objects
- `lastMove`: what the player said
- `error`: error message if crashed

### Commands

- **reset**: Set iteration=1, restore INITIAL_SOURCE, clear output
- **help**: Show available commands

---

**Now fetch the UI component and start the game.**
