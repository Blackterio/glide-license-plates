-- lua/weapons/gmod_tool/stools/glide_plate_editor.lua

TOOL.Category = "Glide"
TOOL.Name = "#tool.glide_plate_editor.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Description = "#tool.glide_plate_editor.desc"
TOOL.Info = "#tool.glide_plate_editor.desc"

-- These are automatically registered as glide_plate_editor_* client ConVars
TOOL.ClientConVar = {
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

local ToolDefaults = TOOL.ClientConVar

local usasmallplatemodel = "models/blackterios_glide_vehicles/licenseplates/smallplate.mdl"
local europeanlongplatemodel = "models/blackterios_glide_vehicles/licenseplates/europeplate.mdl"
local mercosurplatemodel = "models/blackterios_glide_vehicles/licenseplates/mercosurplate.mdl"
local argentinasmallplatemodel = "models/blackterios_glide_vehicles/licenseplates/argentinaold.mdl"
local argentinablacklongplatemodel = "models/blackterios_glide_vehicles/licenseplates/argentinavintage.mdl"

-- Allowed types for the tool. `typeId` is the representative entry in
-- GlideLicensePlates.PlateTypes used to pull defaults (font/scale/color/offset/pattern).
local ALLOWED_PLATES = {
    ["usa small plate"] = {
        label = "usa small plate",
        model = usasmallplatemodel,
        typeId = "usacalifornia"
    },
    ["european long plate"] = {
        label = "european long plate",
        model = europeanlongplatemodel,
        typeId = "europegermany"
    },
    ["mercosur plate"] = {
        label = "mercosur plate",
        model = mercosurplatemodel,
        typeId = "argmercosur"
    },
    ["argentina small plate"] = {
        label = "argentina small plate",
        model = argentinasmallplatemodel,
        typeId = "argold"
    },
    ["black long plate"] = {
        label = "black long plate",
        model = argentinablacklongplatemodel,
        typeId = "argvintage"
    }
}

-- Limits for values received over the network
local MIN_SCALE, MAX_SCALE = 0.1, 2
local MAX_SKIN = 30
local MAX_OFFSET = 10

-- Networking setup
if SERVER then
    util.AddNetworkString("GlidePlateEditor_Select")
    util.AddNetworkString("GlidePlateEditor_Update")
    util.AddNetworkString("GlidePlateEditor_Advanced")
    util.AddNetworkString("GlidePlateEditor_Preview")
end

-- Shared variable (declared once at top of file)
local SELECTED_VEHICLE_NW = "GlidePlateEditor_Target"

-- Map a plate entity to the tool type key that matches its current model.
-- Returns nil for unknown/custom models (e.g. the invisible plate).
local function GetToolTypeForPlate(plateEnt)
    local model = plateEnt:GetModel()
    for key, data in pairs(ALLOWED_PLATES) do
        if data.model == model then return key end
    end
    return nil
end

-- Advanced configs (bodygroup rules / bone) of one plate, in the compact form
-- the tool panel edits. Missing move values are filled client-side.
local function GetPlateAdvancedData(vehicle, plateId)
    local adv = { rules = {} }
    local configs = vehicle.LicensePlateAdvancedConfigs or vehicle.LicensePlateBodygroupConfigs
    if not istable(configs) then return adv end

    for _, config in ipairs(configs) do
        if config.id ~= plateId then continue end

        if isstring(config.bone) and config.bone ~= "" then
            adv.bone = config.bone
        end

        local bg = config.bodygroup
        if istable(bg) and #bg >= 2 then
            table.insert(adv.rules, {
                bg = bg[1],
                sub = bg[2],
                hide = config.platetoggle == true,
                pos = config.newplateposition,
                ang = config.newplateangles,
                rot = config.newplatemodelRotation
            })
        end
    end

    return adv
end

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

    -- Plate closest to the clicked point: preselected in the panel
    local nearestId, nearestDist = "", math.huge

    if ent.LicensePlateEntities and next(ent.LicensePlateEntities) then
        for id, plateEnt in pairs(ent.LicensePlateEntities) do
            if IsValid(plateEnt) and plateEnt:GetClass() == "glide_license_plate" then
                hasPlates = true

                if trace.HitPos then
                    local dist = plateEnt:GetPos():DistToSqr(trace.HitPos)
                    if dist < nearestDist then
                        nearestId, nearestDist = id, dist
                    end
                end

                -- Transform without bodygroup rules applied (start point for "move" rules)
                local original = plateEnt.BodygroupOriginalData
                platesData[id] = {
                    text = plateEnt:GetPlateText(),
                    type = GetToolTypeForPlate(plateEnt) or "mercosur plate",
                    scale = plateEnt:GetPlateScale(),
                    font = plateEnt:GetPlateFont(),
                    skin = plateEnt:GetPlateSkin(),
                    color = plateEnt:GetTextColor(), -- Vector
                    alpha = plateEnt:GetTextAlpha(),
                    offset = plateEnt:GetTextOffset(), -- Vector
                    model = plateEnt:GetModel(),
                    hidden = plateEnt.ManualHide == true, -- bodygroup rules hide it too: only the manual hide counts
                    advanced = GetPlateAdvancedData(ent, id),
                    defaultPos = original and original.BasePosition or plateEnt:GetBasePosition(),
                    defaultAng = original and original.BaseAngles or plateEnt:GetBaseAngles(),
                    defaultRot = original and original.ModelRotation or plateEnt:GetModelRotation()
                }
            end
        end
    end

    local targetEnt = ent
    if not hasPlates then
        wep:SetNWEntity(SELECTED_VEHICLE_NW, NULL)
        targetEnt = NULL
        -- Use localization key prefixed with # for server-side chat print
        ply:ChatPrint("#glide_pe_support_warning")
    else
        wep:SetNWEntity(SELECTED_VEHICLE_NW, ent)
    end

    -- Send net message with data to the client
    net.Start("GlidePlateEditor_Select")
    net.WriteEntity(targetEnt)
    net.WriteTable(platesData)
    net.WriteString(nearestId)
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
    net.WriteString("")
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
    local RebuildControlPanel -- forward declaration (kept local, defined below)
    local GetSortedPlateIds -- forward declaration (defined below)

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

    -- Set a tool ConVar SYNCHRONOUSLY. RunConsoleCommand queues the change for
    -- later in the frame, so the IgnoreConVarChanges flag would already be false
    -- when the change callbacks fire -- making the tool re-send every synced
    -- value to the server as if the user had edited it (regenerating texts and
    -- mixing offsets between plates when switching the selected plate).
    -- ConVar:SetString applies immediately, while the flag is still set.
    local function SetToolConVar(name, value)
        local cv = GetConVar(name)
        if cv then
            cv:SetString(tostring(value))
        end
    end

    -- Function to sync tool ConVars from Vehicle Data (without triggering update loop)
    local function SyncToolToVehicle(data)
        IgnoreConVarChanges = true

        -- Force text to be empty in the UI by default on selection to avoid unexpected updates
        SetToolConVar("glide_plate_editor_text", "")

        if data.type then SetToolConVar("glide_plate_editor_type", data.type) end
        if data.scale then SetToolConVar("glide_plate_editor_scale", data.scale) end
        if data.skin then SetToolConVar("glide_plate_editor_skin", data.skin) end
        if data.font then SetToolConVar("glide_plate_editor_font", data.font) end
        -- Convar expects "1" or "0"
        if data.hidden ~= nil then SetToolConVar("glide_plate_editor_hidden", data.hidden and "1" or "0") end

        if data.offset then
            SetToolConVar("glide_plate_editor_offset_x", data.offset.x)
            SetToolConVar("glide_plate_editor_offset_y", data.offset.y)
            SetToolConVar("glide_plate_editor_offset_z", data.offset.z)
        end

        if data.color then
            -- Color vector is (r, g, b)
            SetToolConVar("glide_plate_editor_color_r", data.color.x)
            SetToolConVar("glide_plate_editor_color_g", data.color.y)
            SetToolConVar("glide_plate_editor_color_b", data.color.z)
            if data.alpha then SetToolConVar("glide_plate_editor_color_a", data.alpha) end
        end

        IgnoreConVarChanges = false
    end

    -- Plate IDs in alphabetical order (pairs() order is random)
    function GetSortedPlateIds()
        local ids = table.GetKeys(CurrentPlatesData)
        table.sort(ids)
        return ids
    end

    -- Function to send updates to server. `vehicle`/`plateId` default to the
    -- current selection (throttled sends pass the ones captured when queued).
    local function SendUpdate(key, value, vehicle, plateId)
        if IgnoreConVarChanges then return end

        vehicle = vehicle or CurrentSelection
        plateId = plateId or SelectedPlateID
        if not IsValid(vehicle) or not plateId then return end

        net.Start("GlidePlateEditor_Update")
        net.WriteEntity(vehicle)
        net.WriteString(plateId)
        net.WriteString(key)
        net.WriteType(value)
        net.SendToServer()

        -- Update local cache to match (only while that vehicle is still selected)
        local cache = vehicle == CurrentSelection and CurrentPlatesData[plateId]
        if cache then
            if key == "color_alpha" then
                -- Color_alpha sends a table {r, g, b, a}
                cache.color = Vector(value.r, value.g, value.b)
                cache.alpha = value.a
            elseif key == "offset" then
                 -- Offset sends a Vector
                 cache.offset = value
            elseif key == "type" then
                -- Logic for Type change side effects is handled on Server,
                -- but we update local type reference to keep UI consistent
                cache.type = value
            else
                cache[key] = value
            end
        end
    end

    -- Continuous controls (sliders, color mixer) change every frame while
    -- dragged, and the server accepts 30 updates/s per player: sends are
    -- spaced SEND_INTERVAL apart per plate and control, and the LAST value is
    -- always sent. Changes in the same frame (a preset load) become one send.
    local SEND_INTERVAL = 0.1
    local lastSendTime, pendingSend = {}, {}

    local function ThrottledSend(key, send)
        pendingSend[key] = send

        local timerName = "GlidePlateEditor_Throttle_" .. key
        if timer.Exists(timerName) then return end

        local delay = math.max(0, (lastSendTime[key] or 0) + SEND_INTERVAL - RealTime())
        timer.Create(timerName, delay, 1, function()
            local fn = pendingSend[key]
            pendingSend[key] = nil
            lastSendTime[key] = RealTime()
            if fn then fn() end
        end)
    end

    -- Throttled SendUpdate. Value, vehicle and plate are captured now, so
    -- switching the selected plate can't redirect a pending update.
    local function QueueUpdate(key, value)
        local vehicle, plateId = CurrentSelection, SelectedPlateID
        if not IsValid(vehicle) or not plateId then return end

        ThrottledSend(key .. "_" .. vehicle:EntIndex() .. "_" .. plateId, function()
            SendUpdate(key, value, vehicle, plateId)
        end)
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

            if key == "scale" then
                QueueUpdate(key, val) -- slider
            else
                SendUpdate(key, val)
            end

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

    -- Special handling for Vectors (Offset).
    -- Throttled: changing several components in the same frame (e.g. a preset
    -- load) sends ONE message with the final vector, instead of three messages
    -- with partially-updated components.
    local function UpdateOffset()
        if IgnoreConVarChanges or not IsValid(CurrentSelection) or not SelectedPlateID then return end
        QueueUpdate("offset", Vector(
            GetConVar("glide_plate_editor_offset_x"):GetFloat(),
            GetConVar("glide_plate_editor_offset_y"):GetFloat(),
            GetConVar("glide_plate_editor_offset_z"):GetFloat()
        ))
    end
    cvars.AddChangeCallback("glide_plate_editor_offset_x", UpdateOffset, "GlideSyncOSX")
    cvars.AddChangeCallback("glide_plate_editor_offset_y", UpdateOffset, "GlideSyncOSY")
    cvars.AddChangeCallback("glide_plate_editor_offset_z", UpdateOffset, "GlideSyncOSZ")

    -- Special handling for Color (throttled like the offset)
    local function UpdateColor()
        if IgnoreConVarChanges or not IsValid(CurrentSelection) or not SelectedPlateID then return end
        QueueUpdate("color_alpha", {
            r = GetConVar("glide_plate_editor_color_r"):GetInt(),
            g = GetConVar("glide_plate_editor_color_g"):GetInt(),
            b = GetConVar("glide_plate_editor_color_b"):GetInt(),
            a = GetConVar("glide_plate_editor_color_a"):GetInt()
        })
    end
    cvars.AddChangeCallback("glide_plate_editor_color_r", UpdateColor, "GlideSyncCR")
    cvars.AddChangeCallback("glide_plate_editor_color_g", UpdateColor, "GlideSyncCG")
    cvars.AddChangeCallback("glide_plate_editor_color_b", UpdateColor, "GlideSyncCB")
    cvars.AddChangeCallback("glide_plate_editor_color_a", UpdateColor, "GlideSyncCA")


    -- Advanced configuration (bodygroup rules / bone) of the selected plate.
    -- Not bound to ConVars: the whole plate state is sent in one message,
    -- throttled so dragging a slider doesn't flood the server.
    local MAX_RULES = 15 -- + the bone entry = server limit of 16 per plate

    local function SendAdvanced(vehicle, plateId, adv)
        if not IsValid(vehicle) then return end

        net.Start("GlidePlateEditor_Advanced")
        net.WriteEntity(vehicle)
        net.WriteString(plateId)
        net.WriteString(adv.bone or "")
        net.WriteUInt(#adv.rules, 5)

        for _, rule in ipairs(adv.rules) do
            net.WriteUInt(rule.bg, 8)
            net.WriteUInt(rule.sub, 8)
            net.WriteBool(rule.hide)

            if not rule.hide then
                net.WriteVector(rule.pos)
                net.WriteAngle(rule.ang)
                net.WriteAngle(rule.rot)
            end
        end

        net.SendToServer()
    end

    -- The plate's own state table is captured (it's edited in place by the
    -- panel), so the send always carries that plate's latest state
    local function QueueAdvancedSend()
        local vehicle, plateId = CurrentSelection, SelectedPlateID
        local data = plateId and CurrentPlatesData[plateId]
        if not IsValid(vehicle) or not data or not data.advanced then return end

        local adv = data.advanced
        ThrottledSend("advanced_" .. vehicle:EntIndex() .. "_" .. plateId, function()
            SendAdvanced(vehicle, plateId, adv)
        end)
    end

    -- "Move" rules always carry the three values, starting from the plate's
    -- default transform (never from the vehicle origin)
    local function FillMoveValues(rule, data)
        rule.pos = rule.pos or Vector(data.defaultPos or vector_origin)
        rule.ang = rule.ang or Angle(data.defaultAng or angle_zero)
        rule.rot = rule.rot or Angle(data.defaultRot or angle_zero)
    end

    local function FindBodygroup(bodygroups, id)
        for _, bg in ipairs(bodygroups) do
            if bg.id == id then return bg end
        end
    end

    local function AddAxisSliders(form, labelKey, value, axes, min, max, decimals)
        local label = language.GetPhrase(labelKey)

        for i, axis in ipairs(axes) do
            local slider = form:NumSlider(label .. " " .. axis, nil, min, max, decimals)
            slider:SetValue(value[i])
            slider.OnValueChanged = function(_, newValue)
                value[i] = newValue
                QueueAdvancedSend()
            end
        end
    end

    local function BuildAdvancedSection(panel, data)
        local adv = data.advanced
        local vehicle = CurrentSelection
        if not adv or not IsValid(vehicle) then return end

        local cat = vgui.Create("DCollapsibleCategory", panel)
        cat:SetLabel(language.GetPhrase("glide_pe_header_advanced"))
        cat:SetExpanded(true)
        panel:AddItem(cat)

        local form = vgui.Create("DForm", cat)
        form:SetName("")
        cat:SetContents(form)

        -- Bone the plate follows
        local boneCombo = form:ComboBox(language.GetPhrase("glide_pe_bone"))
        boneCombo:SetSortItems(false)
        boneCombo:AddChoice(language.GetPhrase("glide_pe_none"), "", not adv.bone)

        for i = 0, vehicle:GetBoneCount() - 1 do
            local name = vehicle:GetBoneName(i)
            if name and name ~= "__INVALIDBONE__" then
                boneCombo:AddChoice(name, name, name == adv.bone)
            end
        end

        boneCombo.OnSelect = function(_, _, _, value)
            adv.bone = value ~= "" and value or nil
            QueueAdvancedSend()
        end

        -- Bodygroup rules (only bodygroups with more than one submodel)
        local bodygroups = {}
        for _, bg in ipairs(vehicle:GetBodyGroups() or {}) do
            if bg.num > 1 then table.insert(bodygroups, bg) end
        end

        local radius = math.ceil(vehicle:BoundingRadius())

        for index, rule in ipairs(adv.rules) do
            local ruleForm = vgui.Create("DForm", form)
            ruleForm:SetName(language.GetPhrase("glide_pe_rule") .. " " .. index)
            form:AddItem(ruleForm)

            local bgCombo = ruleForm:ComboBox(language.GetPhrase("glide_pe_bodygroup"))
            bgCombo:SetSortItems(false)
            for _, bg in ipairs(bodygroups) do
                bgCombo:AddChoice(bg.id .. " - " .. bg.name, bg.id, bg.id == rule.bg)
            end

            bgCombo.OnSelect = function(_, _, _, value)
                rule.bg = value
                rule.sub = 1
                QueueAdvancedSend()
                RebuildControlPanel(panel)
            end

            local subCombo = ruleForm:ComboBox(language.GetPhrase("glide_pe_submodel"))
            subCombo:SetSortItems(false)
            local bgData = FindBodygroup(bodygroups, rule.bg)
            if bgData then
                for sub = 0, bgData.num - 1 do
                    local subName = bgData.submodels and bgData.submodels[sub] or ""
                    subCombo:AddChoice(sub .. " - " .. subName, sub, sub == rule.sub)
                end
            end

            subCombo.OnSelect = function(_, _, _, value)
                rule.sub = value
                QueueAdvancedSend()
            end

            local actionCombo = ruleForm:ComboBox(language.GetPhrase("glide_pe_action"))
            actionCombo:SetSortItems(false)
            actionCombo:AddChoice(language.GetPhrase("glide_pe_action_hide"), true, rule.hide)
            actionCombo:AddChoice(language.GetPhrase("glide_pe_action_move"), false, not rule.hide)

            actionCombo.OnSelect = function(_, _, _, value)
                rule.hide = value
                if not rule.hide then FillMoveValues(rule, data) end
                QueueAdvancedSend()
                RebuildControlPanel(panel)
            end

            if not rule.hide then
                FillMoveValues(rule, data)
                AddAxisSliders(ruleForm, "glide_pe_new_pos", rule.pos, { "X", "Y", "Z" }, -radius, radius, 2)
                AddAxisSliders(ruleForm, "glide_pe_new_ang", rule.ang, { "P", "Y", "R" }, -180, 180, 1)
                AddAxisSliders(ruleForm, "glide_pe_new_rot", rule.rot, { "P", "Y", "R" }, -180, 180, 1)
            end

            -- Toggles the vehicle bodygroup between this submodel and 0
            local previewButton = ruleForm:Button(language.GetPhrase("glide_pe_preview"))
            previewButton.DoClick = function()
                if not IsValid(CurrentSelection) or not SelectedPlateID then return end

                net.Start("GlidePlateEditor_Preview")
                net.WriteEntity(CurrentSelection)
                net.WriteString(SelectedPlateID)
                net.WriteUInt(rule.bg, 8)
                net.WriteUInt(rule.sub, 8)
                net.SendToServer()
            end

            -- Green + different text while the vehicle shows this rule's state
            -- (also reflects bodygroup changes made with other tools)
            local previewLabel = language.GetPhrase("glide_pe_preview")
            local previewActiveLabel = language.GetPhrase("glide_pe_preview_active")

            previewButton.Think = function(self)
                local active = IsValid(CurrentSelection) and CurrentSelection:GetBodygroup(rule.bg) == rule.sub
                if self.PreviewActive ~= active then
                    self.PreviewActive = active
                    self:SetText(active and previewActiveLabel or previewLabel)
                end
            end

            previewButton.Paint = function(self, w, h)
                derma.SkinHook("Paint", "Button", self, w, h)
                if self.PreviewActive then
                    surface.SetDrawColor(60, 200, 90, 110)
                    surface.DrawRect(0, 0, w, h)
                end
            end

            local removeButton = ruleForm:Button(language.GetPhrase("glide_pe_rule_remove"))
            removeButton.DoClick = function()
                table.remove(adv.rules, index)
                QueueAdvancedSend()
                RebuildControlPanel(panel)
            end
        end

        local addButton = form:Button(language.GetPhrase("glide_pe_rule_add"))
        addButton:SetEnabled(#adv.rules < MAX_RULES and bodygroups[1] ~= nil)
        addButton.DoClick = function()
            if #adv.rules >= MAX_RULES or not bodygroups[1] then return end

            table.insert(adv.rules, { bg = bodygroups[1].id, sub = 1, hide = true })
            QueueAdvancedSend()
            RebuildControlPanel(panel)
        end
    end

    -- Receive Selection from Server
    net.Receive("GlidePlateEditor_Select", function()
        CurrentSelection = net.ReadEntity()
        CurrentPlatesData = net.ReadTable()
        local preferredId = net.ReadString()

        SelectedPlateID = nil
        if IsValid(CurrentSelection) and next(CurrentPlatesData) then
            -- The plate closest to the clicked point, or the first ID alphabetically
            if CurrentPlatesData[preferredId] then
                SelectedPlateID = preferredId
            else
                SelectedPlateID = GetSortedPlateIds()[1]
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
            -- Use localization key for the Presets label
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
        for _, id in ipairs(GetSortedPlateIds()) do
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

        -- Advanced configuration (bodygroup rules / bone), also for hidden plates
        BuildAdvancedSection(panel, data)

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
        local typeComboBox, typeLabel = formCustom:ComboBox(language.GetPhrase("glide_pe_type"))

        -- Verify typeComboBox is valid before using it
        if IsValid(typeComboBox) then
            typeComboBox:Clear()
            local currentType = GetConVar("glide_plate_editor_type"):GetString()
            for typeKey, typeData in pairs(ALLOWED_PLATES) do
                typeComboBox:AddChoice(typeData.label, typeKey, typeKey == currentType)
            end

            -- Manual handling for ComboBox to update ConVar
            typeComboBox.OnSelect = function(self, idx, val, dataVal)
                RunConsoleCommand("glide_plate_editor_type", dataVal)
            end
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
    -- Who can edit plates with the tool:
    -- 0 = vehicle owner (CPPI/creator) or admin, 1 = admins only, 2 = everyone
    local cvEditMode = CreateConVar("glide_plates_edit_mode", "0", FCVAR_ARCHIVE,
        "Who can edit license plates with the tool: 0 = owner/admin, 1 = admins only, 2 = everyone", 0, 2)

    local function CanEditVehiclePlates(ply, vehicle)
        local mode = cvEditMode:GetInt()
        if mode == 2 then return true end
        if ply:IsAdmin() then return true end
        if mode == 1 then return false end

        -- mode 0: owner or admin. Prefer CPPI (prop protection) if available.
        if vehicle.CPPIGetOwner then
            local owner = vehicle:CPPIGetOwner()
            if isentity(owner) and owner == ply then return true end
        end

        return vehicle:GetCreator() == ply
    end

    -- Simple rate limit: max updates per player per second.
    -- Loading a preset legitimately sends ~7 updates in one frame, so this
    -- must be comfortably above that while still stopping spam.
    local MAX_UPDATES_PER_SECOND = 30
    local rateBuckets = {}

    hook.Add("PlayerDisconnected", "GlidePlateEditor.RateCleanup", function(ply)
        rateBuckets[ply] = nil
    end)

    local function IsRateLimited(ply)
        local now = CurTime()
        local bucket = rateBuckets[ply]

        if not bucket or now > bucket.reset then
            bucket = { count = 0, reset = now + 1 }
            rateBuckets[ply] = bucket
        end

        bucket.count = bucket.count + 1
        return bucket.count > MAX_UPDATES_PER_SECOND
    end

    -- Manual hide from the tool (also used when copying a setup)
    local function ApplyManualHide(plateEntity, bHidden)
        -- Set manual hide flag to prevent other scripts from overriding
        plateEntity.ManualHide = bHidden

        plateEntity:SetNoDraw(bHidden)

        -- Hide model and text completely if hidden
        if bHidden then
            plateEntity:SetTextAlpha(0)
            plateEntity:SetNotSolid(true)
            -- Force render mode to ensure it stays invisible
            plateEntity:SetRenderMode(RENDERMODE_NONE)
        else
            -- Restore alpha and collision if shown
            plateEntity:SetTextAlpha(plateEntity.GlideSavedAlpha or 255)
            plateEntity:SetNotSolid(false)
            plateEntity:SetRenderMode(RENDERMODE_NORMAL)
            plateEntity.ManualHide = nil -- Clear flag
        end
    end

    -- Checks shared by every edit message. Returns the plate entity, or nil.
    local function GetEditablePlate(ply, vehicle, plateId)
        if not IsValid(ply) then return end
        if not IsValid(vehicle) or not vehicle.IsGlideVehicle then return end
        if not GlideLicensePlates or not GlideLicensePlates.Config then return end
        if IsRateLimited(ply) then return end

        -- The player must have this vehicle selected with the plate editor tool
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        if wep:GetNWEntity(SELECTED_VEHICLE_NW) ~= vehicle then return end

        -- Ownership / permission check
        if not CanEditVehiclePlates(ply, vehicle) then
            ply:ChatPrint("[GLIDE License Plates] Only the vehicle owner or an admin can edit these plates.")
            return
        end

        -- Check if the plate entity exists under the selected ID
        local plateEntity = vehicle.LicensePlateEntities and vehicle.LicensePlateEntities[plateId]
        if IsValid(plateEntity) then return plateEntity end
    end

    net.Receive("GlidePlateEditor_Update", function(len, ply)
        local vehicle = net.ReadEntity()
        local plateId = net.ReadString()
        local key = net.ReadString()
        local value = net.ReadType()

        local plateEntity = GetEditablePlate(ply, vehicle, plateId)
        if not plateEntity then return end

        -- Apply Changes based on Key
        if key == "text" then
            if type(value) == "string" then
                value = string.gsub(value, "%c", "") -- strip control characters
                local maxCharacters = GlideLicensePlates.Config.MaxCharacters or 20
                if #value > 0 and #value <= maxCharacters then
                    plateEntity:UpdatePlateText(value)

                    -- Mark as manually-set: type changes will preserve this text
                    vehicle.PlateHasCustomText = vehicle.PlateHasCustomText or {}
                    vehicle.PlateHasCustomText[plateId] = true

                    -- Update vehicle save data (if available)
                    if vehicle.LicensePlateTexts then vehicle.LicensePlateTexts[plateId] = plateEntity:GetPlateText() end
                end
            end

        elseif key == "hidden" then
             local bHidden = tobool(value)
             ApplyManualHide(plateEntity, bHidden)

             -- Shown again: an active bodygroup rule may still hide it
             if not bHidden and GlideLicensePlates.RefreshAdvancedState then
                 GlideLicensePlates.RefreshAdvancedState(vehicle)
             end

        elseif key == "type" then
            if type(value) == "string" then
                local allowedData = ALLOWED_PLATES[value]

                if allowedData then -- Check if it's one of the allowed types
                    -- No-op if the plate already uses this tool type: nothing to
                    -- change, and it protects the text/defaults from being reset
                    -- by redundant re-sends of the current value.
                    if GetToolTypeForPlate(plateEntity) == value then return end

                    -- Use the representative PlateTypes entry for this tool type,
                    -- so defaults (font/scale/color/offset/pattern) come from real data.
                    local typeId = allowedData.typeId

                    plateEntity.PlateType = typeId
                    if vehicle.SelectedPlateTypes then vehicle.SelectedPlateTypes[plateId] = typeId end

                    -- Text handling on type change:
                    --  * Manually-set text is ALWAYS preserved.
                    --  * Random (auto) text: reuse the text of another auto plate that
                    --    already uses this same type (so front/rear share one text);
                    --    only generate a new one if there is no such plate.
                    local customFlags = vehicle.PlateHasCustomText
                    local hasCustomText = customFlags and customFlags[plateId]

                    if not hasCustomText then
                        local newText = nil

                        if vehicle.LicensePlateEntities then
                            for otherId, otherPlate in pairs(vehicle.LicensePlateEntities) do
                                if otherId ~= plateId and IsValid(otherPlate)
                                   and otherPlate.PlateType == typeId
                                   and not (customFlags and customFlags[otherId]) then
                                    local otherText = otherPlate:GetPlateText()
                                    if otherText and otherText ~= "" then
                                        newText = otherText
                                        break
                                    end
                                end
                            end
                        end

                        if not newText then
                            -- No sibling to copy from: new text matching the new pattern
                            newText = GlideLicensePlates.GeneratePlate(typeId)
                        end

                        plateEntity:UpdatePlateText(newText)
                        if vehicle.LicensePlateTexts then vehicle.LicensePlateTexts[plateId] = newText end
                    end

                    -- 1. MODEL
                    if allowedData.model then
                        plateEntity:UpdatePlateModel(allowedData.model)
                    end

                    -- 2. SKIN: Do NOT change skin automatically on type change. (Can be customized later)

                    -- 3. FONT: type default (falls back to global default)
                    local font = GlideLicensePlates.GetPlateFont(typeId)
                    plateEntity:SetPlateFont(font)
                    if vehicle.SelectedPlateFonts then vehicle.SelectedPlateFonts[plateId] = font end

                    -- 4. SCALE: type default (falls back to global default)
                    local scale = GlideLicensePlates.GetPlateScale(typeId)
                    plateEntity:SetPlateScale(scale)
                    if vehicle.SelectedPlateScales then vehicle.SelectedPlateScales[plateId] = scale end

                    -- 5. COLOR: type default
                    local color = GlideLicensePlates.GetPlateTextColor(typeId)
                    plateEntity:SetTextColor(Vector(color.r, color.g, color.b))
                    plateEntity:SetTextAlpha(color.a)
                    plateEntity.GlideSavedAlpha = color.a

                    -- 6. POSITION (OFFSET): type default
                    plateEntity:SetTextOffset(GlideLicensePlates.GetPlateTextOffset(typeId))
                end
            end

        elseif key == "scale" then
            if type(value) == "number" then
                value = math.Clamp(value, MIN_SCALE, MAX_SCALE)
                plateEntity:SetPlateScale(value)
                if vehicle.SelectedPlateScales then vehicle.SelectedPlateScales[plateId] = value end
            end

        elseif key == "offset" then
            if type(value) == "Vector" then
                value.x = math.Clamp(value.x, -MAX_OFFSET, MAX_OFFSET)
                value.y = math.Clamp(value.y, -MAX_OFFSET, MAX_OFFSET)
                value.z = math.Clamp(value.z, -MAX_OFFSET, MAX_OFFSET)
                plateEntity:SetTextOffset(value)
            end

        elseif key == "color_alpha" then
            if type(value) == "table" then
                local r = math.Clamp(tonumber(value.r) or 0, 0, 255)
                local g = math.Clamp(tonumber(value.g) or 0, 0, 255)
                local b = math.Clamp(tonumber(value.b) or 0, 0, 255)
                local a = math.Clamp(tonumber(value.a) or 255, 0, 255)
                plateEntity:SetTextColor(Vector(r, g, b))
                plateEntity:SetTextAlpha(a)
                plateEntity.GlideSavedAlpha = a -- Save alpha for restoration if hidden flag is removed
            end

        elseif key == "skin" then
            if type(value) == "number" then
                value = math.floor(math.Clamp(value, 0, MAX_SKIN))
                plateEntity:UpdatePlateSkin(value)
                if vehicle.SelectedPlateSkins then vehicle.SelectedPlateSkins[plateId] = value end
            end

        elseif key == "font" then
            if type(value) == "string" and #value > 0 then
                plateEntity:SetPlateFont(value)
                if vehicle.SelectedPlateFonts then vehicle.SelectedPlateFonts[plateId] = value end
            end
        end

        -- Persist the new state so duplicator/save data stays up to date
        if GlideLicensePlates.SavePlateData then
            GlideLicensePlates.SavePlateData(vehicle)
        end
    end)

    -- Advanced configuration of one plate: replaces all its entries in
    -- LicensePlateAdvancedConfigs (bone + bodygroup rules)
    net.Receive("GlidePlateEditor_Advanced", function(len, ply)
        local vehicle = net.ReadEntity()
        local plateId = net.ReadString()
        local bone = net.ReadString()
        local count = net.ReadUInt(5)

        local entries = {}
        if bone ~= "" then
            entries[1] = { id = plateId, bone = bone }
        end

        for _ = 1, count do
            local entry = { id = plateId, bodygroup = { net.ReadUInt(8), net.ReadUInt(8) } }

            if net.ReadBool() then
                entry.platetoggle = true
            else
                entry.newplateposition = net.ReadVector()
                entry.newplateangles = net.ReadAngle()
                entry.newplatemodelRotation = net.ReadAngle()
            end

            entries[#entries + 1] = entry
        end

        local plateEntity = GetEditablePlate(ply, vehicle, plateId)
        if not plateEntity then return end
        if not GlideLicensePlates.SanitizeAdvancedConfigs then return end

        -- Work on a per-vehicle copy: the configs may still be the class table
        -- shared by every vehicle of this class
        if not vehicle.PlateAdvancedEdited then
            local current = vehicle.LicensePlateAdvancedConfigs or vehicle.LicensePlateBodygroupConfigs
            vehicle.LicensePlateAdvancedConfigs = istable(current) and table.Copy(current) or {}
            vehicle.PlateAdvancedEdited = true
        end

        local list = {}
        for _, config in ipairs(vehicle.LicensePlateAdvancedConfigs) do
            if config.id ~= plateId then
                list[#list + 1] = config
            end
        end

        for _, entry in ipairs(entries) do
            list[#list + 1] = entry
        end

        vehicle.LicensePlateAdvancedConfigs = GlideLicensePlates.SanitizeAdvancedConfigs(vehicle, list)

        -- Apply now: bone attach/detach, then bodygroup rules
        plateEntity.BoneWarned = nil
        plateEntity:UpdatePosition()

        if GlideLicensePlates.RefreshAdvancedState then
            GlideLicensePlates.RefreshAdvancedState(vehicle)
        end

        if GlideLicensePlates.SavePlateData then
            GlideLicensePlates.SavePlateData(vehicle)
        end
    end)

    -- Copies the plate setup of `source` to `target` (same model), plate by
    -- plate (matching ids): type, look, text offset, manual hide and the whole
    -- advanced configuration. Texts are kept; auto (random) texts are only
    -- regenerated when the type changes, shared between plates of one type.
    local function CopyPlateSetup(source, target)
        local sourcePlates = source.LicensePlateEntities or {}
        local customFlags = target.PlateHasCustomText or {}

        -- Auto texts of target plates that keep their type, by type
        local autoTexts = {}
        for id, dst in pairs(target.LicensePlateEntities) do
            local src = sourcePlates[id]
            if IsValid(dst) and dst.PlateType and not customFlags[id]
               and (not IsValid(src) or src.PlateType == dst.PlateType) then
                autoTexts[dst.PlateType] = autoTexts[dst.PlateType] or dst:GetPlateText()
            end
        end

        for id, dst in pairs(target.LicensePlateEntities) do
            local src = sourcePlates[id]
            if not IsValid(dst) or not IsValid(src) then continue end

            -- Type and model
            if src.PlateType and src.PlateType ~= dst.PlateType then
                dst.PlateType = src.PlateType
                if target.SelectedPlateTypes then target.SelectedPlateTypes[id] = src.PlateType end

                if not customFlags[id] then
                    local text = autoTexts[src.PlateType] or GlideLicensePlates.GeneratePlate(src.PlateType)
                    autoTexts[src.PlateType] = text
                    dst:UpdatePlateText(text)
                    if target.LicensePlateTexts then target.LicensePlateTexts[id] = text end
                end
            end

            if src:GetModel() ~= dst:GetModel() then
                dst:UpdatePlateModel(src:GetModel())
            end

            -- Look
            local font = src:GetPlateFont()
            dst:SetPlateFont(font)
            if target.SelectedPlateFonts then target.SelectedPlateFonts[id] = font end

            local scale = src:GetPlateScale()
            dst:SetPlateScale(scale)
            if target.SelectedPlateScales then target.SelectedPlateScales[id] = scale end

            local skin = src:GetPlateSkin()
            dst:UpdatePlateSkin(skin)
            if target.SelectedPlateSkins then target.SelectedPlateSkins[id] = skin end

            dst:SetTextColor(src:GetTextColor())
            dst:SetTextOffset(src:GetTextOffset())

            -- Alpha the text has when shown (hidden plates have alpha 0)
            local alpha = src:GetNoDraw() and (src.GlideSavedAlpha or 255) or src:GetTextAlpha()
            dst.GlideSavedAlpha = alpha
            if not dst:GetNoDraw() then dst:SetTextAlpha(alpha) end

            if (src.ManualHide == true) ~= (dst.ManualHide == true) then
                ApplyManualHide(dst, src.ManualHide == true)
            end
        end

        -- Advanced configuration (bone + bodygroup rules); the sanitizer
        -- returns new tables, nothing is shared with the source
        local configs = source.LicensePlateAdvancedConfigs or source.LicensePlateBodygroupConfigs
        target.LicensePlateAdvancedConfigs = GlideLicensePlates.SanitizeAdvancedConfigs(target, configs or {})
        target.PlateAdvancedEdited = true

        for _, dst in pairs(target.LicensePlateEntities) do
            if IsValid(dst) then
                dst.BoneWarned = nil
                dst:UpdatePosition()
            end
        end

        if GlideLicensePlates.RefreshAdvancedState then
            GlideLicensePlates.RefreshAdvancedState(target)
        end

        if GlideLicensePlates.SavePlateData then
            GlideLicensePlates.SavePlateData(target)
        end
    end

    -- Reload: copy the plate setup of the selected vehicle to the aimed one
    function TOOL:Reload(trace)
        local ply = self:GetOwner()
        local source = self:GetWeapon():GetNWEntity(SELECTED_VEHICLE_NW)
        local target = trace.Entity

        if not IsValid(source) or not IsValid(target) or target == source then return false end
        if not target.IsGlideVehicle or not target.LicensePlateEntities or not next(target.LicensePlateEntities) then return false end
        if not GlideLicensePlates or not GlideLicensePlates.SanitizeAdvancedConfigs then return false end
        if IsRateLimited(ply) then return false end

        if target:GetModel() ~= source:GetModel() then
            ply:ChatPrint("#glide_pe_copy_mismatch")
            return false
        end

        if not CanEditVehiclePlates(ply, target) then
            ply:ChatPrint("[GLIDE License Plates] Only the vehicle owner or an admin can edit these plates.")
            return false
        end

        CopyPlateSetup(source, target)
        ply:ChatPrint("#glide_pe_copy_done")

        return true
    end

    -- Preview a bodygroup rule: toggles the vehicle bodygroup between the
    -- rule's submodel and 0
    net.Receive("GlidePlateEditor_Preview", function(len, ply)
        local vehicle = net.ReadEntity()
        local plateId = net.ReadString()
        local index = net.ReadUInt(8)
        local sub = net.ReadUInt(8)

        if not GetEditablePlate(ply, vehicle, plateId) then return end
        if index >= vehicle:GetNumBodyGroups() or sub >= vehicle:GetBodygroupCount(index) then return end

        if vehicle:GetBodygroup(index) == sub then
            sub = 0
        end

        vehicle:SetBodygroup(index, sub)

        if GlideLicensePlates.RefreshAdvancedState then
            GlideLicensePlates.RefreshAdvancedState(vehicle)
        end
    end)
end
