-- lua/autorun/server/sv_advanced_plate_control.lua

-- Only run on server
if not SERVER then return end

-- Helper: Check if the plate is fully initialized in the main system
local function IsPlateReady(plate)
    if not IsValid(plate) then return false end
    if not plate.GlideInitialized then return false end    
    
    -- Check if the position is still the default (0,0,0). 
    -- If so, it means the main script hasn't moved it yet.
    if plate:GetBasePosition():IsZero() then return false end

    local vehicle = plate:GetParentVehicle()
    if not IsValid(vehicle) then return false end
    
    -- Check if the main addon has registered this plate in the vehicle's table
    if not vehicle.LicensePlateEntities then return false end
    
    -- Verify this specific plate is in the table
    local found = false
    for k, v in pairs(vehicle.LicensePlateEntities) do
        if v == plate then found = true break end
    end
    
    return found 
end

-- Function to save original structural data (positions) if not present.
local function CacheOriginalData(plate)
    -- Do not cache if the plate is at 0,0,0 (Uninitialized state)
    if plate:GetBasePosition():IsZero() then return end

    -- Only cache if we haven't already AND the plate has a valid position
    if not plate.BodygroupOriginalData then
        plate.BodygroupOriginalData = {
            BasePosition = plate:GetBasePosition(),
            BaseAngles = plate:GetBaseAngles(),
            ModelRotation = plate:GetModelRotation(),
            IsHidden = plate:GetNoDraw(),
            Initialized = true
        }
    end
end

-- Core logic to check bodygroups and update plate visibility/alpha/position
local function UpdateVehiclePlatesState(vehicle)
    if not IsValid(vehicle) or not vehicle.LicensePlateAdvancedConfigs then return end
    if not vehicle.LicensePlateEntities then return end

    local configs = vehicle.LicensePlateAdvancedConfigs

    -- Iterate through all plates attached to this vehicle
    for id, plate in pairs(vehicle.LicensePlateEntities) do
        if not IsValid(plate) then continue end

        -- Ensure data is cached (Safe to call repeatedly, it checks internally)
        CacheOriginalData(plate)
        local originalData = plate.BodygroupOriginalData
        
        -- If for some reason caching failed (e.g., plate is still at 0,0,0), skip this frame
        if not originalData then continue end

        local activeConfig = nil

        -- Find matching config
        for _, config in ipairs(configs) do
            if config.id == id then
                if config.bodygroup and type(config.bodygroup) == "table" and #config.bodygroup >= 2 then
                    local bgIndex = config.bodygroup[1]
                    local bgState = config.bodygroup[2]

                    if vehicle:GetBodygroup(bgIndex) == bgState then
                        activeConfig = config
                        break 
                    end
                end
            end
        end

        -- Apply Logic
        if activeConfig then
            -- A. Handle Visibility and Text Alpha
            if activeConfig.platetoggle == true then
                -- HIDE
                if not plate.GlideSavedAlpha and plate:GetTextAlpha() > 0 then
                     plate.GlideSavedAlpha = plate:GetTextAlpha()
                end
                
                plate:SetNoDraw(true)
                plate:SetTextAlpha(0) 
            else
                -- SHOW (but modified)
                plate:SetNoDraw(false)
                
                if plate.GlideSavedAlpha then
                    plate:SetTextAlpha(plate.GlideSavedAlpha)
                    plate.GlideSavedAlpha = nil
                end
            end

            -- B. Handle Position/Rotation (if not hidden)
            if not activeConfig.platetoggle then
                if activeConfig.newplateposition then
                    plate:SetBasePosition(activeConfig.newplateposition)
                end
                if activeConfig.newplateangles then
                    plate:SetBaseAngles(activeConfig.newplateangles)
                end
                if activeConfig.newplatemodelRotation then
                    plate:SetModelRotation(activeConfig.newplatemodelRotation)
                end
            end
        else
            -- RESTORE DEFAULTS
            if plate:GetNoDraw() ~= originalData.IsHidden then
                plate:SetNoDraw(originalData.IsHidden)
            end
            
            if plate.GlideSavedAlpha then
                plate:SetTextAlpha(plate.GlideSavedAlpha)
                plate.GlideSavedAlpha = nil
            end

            -- Only restore position if the original data is NOT zero (double safety check)
            if not originalData.BasePosition:IsZero() and plate:GetBasePosition() ~= originalData.BasePosition then
                plate:SetBasePosition(originalData.BasePosition)
            end
            if plate:GetBaseAngles() ~= originalData.BaseAngles then
                plate:SetBaseAngles(originalData.BaseAngles)
            end
            if plate:GetModelRotation() ~= originalData.ModelRotation then
                plate:SetModelRotation(originalData.ModelRotation)
            end
        end
        
        -- Update position immediately
        if plate.UpdatePosition then
            plate:UpdatePosition()
        end
    end
end

-- Hook 1: Run when a bodygroup changes
hook.Add("EntityBodygroupChanged", "GlidePlates_BodygroupChanged", function(ent, index, state)
    if IsValid(ent) and ent:IsVehicle() and ent.LicensePlateAdvancedConfigs then
        timer.Simple(0.1, function() 
            if IsValid(ent) then UpdateVehiclePlatesState(ent) end
        end)
    end
end)

-- Hook 2: Smart Initialization (Retry until ready)
hook.Add("OnEntityCreated", "GlidePlates_BodygroupInit", function(ent)
    if IsValid(ent) and ent:GetClass() == "glide_license_plate" then
        
        -- Start a retry loop to wait for the Main Addon to finish setup
        local attempts = 0
        local timerName = "GlidePlates_InitWait_" .. ent:EntIndex()
        
        timer.Create(timerName, 0.2, 15, function() 
            if not IsValid(ent) then 
                timer.Remove(timerName) 
                return 
            end

            if IsPlateReady(ent) then
                if ent.UpdatePosition then
                    ent:UpdatePosition()
                end
                
                -- System is ready, cache data and apply logic
                local vehicle = ent:GetParentVehicle()
                UpdateVehiclePlatesState(vehicle)
                timer.Remove(timerName)
            else
                attempts = attempts + 1
            end
        end)
    end
end)

-- Hook 3: Watchdog
timer.Create("GlidePlates_BodygroupWatchdog", 3, 0, function()
    if GlideLicensePlates and GlideLicensePlates.ActivePlates then
        for vehicle, _ in pairs(GlideLicensePlates.ActivePlates) do
            if IsValid(vehicle) and vehicle.LicensePlateAdvancedConfigs then
                UpdateVehiclePlatesState(vehicle)
            end
        end
    end
end)