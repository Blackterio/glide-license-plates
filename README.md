# License plate system for Glide vehicles

## How to add support for license plates to your vehicle

### Heres what you can put on your vehicle's LUA file to make it compatible with this system

```
local plateCustomText = "" -- Custom text for the license plate, leave blank if you want random text based on the plate's type. IT MUST BE THE SAME FOR ALL PLATES
local plateType = {"argold", "argvintage"} -- Plate type(s). See the "Every plate type available.md" file in Github for more types. "anytype" (without the {}) for ALL types available. Empty or wrong type will fallback to "argmercosur" 

ENT.LicensePlateConfigs = {
    
    { 
  		id = "rear_main", -- ID for this plate, mainly used on the tool to see which one you're editing, can be anything you like
  		position = Vector(-104.2, 0, 22), -- Plate position in the vehicle
  		angles = Angle(10, 180, 0), -- Text and base model angles
  		modelRotation = Angle(0, 0, 0), -- Base model rotation, adds to the angles of the previous text angle parameter. Rarely needed, mainly used for super specific tweaking.
  		plateType = plateType, 
        customText = plateCustomText, 
        customFont = "" -- Optional license plate font override 
        customSkin = 0, -- Optional custom skin override
        customModel = "path/to/your_model.mdl", -- Optional custom model override for this plate
        textColor = { r = 255, g = 255, b = 255, a = 255 }, -- Optional custom text color	 
        scale = 0.5, -- Optional text scale override, relative to the base model.
        textOffset = Vector(0, 0, 0) -- Optional text offset override, relative to the base model.
    },   
    {
		id = "front_main",
		position = Vector(109.8, 0, 12), 
		angles = Angle(0, 0, 0), 
		modelRotation = Angle(0, 0, 0), 
		plateType = plateType,
		customText = plateCustomText,
	 -- customFont = "" 
	 -- customSkin = 0,		
	 -- customModel = "path/to/your_model.mdl",
	 -- textColor = { r = 255, g = 255, b = 255, a = 255 }, 		
	 -- scale = 0.5, 
	 -- textOffset = Vector(0, 0, 0) 	
    }, -- you can put as many plates as you want, just make sure to use different IDs
  }
```

#### You can also specify what you want to do with a plate when a bodygroup of your chosing is toggled or changed to another submodel

```
  ENT.LicensePlateAdvancedConfigs = {
 
    { 
		id = "front_main", -- Plate ID, it must exist on the vehicle
        bodygroup = {21,1},  -- {Bodygroup,SubmodelID}
		platetoggle = true, -- if true, when bodygroup state is toggled to the value specified above, plate will be hidden
	 -- newplateposition = Vector(0, 0, 0), --  if the bodygroup is toggled to the new state, plate will be moved to this position (relative to vehicle). If plate is hidden this is not needed
     -- newplateangles = Angle(0, 0, 0), --  if the bodygroup is toggled to the new state, plate angle will be modified to this position. If plate is hidden this is not needed
     -- newplatemodelRotation = Angle(0, 0, 0), --  if the bodygroup is toggled to the new state, plate model angle will be modified to this position. If plate is hidden this is not needed 			

    }, -- you can put as many as you want
}
```

This thing is extremely slop coded (AI), feel free to improve it with your REAL talent as you wish. Proper credits will be given for every improvement.
