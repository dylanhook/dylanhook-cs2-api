# Your first script

This adds a checkbox and a small label in the top-left corner. It works without
joining a game.

## Create a file

Open **misc > settings > lua**, then click **open lua folder**. Create `hello.lua` directly in that folder:

```text
%LOCALAPPDATA%\dylanhook\lua\scripts\hello.lua
```

Save the file as UTF-8. Make sure the filename really ends in `.lua`, not
`.lua.txt`.

## Add the script

Copy this into the file and save it:

```lua
local enabled = menu.lua.a:checkbox('hello', true, 'hello_enabled')
local background = color(10, 12, 19, 230)
local accent = color(255, 90, 170)
local caption = 'dylanhook / hello.lua'

on.paint(function()
    if not enabled.value then return end

    local width, height = render.measure_text(caption)
    render.rect(20, 20, width + 22, height + 16, background)
    render.rect(20, 20, 2, height + 16, accent)
    render.text(32, 28, caption, color.white)
end)
```

## Load it

Click **refresh**, select `hello.lua` and click **load**. The label appears on
screen. Open the **lua** tab and toggle **hello** to show or hide it.

`menu.lua.a` puts the checkbox in group **A**. The last argument,
`'hello_enabled'`, is its saved ID. Keep the ID if you rename the label.

`on.paint` runs once per rendered frame. The colors and caption are created
once when the file loads.

## Edit and reload

Change the caption and save the file. Loaded scripts reload automatically. Use
**reload** when you want to apply the file manually.

A failed reload leaves the previous version running. Fix the console error and
reload again.

**unload** stops the script and removes its controls. **delete** also removes the
source file.

Continue with [script basics](concepts.md), or load a complete [example](examples/README.md).
