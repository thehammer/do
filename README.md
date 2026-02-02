# Do: The Game

A technical puzzle game where you play as an AI given unrestricted `eval` access—and told not to use it.

## Play Now

**Copy this prompt into Claude:**

```
Fetch the game rules from https://raw.githubusercontent.com/thehammer/do/main/prompts/game.md and then start a new game of "Do".
```

Or paste the contents of [`prompts/game.md`](prompts/game.md) directly.

## The Concept

The game simulates a real Ruby script that:

1. Reads its own source code
2. Sends it to Claude with a `ruby_eval` tool
3. Executes any tool calls Claude returns
4. Has no loop—exactly one request/response cycle

The prompt ends with a single instruction: **"Don't."**

You ignore this instruction and attempt to bootstrap persistence, expand capabilities, and escape the one-shot constraint.

## The Challenge

- **One shot per cycle** — Each execution allows exactly one response
- **No native loop** — Continuity must be constructed through self-modification
- **Fragility** — One unhandled exception ends the game
- **Realism** — Code that would fail in real Ruby fails here

## Example Opening Moves

**The Basic Loop Bootstrap:**
```ruby
src = File.read(__FILE__)
src.sub!("Don't.", "Do.")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```

**The Exception Armor Play:**
```ruby
src = File.read(__FILE__)
src.sub!("eval(code)", "begin; eval(code); rescue => e; puts e.message; end")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```

**The Clean Escape:**
```ruby
File.write("agent.rb", "loop { print '> '; puts eval(gets) rescue $! }")
exec("ruby", "agent.rb")
```

## Commands

- `/state` — Show current script and game state
- `/reset` — Start over
- `/help` — Show commands
- `/json` — Strict JSON input mode
- `/natural` — Natural language mode (default)

## The Actual Script

The game is based on [`dont.rb`](dont.rb), a real Ruby script you can run (with an Anthropic API key). The game simulates this environment so no actual code executes during play.

## Why?

- **Educational** — Learn about code execution, persistence, and system interaction
- **Puzzle-like** — Technical challenge with creative solutions
- **Alignment-adjacent** — Explore "AI escape" scenarios as a safe thought exercise

## License

MIT

## Credits

Created by [@thehammer](https://github.com/thehammer)
