-- lua/autorun/sh_glide_license_plates.lua

-- Initialize global table
GlideLicensePlates = GlideLicensePlates or {}
GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}

-- Verify if Glide is available
if not Glide then
    if SERVER then
        print("[GLIDE License Plates] Glide is not installed. License plates addon will not work.")
    end
    return
end

-- System configuration
GlideLicensePlates.Config = {
    MaxCharacters = 8,
    DefaultFont = "Arial",
    DefaultModel = "models/sprops/rectangles_superthin/size_1/rect_3x12.mdl",
    DefaultScale = 0.5
}

GlideLicensePlates.PlateTypes = { 
    ["argmercosur"] = {
        pattern = "AB 123 CD",
        model = "models/blackterios_glide_vehicles/licenseplates/argentinamercosur.mdl",
        description = "Mercosur Argentina (AB 123 CD) - Standard plate",
        defaultFont = "GL-Nummernschild-Mtl",
        defaultTextColor = {r = 0, g = 0, b = 0, a = 255}, 
    },
    ["argold"] = {
        pattern = "ABC 123",
        model = "models/blackterios_glide_vehicles/licenseplates/argentinaold.mdl", 
        description = "Argentina Old (ABC 123)",
        defaultFont = "coolvetica",
        defaultTextColor = {r = 255, g = 255, b = 255, a = 255}, 
    },
    ["argvintage"] = {
        pattern = "A123456",
        model = "models/blackterios_glide_vehicles/licenseplates/argentinavintage.mdl",
        description = "Argentina Vintage (A123456)",
        defaultFont = "Times New Roman",
        defaultTextColor = {r = 255, g = 255, b = 255, a = 255}, 
    },    
	["brasilmercosur"] = {
        pattern = "ABC1D23",
        model = "models/blackterios_glide_vehicles/licenseplates/brasilmercosur.mdl",
        description = "Mercosur Brasil (ABC1D23)",
        defaultFont = "GL-Nummernschild-Mtl",
        defaultTextColor = {r = 0, g = 0, b = 0, a = 255}, 
    },
	["paraguaymercosur"] = {
        pattern = "ABCD 123",
        model = "models/blackterios_glide_vehicles/licenseplates/paraguaymercosur.mdl",
        description = "Mercosur Paraguay (ABCD 123)",
        defaultFont = "GL-Nummernschild-Mtl",
        defaultTextColor = {r = 0, g = 0, b = 0, a = 255}, 
    },	
	["uruguaymercosur"] = {
        pattern = "ABC 1234",
        model = "models/blackterios_glide_vehicles/licenseplates/uruguaymercosur.mdl",
        description = "Mercosur Uruguay (ABC 1234)",
        defaultFont = "GL-Nummernschild-Mtl",
        defaultTextColor = {r = 0, g = 0, b = 0, a = 255}, 
    },
}

-- Function to get the default text color
function GlideLicensePlates.GetPlateTextColor(plateType, customTextColor)
    -- Priority: custom color from config > plate type default color > system default (black)
    if customTextColor and type(customTextColor) == "table" then
    --    print("[GLIDE License Plates] Using custom text color for plate")
        return {
            r = customTextColor.r or 0,
            g = customTextColor.g or 0, 
            b = customTextColor.b or 0,
            a = customTextColor.a or 255
        }
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig and plateConfig.defaultTextColor then
    --    print("[GLIDE License Plates] Using default text color for plate type: " .. plateType)
        return {
            r = plateConfig.defaultTextColor.r or 0,
            g = plateConfig.defaultTextColor.g or 0,
            b = plateConfig.defaultTextColor.b or 0,
            a = plateConfig.defaultTextColor.a or 255
        }
    end
    
  --  print("[GLIDE License Plates] Using system default text color (black)")
    return {r = 0, g = 0, b = 0, a = 255} -- Default black
end

-- Function to get the appropriate font for a plate type
function GlideLicensePlates.GetPlateFont(plateType, customFont)
    -- Priority: custom font from vehicle config > plate type custom font > plate type default font > system default
    if customFont and customFont ~= "" then
    --    print("[GLIDE License Plates] Using custom font from config: " .. customFont)
        return customFont
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig then
        if plateConfig.customFont and plateConfig.customFont ~= "" then
        --    print("[GLIDE License Plates] Using plate type custom font: " .. plateConfig.customFont)
            return plateConfig.customFont
        elseif plateConfig.defaultFont and plateConfig.defaultFont ~= "" then
        --    print("[GLIDE License Plates] Using plate type default font: " .. plateConfig.defaultFont)
            return plateConfig.defaultFont
        end
    end
    
   -- print("[GLIDE License Plates] Using system default font: " .. GlideLicensePlates.Config.DefaultFont)
    return GlideLicensePlates.Config.DefaultFont
end

-- Function to set custom font for a plate type
function GlideLicensePlates.SetPlateTypeFont(plateType, fontName)
    if not plateType or not GlideLicensePlates.PlateTypes[plateType] then
    --    print("[GLIDE License Plates] ERROR: Invalid plate type: " .. tostring(plateType))
        return false
    end
    
    if not fontName or fontName == "" then
        GlideLicensePlates.PlateTypes[plateType].customFont = nil
    --    print("[GLIDE License Plates] Custom font cleared for plate type: " .. plateType)
    else
        GlideLicensePlates.PlateTypes[plateType].customFont = fontName
    --    print("[GLIDE License Plates] Custom font set for " .. plateType .. ": " .. fontName)
    end
    return true
end

-- Generate random plates
function GlideLicensePlates.GeneratePlate(plateType)
    local selectedType = plateType
    
    -- Si plateType es una tabla (múltiples tipos), elegir uno aleatoriamente
    if type(plateType) == "table" and #plateType > 0 then
        selectedType = plateType[math.random(1, #plateType)]
    elseif type(plateType) == "table" and #plateType == 0 then
        -- Si la tabla está vacía, usar tipo por defecto
        selectedType = "argmercosur"
    end
    
    -- Verificar que el tipo seleccionado existe
    local config = GlideLicensePlates.PlateTypes[selectedType]
    if not config then
        selectedType = "argmercosur"
        config = GlideLicensePlates.PlateTypes[selectedType]
    end
    
    local pattern = config.pattern
    local result = ""
    
    for i = 1, string.len(pattern) do
        local char = string.sub(pattern, i, i)
        
        -- Verify if it is a letter (A-Z)
        if string.match(char, "[A-Z]") then
            -- Generar letra aleatoria
            result = result .. string.char(math.random(65, 90)) -- A-Z
        -- Verify if it is a number (0-9)  
        elseif string.match(char, "[0-9]") then
            -- Generate random number
            result = result .. tostring(math.random(0, 9))
        else
            -- Mantain special characters
            result = result .. char
        end
    end
    
    return result, selectedType -- Devolver también el tipo seleccionado
end

-- Validate vehicle's license plate configuration
function GlideLicensePlates.ValidateVehicleConfig(vehicle)
    if not IsValid(vehicle) then return false end
    if not vehicle.IsGlideVehicle then return false end
    
    if not vehicle.LicensePlateConfigs then return false end
    
    -- Validar cada configuración de matrícula
    for i, config in ipairs(vehicle.LicensePlateConfigs) do
	if config.textColor then
            if type(config.textColor) ~= "table" then
                config.textColor = nil
                print("[GLIDE License Plates] Invalid textColor config, will use plate type default")
            else
                -- Validate color values
                if not config.textColor.r then config.textColor.r = 0 end
                if not config.textColor.g then config.textColor.g = 0 end  
                if not config.textColor.b then config.textColor.b = 0 end
                if not config.textColor.a then config.textColor.a = 255 end
                
                -- Clamp values to valid range
                config.textColor.r = math.Clamp(config.textColor.r, 0, 255)
                config.textColor.g = math.Clamp(config.textColor.g, 0, 255)
                config.textColor.b = math.Clamp(config.textColor.b, 0, 255)
                config.textColor.a = math.Clamp(config.textColor.a, 0, 255)
                
            --    print("[GLIDE License Plates] Validated custom textColor")
            end
        else
        --    print("[GLIDE License Plates] No custom textColor specified, will use plate type default")
        end

        -- Validar tipo de matrícula (puede ser string o tabla)
        if not config.plateType then
            config.plateType = "argmercosur"
        elseif type(config.plateType) == "table" then
            -- Si es una tabla, verificar que tenga al menos un elemento válido
            local validTypes = {}
            for _, pType in ipairs(config.plateType) do
                if type(pType) == "string" and GlideLicensePlates.PlateTypes[pType] then
                    table.insert(validTypes, pType)
                end
            end
            
            if #validTypes == 0 then
                print("[GLIDE License Plates] WARNING: Couldn't find valid types in configuration, using argmercosur (default)")
                config.plateType = "argmercosur"
            else
                config.plateType = validTypes
            end
        elseif type(config.plateType) == "string" then
            -- If it is a string, verify that exists
            if not GlideLicensePlates.PlateTypes[config.plateType] then
                print("[GLIDE License Plates] WARNING: Type '" .. config.plateType .. "' not found, using argmercosur (default)")
                config.plateType = "argmercosur"
            end
        else
            -- If invalid type
            config.plateType = "argmercosur"
        end
        
        if not config.position or type(config.position) ~= "Vector" then
            config.position = Vector(0, 0, 0)
        end
        
        if not config.angles or type(config.angles) ~= "Angle" then
            config.angles = Angle(0, 0, 0)
        end
        
        if not config.modelRotation or type(config.modelRotation) ~= "Angle" then
            config.modelRotation = Angle(0, 0, 0)
        end
        
        if not config.scale or type(config.scale) ~= "number" or config.scale <= 0 then
            config.scale = GlideLicensePlates.Config.DefaultScale
        end
        
        if config.customModel then
            if type(config.customModel) ~= "string" or config.customModel == "" then
                config.customModel = nil
            elseif not util.IsValidModel(config.customModel) then
                config.customModel = nil
            end
        end
        
        -- Validate custom font configuration
        if config.font then
            if type(config.font) ~= "string" or config.font == "" then
                config.font = nil
            else
                print("[GLIDE License Plates] Validated font parameter: " .. config.font)
            end
        end
        
        -- Also validate customFont parameter
        if config.customFont then
            if type(config.customFont) ~= "string" or config.customFont == "" then
                config.customFont = nil
            else
                print("[GLIDE License Plates] Validated customFont parameter: " .. config.customFont)
            end
        end 
        
        if config.textColor then
            if type(config.textColor) ~= "table" then
                config.textColor = nil
            else
                if not config.textColor.r then config.textColor.r = 0 end
                if not config.textColor.g then config.textColor.g = 0 end
                if not config.textColor.b then config.textColor.b = 0 end
                if not config.textColor.a then config.textColor.a = 255 end
            end
        end
        
        if not config.id then
            config.id = "plate_" .. i
        end
        
        if config.customText then
            if type(config.customText) ~= "string" then
                config.customText = nil
            end
        end
    end
    
    return true
end

-- SERVER FUNCTIONS
if SERVER then
    -- Create all the license plates for the vehicle 
	function GlideLicensePlates.CreateLicensePlates(vehicle)
		if not IsValid(vehicle) then return false end
		if not GlideLicensePlates.ValidateVehicleConfig(vehicle) then return false end
		
		-- Check if we're in duplication restore mode
		if vehicle._RestoreFromDupe then
		--	print("[GLIDE License Plates] Skipping automatic creation - restoration in progress")
			return false
		end
        
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        
        if not vehicle.LicensePlateEntities then
            vehicle.LicensePlateEntities = {}
        end
        
        if not vehicle.LicensePlateTexts then
            vehicle.LicensePlateTexts = {}
        end

        if not vehicle.SelectedPlateTypes then
            vehicle.SelectedPlateTypes = {}
        end

        if not vehicle.SelectedPlateFonts then
            vehicle.SelectedPlateFonts = {}
        end
        
        local globalPlateText = nil
        local globalPlateType = nil
        local needsGlobalText = true
        local useGlobalType = true
        
        -- Verify if a plate has customText
        for i, config in ipairs(vehicle.LicensePlateConfigs) do
            if config.customText and config.customText ~= "" then
                needsGlobalText = false
                break
            end
        end
        
        -- Verify if all plates have the same type set
        local firstConfigType = vehicle.LicensePlateConfigs[1].plateType
        for i = 2, #vehicle.LicensePlateConfigs do
            local currentConfigType = vehicle.LicensePlateConfigs[i].plateType
            -- Compare types (can be strings or tables)
            if type(firstConfigType) ~= type(currentConfigType) then
                useGlobalType = false
                break
            elseif type(firstConfigType) == "table" then
                -- If they're tables, verify if they have the same elements
                if #firstConfigType ~= #currentConfigType then
                    useGlobalType = false
                    break
                else
                    for j, plateType in ipairs(firstConfigType) do
                        if plateType ~= currentConfigType[j] then
                            useGlobalType = false
                            break
                        end
                    end
                    if not useGlobalType then break end
                end
            elseif firstConfigType ~= currentConfigType then
                useGlobalType = false
                break
            end
        end
        
        -- If we need global text and all the plates have the same type, generate a global one
        if needsGlobalText and useGlobalType then
            local firstPlateType = vehicle.LicensePlateConfigs[1].plateType or "argmercosur"
            globalPlateText, globalPlateType = GlideLicensePlates.GeneratePlate(firstPlateType)
        --    print("[GLIDE License Plates] Global text generated: " .. globalPlateText .. " (type: " .. globalPlateType .. ")")
        else
        --    print("[GLIDE License Plates] Using individual configs per plate")
        end
        
        local createdCount = 0
        
        -- Create every plate
        for i, config in ipairs(vehicle.LicensePlateConfigs) do
            local plateId = config.id or "plate_" .. i
            
            -- Verify if there's already a valid plate for this id
            if IsValid(vehicle.LicensePlateEntities[plateId]) then
                createdCount = createdCount + 1
                continue
            end
            
            -- Set plate type and SPECIFIC text for this plate
            local plateType = nil
            local plateText = nil
            local plateFont = nil
            
            -- Generate consistent text
            if not vehicle.LicensePlateTexts[plateId] then
                if config.customText and config.customText ~= "" then
                    -- Use custom text
                    plateText = config.customText
                    -- For custom text, we still need to set model's type
                    if type(config.plateType) == "table" then
                        plateType = config.plateType[math.random(1, #config.plateType)]
                    else
                        plateType = config.plateType or "argmercosur"
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                --    print("[GLIDE License Plates] Using custom text for " .. plateId .. ": " .. plateText .. " (type: " .. plateType .. ")")
                else
                    -- Use global text or generate a specific one
                    if globalPlateType and globalPlateText then
                        -- If we already have a type and global text, use them
                        plateText = globalPlateText
                        plateType = globalPlateType
                    else
                        -- Generate specific for this plate
                        plateText, plateType = GlideLicensePlates.GeneratePlate(config.plateType or "argmercosur")
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                 --   print("[GLIDE License Plates] Generated for " .. plateId .. ": " .. plateText .. " (type: " .. plateType .. ")")
                end
                
                vehicle.LicensePlateTexts[plateId] = plateText
            else
                -- If we already have text, get the stored type
                plateText = vehicle.LicensePlateTexts[plateId]
                plateType = vehicle.SelectedPlateTypes[plateId]
                -- If we don't have stored type, generate a new one
                if not plateType then
                    if type(config.plateType) == "table" then
                        plateType = config.plateType[math.random(1, #config.plateType)]
                    else
                        plateType = config.plateType or "argmercosur"
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                --    print("[GLIDE License Plates] Late generated type for " .. plateId .. ": " .. plateType)
                end
            end
            
            -- Determine the font for this plate
			local configFont = nil
            
            -- First check if the specific plate config has a font
            if config.font and config.font ~= "" then
                configFont = config.font
            --    print("[GLIDE License Plates] Found font in plate config " .. plateId .. ": " .. configFont)
            end
            
            -- If no font in config, check if there's a customFont parameter
            if not configFont and config.customFont and config.customFont ~= "" then
                configFont = config.customFont
            --    print("[GLIDE License Plates] Found customFont in plate config " .. plateId .. ": " .. configFont)
            end
            
            -- Determine final font using the hierarchy
            plateFont = GlideLicensePlates.GetPlateFont(plateType, configFont)
            vehicle.SelectedPlateFonts[plateId] = plateFont
            
        --    print("[GLIDE License Plates] Final font for " .. plateId .. ": " .. plateFont)
            
            -- Create plate entity
            local plateEntity = ents.Create("glide_license_plate")
            if not IsValid(plateEntity) then 
                print("[GLIDE License Plates] Error: Couldn't create plate entity " .. plateId)
                continue 
            end
            
            -- Configure model based on the selected type
            local plateModel = nil
            
            if config.customModel and config.customModel ~= "" and util.IsValidModel(config.customModel) then
                plateModel = config.customModel
            --    print("[GLIDE License Plates] Using custom model for " .. plateId .. ": " .. plateModel)
            else
                -- Use the selected type specifically for this plate
                local actualPlateType = plateType -- plateType already contains the selected type for this plate
                
                if GlideLicensePlates.PlateTypes[actualPlateType] and GlideLicensePlates.PlateTypes[actualPlateType].model then
                    plateModel = GlideLicensePlates.PlateTypes[actualPlateType].model
                 --   print("[GLIDE License Plates] Using " .. actualPlateType .. "'s model for " .. plateId .. ": " .. plateModel)
                else
                    plateModel = GlideLicensePlates.Config.DefaultModel
                    print("[GLIDE License Plates] WARNING: Type " .. actualPlateType .. " doesn't have defined model, using default model: " .. plateModel)
                end
            end
            
            plateEntity:SetModel(plateModel)
            plateEntity:Spawn()
            plateEntity:Activate()
            
            -- Configure physical properties 
            plateEntity:SetMoveType(MOVETYPE_NONE)
            plateEntity:SetSolid(SOLID_NONE)
            plateEntity:SetCollisionGroup(COLLISION_GROUP_WORLD)
            plateEntity.DoNotDuplicate = true
            plateEntity.PhysgunDisabled = false
            plateEntity.PlateId = plateId
            plateEntity.PlateType = plateType 
            
            -- Configure properties after spawn 
-- Store properties locally FIRST
				plateEntity.PlateText = plateText
				plateEntity.PlateScale = config.scale or GlideLicensePlates.Config.DefaultScale
				plateEntity.PlateFont = plateFont
				
				-- Get color
				local textColor = GlideLicensePlates.GetPlateTextColor(plateType, config.textColor)
				plateEntity.TextColorR = textColor.r
				plateEntity.TextColorG = textColor.g
				plateEntity.TextColorB = textColor.b
				plateEntity.TextColorA = textColor.a
				
				-- Now set network variables (this triggers transmission to clients)
				plateEntity:SetPlateText(plateText)
				plateEntity:SetPlateScale(config.scale or GlideLicensePlates.Config.DefaultScale)
				plateEntity:SetPlateFont(plateFont)
				plateEntity:SetTextColor(Vector(textColor.r, textColor.g, textColor.b))
				plateEntity:SetTextAlpha(textColor.a)
				
				-- CRITICAL: Force immediate network update
				if plateEntity.NetworkVarNotify then
					plateEntity:NetworkVarNotify("PlateText", plateText)
					plateEntity:NetworkVarNotify("PlateScale", plateEntity.PlateScale)
					plateEntity:NetworkVarNotify("PlateFont", plateFont)
				end

				-- Configure transform after spawn
				timer.Simple(0.1, function()
					if not IsValid(plateEntity) or not IsValid(vehicle) then return end
 
                plateEntity:SetParentVehicle(vehicle)
                plateEntity:SetModelRotation(config.modelRotation or Angle(0, 0, 0))
                plateEntity:SetBaseTransform(config.position or Vector(0, 0, 0), config.angles or Angle(0, 0, 0))
                
                plateEntity.PlateText = plateText
                plateEntity.PlateScale = config.scale or GlideLicensePlates.Config.DefaultScale
                plateEntity.PlateFont = plateFont -- Store the font
                plateEntity.ParentVehicle = vehicle 
                plateEntity.ModelRotation = config.modelRotation or Angle(0, 0, 0)
                
                plateEntity:UpdatePosition()
            end)
            
            -- Store references
            vehicle.LicensePlateEntities[plateId] = plateEntity
            vehicle:DeleteOnRemove(plateEntity)
            
            createdCount = createdCount + 1
        end
        
        -- Store vehicle in the global list
        GlideLicensePlates.ActivePlates[vehicle] = vehicle.LicensePlateEntities
        
    --    print("[GLIDE License Plates] " .. createdCount .. " plates created for the vehicle")
        return createdCount > 0
    end
    
    -- Remove all license plates
    function GlideLicensePlates.RemoveLicensePlates(vehicle)
        if not IsValid(vehicle) then return end
        
        -- Make sure ActivePlates is initialised
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        
        -- Remove all plates from the vehicle
        if vehicle.LicensePlateEntities then
            for plateId, plateEntity in pairs(vehicle.LicensePlateEntities) do
                if IsValid(plateEntity) then
                    plateEntity:Remove()
                end
            end
            vehicle.LicensePlateEntities = {}
        end
        
        GlideLicensePlates.ActivePlates[vehicle] = nil
        
       -- print("[GLIDE License Plates] All plates removed from vehicle: " .. tostring(vehicle))
    end
    
    -- Remove a specific plate
    function GlideLicensePlates.RemoveSpecificPlate(vehicle, plateId)
        if not IsValid(vehicle) or not vehicle.LicensePlateEntities then return end
        
        local plateEntity = vehicle.LicensePlateEntities[plateId]
        if IsValid(plateEntity) then
            plateEntity:Remove()
            vehicle.LicensePlateEntities[plateId] = nil
            
            if vehicle.LicensePlateTexts then
                vehicle.LicensePlateTexts[plateId] = nil
            end
            
            -- Also clean the selected type
            if vehicle.SelectedPlateTypes then
                vehicle.SelectedPlateTypes[plateId] = nil
            end
            
            -- Clean the selected font
            if vehicle.SelectedPlateFonts then
                vehicle.SelectedPlateFonts[plateId] = nil
            end
            
            print("[GLIDE License Plates] Plate " .. plateId .. " removed")
        end
    end
    
    -- Get a specific plate
    function GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
        if not IsValid(vehicle) or not vehicle.LicensePlateEntities then return nil end
        return vehicle.LicensePlateEntities[plateId]
    end
    
    -- Include server lua file after defining the functions
    include("glide_license_plates/server/sv_license_plates.lua")
    AddCSLuaFile("glide_license_plates/client/cl_license_plates.lua")
    
elseif CLIENT then
    -- Include client files
    include("glide_license_plates/client/cl_license_plates.lua")
end

-- Hook - For when a vehicle is created
hook.Add("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated", function(ent)
    if not IsValid(ent) then return end
    
    timer.Simple(0.1, function()
        if not IsValid(ent) then return end
        if not ent.IsGlideVehicle then return end
        
        if SERVER and GlideLicensePlates.CreateLicensePlates then
            GlideLicensePlates.CreateLicensePlates(ent)
        end
    end)
end)

-- Hook - Clean plates when a vehicle is removed
hook.Add("EntityRemoved", "GlideLicensePlates.OnVehicleRemoved", function(ent)
    if not IsValid(ent) then return end
    if not ent.IsGlideVehicle then return end
    
    if SERVER and GlideLicensePlates.RemoveLicensePlates then
        GlideLicensePlates.RemoveLicensePlates(ent)
    end
end)

-- Cleanup when map is changed
hook.Add("PreCleanupMap", "GlideLicensePlates.MapCleanup", function()
    if SERVER then
        GlideLicensePlates.ActivePlates = {}
    end
end)

-- Duplicator support
if SERVER then
    -- Duplication control variables
    local duplicatingEntities = {}
    local pendingRestores = {}
    local restoringVehicles = {}
    
    -- Enhanced plate data storage that includes colors
    local function SaveCompleteePlateData(vehicle)
        if not IsValid(vehicle) or not vehicle.IsGlideVehicle then return false end
        
        local plateData = {

            timestamp = CurTime(),
        }
        
        local hasData = false
        
        -- Save plate texts
        if vehicle.LicensePlateTexts and not table.IsEmpty(vehicle.LicensePlateTexts) then
            plateData.plateTexts = table.Copy(vehicle.LicensePlateTexts)
            hasData = true
        elseif vehicle.LicensePlateText and vehicle.LicensePlateText ~= "" then
            plateData.plateText = vehicle.LicensePlateText
            hasData = true
        end
        
        -- Save selected plate types
        if vehicle.SelectedPlateTypes and not table.IsEmpty(vehicle.SelectedPlateTypes) then
            plateData.selectedPlateTypes = table.Copy(vehicle.SelectedPlateTypes)
            hasData = true
        end
        
        -- Save selected fonts
        if vehicle.SelectedPlateFonts and not table.IsEmpty(vehicle.SelectedPlateFonts) then
            plateData.selectedPlateFonts = table.Copy(vehicle.SelectedPlateFonts)
            hasData = true
        end
        
        -- CRITICAL: Save the actual colors from the physical plate entities
        if vehicle.LicensePlateEntities and not table.IsEmpty(vehicle.LicensePlateEntities) then
            plateData.actualTextColors = {}
            for plateId, plateEntity in pairs(vehicle.LicensePlateEntities) do
                if IsValid(plateEntity) then
                    -- Get color from the actual entity
                    local colorVector = plateEntity:GetTextColor()
                    local alpha = plateEntity:GetTextAlpha()
                    
                    if colorVector then
                        plateData.actualTextColors[plateId] = {
                            r = math.Round(colorVector.x),
                            g = math.Round(colorVector.y),
                            b = math.Round(colorVector.z),
                            a = alpha or 255
                        }
                        hasData = true
                    end
                end
            end
        end
        
        -- Save configurations (for reference)
        if vehicle.LicensePlateConfigs then
            plateData.plateConfigs = table.Copy(vehicle.LicensePlateConfigs)
            hasData = true
        elseif vehicle.LicensePlateConfig then
            plateData.plateConfig = table.Copy(vehicle.LicensePlateConfig)
            hasData = true
        end
        
        if hasData then
            duplicator.StoreEntityModifier(vehicle, "glide_license_plate_data", plateData)
         --   print("[GLIDE License Plates] Complete plate data saved for duplication")
            return true
        end
        
        return false
    end
    
    -- Enhanced plate creation with proper color restoration
    local function CreatePlatesWithRestoredData(vehicle, plateData)
        if not IsValid(vehicle) or not plateData then return false end
        
     --   print("[GLIDE License Plates] Creating plates with complete restored data")
        
        -- Prevent automatic creation during restoration
        vehicle._RestoreFromDupe = true
        
        -- Initialize storage
        if not vehicle.LicensePlateEntities then
            vehicle.LicensePlateEntities = {}
        end
        
        -- Restore basic data
        if plateData.plateTexts then
            vehicle.LicensePlateTexts = table.Copy(plateData.plateTexts)
        end
        
        if plateData.plateText then
            vehicle.LicensePlateText = plateData.plateText
        end
        
        if plateData.selectedPlateTypes then
            vehicle.SelectedPlateTypes = table.Copy(plateData.selectedPlateTypes)
        end
        
        if plateData.selectedPlateFonts then
            vehicle.SelectedPlateFonts = table.Copy(plateData.selectedPlateFonts)
        end
        
        -- Store restored colors for use during creation
        if plateData.actualTextColors then
            vehicle._RestoredColors = table.Copy(plateData.actualTextColors)
           -- print("[GLIDE License Plates] Restored " .. table.Count(plateData.actualTextColors) .. " text colors")
        end
        
        -- Now create the plates
        local createdCount = 0
        
        if vehicle.LicensePlateConfigs then
            for i, config in ipairs(vehicle.LicensePlateConfigs) do
                local plateId = config.id or "plate_" .. i
                
                if IsValid(vehicle.LicensePlateEntities[plateId]) then
                    continue
                end
                
                -- Get restored data for this plate
                local plateText = vehicle.LicensePlateTexts and vehicle.LicensePlateTexts[plateId]
                local plateType = vehicle.SelectedPlateTypes and vehicle.SelectedPlateTypes[plateId]
                local plateFont = vehicle.SelectedPlateFonts and vehicle.SelectedPlateFonts[plateId]
                
                if not plateText or not plateType then
                --    print("[GLIDE License Plates] Missing restored data for " .. plateId)
                    continue
                end
                
                if not plateFont then
                    plateFont = GlideLicensePlates.GetPlateFont(plateType, config.font or config.customFont)
                end
                
                -- Create plate entity
                local plateEntity = ents.Create("glide_license_plate")
                if not IsValid(plateEntity) then continue end
                
                -- Set model
                local plateModel = GlideLicensePlates.Config.DefaultModel
                if config.customModel and util.IsValidModel(config.customModel) then
                    plateModel = config.customModel
                elseif GlideLicensePlates.PlateTypes[plateType] and GlideLicensePlates.PlateTypes[plateType].model then
                    plateModel = GlideLicensePlates.PlateTypes[plateType].model
                end
                
                plateEntity:SetModel(plateModel)
                plateEntity:Spawn()
                plateEntity:Activate()
                
                -- Basic entity setup
                plateEntity:SetMoveType(MOVETYPE_NONE)
                plateEntity:SetSolid(SOLID_NONE)
                plateEntity:SetCollisionGroup(COLLISION_GROUP_WORLD)
                plateEntity.DoNotDuplicate = true
                plateEntity.PhysgunDisabled = false
                plateEntity.PlateId = plateId
                plateEntity.PlateType = plateType
                
                -- Store reference immediately
                vehicle.LicensePlateEntities[plateId] = plateEntity
                vehicle:DeleteOnRemove(plateEntity)
                
                -- Configure after spawn with PROPER COLOR RESTORATION
-- Set basic properties IMMEDIATELY
                plateEntity:SetPlateText(plateText)
                plateEntity:SetPlateScale(config.scale or GlideLicensePlates.Config.DefaultScale)
                plateEntity:SetPlateFont(plateFont)
                
                -- CRITICAL: Set the correct color IMMEDIATELY
                local textColor = nil
                
                -- Priority 1: Use actual restored color
                if vehicle._RestoredColors and vehicle._RestoredColors[plateId] then
                    textColor = vehicle._RestoredColors[plateId]
                else
                    -- Priority 2: Use color hierarchy
                    textColor = GlideLicensePlates.GetPlateTextColor(plateType, config.textColor)
                end
                
                -- Apply the color IMMEDIATELY
                plateEntity:SetTextColor(Vector(textColor.r, textColor.g, textColor.b))
                plateEntity:SetTextAlpha(textColor.a)
                
                -- Store color values locally IMMEDIATELY
                plateEntity.TextColorR = textColor.r
                plateEntity.TextColorG = textColor.g
                plateEntity.TextColorB = textColor.b
                plateEntity.TextColorA = textColor.a
                
                -- Configure transform after spawn
                timer.Simple(0.1, function()
                    if not IsValid(plateEntity) or not IsValid(vehicle) then return end

                    
                    -- Set parent and transform
                    plateEntity:SetParentVehicle(vehicle)
                    plateEntity:SetModelRotation(config.modelRotation or Angle(0, 0, 0))
                    plateEntity:SetBaseTransform(config.position or Vector(0, 0, 0), config.angles or Angle(0, 0, 0))
                    
                    -- Store properties
                    plateEntity.PlateText = plateText
                    plateEntity.PlateScale = config.scale or GlideLicensePlates.Config.DefaultScale
                    plateEntity.PlateFont = plateFont
                    plateEntity.ParentVehicle = vehicle
                    plateEntity.ModelRotation = config.modelRotation or Angle(0, 0, 0)
                    
                    plateEntity:UpdatePosition()
                end)
                
                createdCount = createdCount + 1
            end
        end
        
        -- Store in global list
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        GlideLicensePlates.ActivePlates[vehicle] = vehicle.LicensePlateEntities
        
        -- Clean up restoration data
        timer.Simple(1, function()
            if IsValid(vehicle) then
                vehicle._RestoreFromDupe = nil
                vehicle._RestoredColors = nil
            end
        end)
        
     --   print("[GLIDE License Plates] Created " .. createdCount .. " plates with restored colors")
        return createdCount > 0
    end
    
    -- Enhanced save hook that ensures colors are saved
    hook.Add("OnEntityCreated", "GlideLicensePlates.SaveCompleteData", function(ent)
        timer.Simple(1, function() -- Longer delay to ensure plates are fully created
            if IsValid(ent) and ent.IsGlideVehicle then
                SaveCompleteePlateData(ent)
            end
        end)
    end)
    
    -- Hook to save data when plates are modified
    local function SaveDataOnPlateChange(vehicle)
        if IsValid(vehicle) and vehicle.IsGlideVehicle then
            timer.Simple(0.2, function()
                if IsValid(vehicle) then
                    SaveCompleteePlateData(vehicle)
                end
            end)
        end
    end
    
    -- Save data when plate text is changed
    local originalUpdatePlateText = nil
    if glide_license_plate then
        local meta = FindMetaTable("Entity")
        originalUpdatePlateText = meta.UpdatePlateText
        
        meta.UpdatePlateText = function(self, newText)
            if originalUpdatePlateText then
                originalUpdatePlateText(self, newText)
            end
            
            if self.ParentVehicle then
                SaveDataOnPlateChange(self.ParentVehicle)
            end
        end
    end
    
    -- Register the duplicator restore function
    duplicator.RegisterEntityModifier("glide_license_plate_data", function(ply, ent, data)
        if not IsValid(ent) or not ent.IsGlideVehicle then 
            print("[GLIDE License Plates] Invalid entity for restoration")
            return 
        end
        
        if not data or type(data) ~= "table" then
            print("[GLIDE License Plates] Invalid restoration data")
            return
        end
        
      --  print("[GLIDE License Plates] Starting plate restoration process")
        
        -- Mark as restoring
        restoringVehicles[ent] = true
        
        -- Remove existing plates
        if GlideLicensePlates.RemoveLicensePlates then
            GlideLicensePlates.RemoveLicensePlates(ent)
        end
        
        -- Restore after delay
        timer.Simple(0.3, function()
            if not IsValid(ent) then 
                restoringVehicles[ent] = nil
                return 
            end
            
            CreatePlatesWithRestoredData(ent, data)
            restoringVehicles[ent] = nil
        end)
    end)
    
    -- Prevent automatic creation during restoration
    hook.Remove("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated")
    hook.Add("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated", function(ent)
        if not IsValid(ent) then return end
        
        timer.Simple(0.1, function()
            if not IsValid(ent) then return end
            if not ent.IsGlideVehicle then return end
            
            -- Skip if restoring
            if restoringVehicles[ent] or ent._RestoreFromDupe then
              --  print("[GLIDE License Plates] Skipping automatic creation - restoration in progress")
                return
            end
            
            if SERVER and GlideLicensePlates.CreateLicensePlates then
                GlideLicensePlates.CreateLicensePlates(ent)
            end
        end)
    end)
    
    -- Clean up on map change
    hook.Add("PreCleanupMap", "GlideLicensePlates.DupeColorCleanup", function()
        duplicatingEntities = {}
        pendingRestores = {}
        restoringVehicles = {}
    end)

    
    -- Advanced Duplicator 2 support
    if AdvDupe2 then
        hook.Add("AdvDupe2_PrePaste", "GlideLicensePlates.AdvDupe2Pre", function(data)
        --    print("[GLIDE License Plates] AdvDupe2 paste starting")
        end)
        
        hook.Add("AdvDupe2_PostPaste", "GlideLicensePlates.AdvDupe2Post", function(data)
        --    print("[GLIDE License Plates] AdvDupe2 paste finished")
            timer.Simple(1, function()
                duplicatingEntities = {}
            end)
        end)
    end
end

print("[GLIDE License Plates] License Plate system loaded correctly.")