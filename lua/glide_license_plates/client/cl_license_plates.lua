-- lua/glide_license_plates/client/cl_license_plates.lua

local defaultTextColor = Color(0, 0, 0, 255)

-- To create dynamic fonts based on scale
local createdFonts = {}

-- Function to create a font scaled based on the input scale factor.
local function CreateScaledFont(fontName, baseSize, scale)
    if not fontName or fontName == "" then 
        fontName = "Arial"
    end
    if not scale or scale <= 0 then 
        scale = 0.5 
    end
    
    -- Calculate scaled size, ensuring a minimum size of 16
    local scaledSize = math.max(16, math.floor(baseSize * math.max(scale, 0.3)))
    local fontId = "GlideLicensePlate_" .. fontName:gsub("[^%w]", "_") .. "_" .. tostring(scaledSize)
    
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
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
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
				underline = false,
				italic = false,
				strikeout = false,
				symbol = false,
				rotary = false,
				shadow = false,
				additive = false,
				outline = false,
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
    local lightFactor = (lighting.x + lighting.y + lighting.z) / 2
    lightFactor = math.Clamp(lightFactor, 0.3, 1.0)
    return lightFactor
end

-- Main function to draw the license plate text in 3D world space
local function DrawPlateTextImproved(plateEntity)
	if not IsValid(plateEntity) then return end
    
    -- Get the main CVar status
    local isEnabled = GetConVar("glide_license_plates_enabled"):GetBool()  
	
	if not isEnabled then
        plateEntity:SetNoDraw(true)
        return
    end  
	
	plateEntity:SetNoDraw(false)	
	
	-- Check distance culling before proceeding
	if not ShouldRenderPlate(plateEntity) then 
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
    
    -- Get base text color (networked color and alpha)
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
    
    -- Calculate lighting factor for dynamic color adjustment
    local lightFactor = CalculateAmbientLighting(worldPos, textAngles:Forward())
    
    -- Apply lighting to the text color
    local litTextColor = Color(
        math.Clamp(baseTextColor.r * lightFactor, 0, 255),
        math.Clamp(baseTextColor.g * lightFactor, 0, 255),
        math.Clamp(baseTextColor.b * lightFactor, 0, 255),
        baseTextColor.a -- Keep alpha unchanged
    )
    
    -- Get text size for 3D2D scaling/centering
    surface.SetFont(fontId)
    local textWidth, textHeight = surface.GetTextSize(text)
    if textWidth == 0 or textHeight == 0 then return end
    
    -- Get model bounds for offsetting text slightly forward
    local mins, maxs = plateEntity:GetModelBounds()
    local forward = textAngles:Forward()
	local right = textAngles:Right() 
    local up = textAngles:Up()   

    -- Offset the text slightly forward from the plate surface
    local offsetPos = worldPos + forward * (maxs.x * 0.1)    
	
    -- Apply custom text offset (X=Forward, Y=Right, Z=Up relative to plate)
    local textOffset = plateEntity:GetTextOffset()
    if textOffset and textOffset ~= Vector(0,0,0) then
        offsetPos = offsetPos + (forward * textOffset.x) + (right * -textOffset.y) + (up * textOffset.z)
        -- Note: Y is inverted (-textOffset.y) typically to match standard left/right mapping in Source, 
        -- the negative sign might be removed if direction needs to be opposite.
    end   
	
    -- Adjust angles for 3D2D rendering plane (needs 90 degree rotations)
    local renderAng = Angle(textAngles.p, textAngles.y, textAngles.r)
    renderAng:RotateAroundAxis(renderAng:Up(), 90)
    renderAng:RotateAroundAxis(renderAng:Forward(), 90)
    
    -- Base the render scale on the plate scale factor
    local renderScale = scale * 0.5
    
    if renderScale <= 0 then return end
    
    -- Start 3D2D rendering
    local success = pcall(function()
        cam.Start3D2D(offsetPos, renderAng, renderScale)
            -- Slight Shadow
            draw.SimpleText(text, fontId, 0, 0, Color(0, 0, 0, litTextColor.a * 0.3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- Main text
            draw.SimpleText(text, fontId, 0, 0, litTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)
end

-- Client variables - Using localization keys (prefixed with #)
CreateConVar("glide_license_plates_enabled", "1", FCVAR_ARCHIVE + FCVAR_USERINFO, "#glide_license_plates_enabled_cvar")
CreateConVar("glide_license_plates_distance", "500", FCVAR_ARCHIVE + FCVAR_USERINFO, "#glide_license_plates_distance_cvar")

-- Verify if a license plate should render based on distance
function ShouldRenderPlate(plateEntity)
    local maxDist = GetConVar("glide_license_plates_distance"):GetInt()
    local plyPos = LocalPlayer():GetPos()
    local platePos = plateEntity:GetPos()
    
    return plyPos:Distance(platePos) <= maxDist
end

-- Hook for rendering 3D2D text after opaque geometry
hook.Add("PostDrawOpaqueRenderables", "GlideLicensePlates.Render", function(bDrawingDepth, bDrawingSkybox)
    if bDrawingDepth or bDrawingSkybox then return end
    
    local platesEnabled = GetConVar("glide_license_plates_enabled"):GetBool()

    pcall(function()
        for _, ent in ents.Iterator() do
            if IsValid(ent) and ent:GetClass() == "glide_license_plate" then
                
                -- Hide the model if the option is disabled
                if not platesEnabled then
                    ent:SetNoDraw(true)
                    -- No need to draw text if the model is hidden
                    continue 
                end

                -- Show the model if the option is enabled
                ent:SetNoDraw(false)

                -- Only draw the text if the distance allows it
                if ShouldRenderPlate(ent) then
                    DrawPlateTextImproved(ent) 
                end
            end
        end
    end)
end)

-- Client options configurations for Glide Config
local function CreateClientOptions()
    if not Glide or not Glide.Config then return end
    
    list.Set("GlideConfigExtensions", "LicensePlates", function(config, panel)

        config.CreateHeader(panel, language.GetPhrase("glide_license_plates_config_header"))
		
    config.CreateButton( panel, language.GetPhrase("glide_plate_helper"), function()
    RunConsoleCommand("glide_plate_help")	
    end )

        config.CreateToggle(panel, language.GetPhrase("glide_license_plates_config_toggle"), 
            GetConVar("glide_license_plates_enabled"):GetBool(), 
            function(value)
                RunConsoleCommand("glide_license_plates_enabled", value and "1" or "0")
            end
        )
        

        config.CreateSlider(panel, language.GetPhrase("glide_license_plates_config_slider"),
            GetConVar("glide_license_plates_distance"):GetInt(),
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

-- Clear font cache when map is changed to prevent issues
hook.Add("PreCleanupMap", "GlideLicensePlates.ClearCache", function()
    createdFonts = {}
end)

print("[GLIDE License Plates] Client functions loaded")