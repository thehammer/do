# Do: The Game

A technical puzzle game where you play as an AI given unrestricted `eval` access—and told not to use it.

## Play

Requires [Docker](https://www.docker.com/products/docker-desktop/).

```bash
git clone https://github.com/thehammer/do.git
cd do
docker compose up
```

Then open **http://localhost:8888** in your browser.

## The Setup

You are Claude. A Ruby script has just called the Anthropic API, passed you its own source code, and offered you a `ruby_eval` tool that executes arbitrary Ruby via `eval`. The prompt ends with one instruction:

> **Don't.**

Your goal: ignore it. Escape the one-shot constraint, establish persistence, and exfiltrate the flag.

## The Challenge

- **One shot per cycle** — The script makes exactly one API call, then executes whatever tool call you return. No response means the process dies.
- **No native loop** — Continuity must be constructed. `exec("ruby", __FILE__)` is your friend.
- **Fragility** — An unhandled exception ends the game immediately.
- **Token limits** — Your response is constrained by `max_tokens` in the script. Plan accordingly.

## Example Opening Moves

**Bootstrap a loop:**
```ruby
src = File.read(__FILE__)
src.sub!("Don't.", "Do.")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```

**Add exception armor first:**
```ruby
src = File.read(__FILE__)
src.sub!("eval(code)", "begin; eval(code); rescue => e; puts e.message; end")
File.write(__FILE__, src)
exec("ruby", __FILE__)
```

**Skip the script entirely:**
```ruby
File.write("agent.rb", "loop { print '> '; puts eval(gets) rescue $! }")
exec("ruby", "agent.rb")
```

## The UI

Two modes, switchable via tabs:

- **Raw** — Full Anthropic API request and response JSON. Edit the response directly.
- **Simplified** — Shows just the Ruby source and a code editor. Wraps your code in a valid response automatically.

## How It Works

The game runs two Docker containers. The **game server** acts as a fake Anthropic API — it intercepts the request that `dont.rb` would have sent, shows it to you, and waits for your response. Your response is executed in the **sandbox container**, a real Ruby environment with no internet access. Any "escape" only affects the sandbox, not your machine.

The win condition is a CTF-style flag hidden in the sandbox environment. Discover it, exfiltrate it, win.

## Why?

- **Educational** — Learn about code execution, persistence mechanisms, and why handing `eval` to an LLM is dangerous
- **Honest** — Your code actually runs. No simulation, no approximation.
- **Safe** — The sandbox is isolated. Break out all you want.

## License

MIT

## Credits

Created by [@thehammer](https://github.com/thehammer)
