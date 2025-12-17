-- lua/weapons/gmod_tool/stools/glide_plate_editor.lua

TOOL.Category = "Glide"
TOOL.Name = "License Plate Editor"
TOOL.Command = nil
TOOL.ConfigName = "" 

-- Using localization keys for description and info
TOOL.Description = "#tool.glide_plate_editor.desc"
TOOL.Info = "#tool.glide_plate_editor.desc"


local ToolDefaults = {
    type = "mercosur plate",
    text = "",
    scale = 0.5,
    skin = 0,
    font = "Arial",
    hidden = 0,
    offset_x = 0,
    offset_y = 0,
    offset_z = 0,
    color_r = 0,
    color_g = 0,
    color_b = 0,
    color_a = 255
}

-- Assign the local table to the tool's variable
TOOL.ClientConVar = ToolDefaults

local usasmallplatemodel = "models/blackterios_glide_vehicles/licenseplates/smallplate.mdl"
local europeanlongplatemodel = "models/blackterios_glide_vehicles/licenseplates/europeplate.mdl"
local mercosurplatemodel = "models/blackterios_glide_vehicles/licenseplates/mercosurplate.mdl"
local argentinasmallplatemodel = "models/blackterios_glide_vehicles/licenseplates/argentinaold.mdl"
local argentinablacklongplatemodel = "models/blackterios_glide_vehicles/licenseplates/argentinavintage.mdl"

-- Define the allowed types and their models for filtering and model setting
local ALLOWED_PLATES = {
    ["usa small plate"] = {
        label = "usa small plate",
        model = usasmallplatemodel
    },
    ["european long plate"] = {
        label = "european long plate",
        model = europeanlongplatemodel
    },
    ["mercosur plate"] = {
        label = "mercosur plate",
        model = mercosurplatemodel
    },
    ["argentina small plate"] = {
        label = "argentina small plate",
        model = argentinasmallplatemodel
    },
    ["black long plate"] = {
        label = "black long plate",
        model = argentinablacklongplatemodel
    }
}

if CLIENT then
    -- Tool translations are now handled by localization files (e.g., glide_license_plates_languages.properties)
    -- The previous language.Add calls for tool properties and UI labels are now unnecessary 
    -- as the localization keys (#tool.glide_plate_editor.desc, #glide_pe_header_select, etc.) 
    -- are used directly in the code or automatically by the tool system.
end

-- Networking setup
if SERVER then
    util.AddNetworkString("GlidePlateEditor_Select")
    util.AddNetworkString("GlidePlateEditor_Update")
    
    local SELECTED_VEHICLE_NW = "GlidePlateEditor_Target"

    -- Hook to clean selection if the vehicle is removed
    hook.Add("EntityRemoved", "GlidePlateEditor_VehicleRemoved", function(ent)
        if not ent.IsGlideVehicle then return end

        for _, player in pairs(player.GetAll()) do
            local wep = player:GetWeapon("gmod_tool")
            if IsValid(wep) then
                local tool = player:GetTool("glide_plate_editor") 
                if IsValid(tool) then
                    local selected = wep:GetNWEntity(SELECTED_VEHICLE_NW)
                    if selected == ent then
                        tool:RightClick(nil) -- Deselect the vehicle for the user
                    end
                end
            end
        end
    end)
end

-- Shared Variables
local SELECTED_VEHICLE_NW = "GlidePlateEditor_Target"

-- Called when the user Left Clicks
function TOOL:LeftClick(trace)
    local ent = trace.Entity
    
    if CLIENT then return true end -- Only allow server to process selection logic
    
    -- SERVER LOGIC STARTS HERE
    local ply = self:GetOwner()
    local wep = self:GetWeapon()
    local currentSelected = wep:GetNWEntity(SELECTED_VEHICLE_NW)

    -- Check if target is valid and a Glide Vehicle
    if (not IsValid(ent) or not ent.IsGlideVehicle) then 
        if IsValid(currentSelected) and currentSelected != ent then
            self:RightClick(nil) -- Deselect if clicking something else
        end
        return false 
    end

    local platesData = {}
    local hasPlates = false
    
    -- Check if it's the new multi-plate system (preferred)
    if ent.LicensePlateEntities and next(ent.LicensePlateEntities) then
        for id, plateEnt in pairs(ent.LicensePlateEntities) do
            if IsValid(plateEnt) and plateEnt:GetClass() == "glide_license_plate" then
                hasPlates = true
                platesData[id] = {
                    text = plateEnt:GetPlateText(),
                    type = plateEnt.PlateType or "mercosur plate", 
                    scale = plateEnt:GetPlateScale(),
                    font = plateEnt:GetPlateFont(),
                    skin = plateEnt:GetPlateSkin(),
                    color = plateEnt:GetTextColor(), -- Vector
                    alpha = plateEnt:GetTextAlpha(),
                    offset = plateEnt:GetTextOffset(), -- Vector
                    model = plateEnt:GetModel(), 
                    hidden = plateEnt:GetNoDraw()
                }
            end
        end
    -- Fallback for the old single-plate system
    elseif IsValid(ent.LicensePlateEntity) and ent.LicensePlateEntity:GetClass() == "glide_license_plate" then
        local plateEnt = ent.LicensePlateEntity
        local id = "main"
        hasPlates = true
        platesData[id] = {
            text = plateEnt:GetPlateText(),
            type = plateEnt.PlateType or "mercosur plate", 
            scale = plateEnt:GetPlateScale(),
            font = plateEnt:GetPlateFont(),
            skin = plateEnt:GetPlateSkin(),
            color = plateEnt:GetTextColor(), -- Vector
            alpha = plateEnt:GetTextAlpha(),
            offset = plateEnt:GetTextOffset(), -- Vector
            model = plateEnt:GetModel(),
            hidden = plateEnt:GetNoDraw()
        }
    end

    local targetEnt = ent
    if not hasPlates then 
        wep:SetNWEntity(SELECTED_VEHICLE_NW, NULL)
        targetEnt = NULL
        -- FIX: Use localization key prefixed with # for server-side chat print
        ply:ChatPrint("#glide_pe_support_warning") 
    else
        wep:SetNWEntity(SELECTED_VEHICLE_NW, ent)
    end
    
    -- Send net message with data to the client
    net.Start("GlidePlateEditor_Select")
    net.WriteEntity(targetEnt)
    net.WriteTable(platesData)
    net.Send(ply)

    return true
end

-- Called when the user Right Clicks (Deselects)
function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local wep = self:GetWeapon()
    
    wep:SetNWEntity(SELECTED_VEHICLE_NW, NULL)
    
    -- Notify client of deselection
    net.Start("GlidePlateEditor_Select")
    net.WriteEntity(NULL)
    net.WriteTable({})
    net.Send(ply)
    
    return true
end

-- Server side Think hook to check selection validity
function TOOL:Think()
    if SERVER then
        local ent = self:GetWeapon():GetNWEntity(SELECTED_VEHICLE_NW)
        -- Deselect if vehicle is invalid, not a Glide Vehicle, or too far away (1000^2 = 1,000,000)
        if IsValid(ent) and (not ent.IsGlideVehicle or ent:GetPos():DistToSqr(self:GetOwner():GetPos()) > 1000000) then
            self:RightClick(nil)
        end
    end
end

-- Client Side Logic: Halo & UI
if CLIENT then
    local CurrentSelection = nil
    local CurrentPlatesData = {}
    local SelectedPlateID = nil
    local EditorPanel = nil 
    local IgnoreConVarChanges = false -- Flag to prevent loop when syncing selection
    
    -- Helper to get and prioritize fonts
    local function GetPrioritizedFonts(currentFont)
        local REQUIRED_FONTS = {
            "Arial",
            "Tahoma",
            "Verdana",
            "Courier New",
            "Times New Roman",
            "GL-Nummernschild-Mtl",
            "Dealerplate California",
        }
        
        local allFontsMap = {}
        if surface and surface.GetAvailableFonts then 
            for _, fontName in ipairs(surface.GetAvailableFonts()) do
                allFontsMap[fontName] = true
            end
        end

        local prioritizedFonts = {}
        local added = {}
        
        -- Add current font first if it's not a required one
        local currentFontIsRequired = false
        for _, reqFont in ipairs(REQUIRED_FONTS) do
            if reqFont == currentFont then
                currentFontIsRequired = true
                break
            end
        end

        if currentFont and not currentFontIsRequired and not added[currentFont] and allFontsMap[currentFont] then
            table.insert(prioritizedFonts, currentFont)
            added[currentFont] = true
        end

        -- Add required fonts
        for _, fontName in ipairs(REQUIRED_FONTS) do
            if not added[fontName] then
                table.insert(prioritizedFonts, fontName)
                added[fontName] = true
            end
        end
        
        return prioritizedFonts
    end

    -- Function to sync tool ConVars from Vehicle Data (without triggering update loop)
    local function SyncToolToVehicle(data)
        IgnoreConVarChanges = true
        
        -- Force text to be empty in the UI by default on selection to avoid unexpected updates
        RunConsoleCommand("glide_plate_editor_text", "") 
        
        if data.type then RunConsoleCommand("glide_plate_editor_type", data.type) end
        if data.scale then RunConsoleCommand("glide_plate_editor_scale", tostring(data.scale)) end
        if data.skin then RunConsoleCommand("glide_plate_editor_skin", tostring(data.skin)) end
        if data.font then RunConsoleCommand("glide_plate_editor_font", data.font) end
        -- Convar expects "1" or "0"
        if data.hidden ~= nil then RunConsoleCommand("glide_plate_editor_hidden", data.hidden and "1" or "0") end 
        
        if data.offset then 
            RunConsoleCommand("glide_plate_editor_offset_x", tostring(data.offset.x))
            RunConsoleCommand("glide_plate_editor_offset_y", tostring(data.offset.y))
            RunConsoleCommand("glide_plate_editor_offset_z", tostring(data.offset.z))
        end
        
        if data.color then
            -- Color vector is (r, g, b)
            RunConsoleCommand("glide_plate_editor_color_r", tostring(data.color.x))
            RunConsoleCommand("glide_plate_editor_color_g", tostring(data.color.y))
            RunConsoleCommand("glide_plate_editor_color_b", tostring(data.color.z))
            if data.alpha then RunConsoleCommand("glide_plate_editor_color_a", tostring(data.alpha)) end
        end

        IgnoreConVarChanges = false
    end

    -- Function to send updates to server
    local function SendUpdate(key, value)
        if IgnoreConVarChanges then return end
        if not IsValid(CurrentSelection) or not SelectedPlateID then return end
        
        net.Start("GlidePlateEditor_Update")
        net.WriteEntity(CurrentSelection)
        net.WriteString(SelectedPlateID)
        net.WriteString(key)
        net.WriteType(value)
        net.SendToServer()
        
        -- Update local cache to match
        if CurrentPlatesData[SelectedPlateID] then
            if key == "color_alpha" then
                -- Color_alpha sends a table {r, g, b, a}
                CurrentPlatesData[SelectedPlateID].color = Vector(value.r, value.g, value.b)
                CurrentPlatesData[SelectedPlateID].alpha = value.a
            elseif key == "offset" then
                 -- Offset sends a Vector
                 CurrentPlatesData[SelectedPlateID].offset = value
            elseif key == "type" then
                -- Logic for Type change side effects is handled on Server, 
                -- but we update local type reference to keep UI consistent
                CurrentPlatesData[SelectedPlateID].type = value
            else
                CurrentPlatesData[SelectedPlateID][key] = value
            end
        end
    end

    -- --------------------------------------------------------
    -- ConVar Callbacks
    -- This enables Presets to work. When a Preset loads, it changes ConVars.
    -- These callbacks detect the change and send it to the vehicle.
    -- --------------------------------------------------------
    local function AddCallback(cvarName, key, typeConversion)
        cvars.AddChangeCallback(cvarName, function(convar_name, old_value, new_value)
            if IgnoreConVarChanges then return end
            
            local val = new_value
            if typeConversion == "number" then val = tonumber(new_value) end
            if typeConversion == "bool" then val = tobool(new_value) end
            
            SendUpdate(key, val)
            
            -- If plate type changes, we need to rebuild UI to update available fonts/defaults if necessary
            if key == "type" and IsValid(EditorPanel) then
                 -- Delay slightly to ensure data propagation
                 timer.Simple(0.1, function() if IsValid(EditorPanel) then RebuildControlPanel(EditorPanel) end end)
            end
        end, "GlideEditorSync_" .. cvarName)
    end

    AddCallback("glide_plate_editor_text", "text")
    AddCallback("glide_plate_editor_type", "type")
    AddCallback("glide_plate_editor_scale", "scale", "number")
    AddCallback("glide_plate_editor_skin", "skin", "number")
    AddCallback("glide_plate_editor_font", "font")
    AddCallback("glide_plate_editor_hidden", "hidden", "bool")
    
    -- Special handling for Vectors (Offset)
    local function UpdateOffset()
        if IgnoreConVarChanges then return end
        local vec = Vector(
            GetConVar("glide_plate_editor_offset_x"):GetFloat(),
            GetConVar("glide_plate_editor_offset_y"):GetFloat(),
            GetConVar("glide_plate_editor_offset_z"):GetFloat()
        )
        SendUpdate("offset", vec)
    end
    cvars.AddChangeCallback("glide_plate_editor_offset_x", UpdateOffset, "GlideSyncOSX")
    cvars.AddChangeCallback("glide_plate_editor_offset_y", UpdateOffset, "GlideSyncOSY")
    cvars.AddChangeCallback("glide_plate_editor_offset_z", UpdateOffset, "GlideSyncOSZ")

    -- Special handling for Color
    local function UpdateColor()
        if IgnoreConVarChanges then return end
        local col = {
            r = GetConVar("glide_plate_editor_color_r"):GetInt(),
            g = GetConVar("glide_plate_editor_color_g"):GetInt(),
            b = GetConVar("glide_plate_editor_color_b"):GetInt(),
            a = GetConVar("glide_plate_editor_color_a"):GetInt()
        }
        SendUpdate("color_alpha", col)
    end
    cvars.AddChangeCallback("glide_plate_editor_color_r", UpdateColor, "GlideSyncCR")
    cvars.AddChangeCallback("glide_plate_editor_color_g", UpdateColor, "GlideSyncCG")
    cvars.AddChangeCallback("glide_plate_editor_color_b", UpdateColor, "GlideSyncCB")
    cvars.AddChangeCallback("glide_plate_editor_color_a", UpdateColor, "GlideSyncCA")


    -- Receive Selection from Server
    net.Receive("GlidePlateEditor_Select", function()
        CurrentSelection = net.ReadEntity()
        CurrentPlatesData = net.ReadTable()
        
        SelectedPlateID = nil
        if IsValid(CurrentSelection) and next(CurrentPlatesData) then
            -- Default to the first found ID
            for id, _ in pairs(CurrentPlatesData) do
                SelectedPlateID = id
                break
            end
            
            -- Sync ConVars to match the selected vehicle initially
            if SelectedPlateID and CurrentPlatesData[SelectedPlateID] then
                SyncToolToVehicle(CurrentPlatesData[SelectedPlateID])
            end
        end

        -- Rebuild the UI panel with the new selection data
        if IsValid(EditorPanel) then
            RebuildControlPanel(EditorPanel)
        end
    end)

    -- Halo Render to highlight the selected vehicle
    hook.Add("PreDrawHalos", "GlidePlateEditor_Halo", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        
        local toolObj = ply:GetTool()
        if not toolObj or toolObj.Mode ~= "glide_plate_editor" then return end

        local target = wep:GetNWEntity(SELECTED_VEHICLE_NW)
        if IsValid(target) then
            halo.Add({target}, Color(0, 255, 255), 2, 2, 1, true, false)
        end
    end)

    -- UI Construction (Control Panel)
    function RebuildControlPanel(panel)
        panel:Clear()

        -- 0. PRESETS (Added Feature)
        local presetParams = {
            -- FIX: Use localization key for the Presets label
            Label = language.GetPhrase("glide_pe_presets"), 
            MenuButton = 1,
            Folder = "glide_license_plate",
            Options = {
                ["Default Argentina Mercosur"] = {
                    glide_plate_editor_type = "mercosur plate",
                    glide_plate_editor_scale = "0.37",
                    glide_plate_editor_font = "GL-Nummernschild-Mtl",
                    glide_plate_editor_skin = "0",
                    glide_plate_editor_color_r = "0",
                    glide_plate_editor_color_g = "0",
                    glide_plate_editor_color_b = "0",
                    glide_plate_editor_color_a = "255",
                    glide_plate_editor_offset_x = "0",
                    glide_plate_editor_offset_y = "0",
                    glide_plate_editor_offset_z = "-0.55"
                },
                ["Default USA California"] = {
                    glide_plate_editor_type = "usa small plate",
                    glide_plate_editor_scale = "0.37",
                    glide_plate_editor_font = "Dealerplate California",
                    glide_plate_editor_skin = "0",
                    glide_plate_editor_color_r = "18",
                    glide_plate_editor_color_g = "28",
                    glide_plate_editor_color_b = "97",
                    glide_plate_editor_color_a = "255"
                }
            },
            CVars = table.GetKeys(ToolDefaults) 
        }
        
        -- Prefix CVars for the preset system
        for k, v in ipairs(presetParams.CVars) do
            presetParams.CVars[k] = "glide_plate_editor_" .. v
        end
        
        panel:AddControl("ComboBox", presetParams)
        
        -- 1. Selection Dropdown
        -- Use localization key for label
        local idCombo, idLabel = panel:ComboBox(language.GetPhrase("glide_pe_plate_id"))
        idCombo:SetSortItems(false)
        for id, _ in pairs(CurrentPlatesData) do
            idCombo:AddChoice(id, id, id == SelectedPlateID)
        end
        
        idCombo.OnSelect = function(self, index, value)
            SelectedPlateID = value
            -- When switching IDs, sync tool to this new plate
            if CurrentPlatesData[value] then
                SyncToolToVehicle(CurrentPlatesData[value])
            end
            RebuildControlPanel(panel)
        end

        if not SelectedPlateID or not CurrentPlatesData[SelectedPlateID] then return end
        
        -- Get current data to populate lists, but controls are bound to ConVars
        local data = CurrentPlatesData[SelectedPlateID]

        -- 2. Text Input (Bound to ConVar)
        -- Use localization key for label
        local textEntry = panel:TextEntry(language.GetPhrase("glide_pe_text"), "glide_plate_editor_text")

        -- 3. Visibility Toggle (Bound to ConVar)
        -- Use localization key for label
        panel:CheckBox(language.GetPhrase("glide_pe_hidden"), "glide_plate_editor_hidden")

        if data.hidden then return end

        -- === SECTION: CUSTOMIZATION ===
        local catCustom = vgui.Create("DCollapsibleCategory", panel)
        -- Use localization key for label
        catCustom:SetLabel(language.GetPhrase("glide_pe_header_custom"))
        catCustom:SetExpanded(true)
        panel:AddItem(catCustom)

        local formCustom = vgui.Create("DForm", catCustom)
        formCustom:SetName("")
        catCustom:SetContents(formCustom)

        -- --- Basic Controls ---
        
        -- Plate Type Selector 
        -- Use localization key for label
        local typeCombo = formCustom:ComboBox(language.GetPhrase("glide_pe_type"))
        
        local function PopulateTypes()
            typeCombo:Clear()
            local currentType = GetConVar("glide_plate_editor_type"):GetString()
            for typeKey, typeData in pairs(ALLOWED_PLATES) do
                typeCombo:AddChoice(typeData.label, typeKey, typeKey == currentType)
            end
        end // <--- FIX APPLIED HERE: Used 'end' instead of '}' to close the function
        PopulateTypes() 
        
        -- Manual handling for ComboBox to update ConVar
        typeCombo.OnSelect = function(self, idx, val, dataVal)
            RunConsoleCommand("glide_plate_editor_type", dataVal)
        end

        -- Basic Controls: Offset (Bound to ConVars)
        -- Use localization key for labels
        local xSlide = formCustom:NumSlider(language.GetPhrase("glide_pe_text_pos_X"), "glide_plate_editor_offset_x", -5, 5, 2)
        local ySlide = formCustom:NumSlider(language.GetPhrase("glide_pe_text_pos_Y"), "glide_plate_editor_offset_y", -5, 5, 2)
        local zSlide = formCustom:NumSlider(language.GetPhrase("glide_pe_text_pos_Z"), "glide_plate_editor_offset_z", -5, 5, 2)

        -- Basic Controls: Color (Bound to ConVars)
        local mixer = vgui.Create("DColorMixer", formCustom)
        -- Use localization key for label
        mixer:SetLabel(language.GetPhrase("glide_pe_text_color"))
        mixer:SetPalette(true)
        mixer:SetAlphaBar(true)
        mixer:SetWangs(true)
        
        -- Link DColorMixer to ConVars
        mixer:SetConVarR("glide_plate_editor_color_r")
        mixer:SetConVarG("glide_plate_editor_color_g")
        mixer:SetConVarB("glide_plate_editor_color_b")
        mixer:SetConVarA("glide_plate_editor_color_a")
        
        formCustom:AddItem(mixer)

        -- Basic Controls: Scale (Bound to ConVar)
        -- Use localization key for label
        formCustom:NumSlider(language.GetPhrase("glide_pe_text_scale"), "glide_plate_editor_scale", 0.1, 2.0, 2)
        
        -- --- Advanced Controls ---

        -- Advanced Controls: Skin Slider (Bound to ConVar)
        -- Use localization key for label
        local defaultMaxSkin = 30 
        local currentSkin = data.skin or 0
        local maxSkin = math.max(defaultMaxSkin, currentSkin)

        formCustom:NumSlider(language.GetPhrase("glide_pe_skin"), "glide_plate_editor_skin", 0, maxSkin, 0)

        -- Advanced Controls: Font ComboBox
        local currentFont = GetConVar("glide_plate_editor_font"):GetString()
        local fontList = GetPrioritizedFonts(currentFont)

        -- Use localization key for label
        local fontEntry, fontLabel = formCustom:ComboBox(language.GetPhrase("glide_pe_font"))
        fontEntry:SetSortItems(false)
        
        for _, fontName in ipairs(fontList) do
            fontEntry:AddChoice(fontName, fontName, fontName == currentFont)
        end
        
        fontEntry.OnSelect = function(self, index, value)
            RunConsoleCommand("glide_plate_editor_font", value)
        end
    end

    function TOOL:BuildCPanel()
        EditorPanel = self
        RebuildControlPanel(self)
    end
end

-- Server Side Logic
if SERVER then
    -- Hardcoded map for the requested plates to set models on the server
    local ALLOWED_PLATES_SERVER = {
            ["usa small plate"] = {
                label = "usa small plate",
                model = usasmallplatemodel
            },
            ["european long plate"] = {
                label = "european long plate",
                model = europeanlongplatemodel
            },
            ["mercosur plate"] = {
                label = "mercosur plate",
                model = mercosurplatemodel
            },
            ["argentina small plate"] = {
                label = "argentina small plate",
                model = argentinasmallplatemodel
            },
            ["black long plate"] = {
                label = "black long plate",
                model = argentinablacklongplatemodel
            }
    }

    net.Receive("GlidePlateEditor_Update", function(len, ply)
        local vehicle = net.ReadEntity()
        local plateId = net.ReadString()
        local key = net.ReadString()
        local value = net.ReadType()

        -- Validation
        if not IsValid(vehicle) or not vehicle.IsGlideVehicle then return end
        
        local plateEntity = nil
        -- Check if the plate entity exists under the selected ID
        if vehicle.LicensePlateEntities then
            plateEntity = vehicle.LicensePlateEntities[plateId]
        end

        if not IsValid(plateEntity) then return end

        -- Apply Changes based on Key
        if key == "text" then
            if type(value) == "string" and #value <= (GlideLicensePlates.Config.MaxCharacters or 20) then
                -- UpdatePlateText with "" forces regeneration based on current PlateType.
                plateEntity:UpdatePlateText(value) 

                -- Update vehicle save data (if available)
                if vehicle.LicensePlateTexts then vehicle.LicensePlateTexts[plateId] = plateEntity:GetPlateText() end
            end
        
        elseif key == "hidden" then
             local bHidden = tobool(value)
             plateEntity:SetNoDraw(bHidden)
             
             -- Hide model and text completely if hidden
             if bHidden then
                plateEntity:SetTextAlpha(0)
                plateEntity:SetNotSolid(true) 
             else
                -- Restore alpha and collision if shown
                plateEntity:SetTextAlpha(plateEntity.GlideSavedAlpha or 255)
                plateEntity:SetNotSolid(false)
             end

        elseif key == "type" then
            if type(value) == "string" then
                -- Look up default configuration data for this type
                local typeData = GlideLicensePlates.PlateTypes[value] or {}
                local allowedData = ALLOWED_PLATES_SERVER[value] -- Look up in hardcoded list

                if allowedData then -- Check if it's one of the allowed types
                    plateEntity.PlateType = value
                    
                    if vehicle.SelectedPlateTypes then vehicle.SelectedPlateTypes[plateId] = value end

                    -- Remove pattern on type change
                    plateEntity.PlatePattern = ""
                    if vehicle.SelectedPlatePatterns then vehicle.SelectedPlatePatterns[plateId] = "" end
                    
                    -- Force text regeneration to fulfill user request to generate a new plate text
                    plateEntity:UpdatePlateText("") 

                    -- 1. MODEL: Use the model from the hardcoded list
                    if allowedData.model then
                        plateEntity:UpdatePlateModel(allowedData.model)
                    end
                    
                    -- 2. SKIN: Do NOT change skin automatically on type change. (Can be customized later)
                    
                    -- 3. FONT: Set font to type default or global default
                    local font = typeData.font or GlideLicensePlates.GetPlateFont(value)
                    plateEntity:SetPlateFont(font)
                    if vehicle.SelectedPlateFonts then vehicle.SelectedPlateFonts[plateId] = font end
                    
                    -- 4. SCALE: Set scale to type default or global default
                    local scale = typeData.textscale or GlideLicensePlates.Config.DefaultScale or 0.5
                    plateEntity:SetPlateScale(scale)
                    if vehicle.SelectedPlateScales then vehicle.SelectedPlateScales[plateId] = scale end

                    -- 5. COLOR: Set color to type default (if defined)
                    if typeData.textcolor and type(typeData.textcolor) == "table" then
                        local color = typeData.textcolor
                        local r, g, b, a = color.r or 0, color.g or 0, color.b or 0, color.a or 255
                        plateEntity:SetTextColor(Vector(r, g, b))
                        plateEntity:SetTextAlpha(a)
                        plateEntity.GlideSavedAlpha = a
                    end

                    -- 6. POSITION (OFFSET): Set offset to type default (if defined)
                    if typeData.textposition and type(typeData.textposition) == "Vector" then
                        plateEntity:SetTextOffset(typeData.textposition)
                    end
                end
            end

        elseif key == "scale" then
            if type(value) == "number" then
                plateEntity:SetPlateScale(value) 
                if vehicle.SelectedPlateScales then vehicle.SelectedPlateScales[plateId] = value end
            end

        elseif key == "offset" then
            if type(value) == "Vector" then
                plateEntity:SetTextOffset(value)
            end

        elseif key == "color_alpha" then
            if type(value) == "table" then
                local r, g, b, a = value.r, value.g, value.b, value.a
                plateEntity:SetTextColor(Vector(r, g, b))
                plateEntity:SetTextAlpha(a)
                plateEntity.GlideSavedAlpha = a -- Save alpha for restoration if hidden flag is removed
            end

        elseif key == "skin" then
            if type(value) == "number" then
                plateEntity:SetPlateSkin(value)
                if vehicle.SelectedPlateSkins then vehicle.SelectedPlateSkins[plateId] = value end
            end
            
        elseif key == "font" then
            if type(value) == "string" and #value > 0 then
                plateEntity:SetPlateFont(value)
            end
        end
        
        if vehicle.UpdatePlateText then
             -- (Vehicle specific function to mark dirty/update)
        end
    end)
end