# Sound

Play a game sound or a local WAV clip. Local clips use their own audio output and can be played from any active callback.

## sound.load_file

```text
sound.load_file(filename: string | number) -> sound_clip | nil
```

Loads a WAV file from the script's [asset folder](resources.md#folders). Call while
loading or in a render-side callback. Playback reuses the decoded samples and
does not open the file again.

For `example.lua`, put `chime.wav` in `example.assets` beside the script:

```lua
local chime = sound.load_file("chime.wav")
assert(chime, why.last())

menu.lua.a:button("play chime", function()
    if not chime:play(0.2) then
        console.warn(why.last() or "sound unavailable")
    end
end)
```

| Resource | Limit |
| --- | --- |
| Format | RIFF/WAVE, uncompressed 16-bit PCM, mono or stereo. |
| Sample rate | 8,000-192,000 Hz. |
| Duration | Up to 10 seconds. |
| File | Up to 4 MiB. Ordinary asset filename rules apply. |
| Live clips | 16 per script. |
| Decoded samples | 8 MiB total per script. |
| Each load attempt | 128 native work units. |

Compressed WAV, floating-point WAV, extensible WAV, MP3 and other formats are not supported. A missing file, malformed audio or an exhausted resource limit returns `nil` and records `why.last()`. Invalid argument types, an unsupported callback context and an exhausted work allowance raise an error.

The returned clip owns its samples. Changing the file does not change an already loaded clip. Reload the script to load the new version. Unsafe-script permission is not required.

## sound_clip.duration

```text
sound_clip.duration: number | nil
```

The clip's duration in seconds. Available while loading and in any callback. After release, returns `nil` and records `why.last()`.

## sound_clip:play

```text
sound_clip:play(volume: number = 1) -> true | nil
```

Plays the loaded clip once. Available in any active callback, including buttons, timers and paint. It raises an error during source loading. `volume` must be finite and between `0` and `1`; `0` submits a silent clip, while `1` uses the file's recorded level.

Returns `true` when submitted, or `nil` if the handle is released, audio output is unavailable or every playback voice is busy. Read `why.last()` immediately for the failure. Invalid volume raises an error. Each attempt on a live clip costs 64 native work units.

Four playback voices are shared with the built-in local audio output. A busy output refuses the new clip instead of interrupting another sound or building a queue. Calling from paint plays once per call, so use an event, button or a one-shot condition for notifications.

Submission does not prove the sound was audible. Device volume, a silent file or a volume of zero can make a successful submission inaudible.

## sound_clip:release

```text
sound_clip:release()
```

Releases the loaded clip and returns its resource slot. Repeated calls are harmless. Clips are also released on garbage collection and script unload.

A sound already submitted finishes using its own sample copy. Release prevents future playback. It does not stop an existing sound. This method is available while loading and in any callback. Unknown clip fields return `nil`. Assigning a field raises an error.

## sound.play_game

```text
sound.play_game(path: string | number, gain: number) -> true
```

Submits the sound immediately. Call it from [`on.game_event`](../events.md#ongame_event) or [`on.frame_stage`](../events.md#onframe_stage). It raises an error in every other context, including loading and timers.

```lua
on.game_event("round_start", function()
    sound.play_game("sounds/ui/laptop_click_01", 0.15)
end)
```

| Parameter | Meaning |
| --- | --- |
| `path` | An extensionless resource name beginning with `sounds/`, up to 255 bytes. |
| `gain` | A required finite number from `0` through `0.5`. There is no default. |

Use forward slashes and printable ASCII characters. The path must have a nonempty name after `sounds/`, with no empty segments, `.` or `..` segments, trailing slash, or dot in its final segment. Backslashes, colons, `*`, `?`, double quotes, `<`, `>`, and `|` are refused. The game adds the sound extension.

Returns `true` when the playback request completes. This does not confirm that the named resource exists or that a sound was audible.

Each call uses 64 units from the callback's active [native work policy](../limits.md). Other work in the same callback uses that allowance too.

Invalid types, an oversized path, an embedded NUL, a non-finite gain, the wrong callback, or an exhausted allowance raise a Lua error. Other failures raise `game sound refused: <reason>`:

| Reason | Meaning |
| --- | --- |
| `path_empty` | The path is empty. |
| `path_not_canonical` | The path does not follow the resource-name rules above. |
| `path_has_extension` | The final path segment contains a dot. |
| `gain_out_of_range` | The gain is outside `0`-`0.5`. |
| `unavailable` | Game sound playback is unavailable. |
| `gain_format_failed` | The gain could not be prepared for playback. |
| `engine_fault` | The game failed while handling the playback request. |

Failures do not update [`why.last()`](why.md#whylast).
