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
	self:NetworkVar("Vector", 2, "TextOffset") 
    
    -- Setup network var callbacks
    if CLIENT then
        self:NetworkVarNotify("PlateText", function(ent, name, old, new)
            ent.PlateText = new
        end)
        
        self:NetworkVarNotify("PlateScale", function(ent, name, old, new)
            ent.PlateScale = new
        end)
        
        self:NetworkVarNotify("PlateFont", function(ent, name, old, new)
            ent.PlateFont = new
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
    
    -- Save Support
    if SERVER then

        local VehicleMeta = FindMetaTable("Entity")
        if VehicleMeta then
          
            local function GLIDESave_TransferPlateData(entity, saveTable)
                if IsValid(entity.LicensePlateEntity) and entity.LicensePlateEntity:GetClass() == "glide_license_plate" then
                    local plate = entity.LicensePlateEntity
                    
                    saveTable.GLIDE_PlateText = plate:GetPlateText()
                    saveTable.GLIDE_PlateScale = plate:GetPlateScale()
                    saveTable.GLIDE_PlateFont = plate:GetPlateFont()
                    saveTable.GLIDE_ModelRotation = plate:GetModelRotation()
                    saveTable.GLIDE_BasePosition = plate:GetBasePosition()
                    saveTable.GLIDE_BaseAngles = plate:GetBaseAngles()
                    saveTable.GLIDE_TextColor = plate:GetTextColor()
                    saveTable.GLIDE_TextAlpha = plate:GetTextAlpha()
                    saveTable.GLIDE_TextOffset = plate:GetTextOffset()
                    
                    saveTable.GLIDE_PlateModel = plate:GetModel()
                    saveTable.GLIDE_PlateMaterial = plate:GetMaterial()
                    
                    saveTable.GLIDE_HasLicensePlate = true
                end
            end

            if IsValid(self:GetParentVehicle()) then

                self:GetParentVehicle().GLIDE_LicensePlate_PopulateSaveTable = GLIDESave_TransferPlateData
            end
        end
    end
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
    else
        -- CLIENT: Initialize local cache
        self.PlateText = self:GetPlateText() or ""
        self.PlateScale = self:GetPlateScale() or 0.5
        self.PlateFont = self:GetPlateFont() or "Arial"
		self.TextOffset = self:GetTextOffset() or Vector(0, 0, 0) 
		
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
    
    if IsValid(self.ParentVehicle) then
        self:SetParentVehicle(self.ParentVehicle)
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
        
        local netText = self:GetPlateText()
        if netText and netText ~= "" then
            self.PlateText = netText
        else
            hasAllData = false
        end
        
        local netScale = self:GetPlateScale()
        if netScale and netScale > 0 then
            self.PlateScale = netScale
        else
            hasAllData = false
        end
        
        local netFont = self:GetPlateFont()
        if netFont and netFont ~= "" then
            self.PlateFont = netFont
        else
            hasAllData = false
        end
        
        local netModelRot = self:GetModelRotation()
        if netModelRot then
            self.ModelRotation = netModelRot
        end
        
        -- Check if color data is available
        local colorVec = self:GetTextColor()
        if colorVec then
            local alpha = self:GetTextAlpha()
            self.CachedTextColor = Color(
                math.Clamp(math.Round(colorVec.x), 0, 255),
                math.Clamp(math.Round(colorVec.y), 0, 255),
                math.Clamp(math.Round(colorVec.z), 0, 255),
                alpha or 255
            )
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
        -- Remove the reference from the parent vehicle when the plate is removed
        if IsValid(self.ParentVehicle) then
            self.ParentVehicle.LicensePlateEntity = nil
            
            if GlideLicensePlates and GlideLicensePlates.ActivePlates then
                GlideLicensePlates.ActivePlates[self.ParentVehicle] = nil
            end
        end
    end
    
    function ENT:Think()
        -- Update position in the server (for physics/network sync)
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
        
        -- Update position immediately
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
        
        -- Make the plate delete when the vehicle is deleted
        vehicle:DeleteOnRemove(self)
        
        -- Assign the license plate entity to the vehicle (CRUCIAL for saving)
        vehicle.LicensePlateEntity = self
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
        
        -- Update position and angles immediately
        self:UpdatePosition()
    end
end

function ENT:CanTool(ply, trace, tool)
    return true
end

function ENT:PhysgunPickup(ply)
    return false
end

function ENT:CanProperty(ply, property)
    return false
end
