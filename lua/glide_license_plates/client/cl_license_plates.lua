-- lua/glide_license_plates/client/cl_license_plates.lua

local defaultTextColor = Color(0, 0, 0, 255)

-- To create dynamic fonts based on scale
local createdFonts = {}

local function CreateScaledFont(fontName, baseSize, scale)
    if not fontName or fontName == "" then 
        fontName = "Arial"
    end
    if not scale or scale <= 0 then 
        scale = 0.5 
    end
    
    local scaledSize = math.max(16, math.floor(baseSize * math.max(scale, 0.3)))
    local fontId = "GlideLicensePlate_" .. fontName:gsub("[^%w]", "_") .. "_" .. tostring(scaledSize)
    
    if createdFonts[fontId] then
        return fontId
    end
    
    surface.CreateFont(fontId, {
        font = fontName,
        size = scaledSize,
        weight = 700,
        antialias = true,
        shadow = false,
        extended = false
    })
    
    -- Verify if created correctly
    surface.SetFont(fontId)
    local testW, testH = surface.GetTextSize("A")
    
    if not testW or testW == 0 or not testH or testH == 0 then
        print("[GLIDE License Plates] Font '" .. fontName .. "' failed to create, falling back to Arial")
        fontId = "GlideLicensePlate_Arial_" .. tostring(scaledSize)
        
        if not createdFonts[fontId] then
            surface.CreateFont(fontId, {
                font = "Arial",
                size = scaledSize,
                weight = 700,
                antialias = true,
                shadow = false,
                extended = false
            })
            createdFonts[fontId] = true
        end
    else
        createdFonts[fontId] = true
    end
    
    return fontId
end

-- Text render, with ambient lighting
local function CalculateAmbientLighting(pos, normal)
    local lighting = render.ComputeLighting(pos, normal)
    local lightFactor = (lighting.x + lighting.y + lighting.z) / 2
    lightFactor = math.Clamp(lightFactor, 0.3, 1.0)
    return lightFactor
end

local function DrawPlateTextImproved(plateEntity)
    if not IsValid(plateEntity) then return end
    
    -- Get text from network variable directly
    local text = plateEntity:GetPlateText()
    
    -- DEBUG: If no text from network var, try local property
    if not text or text == "" then
        text = plateEntity.PlateText
    end
    
    if not text or text == "" then 
        return 
    end
    
    local scale = plateEntity:GetPlateScale()
    if not scale or scale <= 0 then
        scale = plateEntity.PlateScale or GlideLicensePlates.Config.DefaultScale
    end
    
    local fontName = plateEntity:GetPlateFont()
    if not fontName or fontName == "" then
        fontName = plateEntity.PlateFont or GlideLicensePlates.Config.DefaultFont
    end
    
    -- Ensure we have valid scale and font
    if not scale or scale <= 0 then return end
    if not fontName or fontName == "" then fontName = "Arial" end
    
    local fontId = CreateScaledFont(fontName, 64, scale)
    
    -- Get color with proper fallback chain
    local baseTextColor = Color(0, 0, 0, 255)
    
    local colorVec = plateEntity:GetTextColor()
    local alpha = plateEntity:GetTextAlpha()
    
    if colorVec then
        baseTextColor = Color(
            math.Clamp(math.Round(colorVec.x), 0, 255),
            math.Clamp(math.Round(colorVec.y), 0, 255),
            math.Clamp(math.Round(colorVec.z), 0, 255),
            math.Clamp(alpha or 255, 0, 255)
        )
    end
    
    local parentVehicle = plateEntity:GetParentVehicle()
    if not IsValid(parentVehicle) then return end
    
    local basePos = plateEntity:GetBasePosition()
    local baseAng = plateEntity:GetBaseAngles()
    
    if not basePos or not baseAng then return end
    
    local worldPos = parentVehicle:LocalToWorld(basePos)
    local textAngles = parentVehicle:LocalToWorldAngles(baseAng)
    
    -- Calculate lighting
    local lightFactor = CalculateAmbientLighting(worldPos, textAngles:Forward())
    
    local litTextColor = Color(
        math.Clamp(baseTextColor.r * lightFactor, 0, 255),
        math.Clamp(baseTextColor.g * lightFactor, 0, 255),
        math.Clamp(baseTextColor.b * lightFactor, 0, 255),
        baseTextColor.a
    )
    
    surface.SetFont(fontId)
    local textWidth, textHeight = surface.GetTextSize(text)
    if textWidth == 0 or textHeight == 0 then return end
    
    local mins, maxs = plateEntity:GetModelBounds()
    local forward = textAngles:Forward()
	local right = textAngles:Right() 
    local up = textAngles:Up()   

    local offsetPos = worldPos + forward * (maxs.x * 0.1)    
	
 -- Apply custom text offset (X=Forward, Y=Right, Z=Up relative to plate)
    local textOffset = plateEntity:GetTextOffset()
    if textOffset and textOffset ~= Vector(0,0,0) then
        offsetPos = offsetPos + (forward * textOffset.x) + (right * -textOffset.y) + (up * textOffset.z)
        -- Note: Y is inverted (-textOffset.y) typically to match standard left/right mapping in Source, 
        -- remove minus if direction is opposite to desired.
    end   
	
    local renderAng = Angle(textAngles.p, textAngles.y, textAngles.r)
    renderAng:RotateAroundAxis(renderAng:Up(), 90)
    renderAng:RotateAroundAxis(renderAng:Forward(), 90)
    
    -- FIXED: Better scale calculation
    -- Use the actual model dimensions and scale value directly
    local modelWidth = math.abs(maxs.y - mins.y)
    local modelHeight = math.abs(maxs.z - mins.z)
    
    -- Base the render scale on matching text width to model width
    -- Divide by a smaller value to reduce text size (was 0.08, now 0.012)
    local renderScale = scale * 0.5
    
    if renderScale <= 0 then return end
    
    local success = pcall(function()
        cam.Start3D2D(offsetPos, renderAng, renderScale)
            -- Slight Shadow
            draw.SimpleText(text, fontId, 0, 0, Color(0, 0, 0, litTextColor.a * 0.3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- Main text
            draw.SimpleText(text, fontId, 0, 0, litTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)
end

-- Client variables
CreateConVar("glide_license_plates_enabled", "1", FCVAR_ARCHIVE + FCVAR_USERINFO, "Habilitar renderizado de matrículas")
CreateConVar("glide_license_plates_distance", "500", FCVAR_ARCHIVE + FCVAR_USERINFO, "Distancia máxima de renderizado de matrículas")

-- Verify if a license plate should render
function ShouldRenderPlate(plateEntity)
    if not GetConVar("glide_license_plates_enabled"):GetBool() then
        return false
    end
    
    local maxDist = GetConVar("glide_license_plates_distance"):GetInt()
    local plyPos = LocalPlayer():GetPos()
    local platePos = plateEntity:GetPos()
    
    return plyPos:Distance(platePos) <= maxDist
end

hook.Add("PostDrawOpaqueRenderables", "GlideLicensePlates.Render", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingDepth or bDrawingSkybox then return end
    
    pcall(function()
        for _, ent in ents.Iterator() do
            if IsValid(ent) and ent:GetClass() == "glide_license_plate" and ShouldRenderPlate(ent) then
                DrawPlateTextImproved(ent) 
            end
        end
    end)
end)

-- Client options configurations
local function CreateClientOptions()
    if not Glide or not Glide.Config then return end
    
    list.Set("GlideConfigExtensions", "LicensePlates", function(config, panel)
        config.CreateHeader(panel, "License Plates configuration")
        
        config.CreateToggle(panel, "Show plates", 
            GetConVar("glide_license_plates_enabled"):GetBool(), 
            function(value)
                RunConsoleCommand("glide_license_plates_enabled", value and "1" or "0")
            end
        )
        
        config.CreateSlider(panel, "Render distance",
            GetConVar("glide_license_plates_distance"):GetInt(),
            100, 2000, 0,
            function(value)
                RunConsoleCommand("glide_license_plates_distance", tostring(value))
            end
        )

        config.CreateButton(panel, "Generate a random plate, specify plate ID", function()
            RunConsoleCommand("glide_random_plate")
        end)
    end)
end

hook.Add("InitPostEntity", "GlideLicensePlates.InitClient", function()
    timer.Simple(1, CreateClientOptions)
end)

concommand.Add("glide_plate_help", function()
    chat.AddText(Color(255, 0, 100), "[GLIDE License Plates] These are just temporary commands for testing and debug purposes, they can't be saved with duplicators:")
    chat.AddText(Color(100, 255, 100), "[GLIDE License Plates] Available commands:")

    chat.AddText(Color(255, 255, 100), "glide_random_plate <plate_id>", Color(255, 255, 255), " - Generate a new random plate (vehicle owner/admin)")
    chat.AddText(Color(255, 255, 100), "glide_change_plate <text>", Color(255, 255, 255), " - Change plate text (only admin)")
    chat.AddText(Color(255, 255, 100), "glide_license_plates_enabled 0/1", Color(255, 255, 255), " - Habilitar/deshabilitar matrículas")
    chat.AddText(Color(255, 255, 100), "glide_license_plates_distance <num>", Color(255, 255, 255), " - Cambiar distancia de renderizado")
    chat.AddText(Color(255, 255, 100), "glide_change_text_color <r> <g> <b> [a]", Color(255, 255, 255), " - Change text's color (only admin)")
    chat.AddText(Color(255, 255, 100), "glide_remove_plate <plate_id>", Color(255, 255, 255), " - Remove plate (only admin)")
    chat.AddText(Color(255, 255, 100), "glide_recreate_plates", Color(255, 255, 255), " - Recreate all license plates (only admin)")
end)

-- Clean cache when map is changed
hook.Add("PreCleanupMap", "GlideLicensePlates.ClearCache", function()
    createdFonts = {}
end)

print("[GLIDE License Plates] Client functions loaded")