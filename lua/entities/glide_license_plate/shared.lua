-- lua/entities/glide_license_plate/shared.lua

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
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
end
 
function ENT:Initialize()
    if SERVER then
        self:SetModel("")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WORLD)
        
        self:SetNotSolid(true)

        -- Default color
        self:SetTextColor(Vector(0, 0, 0))
        self:SetTextAlpha(255)

        self.DoNotDuplicate = true
        self.PhysgunDisabled = true
        
        -- Force network variable updates
        timer.Simple(0, function()
            if IsValid(self) then
                -- Trigger network update
                self:SetPlateText(self.PlateText or "")
                self:SetPlateScale(self.PlateScale or GlideLicensePlates.Config.DefaultScale)
                self:SetPlateFont(self.PlateFont or GlideLicensePlates.Config.DefaultFont)
            end
        end)
    else
        -- CLIENT: Initialize local cache
        self.PlateText = ""
        self.PlateScale = 0.5
        self.PlateFont = "Arial"
        self.CachedTextColor = Color(0, 0, 0, 255)
    end
     
    -- Apply initial configuration
    if self.PlateText and self.PlateText ~= "" then
        self:SetPlateText(self.PlateText)
    end
    if self.PlateScale and self.PlateScale > 0 then
        self:SetPlateScale(self.PlateScale)
    end
    if self.PlateFont and self.PlateFont ~= "" then
        self:SetPlateFont(self.PlateFont)
    end
    self:SetModelRotation(self.ModelRotation or Angle(0, 0, 0))
    
    if IsValid(self.ParentVehicle) then
        self:SetParentVehicle(self.ParentVehicle)
    end
end
-- Force network variable synchronization
function ENT:OnEntityDataUpdate(key)
    if CLIENT then
        -- Force update local cache when network vars change
        if key == "PlateText" then
            self.PlateText = self:GetPlateText()
        elseif key == "PlateScale" then
            self.PlateScale = self:GetPlateScale()
        elseif key == "PlateFont" then
            self.PlateFont = self:GetPlateFont()
        elseif key == "TextColor" then
            -- Force color update
            local colorVec = self:GetTextColor()
            if colorVec then
                self.CachedTextColor = Color(colorVec.x, colorVec.y, colorVec.z, self:GetTextAlpha())
            end
        end
    end
end
function ENT:UpdatePosition()
    if not IsValid(self:GetParentVehicle()) then return end
    
    local vehicle = self:GetParentVehicle()
    local basePos = self:GetBasePosition()
    local baseAng = self:GetBaseAngles()
    local modelRot = self:GetModelRotation()
    
	-- Calculate world position from vehicle's base position 
    local worldPos = vehicle:LocalToWorld(basePos)
    
	-- Calculate final angles combining base + rotation of the model
    local finalAngles = vehicle:LocalToWorldAngles(baseAng + modelRot)
    
    -- Apply position and angles
    self:SetPos(worldPos)
    self:SetAngles(finalAngles)
end

if CLIENT then
    -- Track if entity is ready for rendering
    ENT.ReadyForRender = false
    ENT.InitAttempts = 0
    
    function ENT:Draw()
        -- Draw model
        self:DrawModel()
        return
    end
    
    function ENT:Think()
        -- Update local properties from network variables
        local hasAllData = true
        
        if self:GetPlateText() ~= "" then
            self.PlateText = self:GetPlateText()
        else
            hasAllData = false
        end
        
        if self:GetPlateScale() > 0 then
            self.PlateScale = self:GetPlateScale()
        else
            hasAllData = false
        end
        
        if self:GetPlateFont() ~= "" then
            self.PlateFont = self:GetPlateFont()
        else
            hasAllData = false
        end
        
        if self:GetModelRotation() then
            self.ModelRotation = self:GetModelRotation()
        end
        
        -- Check if color data is available
        local colorVec = self:GetTextColor()
        if colorVec and (colorVec.x > 0 or colorVec.y > 0 or colorVec.z > 0 or self:GetTextAlpha() < 255) then
            -- Color data is present
        else
            hasAllData = false
        end
        
        if IsValid(self:GetParentVehicle()) then
            self.ParentVehicle = self:GetParentVehicle()
            -- Update position continuously
            self:UpdatePosition()
        else
            hasAllData = false
        end
        
        -- Mark as ready when all data is available
        if hasAllData then
            self.ReadyForRender = true
            self.InitAttempts = 0
        else
            self.InitAttempts = (self.InitAttempts or 0) + 1
            -- Force ready after 50 attempts (5 seconds) to prevent permanent invisibility
            if self.InitAttempts > 50 then
                self.ReadyForRender = true
            end
        end
        
        return true
    end
end

if SERVER then
    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end
    
    function ENT:OnRemove()
        if IsValid(self.ParentVehicle) then
            self.ParentVehicle.LicensePlateEntity = nil
            
            if GlideLicensePlates and GlideLicensePlates.ActivePlates then
                GlideLicensePlates.ActivePlates[self.ParentVehicle] = nil
            end
        end
    end
    
    function ENT:Think()
	
        -- Update position in the server
        if IsValid(self:GetParentVehicle()) then
            self:UpdatePosition()
        end
        
        return true
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
        
        -- Update position inmediately
        self:UpdatePosition()
    end
    
    function ENT:UpdatePlateText(newText)
        if not newText or newText == "" then return end
        
        self.PlateText = newText
        self:SetPlateText(newText)
        
        if IsValid(self.ParentVehicle) then
            self.ParentVehicle.LicensePlateText = newText
        end
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
    
    function ENT:SetParentVehicle(vehicle)
        if not IsValid(vehicle) then return end
        
        self.ParentVehicle = vehicle
        self:SetParentVehicle(vehicle)
        
        vehicle:DeleteOnRemove(self)
    end
    
    function ENT:UpdatePlateModel(newModel)
        if not newModel or newModel == "" then return end
        if not util.IsValidModel(newModel) then return end
        
        self:SetModel(newModel)
        self:PhysicsInit(SOLID_VPHYSICS)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Sleep()
        end
        
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
        
        -- Update position and angles inmediately
        self:UpdatePosition()
        
      --  print("[GLIDE License Plates] Rotación actualizada a: P=" .. newRotation.p .. " Y=" .. newRotation.y .. " R=" .. newRotation.r)
    end
end

-- Prevent toolgun, physgun and dupe interactions
function ENT:CanTool(ply, trace, tool)
    return true
end

function ENT:PhysgunPickup(ply)
    return false
end

function ENT:CanProperty(ply, property)
    return false
end