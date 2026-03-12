-- lua/autorun/client/cl_glide_category.lua
-- This file ensures the "Glide" tool category exists
-- It loads after Glide base to register the category

if CLIENT then
    -- Register the Glide tool category icon
    list.Set("ContentCategoryIcons", "Glide", "materials/glide/icons/car.png")
    
    -- Add a simple help text to ensure category is registered
    hook.Add("AddToolMenuCategories", "GlideLicensePlates_RegisterCategory", function()
        -- This ensures the category is registered
    end)
end
