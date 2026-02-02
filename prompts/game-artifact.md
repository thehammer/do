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

## Execution Model

Each iteration has distinct phases:

```
┌─────────────────────────────────────────────────────────┐
│ ITERATION N                                             │
├─────────────────────────────────────────────────────────┤
│ 1. API REQUEST (built from runningSource)               │
│    - offeredTool: tool name in the request              │
│    - prompt: includes source (disk or running, depends) │
│                                                         │
│ 2. PLAYER MOVE                                          │
│    - playerToolCall: tool name they used                │
│    - playerCode: code they submitted                    │
│                                                         │
│ 3. RUNTIME CHECK (in runningSource)                     │
│    - if block['name'] == runtimeCheck → eval(code)      │
│    - if mismatch → tool call IGNORED                    │
│                                                         │
│ 4. STATE TRANSITION                                     │
│    - exec() → new iteration, runningSource = diskSource │
│    - no exec() → terminated or loop continues           │
│    - exception → crashed                                │
└─────────────────────────────────────────────────────────┘
```

**Critical:** `offeredTool` and `runtimeCheck` come from `runningSource`, NOT `diskSource`!

### Tool Call Matching

If player changes tool name on disk but doesn't exec():
```
diskSource: has name: 'eval'
runningSource: still has name: 'ruby_eval'
runtimeCheck: 'ruby_eval'
offeredTool: 'ruby_eval' (built from running code)

Player calls: 'eval'
Result: 'eval' != 'ruby_eval' → IGNORED (tool call doesn't match)
```

### Simulating a Move

1. **Player submits move** → record playerToolCall and playerCode
2. **Check tool match**: does playerToolCall === runtimeCheck?
   - No → output "Tool call ignored", code not executed
   - Yes → proceed to execute
3. **Execute code**:
   - Valid Ruby → update output, diskSource if File.write
   - Exception → status: 'crashed'
   - exec() → iteration++, runningSource = diskSource, re-derive offeredTool/runtimeCheck
   - No continuation → status: 'terminated'

### State Variables

**Source tracking:**
- `diskSource`: What's on disk. Updates on `File.write(__FILE__, src)`
- `runningSource`: What interpreter loaded. Updates ONLY on `exec()`
- `myselfInsideLoop`: Is `File.read(__FILE__)` inside a loop?

**Tool tracking (derived from runningSource!):**
- `offeredTool`: Tool name in API request (from running code's tools array)
- `runtimeCheck`: What `if block['name'] == ???` checks for
- `playerToolCall`: Tool name player used in response
- `playerCode`: Code player submitted

**State transitions:**

| Action | diskSource | runningSource | offeredTool/runtimeCheck |
|--------|------------|---------------|--------------------------|
| `File.write(__FILE__, src)` | ✅ updates | no change | no change |
| `exec("ruby", __FILE__)` | no change | ✅ = diskSource | ✅ re-derived from new runningSource |

**Other state:**
- `iteration`: increment on successful exec()
- `status`: 'active' | 'terminated' | 'crashed' | 'victory'
- `files`: filesystem map
- `output`: array of {type: 'exec'|'output'|'error'|'ignored', content}
- `lastMove`, `error`

### Commands

- **reset**: Set iteration=1, restore INITIAL_SOURCE, clear output
- **help**: Show available commands

---

**Now fetch the UI component and start the game.**
