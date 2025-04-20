# Editor completion

Download [dylanhook.d.lua](dylanhook.d.lua) and place it in a
\`.dylanhook-api\` folder inside your script project. The file is for LuaLS
completion only. Do not load it as a script.

Add the library to \`.luarc.json\`:

\`\`\`json
{
  "runtime.version": "LuaJIT",
  "workspace.library": [".dylanhook-api"],
  "workspace.checkThirdParty": false
}
\`\`\`

Merge these keys with any LuaLS settings you already use.

The definitions include public modules, functions, userdata members, properties,
named keys and menu destinations. Runtime-only values such as schema paths still
depend on the game and are not generated as editor fields.

Autocomplete does not validate callback context or runtime availability. Use the
API reference for those rules.
