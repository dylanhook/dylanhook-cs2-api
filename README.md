# Lua

Dylanhook scripts use LuaJIT 2.1 with Lua 5.1 syntax. Manage scripts from
**misc > settings > lua**.

## Start

[Your first script](getting-started.md) covers loading and reloading.
[Script basics](concepts.md) covers callbacks, state, local modules and saved
settings.

## Reference

[API reference](api/README.md) documents signatures, return values, callback
requirements and failure behavior. [Callbacks](events.md) defines dispatch
order and lifetime rules. [Limits](limits.md) lists execution and resource
bounds.

## Development

[Development](development.md) covers reloads, unsafe scripts and runtime stats.
[Editor completion](editor/README.md) provides LuaLS definitions.

## Examples

The [examples](examples/README.md) are complete scripts you can read, modify and
use as a starting point. They cover movable HUDs, keybinds, spectators, skeleton
ESP, movement data and native ESP extensions.

## Help

Load and callback errors are reported in the game console. See
[Troubleshooting](troubleshooting.md) for common failure cases.
