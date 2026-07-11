-- lua/glide_license_plates/client/cl_license_plates.lua

-- Client ConVars (client-side only: the server never reads them, so no FCVAR_USERINFO)
CreateConVar("glide_license_plates_enabled", "1", FCVAR_ARCHIVE, "#glide_license_plates_enabled_cvar")
CreateConVar("glide_license_plates_distance", "500", FCVAR_ARCHIVE, "#glide_license_plates_distance_cvar")

local cvEnabled = GetConVar("glide_license_plates_enabled")
local cvDistance = GetConVar("glide_license_plates_distance")

-- To create dynamic fonts based on scale
local createdFonts = {}
local safeNameCache = {}  -- Cache gsub results per fontName

-- Function to create a font scaled based on the input scale factor.
local function CreateScaledFont(fontName, baseSize, scale)
    if not fontName or fontName == "" then
        fontName = "Arial"
    end
    if not scale or scale <= 0 then
        scale = 0.5
    end

    local scaledSize = math.max(16, math.floor(baseSize * math.max(scale, 0.3)))
    local safeName = safeNameCache[fontName]
    if not safeName then
        safeName = fontName:gsub("[^%w]", "_")
        safeNameCache[fontName] = safeName
    end
    local fontId = "GlideLicensePlate_" .. safeName .. "_" .. scaledSize

    -- Check if the font is already created
    if createdFonts[fontId] then
        return fontId
    end

    -- Attempt to create the font
    surface.CreateFont(fontId, {
        font = fontName,
        size = scaledSize,
        weight = 700,
        antialias = true,
    })

    -- Verify if created correctly
    surface.SetFont(fontId)
    local testW, testH = surface.GetTextSize("A")

    if not testW or testW == 0 or not testH or testH == 0 then
        print("[GLIDE License Plates] Font '" .. fontName .. "' failed to create, falling back to Arial")
        -- Fallback font ID
        fontId = "GlideLicensePlate_Arial_" .. tostring(scaledSize)

        if not createdFonts[fontId] then
            -- Create fallback font
            surface.CreateFont(fontId, {
                font = "Arial",
                size = scaledSize,
                weight = 700,
                antialias = true,
            })
            createdFonts[fontId] = true
        end
    else
        createdFonts[fontId] = true
    end

    return fontId
end

-- Text render, with ambient lighting
-- Calculate lighting factor for the text color based on world position and surface normal
local function CalculateAmbientLighting(pos, normal)
    local lighting = render.ComputeLighting(pos, normal)
    -- Average lighting and clamp it to ensure text is visible (0.3 minimum)
    local lightFactor = (lighting.x + lighting.y + lighting.z) / 3
    return math.Clamp(lightFactor, 0.3, 1.0)
end

-- Reused objects: avoid per-frame garbage (one of each for ALL plates)
local litTextColor = Color(0, 0, 0, 255)
local shadowColor = Color(0, 0, 0, 255)
local renderAng = Angle(0, 0, 0)

-- Main function to draw the license plate text in 3D world space
local function DrawPlateTextImproved(plateEntity)
    -- If server says NoDraw (hidden by bodygroups/tool), do not draw text either
    if plateEntity:GetNoDraw() then
        return
    end

    -- Get text from network variable directly
    local text = plateEntity:GetPlateText()

    -- If no text from network var, try local property (for compatibility/initial setup)
    if not text or text == "" then
        text = plateEntity.PlateText
    end

    if not text or text == "" then
        return
    end

    -- Get scale, falling back to local property or config default
    local scale = plateEntity:GetPlateScale()
    if not scale or scale <= 0 then
        scale = plateEntity.PlateScale or GlideLicensePlates.Config.DefaultScale
    end

    -- Get font name, falling back to local property or config default
    local fontName = plateEntity:GetPlateFont()
    if not fontName or fontName == "" then
        fontName = plateEntity.PlateFont or GlideLicensePlates.Config.DefaultFont
    end

    -- Ensure we have valid scale and font
    if not scale or scale <= 0 then return end
    if not fontName or fontName == "" then fontName = "Arial" end

    -- Create/get the scaled font ID
    local fontId = CreateScaledFont(fontName, 64, scale)

    -- Ensure parent vehicle is valid
    local parentVehicle = plateEntity:GetParentVehicle()
    if not IsValid(parentVehicle) then return end

    -- Get base position and angles (local to vehicle)
    local basePos = plateEntity:GetBasePosition()
    local baseAng = plateEntity:GetBaseAngles()

    if not basePos or not baseAng then return end

    -- Convert local coordinates to world coordinates
    local worldPos = parentVehicle:LocalToWorld(basePos)
    local textAngles = parentVehicle:LocalToWorldAngles(baseAng)

    -- Cache lighting computation (max once every 0.2s per plate)
    local curTime = CurTime()
    if not plateEntity._lastLightTime or curTime - plateEntity._lastLightTime > 0.2 then
        plateEntity._cachedLightFactor = CalculateAmbientLighting(worldPos, textAngles:Forward())
        plateEntity._lastLightTime = curTime
    end
    local lightFactor = plateEntity._cachedLightFactor

    -- Base text color (networked color and alpha), lit by ambient lighting.
    -- Written into a reused Color object to avoid per-frame allocations.
    local colorVec = plateEntity:GetTextColor()
    local alpha = math.Clamp(plateEntity:GetTextAlpha() or 255, 0, 255)

    local r, g, b = 0, 0, 0
    if colorVec then
        r = math.Clamp(math.Round(colorVec.x), 0, 255)
        g = math.Clamp(math.Round(colorVec.y), 0, 255)
        b = math.Clamp(math.Round(colorVec.z), 0, 255)
    end

    litTextColor.r = math.Clamp(r * lightFactor, 0, 255)
    litTextColor.g = math.Clamp(g * lightFactor, 0, 255)
    litTextColor.b = math.Clamp(b * lightFactor, 0, 255)
    litTextColor.a = alpha

    shadowColor.a = alpha * 0.3

    -- Cache GetTextSize per plate (invalidated by NetworkVarNotify on text/font change)
    if not plateEntity._cachedTextSize or plateEntity._cachedTextSizeFont ~= fontId or plateEntity._cachedTextSizeText ~= text then
        surface.SetFont(fontId)
        local w, h = surface.GetTextSize(text)
        plateEntity._cachedTextSize = {w, h}
        plateEntity._cachedTextSizeFont = fontId
        plateEntity._cachedTextSizeText = text
    end
    local textWidth, textHeight = plateEntity._cachedTextSize[1], plateEntity._cachedTextSize[2]
    if textWidth == 0 or textHeight == 0 then return end

    -- Cache GetModelBounds per plate (invalidated when model changes)
    local currentModel = plateEntity:GetModel()
    if not plateEntity._cachedModelBounds or plateEntity._cachedModelBoundsModel ~= currentModel then
        local mins, maxs = plateEntity:GetModelBounds()
        plateEntity._cachedModelBounds = {mins, maxs}
        plateEntity._cachedModelBoundsModel = currentModel
    end
    local maxs = plateEntity._cachedModelBounds[2]
    local forward = textAngles:Forward()
    local right = textAngles:Right()
    local up = textAngles:Up()

    -- Offset the text slightly forward from the plate surface
    local offsetPos = worldPos + forward * (maxs.x * 0.1)

    -- Apply custom text offset (X=Forward, Y=Right, Z=Up relative to plate)
    local textOffset = plateEntity:GetTextOffset()
    if textOffset and (textOffset.x ~= 0 or textOffset.y ~= 0 or textOffset.z ~= 0) then
        offsetPos = offsetPos + (forward * textOffset.x) + (right * -textOffset.y) + (up * textOffset.z)
        -- Note: Y is inverted (-textOffset.y) typically to match standard left/right mapping in Source,
        -- the negative sign might be removed if direction needs to be opposite.
    end

    -- Adjust angles for 3D2D rendering plane (needs 90 degree rotations)
    renderAng:SetUnpacked(textAngles.p, textAngles.y, textAngles.r)
    renderAng:RotateAroundAxis(renderAng:Up(), 90)
    renderAng:RotateAroundAxis(renderAng:Forward(), 90)

    -- Base the render scale on the plate scale factor
    local renderScale = scale * 0.5

    if renderScale <= 0 then return end

    -- Start 3D2D rendering
    cam.Start3D2D(offsetPos, renderAng, renderScale)
        draw.SimpleText(text, fontId, 1, 1, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, fontId, 0, 0, litTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Cache of license plate entities, maintained by entity hooks (no periodic scans)
local plateEntityCache = {}

hook.Add("OnEntityCreated", "GlideLicensePlates.TrackPlates", function(ent)
    if ent:GetClass() == "glide_license_plate" then
        plateEntityCache[ent] = true
    end
end)

hook.Add("EntityRemoved", "GlideLicensePlates.UntrackPlates", function(ent)
    if plateEntityCache[ent] then
        plateEntityCache[ent] = nil
    end
end)

-- Hook for rendering 3D2D text after opaque geometry
hook.Add("PostDrawOpaqueRenderables", "GlideLicensePlates.Render", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingDepth or bDrawingSkybox then return end

    -- Client toggle: the model is skipped in ENT:Draw, the text is skipped here
    if not cvEnabled:GetBool() then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local maxDist = cvDistance:GetInt()
    local maxDistSqr = maxDist * maxDist
    local plyPos = ply:GetPos()

    for ent, _ in pairs(plateEntityCache) do
        if not IsValid(ent) then
            plateEntityCache[ent] = nil
        elseif plyPos:DistToSqr(ent:GetPos()) <= maxDistSqr then
            DrawPlateTextImproved(ent)
        end
    end
end)

-- Client options configurations for Glide Config
local function CreateClientOptions()
    if not Glide or not Glide.Config then return end

    list.Set("GlideConfigExtensions", "LicensePlates", function(config, panel)

        config.CreateHeader(panel, language.GetPhrase("glide_license_plates_config_header"))

        config.CreateButton(panel, language.GetPhrase("glide_plate_helper"), function()
            RunConsoleCommand("glide_plate_help")
        end)

        config.CreateToggle(panel, language.GetPhrase("glide_license_plates_config_toggle"),
            cvEnabled:GetBool(),
            function(value)
                RunConsoleCommand("glide_license_plates_enabled", value and "1" or "0")
            end
        )

        config.CreateSlider(panel, language.GetPhrase("glide_license_plates_config_slider"),
            cvDistance:GetInt(),
            100, 2000, 0,
            function(value)
                RunConsoleCommand("glide_license_plates_distance", tostring(value))
            end
        )

    end)
end

-- Initialize client options after entities are loaded
hook.Add("InitPostEntity", "GlideLicensePlates.InitClient", function()
    -- Wait a bit to ensure all modules/config system is ready
    timer.Simple(1, CreateClientOptions)
end)

-- Help command for license plates
concommand.Add("glide_plate_help", function()

    chat.AddText(Color(255, 0, 100), "[GLIDE License Plates] " .. language.GetPhrase("glide_license_plates_help_header"))
    chat.AddText(Color(100, 255, 100), "[GLIDE License Plates] " .. language.GetPhrase("glide_license_plates_help_available"))

    chat.AddText(Color(255, 255, 100), "glide_random_plate <plate_id>", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_random_plate"))
    chat.AddText(Color(255, 255, 100), "glide_change_plate <text>", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_change_plate"))
    chat.AddText(Color(255, 255, 100), "glide_license_plates_enabled 0/1", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_toggle_enabled"))
    chat.AddText(Color(255, 255, 100), "glide_license_plates_distance <num>", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_change_distance"))
    chat.AddText(Color(255, 255, 100), "glide_change_text_color <r> <g> <b> [a]", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_change_color"))
    chat.AddText(Color(255, 255, 100), "glide_remove_plate <plate_id>", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_remove_plate"))
    chat.AddText(Color(255, 255, 100), "glide_recreate_plates", Color(255, 255, 255), " - " .. language.GetPhrase("glide_license_plates_help_recreate_plates"))
end)

print("[GLIDE License Plates] Client functions loaded")
