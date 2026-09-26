# Blackterio's Glide License Plates

License plate system for [Glide](https://github.com/StyledStrike/gmod-glide) vehicles.

## Adding plates to your Glide vehicle

Define `ENT.LicensePlateConfigs` in your vehicle's `shared.lua` (or inject it
server-side, see `lua/autorun/server/sv_glide_base_vehicles_plates.lua`):

```lua
ENT.LicensePlateConfigs = {
    {
        id = "front_main",              -- unique id per plate (optional, auto "plate_N")
        position = Vector(111.5, 0, -13), -- local to the vehicle
        angles = Angle(0, 0, 0),          -- local to the vehicle
        plateType = "argmercosur",        -- type id, group name, list of either, or "anytype"
        -- Optional overrides:
        -- customText = "MY PLATE",       -- fixed text instead of a random one
        -- customModel = "models/...",    -- custom plate model
        -- customSkin = 2,                -- skin override
        -- font = "Arial",                -- font override
        -- scale = 0.4,                   -- text scale override
        -- textColor = { r=0, g=0, b=0, a=255 },
        -- textOffset = Vector(0, 0, 0),  -- X=forward, Y=right(inverted), Z=up
        -- modelRotation = Angle(0, 0, 0),
    },
}
```

`plateType` accepts:
- A type id (e.g. `"argmercosur"`, `"usacalifornia"`, `"europegermany"`...)
- A group name (`"usaplates"`, `"europeplates"`, `"mercosurplates"`, `"argentinaplates"`,
  `"gtavplates"`, `"gtasaplates"`, `"gtaivplates"`, `"gtavandreasplates"`)
- A table mixing both: `{ "gtavplates", "usacalifornia" }` (one is picked at random)
- `"anytype"` for any registered type

## Hiding/moving plates with bodygroups

Define `ENT.LicensePlateAdvancedConfigs` to react to vehicle bodygroups
(e.g. a bumper that covers the plate):

```lua
ENT.LicensePlateAdvancedConfigs = {
    {
        id = "front_main",
        bodygroup = {3, 1},   -- { bodygroup index, submodel value }
        platetoggle = true,   -- hide the plate while active
        -- Or move it instead of hiding:
        -- newplateposition = Vector(...),
        -- newplateangles = Angle(...),
        -- newplatemodelRotation = Angle(...),
    },
}
```

Note: GMod/Glide provide no bodygroup-change hook, so changes are detected by
polling every 0.5 seconds. (`LicensePlateBodygroupConfigs`, the legacy key, is still
supported.)

## Attaching a plate to a bone

For plates on moving parts (a trunk lid, a tailgate...), add an entry with
`bone` to `ENT.LicensePlateAdvancedConfigs`. The plate follows that bone:

```lua
ENT.LicensePlateAdvancedConfigs = {
    { id = "rear_main", bone = "trunk" },  -- always active, no bodygroup needed
}
```

- `position`/`angles` stay in vehicle space, measured with the part closed.
- The bone must exist in the model with that exact name, or the plate stays
  on the vehicle (a warning is printed in the server console).
- The rest pose is read on the server, so the part must be animated
  client-side (pose parameters or bone manipulation on the client).

## Registering custom plate types from another addon

```lua
hook.Add("GlideLicensePlatesLoaded", "MyAddon.RegisterPlates", function()
    GlideLicensePlates.PlateTypes["mytype"] = {
        pattern = "AB 123 CD",  -- A-Z become random letters, 0-9 random digits
        model = "models/my/plate.mdl",
        description = "My plate (AB 123 CD)",
        defaultFont = "Arial",
        defaultTextColor = { r = 0, g = 0, b = 0, a = 255 },
        defaultScale = 0.37,
        defaultTextOffset = Vector(0, 0, 0),
        defaultSkin = 0,
    }
    GlideLicensePlates.PlateGroups["mygroup"] = { "mytype" }
end)
```

## Plate editor tool

The "License plate editor" tool (Glide category) edits text, type, color, offset,
skin and visibility per plate, plus its "Advanced Configuration": the bone it follows
and its bodygroup rules (hide/move, with a preview button). All tool edits are saved
with dupes and saves.
- Left click selects a vehicle; the plate closest to where you clicked is preselected.
- Reload (R) copies the selected vehicle's plate setup to the aimed vehicle (same model
  only). Plate texts are not copied.

Text behavior when changing the plate type:
- Manually-set text (typed in the tool or via `glide_change_plate`) is always preserved.
- Random (auto) text: if another auto plate of the vehicle already uses the new type,
  its text is reused (front/rear plates share one text); otherwise a new random text
  matching the new type's pattern is generated. `glide_random_plate` makes a plate
  "auto" again.

## ConVars

| ConVar | Realm | Default | Description |
|--------|-------|---------|-------------|
| `glide_license_plates_enabled` | client | 1 | Render license plates |
| `glide_license_plates_distance` | client | 500 | Plate render distance |
| `glide_plates_edit_mode` | server | 0 | Tool permissions: 0 = owner/admin, 1 = admins only, 2 = everyone |

## Console commands

- `glide_random_plate [plate_id]` — new random plate (vehicle owner/admin)
- `glide_change_plate <text> [plate_id]` — set plate text (admin)
- `glide_change_text_color <r> <g> <b> [a] [plate_id]` — set text color (admin)
- `glide_change_plate_skin <skin> [plate_id]` — set plate skin (admin)
- `glide_list_plates`, `glide_remove_plate <plate_id>`, `glide_recreate_plates`,
  `glide_debug_plate [plate_id]` — admin utilities

## Fonts

The addon ships `GL-Nummernschild-Mtl` (EU-style plates). The USA types default
to `Dealerplate California` and the old Argentina type to `coolvetica`: those
fonts are NOT bundled — if the client doesn't have them installed (or provided
by another addon), the text silently falls back to Arial. Bundle the TTFs in
`resource/fonts/` if their licenses allow it.
