-- lua/autorun/server/sh_glide_base_vehicles_plates.lua

-- External configuration for vehicles that cannot be edited directly
-- Mainly used for the base Glide vehicles, I don't really recommend using this method for normal vehicles

local plates = {"gtavplates", "gtasaplates", "gtaivplates"}
local frontid = "front_main"
local rearid = "rear_main"

local externalConfigs = {
    ["gtav_speedo"] = {
		-- Base config
        BasePlates = {
            {
                id = frontid,
                position = Vector(111.5, 0, -13),
                angles = Angle(0, 0, 0),
                plateType = plates,
            },
            {
                id = rearid,
                position = Vector(-120.5, -15.698, 8.534),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },
        -- Bodygroups
        Advanced = {
            {
                id = frontid,
                bodygroup = {3, 1}, -- If bodygroup 8 is submodel 1
                platetoggle = true  -- Hide the plate
            }
        }
    },    
    ["gtav_police_cruiser"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.5),
                angles = Angle(0, 0, 0),
                plateType = "gtavandreasplates",
            },
            {
                id = rearid,
                position = Vector(-114.9, 0, 8.3),
                angles = Angle(-10, 180, 0),
                plateType = "gtavandreasplates",
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {5, 1}, 
                platetoggle = true  
            }
        }
    },     
	["gtav_jb700"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-108.3, 0, 3.5),
                angles = Angle(-8, 180, 0),
                plateType = plates,
            }
        },
        Advanced = {
            {
                id = rearid,
                bodygroup = {5, 1}, 
                platetoggle = true  
            }
        }
    },
    ["gtav_insurgent"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-138.3, 0, -2.85),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        }
    },  
    ["gtav_infernus"] = {
        BasePlates = {

            {
                id = rearid,
                position = Vector(-91.4, 0.25, -2.9),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },
		Advanced = {
            {
                id = rearid,
                bodygroup = {9, 1}, 
                platetoggle = true  
            }
        }
    },     
    ["gtav_hauler"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(147.9, 0, -37.5),
                angles = Angle(0, 0, 0),
                plateType = plates,
            },
            {
                id = rearid,
                position = Vector(-151.2, 0, -22.5),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
			{
                id = frontid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            }, -- Idk if its an error with the truck's model, but bodygroup 7 and 8 are the same thing 
        }
    }, 
    ["gtav_gauntlet_classic"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-99.5, 0, 9.6),
                angles = Angle(21, 180, 0),
                plateType = plates,
            }
        }
    },      
	["gtav_dukes"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-129.5, 0, -2.9),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },
		Advanced = {
            {
                id = rearid,
                bodygroup = {5, 1}, 
                platetoggle = true  
            }           
        }
    },	
	["gtav_blazer"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-31.9, 0, 6.2),
                angles = Angle(-8, 180, 0),
                plateType = plates,
            }
        }
    },  	
	["gtav_bati801"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-41.7, 0, 15.7),
                angles = Angle(-36, 180, 0),
                plateType = plates,
            }
        }
    },
    ["gtav_airbus"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(294.3, 0, -23.2),
                angles = Angle(0, 0, 0),
                plateType = plates,
            },
            {
                id = rearid,
                position = Vector(-291.9, 0, 5),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },    
	["glide_experiments_blazer_aqua"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-44.5, 0, 17),
                angles = Angle(-15, 180, 0),
                plateType = plates,
            }
        },
    }, 
	["glide_experiments_caddy"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(48, 0, -5.5),
                angles = Angle(0, 0, 0),
                plateType = plates,
            },           
			{
                id = rearid,
                position = Vector(-46.9, 0,-5.5),
                angles = Angle(0, 180, 0),
                plateType = plates,
            }
        },

    }, 	
	["glide_experiments_deluxo"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-93.4, 0, 13.5),
                angles = Angle(-10.3, 180, 0),
                plateType = plates,
            }           
        },
    }, 
  	
}

local function ApplyExternalConfig(ent)
    if not IsValid(ent) then return end

    local class = ent:GetClass()
    local config = externalConfigs[class]

    -- We ensure the vehicle is a Glide vehicle before injecting
    if config and ent.IsGlideVehicle then
        local base = config.BasePlates or config
        local advanced = config.Advanced

        -- Inject the configurations into the entity
        ent.LicensePlateConfigs = base
        
        if advanced then
            ent.LicensePlateAdvancedConfigs = advanced
        end

    end
end

hook.Add("OnEntityCreated", "GlideExternalPlates_Init", function(ent)
    -- Timer 0 ensures injection happens before the main addon's 0.1s timer
    timer.Simple(0, function()
        ApplyExternalConfig(ent)
    end)
end)

-- Ensure all state tables are captured by GMod Duplicator and Saves
hook.Add("OnEntityCopyTable", "GlideExternalPlates_SavePersistence", function(ent, data)
    if IsValid(ent) and ent.IsGlideVehicle then
        -- Essential structural data
        if ent.LicensePlateConfigs then
            data.LicensePlateConfigs = table.Copy(ent.LicensePlateConfigs)
        end
        
        if ent.LicensePlateAdvancedConfigs then
            data.LicensePlateAdvancedConfigs = table.Copy(ent.LicensePlateAdvancedConfigs)
        end

        -- State data (Crucial for restoring the exact plate text and type)
        data.LicensePlateTexts = ent.LicensePlateTexts
        data.SelectedPlateTypes = ent.SelectedPlateTypes
        data.SelectedPlateScales = ent.SelectedPlateScales
        data.SelectedPlateSkins = ent.SelectedPlateSkins
        data.SelectedPlateFonts = ent.SelectedPlateFonts
        
        if ent._GlidePlateData then
            data._GlidePlateData = ent._GlidePlateData
        end
    end
end)
