-- lua/autorun/server/sv_advanced_plate_control.lua
--
-- Bodygroup-driven plate control (visibility / position / rotation).
-- Handles BOTH config keys:
--   * vehicle.LicensePlateAdvancedConfigs  (current)
--   * vehicle.LicensePlateBodygroupConfigs (legacy, kept for third-party vehicles)
-- This file replaces the old separate sv_bodygroup_plate_control.lua system.

-- Only run on server
if not SERVER then return end

-- Store previous bodygroup states for change detection
local vehicleBodygroupCache = {}

-- Get whichever bodygroup config table the vehicle uses (advanced takes priority)
local function GetBodygroupConfigs(vehicle)
    return vehicle.LicensePlateAdvancedConfigs or vehicle.LicensePlateBodygroupConfigs
end

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

    -- O(1) lookup using PlateId as key
    return vehicle.LicensePlateEntities[plate.PlateId] == plate
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
    if not IsValid(vehicle) then return end
    if not vehicle.LicensePlateEntities then return end

    local configs = GetBodygroupConfigs(vehicle)
    if not configs then return end

    -- Iterate through all plates attached to this vehicle
    for id, plate in pairs(vehicle.LicensePlateEntities) do
        if not IsValid(plate) then continue end

        -- Helper: If manually hidden by the tool, skip advanced logic and force hide
        if plate.ManualHide then
            if not plate:GetNoDraw() then
                plate:SetNoDraw(true)
                plate:SetTextAlpha(0)
                plate:SetRenderMode(RENDERMODE_NONE)
            end
            continue
        end

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
                -- Force RenderMode to NONE and disable shadows to prevent client override
                plate:SetRenderMode(RENDERMODE_NONE)
                plate:DrawShadow(false)
            else
                -- SHOW (but modified)
                plate:SetNoDraw(false)
                -- Restore RenderMode and shadows
                plate:SetRenderMode(RENDERMODE_NORMAL)
                plate:DrawShadow(true)

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
            local shouldHide = originalData.IsHidden

            if plate:GetNoDraw() ~= shouldHide then
                plate:SetNoDraw(shouldHide)
                -- Restore visual properties if we are unhiding
                if not shouldHide then
                    plate:SetRenderMode(RENDERMODE_NORMAL)
                    plate:DrawShadow(true)
                else
                    plate:SetRenderMode(RENDERMODE_NONE)
                    plate:DrawShadow(false)
                end
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

-- Function to check for bodygroup changes (polling: neither GMod nor Glide
-- currently fire any hook when a bodygroup changes, so this is the only
-- reliable detection method)
local function CheckBodygroupChanges(vehicle)
    local configs = GetBodygroupConfigs(vehicle)
    if not configs then return end

    if not vehicleBodygroupCache[vehicle] then
        vehicleBodygroupCache[vehicle] = {}
    end

    local cached = vehicleBodygroupCache[vehicle]
    local hasChanges = false

    -- Check each bodygroup referenced in configs
    for _, config in ipairs(configs) do
        if config.bodygroup and type(config.bodygroup) == "table" and #config.bodygroup >= 2 then
            local bgIndex = config.bodygroup[1]
            local currentState = vehicle:GetBodygroup(bgIndex)
            local previousState = cached[bgIndex]

            -- If state changed (or first check)
            if previousState == nil or currentState ~= previousState then
                cached[bgIndex] = currentState
                hasChanges = true
            end
        end
    end

    if hasChanges then
        UpdateVehiclePlatesState(vehicle)
    end
end

-- Smart Initialization (Retry until ready)
-- This fixes the issue of plates not appearing correctly on quick respawns
hook.Add("OnEntityCreated", "GlideLicensePlates.BodygroupInit", function(ent)
    if IsValid(ent) and ent:GetClass() == "glide_license_plate" then

        -- Start a retry loop to wait for the Main Addon to finish setup
        local timerName = "GlideLicensePlates_InitWait_" .. ent:EntIndex()

        timer.Create(timerName, 0.2, 15, function() -- Try every 0.2s, up to 3 seconds
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
            end
        end)
    end
end)

-- Initialize the bodygroup cache for new vehicles.
-- The config check happens inside the timer because configs may be injected
-- after creation (external configs use a 0s timer).
hook.Add("OnEntityCreated", "GlideLicensePlates.BodygroupVehicleInit", function(ent)
    -- Cheap synchronous early-out: skip every non-Glide entity
    if not ent.IsGlideVehicle and not scripted_ents.IsBasedOn(ent:GetClass(), "base_glide") then return end

    timer.Simple(0.5, function()
        if not IsValid(ent) or not ent.IsGlideVehicle then return end

        local configs = GetBodygroupConfigs(ent)
        if not configs then return end

        -- Initialize bodygroup cache
        vehicleBodygroupCache[ent] = {}
        for _, config in ipairs(configs) do
            if config.bodygroup and type(config.bodygroup) == "table" and #config.bodygroup >= 2 then
                local bgIndex = config.bodygroup[1]
                vehicleBodygroupCache[ent][bgIndex] = ent:GetBodygroup(bgIndex)
            end
        end
        -- Apply initial state
        UpdateVehiclePlatesState(ent)
    end)
end)

-- Consolidated timer: change detection + consistency check every 3s
timer.Create("GlideLicensePlates_BodygroupPolling", 3, 0, function()
    if not GlideLicensePlates or not GlideLicensePlates.ActivePlates then return end
    for vehicle, _ in pairs(GlideLicensePlates.ActivePlates) do
        if IsValid(vehicle) and GetBodygroupConfigs(vehicle) then
            CheckBodygroupChanges(vehicle)    -- detects changes, updates on change
            UpdateVehiclePlatesState(vehicle) -- consistency check (watchdog)
        end
    end
end)

-- Cleanup cache when vehicle is removed
hook.Add("EntityRemoved", "GlideLicensePlates.BodygroupCleanup", function(ent)
    if vehicleBodygroupCache[ent] then
        vehicleBodygroupCache[ent] = nil
    end
end)
