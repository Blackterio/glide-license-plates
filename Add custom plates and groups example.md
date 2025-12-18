-- lua/autorun/sh_custom_plates_example.lua

-- [Change] Use the custom hook to ensure the base system is fully loaded
hook.Add("GlideLicensePlatesLoaded", "ExampleCustomGlideLicensePlates", function()
    if not GlideLicensePlates or not GlideLicensePlates.PlateTypes then return end

    -- [Optimization] Safe assignment to the global table
    GlideLicensePlates.PlateTypes["examplecustomplate1"] = {
        description = "[Custom] example customplate1", 
        model = "models/blackterios_glide_vehicles/licenseplates/europeplate.mdl",
        pattern = "1-AB-2-C", 
        font = "Arial",
        textscale = 0.4,
        textposition = Vector(0, 0, -0.5),
        textcolor = {r = 212, g = 175, b = 55, a = 255}, 
        skin = 0
    }

    GlideLicensePlates.PlateTypes["examplecustomplate2"] = {
        description = "[Custom] example customplate2",
        model = "models/blackterios_glide_vehicles/licenseplates/smallplate.mdl",
        pattern = "AB-123-ABCD", 
        font = "coolvetica",
        textscale = 0.5,
        textposition = Vector(0, 0, 0.1),
        textcolor = {r = 255, g = 255, b = 255, a = 255},
        skin = 1
    }

    -- [New] Example of adding these custom plates to a group
    GlideLicensePlates.PlateGroups["custom_group"] = {
        "examplecustomplate1",
        "examplecustomplate2"
    }
    
    -- [New] Or adding to an existing group
    if GlideLicensePlates.PlateGroups["mercosurplates"] then
        table.insert(GlideLicensePlates.PlateGroups["mercosurplates"], "examplecustomplate1")
    end
end)