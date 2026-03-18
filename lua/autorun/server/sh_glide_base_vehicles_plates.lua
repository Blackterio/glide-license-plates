-- luaautorunserversh_glide_base_vehicles_plates.lua

-- External configuration for vehicles that cannot be edited directly
-- Mainly used for the base Glide vehicles, I don't really recommend using this method for normal vehicles

local plates = {"gtavplates", "gtasaplates", "gtaivplates"}
local frontid = "front_main"
local rearid = "rear_main"
local invisibleplate = "models/blackterios_glide_vehicles/licenseplates/invisibleplate.mdl"

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

  	
	-- GTA V - Sedans Pack (Exidnost)
		
	["gtav_vapid_cruiser_taxi"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },           
        }
    },		

	["gtav_albany_emperor"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -9.3),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-123.3, 0, 4.1),
                angles = Angle(-1, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },
 	
	["gtav_albany_emperor_rusty"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -9.3),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-123.3, 0, 4.1),
                angles = Angle(-1, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },
	["gtav_albany_emperor_snowed"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -9.3),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavnorthyankton",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-123.3, 0, 4.1),
                angles = Angle(-1, 180, 0),
                plateType = "gtavnorthyankton",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_albany_esperanto"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -8.5),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-106.5, 0, 3.5),
                angles = Angle(-20, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
    },			
	["gtav_albany_esperanto_nysp"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -8.5),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-106.5, 0, 3.5),
                angles = Angle(-20, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },           
        }
    },			
	["gtav_albany_esperanto_nysp_snow"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(107.5, 0, -8.5),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-106.5, 0, 3.5),
                angles = Angle(-20, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_albany_primo"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(114.5, 0, -8),
                angles = Angle(-1.5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-115, 0, 6.2),
                angles = Angle(-5, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_albany_stretch"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(172.3, 0, -13.9),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-176.2, 0, 0.5),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_albany_washington"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(116, 0, -6.6),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-118.8, 0, 8),
                angles = Angle(-12, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_benefactor_glendale"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(104.5, 0, -18.5),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-103.8, 0, -3),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_benefactor_schafter"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(111.9, 0, -8.5),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-117.8, 0, 12),
                angles = Angle(-15, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_albany_romero"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(120.5, 0, -6.6),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-132.3, 0, -7),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {9, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {9, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_cheval_fugitive"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(105.3, 0, -14.5),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-118, 0, -9.5),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_cheval_surge"] = {
        BasePlates = {

            {
                id = rearid,
                position = Vector(-95.7, 0, -7.4),
                angles = Angle(-2, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
           
			{
                id = rearid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_declasse_asea"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(93.5, 0, -6),
                angles = Angle(-0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-101.3, 0, -7),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {16, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {16, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_declasse_asea_snowed"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(93.5, 0, -6),
                angles = Angle(-0, 0, 0),
                plateType = "gtavnorthyankton",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-101.3, 0, -7),
                angles = Angle(-0, 180, 0),
                plateType = "gtavnorthyankton",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_declasse_premier"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(101.5, 0, -7),
                angles = Angle(5, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-99.4, 0, 15.4),
                angles = Angle(-8, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_dundreary_regina"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(109.3, 0, -17),
                angles = Angle(20, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-131, 0, -12.7),
                angles = Angle(-2, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },			
	["gtav_enus_super_diamond"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(114.5, 0, -6),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-137.1, 0, 15),
                angles = Angle(-4, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_karin_asterope"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(109.5, 0, -6.5),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-105, 0, 14),
                angles = Angle(-4, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_karin_intruder"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(112, 0, -12.9),
                angles = Angle(9, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-111.5, 0, -8.5),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_lampadati_felon"] = {
        BasePlates = {

            {
                id = rearid,
                position = Vector(-114.8, 0, 2),
                angles = Angle(-15, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_obey_tailgater"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(111.0, 0, -11),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-108.1, 0, 9.2),
                angles = Angle(-5, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {11, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_ocelot_jackal"] = {
        BasePlates = {
            {
                id = rearid,
                position = Vector(-114.5, 0, -5.5),
                angles = Angle(-7, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {            
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_ubermacht_oracle"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(112, 0, 6),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-118.3, 0, 23),
                angles = Angle(-19, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {9, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {9, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_ubermacht_oracle_xs"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(108.4, 0, -16),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-111.7, 0, 2.3),
                angles = Angle(-15, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {8, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_vapid_cruiser"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },           
        }
    },			
	["gtav_vapid_cruiser_sheriff"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_vapid_cruiser_sheriff_alt"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },			
	["gtav_vapid_cruiser_unmarked"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {12, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_vapid_police_cruiser"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_vapid_police_cruiser_alt"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(121.5, 0, -6.7),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-114.8, 0, 8.2),
                angles = Angle(-10, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,						
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_vapid_interceptor"] = {
        BasePlates = {

            {
                id = rearid,
                position = Vector(-113.5, 0, 10),
                angles = Angle(-20, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
          
			{
                id = rearid,
                bodygroup = {14, 1}, 
                platetoggle = true  
            },           
        }
    },	
	["gtav_vapid_police_interceptor"] = {
        BasePlates = {

            {
                id = rearid,
                position = Vector(-113.5, 0, 10),
                angles = Angle(-20, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
          
			{
                id = rearid,
                bodygroup = {18, 1}, 
                platetoggle = true  
            },           
        }
    },
	["gtav_vapid_stanier"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(111, 0, -9),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-122, 0, 3.7),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {7, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_vulcar_ingot"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(105, 0, -9),
                angles = Angle(0, 0, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-104, 0, 2),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {10, 1}, 
                platetoggle = true  
            },           
        }
    },		
	["gtav_vulcar_warrener"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(97.5, 0, 5),
                angles = Angle(17, 0, -2),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-106.5, 0, 19.3),
                angles = Angle(-15, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
    },				
	["gtav_zirconium_stratum"] = {
        BasePlates = {
            {
                id = frontid,
                position = Vector(109, 0, -0.9),
                angles = Angle(0, 0, -0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,			
            },
            {
                id = rearid,
                position = Vector(-115.5, 0, 2.2),
                angles = Angle(-0, 180, 0),
                plateType = "gtavsanandreaswhite",
				customModel = invisibleplate,				
            }
        },
        Advanced = {
            {
                id = frontid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },               
			{
                id = rearid,
                bodygroup = {13, 1}, 
                platetoggle = true  
            },           
        }
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