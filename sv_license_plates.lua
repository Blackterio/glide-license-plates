-- lua/glide_license_plates/server/sv_license_plates.lua

-- Timer to update positions 
local function StartPlateUpdateTimer()
    if timer.Exists("GlideLicensePlates_UpdateAll") then return end
    
    timer.Create("GlideLicensePlates_UpdateAll", 0.1, 0, function() -- 10 FPS para posiciones
        if not GlideLicensePlates or not GlideLicensePlates.ActivePlates then return end
        
        for vehicle, plateEntities in pairs(GlideLicensePlates.ActivePlates) do
            if IsValid(vehicle) and plateEntities then
                for plateId, plateEntity in pairs(plateEntities) do
                    if IsValid(plateEntity) and plateEntity.UpdatePosition then
                        plateEntity:UpdatePosition()
                    else
                        -- Clean invalid references
                        plateEntities[plateId] = nil
                    end
                end
                
                -- If there's not valid plates, clean vehicle
                if table.IsEmpty(plateEntities) then
                    GlideLicensePlates.ActivePlates[vehicle] = nil
                end
            else
                -- Clean invalid references
                GlideLicensePlates.ActivePlates[vehicle] = nil
            end
        end
        
        -- If there's not active plates, stop timer
        if table.IsEmpty(GlideLicensePlates.ActivePlates) then
            timer.Remove("GlideLicensePlates_UpdateAll")
        end
    end)
end

-- Start timer when needed
hook.Add("Think", "GlideLicensePlates.CheckForTimer", function()
    if GlideLicensePlates and GlideLicensePlates.ActivePlates then
        if not table.IsEmpty(GlideLicensePlates.ActivePlates) then
            StartPlateUpdateTimer()
        end
    end
end)

-- Commands

-- To get vehicle and plate from trace (player's pov)
local function GetVehicleAndPlateFromTrace(ply)
    local trace = ply:GetEyeTrace()
    local vehicle = trace.Entity
    local plateId = nil
    local plateEntity = nil
    
    -- If points directly to a plate
    if IsValid(vehicle) and vehicle:GetClass() == "glide_license_plate" then
        plateEntity = vehicle
        plateId = plateEntity.PlateId
        vehicle = plateEntity:GetParentVehicle()
    end
    
    if not IsValid(vehicle) or not vehicle.IsGlideVehicle or (not vehicle.LicensePlateConfigs and not vehicle.LicensePlateConfig) then
        return nil, nil, nil, "You must look at a valid Glide vehicle with the license plate system."
    end
    
    -- If didn't point to a specific plate, use the first one
    if not plateId then
        if vehicle.LicensePlateEntities then
            for id, entity in pairs(vehicle.LicensePlateEntities) do
                if IsValid(entity) then
                    plateId = id
                    plateEntity = entity
                    break
                end
            end
        elseif IsValid(vehicle.LicensePlateEntity) then
            plateEntity = vehicle.LicensePlateEntity
            plateId = "main"
        end
    end
    
    return vehicle, plateId, plateEntity, nil
end

-- Command to change a specific plate
concommand.Add("glide_change_plate", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        return
    end
    
    if not args[1] then
        ply:ChatPrint("[GLIDE License Plates] Use: glide_change_plate 'new text' 'plate_id'")
        return
    end
    
    local vehicle, plateId, plateEntity, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    -- If plate ID was specified
    if args[2] then
        plateId = args[2]
        plateEntity = GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
        if not IsValid(plateEntity) then
            ply:ChatPrint("[GLIDE License Plates] Couldn't find license plate with ID: " .. plateId)
            return
        end
    end
    
    local newText = args[1]
    if string.len(newText) > (GlideLicensePlates.Config.MaxCharacters or 8) then
        ply:ChatPrint("[GLIDE License Plates] Text is too long (8 characters max).")
        return
    end
    
    -- Update text
    if vehicle.LicensePlateTexts then
        vehicle.LicensePlateTexts[plateId] = newText
    elseif plateId == "main" then
        vehicle.LicensePlateText = newText
    end
    
    -- Recreate specific plate
    if IsValid(plateEntity) then
        plateEntity:UpdatePlateText(newText)
        ply:ChatPrint("[GLIDE License Plates] License plate '" .. plateId .. "' changed to: " .. newText)
    else
        ply:ChatPrint("[GLIDE License Plates] Error updating the plate.")
    end
end)

-- Command to regenerate a specific plate
concommand.Add("glide_random_plate", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local vehicle, plateId, plateEntity, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    if vehicle:GetCreator() ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[GLIDE License Plates] Only vehicle owner or an admin can do this.")
        return
    end
    
    -- If plate ID was specified
    if args[1] then
        plateId = args[1]
        plateEntity = GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
        if not IsValid(plateEntity) then
            ply:ChatPrint("[GLIDE License Plates] Couldn't find license plate with ID: " .. plateId)
            return
        end
    end
    
    -- Get plate configuration
    local config = nil
    if vehicle.LicensePlateConfigs then
        for _, cfg in ipairs(vehicle.LicensePlateConfigs) do
            if cfg.id == plateId then
                config = cfg
                break
            end
        end
    elseif vehicle.LicensePlateConfig then
        config = vehicle.LicensePlateConfig
    end
    
    if not config then
        ply:ChatPrint("[GLIDE License Plates] Couldn't find license plate configuration.")
        return
    end
    
    -- Generate new text and type
    local newText, selectedType = GlideLicensePlates.GeneratePlate(config.plateType or "argmercosur")
    
    -- Update text and type stored
    if vehicle.LicensePlateTexts then
        vehicle.LicensePlateTexts[plateId] = newText
    elseif plateId == "main" then
        vehicle.LicensePlateText = newText
    end
    
    -- Update selected type
    if vehicle.SelectedPlateTypes then
        vehicle.SelectedPlateTypes[plateId] = selectedType
    end
    
    -- Update license plate
    if IsValid(plateEntity) then
        plateEntity:UpdatePlateText(newText)
        plateEntity.PlateType = selectedType
        
        -- Get correct model for selected type
        local plateModel = nil
        
        if config.customModel and config.customModel ~= "" and util.IsValidModel(config.customModel) then
            plateModel = config.customModel
        --    print("[GLIDE License Plates] Keeping custom model: " .. plateModel)
        else
            if GlideLicensePlates.PlateTypes[selectedType] and GlideLicensePlates.PlateTypes[selectedType].model then
                plateModel = GlideLicensePlates.PlateTypes[selectedType].model
            --    print("[GLIDE License Plates] New model for type " .. selectedType .. ": " .. plateModel)
            else
                plateModel = GlideLicensePlates.Config.DefaultModel
            --    print("[GLIDE License Plates] Using default model: " .. plateModel)
            end
        end
        
        -- Update model if needed
        if plateEntity:GetModel() ~= plateModel then
        --    print("[GLIDE License Plates] Changing model of " .. plateEntity:GetModel() .. " to " .. plateModel)
            plateEntity:UpdatePlateModel(plateModel)
        else
        --    print("[GLIDE License Plates] Model is already valid: " .. plateModel)
        end
        
        ply:ChatPrint("[GLIDE License Plates] New plate generated for '" .. plateId .. "': " .. newText .. " (type: " .. selectedType .. ")")
    else
        ply:ChatPrint("[GLIDE License Plates] Error updating the plate.")
    end
end)


-- Command to update specific plate's text color
concommand.Add("glide_change_text_color", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[GLIDE License Plates] Only admins can use this.")
        return
    end
    
    if not args[1] or not args[2] or not args[3] then
        ply:ChatPrint("[GLIDE License Plates] Use: glide_change_text_color <r> <g> <b> [a] [plate_id]")
        ply:ChatPrint("Values from 0 to 255. Alpha is optional (dafault is 255)")
        return
    end
    
    local vehicle, plateId, plateEntity, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    -- If plate ID was specified
    if args[5] then
        plateId = args[5]
        plateEntity = GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
        if not IsValid(plateEntity) then
            ply:ChatPrint("[GLIDE License Plates] Couldn't find license plate with ID: " .. plateId)
            return
        end
    end
    
    local r = math.Clamp(tonumber(args[1]) or 0, 0, 255)
    local g = math.Clamp(tonumber(args[2]) or 0, 0, 255)
    local b = math.Clamp(tonumber(args[3]) or 0, 0, 255)
    local a = math.Clamp(tonumber(args[4]) or 255, 0, 255)
    
    -- Update vehicle's configuration
    local targetConfig = nil
    if vehicle.LicensePlateConfigs then
        for _, config in ipairs(vehicle.LicensePlateConfigs) do
            if config.id == plateId then
                targetConfig = config
                break
            end
        end
    elseif vehicle.LicensePlateConfig then
        targetConfig = vehicle.LicensePlateConfig
    end
    
    if targetConfig then
        if not targetConfig.textColor then
            targetConfig.textColor = {}
        end
        
        targetConfig.textColor.r = r
        targetConfig.textColor.g = g
        targetConfig.textColor.b = b
        targetConfig.textColor.a = a
    end
    
    -- Update existing plate
    if IsValid(plateEntity) then
        plateEntity:SetTextColor(Vector(r, g, b))
        plateEntity:SetTextAlpha(a)
        
        -- Also update local properties
        plateEntity.TextColorR = r
        plateEntity.TextColorG = g
        plateEntity.TextColorB = b
        plateEntity.TextColorA = a
        
        ply:ChatPrint(string.format("[GLIDE License Plates] Text color of '%s' changed to: R=%d G=%d B=%d A=%d", plateId, r, g, b, a))
    else
        ply:ChatPrint("[GLIDE License Plates] Error: Couldn't find plate's entity.")
    end
end)

-- Command to list all plates of the vehicle
concommand.Add("glide_list_plates", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        return
    end
    
    local vehicle, _, _, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    ply:ChatPrint("====== VEHICLE LICENSE PLATES ======")
    
    local count = 0
    if vehicle.LicensePlateEntities then
        for plateId, plateEntity in pairs(vehicle.LicensePlateEntities) do
            count = count + 1
            local text = vehicle.LicensePlateTexts and vehicle.LicensePlateTexts[plateId] or "No Text"
            local plateType = vehicle.SelectedPlateTypes and vehicle.SelectedPlateTypes[plateId] or "unknown"
            local status = IsValid(plateEntity) and "VALID" or "INVALID"
            ply:ChatPrint(string.format("ID: %s | Text: %s | Type: %s | Status: %s", plateId, text, plateType, status))
        end
    elseif IsValid(vehicle.LicensePlateEntity) then
        count = 1
        local text = vehicle.LicensePlateText or "No Text"
        local plateType = vehicle.LicensePlateType or "unknown"
        ply:ChatPrint(string.format("ID: main | Text: %s | Type: %s | Status: VALID", text, plateType))
    end
    
    if count == 0 then
        ply:ChatPrint("Couldn't find any license plates in this vehicle.")
    else
        ply:ChatPrint("License plates total: " .. count)
    end
    ply:ChatPrint("========================================")
end)


-- Command to delete a specific plate
concommand.Add("glide_remove_plate", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[GLIDE License Plates] Only admins can use this.")
        return
    end
    
    if not args[1] then
        ply:ChatPrint("[GLIDE License Plates] Us: glide_remove_plate <plate_id>")
        return
    end
    
    local vehicle, _, _, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    local plateId = args[1]
    
    if GlideLicensePlates.RemoveSpecificPlate then
        GlideLicensePlates.RemoveSpecificPlate(vehicle, plateId)
        ply:ChatPrint("[GLIDE License Plates] Plate '" .. plateId .. "' removed.")
    else
        ply:ChatPrint("[GLIDE License Plates] Error: Function not available.")
    end
end)

-- Command to regenerate all plates
concommand.Add("glide_recreate_plates", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[GLIDE License Plates] Only admins can use this.")
        return
    end
    
    local vehicle, _, _, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    -- Delete all existing license plates 
    if GlideLicensePlates.RemoveLicensePlates then
        GlideLicensePlates.RemoveLicensePlates(vehicle)
    end
    
    -- Recreate all plates
    timer.Simple(0.2, function()
        if IsValid(vehicle) and GlideLicensePlates.CreateLicensePlates then
            GlideLicensePlates.CreateLicensePlates(vehicle)
            ply:ChatPrint("[GLIDE License Plates] All license plates have been recreated.")
        end
    end)
end)
-- Debug command to check network vars
concommand.Add("glide_debug_plate", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local vehicle, plateId, plateEntity, error = GetVehicleAndPlateFromTrace(ply)
    if error then
        ply:ChatPrint("[GLIDE License Plates] " .. error)
        return
    end
    
    if args[1] then
        plateId = args[1]
        plateEntity = GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
    end
    
    if not IsValid(plateEntity) then
        ply:ChatPrint("[GLIDE License Plates] Invalid plate entity")
        return
    end
    
    ply:ChatPrint("====== PLATE DEBUG INFO ======")
    ply:ChatPrint("Plate ID: " .. tostring(plateId))
    ply:ChatPrint("Network Vars:")
    ply:ChatPrint("  PlateText: " .. tostring(plateEntity:GetPlateText()))
    ply:ChatPrint("  PlateScale: " .. tostring(plateEntity:GetPlateScale()))
    ply:ChatPrint("  PlateFont: " .. tostring(plateEntity:GetPlateFont()))
    ply:ChatPrint("Local Properties:")
    ply:ChatPrint("  plateEntity.PlateText: " .. tostring(plateEntity.PlateText))
    ply:ChatPrint("  plateEntity.PlateScale: " .. tostring(plateEntity.PlateScale))
    ply:ChatPrint("  plateEntity.PlateFont: " .. tostring(plateEntity.PlateFont))
    ply:ChatPrint("Color:")
    local colorVec = plateEntity:GetTextColor()
    if colorVec then
        ply:ChatPrint("  RGB: " .. math.Round(colorVec.x) .. ", " .. math.Round(colorVec.y) .. ", " .. math.Round(colorVec.z))
        ply:ChatPrint("  Alpha: " .. tostring(plateEntity:GetTextAlpha()))
    end
    ply:ChatPrint("===============================")
end)

-- Cleanup timer when map is changed
hook.Add("PreCleanupMap", "GlideLicensePlates.CleanupTimer", function()
    timer.Remove("GlideLicensePlates_UpdateAll")
    if GlideLicensePlates and GlideLicensePlates.ActivePlates then
        table.Empty(GlideLicensePlates.ActivePlates)
    end
end)

print("[GLIDE License Plates] Server commands loaded.") 