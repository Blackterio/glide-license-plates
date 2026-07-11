-- lua/glide_license_plates/server/sv_license_plates.lua

-- NOTE: plates are parented to their vehicle (see ENT:UpdatePosition), so there
-- is no position-update timer anymore: the engine moves them with the vehicle.

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

    if not IsValid(vehicle) or not vehicle.IsGlideVehicle or not vehicle.LicensePlateConfigs then
        return nil, nil, nil, "You must look at a valid Glide vehicle with the license plate system."
    end

    -- If didn't point to a specific plate, use the first one
    if not plateId and vehicle.LicensePlateEntities then
        for id, entity in pairs(vehicle.LicensePlateEntities) do
            if IsValid(entity) then
                plateId = id
                plateEntity = entity
                break
            end
        end
    end

    return vehicle, plateId, plateEntity, nil
end

-- Persist current plate state for the duplicator (debounced, defined in the autorun file)
local function SavePlateData(vehicle)
    if GlideLicensePlates.SavePlateData then
        GlideLicensePlates.SavePlateData(vehicle)
    end
end

-- Command to change a specific plate
concommand.Add("glide_change_plate", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        return
    end

    if not args[1] or #args[1] == 0 then
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

    local maxCharacters = GlideLicensePlates.Config.MaxCharacters or 20
    local newText = args[1]
    if string.len(newText) > maxCharacters then
        ply:ChatPrint("[GLIDE License Plates] Text is too long (" .. maxCharacters .. " characters max).")
        return
    end

    -- Update text
    if vehicle.LicensePlateTexts then
        vehicle.LicensePlateTexts[plateId] = newText
    end

    -- Mark as manually-set: type changes will preserve this text
    vehicle.PlateHasCustomText = vehicle.PlateHasCustomText or {}
    vehicle.PlateHasCustomText[plateId] = true

    -- Recreate specific plate
    if IsValid(plateEntity) then
        plateEntity:UpdatePlateText(newText)
        SavePlateData(vehicle)
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
    end

    -- The text is random again: clear the manually-set flag
    if vehicle.PlateHasCustomText then
        vehicle.PlateHasCustomText[plateId] = nil
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
        else
            if GlideLicensePlates.PlateTypes[selectedType] and GlideLicensePlates.PlateTypes[selectedType].model then
                plateModel = GlideLicensePlates.PlateTypes[selectedType].model
            else
                plateModel = GlideLicensePlates.Config.DefaultModel
            end
        end

        -- Update model if needed
        if plateEntity:GetModel() ~= plateModel then
            plateEntity:UpdatePlateModel(plateModel)
        end

        -- Update skin for the new type
        local newSkin = GlideLicensePlates.GetPlateSkin(selectedType, config.customSkin)
        plateEntity:UpdatePlateSkin(newSkin)

        -- Store the new skin
        if vehicle.SelectedPlateSkins then
            vehicle.SelectedPlateSkins[plateId] = newSkin
        end

        SavePlateData(vehicle)

        ply:ChatPrint("[GLIDE License Plates] New plate generated for '" .. plateId .. "': " .. newText .. " (type: " .. selectedType .. ", skin: " .. newSkin .. ")")
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
        ply:ChatPrint("Values from 0 to 255. Alpha is optional (default is 255)")
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

        SavePlateData(vehicle)

        ply:ChatPrint(string.format("[GLIDE License Plates] Text color of '%s' changed to: R=%d G=%d B=%d A=%d", plateId, r, g, b, a))
    else
        ply:ChatPrint("[GLIDE License Plates] Error: Couldn't find plate's entity.")
    end
end)

-- Command to change plate skin
concommand.Add("glide_change_plate_skin", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[GLIDE License Plates] Only admins can use this.")
        return
    end

    if not args[1] then
        ply:ChatPrint("[GLIDE License Plates] Use: glide_change_plate_skin <skin_number> [plate_id]")
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

    local newSkin = math.max(0, tonumber(args[1]) or 0)

    -- Update vehicle's configuration
    local targetConfig = nil
    if vehicle.LicensePlateConfigs then
        for _, config in ipairs(vehicle.LicensePlateConfigs) do
            if config.id == plateId then
                targetConfig = config
                break
            end
        end
    end

    if targetConfig then
        targetConfig.customSkin = newSkin
    end

    -- Update existing plate
    if IsValid(plateEntity) then
        plateEntity:UpdatePlateSkin(newSkin)

        -- Store the new skin
        if vehicle.SelectedPlateSkins then
            vehicle.SelectedPlateSkins[plateId] = newSkin
        end

        SavePlateData(vehicle)

        ply:ChatPrint(string.format("[GLIDE License Plates] Skin of '%s' changed to: %d", plateId, newSkin))
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
            local plateSkin = vehicle.SelectedPlateSkins and vehicle.SelectedPlateSkins[plateId] or 0
            local status = IsValid(plateEntity) and "VALID" or "INVALID"
            ply:ChatPrint(string.format("ID: %s | Text: %s | Type: %s | Skin: %d | Status: %s", plateId, text, plateType, plateSkin, status))
        end
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
        ply:ChatPrint("[GLIDE License Plates] Use: glide_remove_plate <plate_id>")
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
        SavePlateData(vehicle)
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
            SavePlateData(vehicle)
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
    ply:ChatPrint("  PlateSkin: " .. tostring(plateEntity:GetPlateSkin()))
    ply:ChatPrint("Local Properties:")
    ply:ChatPrint("  plateEntity.PlateText: " .. tostring(plateEntity.PlateText))
    ply:ChatPrint("  plateEntity.PlateScale: " .. tostring(plateEntity.PlateScale))
    ply:ChatPrint("  plateEntity.PlateFont: " .. tostring(plateEntity.PlateFont))
    ply:ChatPrint("  plateEntity.PlateSkin: " .. tostring(plateEntity.PlateSkin))
    ply:ChatPrint("Color:")
    local colorVec = plateEntity:GetTextColor()
    if colorVec then
        ply:ChatPrint("  RGB: " .. math.Round(colorVec.x) .. ", " .. math.Round(colorVec.y) .. ", " .. math.Round(colorVec.z))
        ply:ChatPrint("  Alpha: " .. tostring(plateEntity:GetTextAlpha()))
    end
    ply:ChatPrint("===============================")
end)

print("[GLIDE License Plates] Server commands loaded.")
