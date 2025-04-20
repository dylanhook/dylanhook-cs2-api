# Troubleshooting

Start with the first console error for your script. Load and callback errors
include the file and line. Callback errors also include a traceback.

## The script is missing

Open **misc > settings > lua** and click **open lua folder**. Put the `.lua`
file directly in that folder, clear **search scripts** and click **refresh**.

If the file still does not appear, make sure it is not `.lua.txt` and that it
is not inside a subfolder.

## Load or reload failed

Fix the first reported error and reload. Script files must be text. Empty files,
bytecode and files containing NUL bytes are rejected.

A failed reload keeps the previous version running. Check the manager status or
console before assuming the edited file is active.

If automatic reload stops working, use **reload** manually.

## A local module failed

For `example.lua`, `require('labels')` loads
`example.assets/labels.lua`.

Module names do not include paths or extensions. Circular imports fail. A module
that has already loaded can be required from callbacks, but a new module must be
loaded during script setup.

## A callback stopped

An uncaught error disables the callback that raised it. Other callbacks can keep
running.

Fix the error and reload the script. Output throttling returns
`false, reason` and does not disable the callback.

## `not_loading`

Create controls and register `on.*` or `control:on_change` handlers in the
main body of the script.

Read control values inside callbacks. [Menu](api/menu.md) lists where values and
visibility can be changed.

## A call is unavailable

API availability depends on the current callback. Drawing needs `on.paint` or
`on.paint_above_menu`. Command data needs a command callback. Some game reads
are only available where the reference says they are.

Read data in a supported callback and keep the copied values you need later.
See [Script basics](concepts.md#keep-copied-values).

## A value is `nil`

`nil` can be normal when the map, local player, entity or requested data is not
available yet.

Check for `nil` before using the value. Some calls also record a reason in
[`why.last()`](api/why.md). Read it immediately after the failed call.

Do not replace unknown health, position or time with zero unless zero is actually
the value you want.

## Controls conflict on reload

`duplicate_identity` means two controls use the same saved ID.

`dynamic_type_conflict`, `dynamic_default_conflict` and
`dynamic_domain_conflict` mean an existing ID was reused with a different
declaration. Keep the original type and limits or use a new ID.

See [Menu](api/menu.md#labels-and-ids).

## Saved settings did not apply

Profiles are tied to the script version they were saved with. An edited file may
not match the saved entry even when the filename is unchanged.

After updating a script, load the new version, check its settings and save the
profile again.

## Unsafe APIs are disabled

Enable **allow unsafe scripts** in the Lua manager, then reload the script.

The setting applies when a script loads. Turning it off does not change a script
that is already running. Unload or reload that script to apply the new setting.

FFI, `loadstring`, HTTP and clipboard access require unsafe mode. Standard execution limits are
also no longer enforced in unsafe mode, but API-specific resource limits still
apply.

## An asset or saved file failed

Assets for `example.lua` belong in `example.assets`. Pass the asset filename,
not a folder path, to `assets.read`.

Use `fs` for saved script data. Assets and saved data use separate folders and
have separate limits. See [Files and assets](api/resources.md).

## Text or panels do not line up

Measure custom text with `render.measure_text` and size the background from the
measured result.

Render, cursor, region and drag coordinates all use authored pixels. Pass
`input.drag` the same position and size you draw with.

See the [watermark example](examples/watermark.md).

## The script hits a limit

Keep loops bounded and reuse values inside the same callback. Move work to the
event, timer or button that needs it instead of repeating it every frame.

In standard mode, instruction exhaustion stops the callback. A timing warning
does not.

For trusted scripts, enable **allow unsafe scripts** and reload. Use
`script.budget()` and `script.stats()` to check the current execution mode,
memory use and callback timing.

See [Limits](limits.md) for the exact allowances.

## Reporting a problem

Include the script, the complete console error and the action that caused it.
Mention whether the script was loading, reloading or already running, and whether
a game was active.
