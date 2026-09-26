-- lua/entities/glide_license_plate/shared.lua

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "GLIDE License Plate"
ENT.Category = "GLIDE"
ENT.Spawnable = false
ENT.AdminOnly = false

-- License plate properties
ENT.PlateText = ""
ENT.PlateScale = 0.5
ENT.PlateFont = "coolvetica"
ENT.ParentVehicle = NULL
ENT.ModelRotation = Angle(0, 0, 0)
ENT.BasePosition = Vector(0, 0, 0)
ENT.BaseAngles = Angle(0, 0, 0)
ENT.PlateSkin = 0

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "PlateText")
    self:NetworkVar("Float", 0, "PlateScale")
    self:NetworkVar("String", 1, "PlateFont")
    self:NetworkVar("Entity", 0, "ParentVehicle")
    self:NetworkVar("Angle", 0, "ModelRotation")
    self:NetworkVar("Vector", 0, "BasePosition")
    self:NetworkVar("Angle", 1, "BaseAngles")
    self:NetworkVar("Vector", 1, "TextColor")
    self:NetworkVar("Float", 1, "TextAlpha")
    self:NetworkVar("Vector", 2, "TextOffset")
    self:NetworkVar("Int", 0, "PlateSkin")

    -- Setup network var callbacks
    if CLIENT then
        self:NetworkVarNotify("PlateText", function(ent, name, old, new)
            ent.PlateText = new
            ent._cachedTextSize = nil
        end)

        self:NetworkVarNotify("PlateScale", function(ent, name, old, new)
            ent.PlateScale = new
        end)

        self:NetworkVarNotify("PlateFont", function(ent, name, old, new)
            ent.PlateFont = new
            ent._cachedTextSize = nil
        end)

        self:NetworkVarNotify("PlateSkin", function(ent, name, old, new)
            ent.PlateSkin = new
            if IsValid(ent) then
                ent:SetSkin(new)
            end
        end)

        self:NetworkVarNotify("TextColor", function(ent, name, old, new)
            if new then
                ent.CachedTextColor = Color(
                    math.Clamp(math.Round(new.x), 0, 255),
                    math.Clamp(math.Round(new.y), 0, 255),
                    math.Clamp(math.Round(new.z), 0, 255),
                    ent:GetTextAlpha()
                )
            end
        end)

        self:NetworkVarNotify("TextAlpha", function(ent, name, old, new)
            if ent.CachedTextColor then
                ent.CachedTextColor.a = new
            end
        end)

        self:NetworkVarNotify("TextOffset", function(ent, name, old, new)
            ent.TextOffset = new
        end)
    end
end

-- =========================================================================
-- Serialization for Saves and Duplicators
-- =========================================================================

-- Function called when the entity is saved (vanilla save or dupe)
function ENT:Save(table)
    -- Serialize properties that need to persist (Network Variables and local properties)

    table.PlateText = self:GetPlateText()
    table.PlateScale = self:GetPlateScale()
    table.PlateFont = self:GetPlateFont()
    table.PlateSkin = self:GetPlateSkin()
    table.TextColor = self:GetTextColor() -- Vector
    table.TextAlpha = self:GetTextAlpha() -- Float
    table.TextOffset = self:GetTextOffset() -- Vector
    table.ModelRotation = self:GetModelRotation() -- Angle

    -- Glide-specific saved properties
    table.PlateType = self.PlateType
    table.GlideSavedAlpha = self.GlideSavedAlpha
    table.IsHidden = self:GetNoDraw() -- Current visibility state
    table.ManualHide = self.ManualHide  -- Save manual hide state
    table.Model = self:GetModel() -- Also save the current model
end

-- Function called when the entity is restored (vanilla save or dupe)
function ENT:Restore(table)
    -- Deserialize properties and apply them
    self.IsRestored = true -- Flag the entity as being restored

    -- Restore manual hide state
    if table.ManualHide then
        self.ManualHide = table.ManualHide
    end

    if table.Model then
        self:SetModel(table.Model)
    end

    -- Restore all NWVars (Set... functions)
    if table.PlateText then
        self:SetPlateText(table.PlateText)
    end

    if table.PlateScale then
        self:SetPlateScale(table.PlateScale)
    end

    if table.PlateFont then
        self:SetPlateFont(table.PlateFont)
    end

    if table.PlateSkin ~= nil then
        self:SetSkin(table.PlateSkin)
        self:SetPlateSkin(table.PlateSkin)
    end

    if table.TextColor and table.TextAlpha ~= nil then
        self:SetTextColor(table.TextColor)
        self:SetTextAlpha(table.TextAlpha)
    end

    if table.TextOffset then
        self:SetTextOffset(table.TextOffset)
    end

    if table.ModelRotation then
        self:SetModelRotation(table.ModelRotation)
    end

    -- Glide-specific restored properties
    if table.PlateType then
        self.PlateType = table.PlateType
    end
    if table.GlideSavedAlpha ~= nil then
        self.GlideSavedAlpha = table.GlideSavedAlpha
    end

    if table.IsHidden ~= nil then
        local isHidden = tobool(table.IsHidden)
        self:SetNoDraw(isHidden)
        self:SetTextAlpha(isHidden and 0 or (self.GlideSavedAlpha or 255))
        self:SetNotSolid(isHidden)
    end

    if SERVER then
        -- Delay the final setup until the next frame to ensure the parent vehicle is fully restored.
        timer.Simple(0, function()
            if not IsValid(self) then return end

            -- Force-apply the model and rotation via the server update functions
            if self.UpdatePlateModel and table.Model then
                self:UpdatePlateModel(table.Model) -- Updates model and position
            end

            if self.UpdateModelRotation and table.ModelRotation then
                self:UpdateModelRotation(table.ModelRotation)
            end

            -- CRITICAL: Force the text update with the saved text.
            -- This ensures the custom logic of the system applies the restored NWVar.
            if self.UpdatePlateText and table.PlateText then
                self:UpdatePlateText(table.PlateText)
            end
        end)
    end
end

function ENT:Initialize()
    if SERVER then
        -- Plates are purely decorative: no physics object, no collisions.
        -- They follow the vehicle via SetParent (see UpdatePosition).
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        self:SetNotSolid(true)

        -- Default color
        self:SetTextColor(Vector(0, 0, 0))
        self:SetTextAlpha(255)

        self.DoNotDuplicate = true
        self.PhysgunDisabled = true
    else
        -- CLIENT: Initialize local cache
        self.PlateText = self:GetPlateText() or ""
        self.PlateScale = self:GetPlateScale() or 0.5
        self.PlateFont = self:GetPlateFont() or "Arial"
        self.TextOffset = self:GetTextOffset() or Vector(0, 0, 0)
        self.PlateSkin = self:GetPlateSkin() or 0

        local colorVec = self:GetTextColor()
        if colorVec then
            self.CachedTextColor = Color(
                math.Clamp(math.Round(colorVec.x), 0, 255),
                math.Clamp(math.Round(colorVec.y), 0, 255),
                math.Clamp(math.Round(colorVec.z), 0, 255),
                self:GetTextAlpha()
            )
        else
            self.CachedTextColor = Color(0, 0, 0, 255)
        end
    end

    -- Apply initial configuration (without forcing unnecessary updates)
    if self.ModelRotation then
        self:SetModelRotation(self.ModelRotation)
    end
end

if CLIENT then
    local cvEnabled

    function ENT:Draw()
        -- Client-side toggle: skip drawing instead of touching NoDraw,
        -- so it never fights the server-side (bodygroup/tool) visibility state.
        cvEnabled = cvEnabled or GetConVar("glide_license_plates_enabled")
        if cvEnabled and not cvEnabled:GetBool() then return end

        self:DrawModel()
    end

    local nudgePos = Vector()

    -- Plates that follow a bone: the engine only refreshes their position when
    -- the vehicle moves, not when a client-side animation (door pose parameter)
    -- moves the bone. Changing the local pos forces the refresh every frame.
    function ENT:Think()
        if not self:IsEffectActive(EF_FOLLOWBONE) then return end

        local localPos = self:GetLocalPos()
        nudgePos:Set(localPos)
        nudgePos.x = nudgePos.x + 0.01

        self:SetLocalPos(nudgePos)
        self:SetLocalPos(localPos)
    end
end

if SERVER then
    function ENT:OnRemove()
        if IsValid(self.ParentVehicle) then
            local vehicle = self.ParentVehicle

            if GlideLicensePlates and GlideLicensePlates.ActivePlates then
                local vehiclePlates = GlideLicensePlates.ActivePlates[vehicle]
                if vehiclePlates and self.PlateId then
                    vehiclePlates[self.PlateId] = nil
                end
                if not vehiclePlates or not next(vehiclePlates) then
                    GlideLicensePlates.ActivePlates[vehicle] = nil
                end
            end
        end
    end

    -- Bone this plate must follow: an entry of LicensePlateAdvancedConfigs
    -- with this plate's id and a `bone` name (always active, no bodygroup).
    local function GetFollowBoneName(vehicle, plateId)
        local configs = vehicle.LicensePlateAdvancedConfigs
        if not configs or not plateId then return nil end

        for _, config in ipairs(configs) do
            if config.id == plateId and isstring(config.bone) and config.bone ~= "" then
                return config.bone
            end
        end
    end

    -- Keep the plate attached to the vehicle. Parenting makes the engine move
    -- (and transmit) the plate with the vehicle: no per-tick updates needed.
    -- With a `bone` config the plate follows that bone (FollowBone). Positions
    -- stay in vehicle space (bone at rest) and are converted to bone space here.
    function ENT:UpdatePosition()
        local vehicle = self:GetParentVehicle()
        if not IsValid(vehicle) then return end

        local localPos = self:GetBasePosition()
        local localAng = self:GetBaseAngles() + self:GetModelRotation()

        local boneName = GetFollowBoneName(vehicle, self.PlateId)
        local boneId = boneName and vehicle:LookupBone(boneName)

        if boneId and self.FollowBoneId ~= boneId then
            -- Bone transform relative to the vehicle, cached once. Moving parts are
            -- animated client-side, so on the server the bone is at its rest pose.
            local matrix = vehicle:GetBoneMatrix(boneId)
            local restPos, restAng
            if matrix then
                restPos, restAng = WorldToLocal(matrix:GetTranslation(), matrix:GetAngles(), vehicle:GetPos(), vehicle:GetAngles())
            end

            -- GetBoneMatrix can return garbage serverside on some models
            if restPos and restPos:Length() <= vehicle:BoundingRadius() * 2 then
                self.BoneRestPos, self.BoneRestAng = restPos, restAng
                self:FollowBone(vehicle, boneId)
                self.FollowBoneId = boneId
                self.FollowBoneName = boneName
            else
                boneId = nil
            end
        end

        if boneName and not boneId and not self.BoneWarned then
            self.BoneWarned = true
            print("[GLIDE License Plates] Can't follow bone '" .. boneName .. "' on " .. vehicle:GetModel() .. ", plate '" .. tostring(self.PlateId) .. "' stays on the vehicle.")
        end

        if boneId then
            local bonePos, boneAng = WorldToLocal(localPos, localAng, self.BoneRestPos, self.BoneRestAng)
            self:SetLocalPos(bonePos)
            self:SetLocalAngles(boneAng)
            return
        end

        if self.FollowBoneId then
            -- Detach from the bone: SetParent without attachment keeps the bone index
            self:FollowBone(NULL, 0)
            self:SetParent(vehicle, 0)
            self.FollowBoneId, self.FollowBoneName = nil, nil
        elseif self:GetParent() ~= vehicle then
            self:SetParent(vehicle)
        end

        self:SetLocalPos(localPos)
        self:SetLocalAngles(localAng)
    end

    -- Set base position and angles (relative to vehicle)
    function ENT:SetBaseTransform(position, angles)
        if position then
            self.BasePosition = position
            self:SetBasePosition(position)
        end

        if angles then
            self.BaseAngles = angles
            self:SetBaseAngles(angles)
        end

        -- Update position immediately
        self:UpdatePosition()
    end

    function ENT:UpdatePlateText(newText)
        if not newText or newText == "" then return end

        self.PlateText = newText
        self:SetPlateText(newText)
    end

    function ENT:UpdatePlateScale(newScale)
        if not newScale or newScale <= 0 then return end

        self.PlateScale = newScale
        self:SetPlateScale(newScale)
    end

    function ENT:UpdatePlateFont(newFont)
        if not newFont or newFont == "" then return end

        self.PlateFont = newFont
        self:SetPlateFont(newFont)
    end

    function ENT:UpdatePlateSkin(newSkin)
        newSkin = tonumber(newSkin)
        if not newSkin or newSkin < 0 then return end

        self.PlateSkin = newSkin
        self:SetPlateSkin(newSkin)
        self:SetSkin(newSkin)
    end

    function ENT:UpdatePlateModel(newModel)
        if not newModel or newModel == "" then return end
        if not util.IsValidModel(newModel) then return end

        self:SetModel(newModel)

        -- Update position after changing model
        self:UpdatePosition()
    end

    function ENT:UpdatePlateMaterial(newMaterial, plateColor)
        if newMaterial and newMaterial ~= "" then
            self:SetMaterial(newMaterial)
        end

        if plateColor and type(plateColor) == "table" then
            self:SetColor(Color(plateColor.r or 255, plateColor.g or 255, plateColor.b or 255, plateColor.a or 255))
        end
    end

    -- Update model rotation
    function ENT:UpdateModelRotation(newRotation)
        if not newRotation or type(newRotation) ~= "Angle" then return end

        self.ModelRotation = newRotation
        self:SetModelRotation(newRotation)

        -- Update position and angles immediately
        self:UpdatePosition()
    end
end

function ENT:CanTool(ply, trace, tool)
    -- Only allow the plate editor: prevents random tools (material, remover...)
    -- from being applied to plates, which have no CPPI owner of their own.
    return tool == "glide_plate_editor"
end

function ENT:PhysgunPickup(ply)
    return false
end

function ENT:CanProperty(ply, property)
    return false
end
