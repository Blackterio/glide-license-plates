-- lua/autorun/sh_glide_license_plates.lua

-- Initialize global table
GlideLicensePlates = GlideLicensePlates or {}
GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}

-- Verify if Glide is available
if not Glide then
    if SERVER then
        print("[GLIDE License Plates] Glide is not installed. License plates addon will not work.")
    end
    return
end

-- System configuration
GlideLicensePlates.Config = {
    MaxCharacters = 20,
    DefaultFont = "Arial",
    DefaultModel = "models/sprops/rectangles_superthin/size_1/rect_3x12.mdl",
    DefaultScale = 0.5,
    DefaultSkin = 0
}
local mercosurmodel = "models/blackterios_glide_vehicles/licenseplates/mercosurplate.mdl"
local mercosurtextscale = 0.37
local mercosurtextposition = Vector(0, 0, -0.55)
local mercosureuropetextfont = "GL-Nummernschild-Mtl"

local textcolorblack = {r = 0, g = 0, b = 0, a = 255}
local textcolorred = {r = 205, g = 10, b = 10, a = 255}

local usasmallplate = "models/blackterios_glide_vehicles/licenseplates/smallplate.mdl"
local usatextscale = 0.37
local usatextfont = "Dealerplate California"

local floridatextcolors = {r = 47, g = 116, b = 83, a = 255}
local floridatextposition = Vector(0.2, 0, 0.15)
local floridaskin = 3

local illinoistextposition = Vector(0.2, 0, -0.2)
local illinoisskin = 4 

local europelongplate = "models/blackterios_glide_vehicles/licenseplates/europeplate.mdl"	
local europetextscale = 0.34
local europetextposition = Vector(0.2, 0.6, 0.1)
local europetextposition2 = Vector(0.2, 0.8, 0.1)

local gtatextposition = Vector(0.2, 0, -0.5)
local gtatextcolor1 = {r = 18, g = 28, b = 97, a = 255}
local gtatextcolor2 = {r = 180, g = 196, b = 54, a = 255}

GlideLicensePlates.PlateTypes = { 

--LATAM
    ["argmercosur"] = {
        pattern = "AB 123 CD",
        model = mercosurmodel,
        description = "Mercosur Argentina (AB 123 CD) - Standard plate",
        defaultFont = mercosureuropetextfont,
        defaultTextColor = textcolorblack,
        defaultScale = mercosurtextscale, 
		defaultTextOffset = mercosurtextposition,
		defaultSkin = 0,		
    },
    ["argold"] = {
        pattern = "ABC 123",
        model = "models/blackterios_glide_vehicles/licenseplates/argentinaold.mdl", 
        description = "Argentina Old (ABC 123)",
        defaultFont = "coolvetica",
        defaultTextColor = {r = 255, g = 255, b = 255, a = 255},
        defaultScale = 0.33,
        defaultSkin = 0,
    },
    ["argvintage"] = {
        pattern = "A123456",
        model = "models/blackterios_glide_vehicles/licenseplates/argentinavintage.mdl",
        description = "Argentina Vintage (A123456)",
        defaultFont = "Times New Roman",
        defaultTextColor = {r = 255, g = 255, b = 255, a = 255},
        defaultScale = 0.4,
        defaultSkin = 0,
    },    
	["brasilmercosur"] = {
        pattern = "ABC1D23",
        model = mercosurmodel,
        description = "Mercosur Brasil (ABC1D23)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = mercosurtextscale,  
		defaultTextOffset = mercosurtextposition,
        defaultSkin = 1,
    },
	["paraguaymercosur"] = {
        pattern = "ABCD 123",
        model = mercosurmodel,
        description = "Mercosur Paraguay (ABCD 123)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = mercosurtextscale, 
		defaultTextOffset = mercosurtextposition,
        defaultSkin = 2,
    },	
	["uruguaymercosur"] = {
        pattern = "ABC 1234",
        model = mercosurmodel,
        description = "Mercosur Uruguay (ABC 1234)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = mercosurtextscale,  
		defaultTextOffset = mercosurtextposition,
        defaultSkin = 3,
    },
	
--USA
	["usacalifornia"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "California (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = {r = 18, g = 28, b = 97, a = 255},
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, -0.5),
        defaultSkin = 0,
    },		
	["usacoloradov1"] = {
        pattern = "123 ABC",
        model = usasmallplate,
        description = "Colorado V1 (123 ABC)",
        defaultFont = usatextfont,
        defaultTextColor = {r = 5, g = 30, b = 16, a = 255},
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, 0.01),
        defaultSkin = 1,
    },		
	["usacoloradov2"] = {
        pattern = "ABC 123",
        model = usasmallplate,
        description = "Colorado V2 (ABC 123)",
        defaultFont = usatextfont,
        defaultTextColor = {r = 5, g = 30, b = 16, a = 255},
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, 0.01),
        defaultSkin = 1,
    },		
	["usadelaware"] = {
        pattern = "123456",
        model = usasmallplate,
        description = "Delaware (123456)",
        defaultFont = usatextfont,
        defaultTextColor = {r = 220, g = 189, b = 88, a = 255},
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, 0.15),
        defaultSkin = 2,
    },		
	["usafloridav1"] = {
        pattern = "AB1   2CD",
        model = usasmallplate,
        description = "Florida V1 (AB1   2CD)",
        defaultFont = usatextfont,
        defaultTextColor = floridatextcolors,
        defaultScale = usatextscale,  
		defaultTextOffset = floridatextposition,
        defaultSkin = floridaskin,
    },		
	["usafloridav2"] = {
        pattern = "A12   3BC",
        model = usasmallplate,
        description = "Florida V2 (A12   3BC)",
        defaultFont = usatextfont,
        defaultTextColor = floridatextcolors,
        defaultScale = usatextscale,  
		defaultTextOffset = floridatextposition,
        defaultSkin = floridaskin,
    },		
	["usafloridav3"] = {
        pattern = "123   4AB",
        model = usasmallplate,
        description = "Florida V3 (123   4AB)",
        defaultFont = usatextfont,
        defaultTextColor = floridatextcolors,
        defaultScale = usatextscale,  
		defaultTextOffset = floridatextposition,
        defaultSkin = floridaskin,
    },		
	["usafloridav4"] = {
        pattern = "12A   BCD",
        model = usasmallplate,
        description = "Florida V4 (12A   BCD)",
        defaultFont = usatextfont,
        defaultTextColor = floridatextcolors,
        defaultScale = usatextscale,  
		defaultTextOffset = floridatextposition,
        defaultSkin = floridaskin,
    },		
	["usafloridav5"] = {
        pattern = "123   ABC",
        model = usasmallplate,
        description = "Florida V5 (123   ABC)",
        defaultFont = usatextfont,
        defaultTextColor = floridatextcolors,
        defaultScale = usatextscale,  
		defaultTextOffset = floridatextposition,
        defaultSkin = floridaskin,
    },		
	["usaillinoisv1"] = {
        pattern = "AB1 2345",
        model = usasmallplate,
        description = "Illinois V1 (AB1 2345)",
        defaultFont = usatextfont,
        defaultTextColor = textcolorred,
        defaultScale = usatextscale,  
		defaultTextOffset = illinoistextposition,
        defaultSkin = illinoisskin,
    },		
	["usaillinoisv2"] = {
        pattern = "A12 3456",
        model = usasmallplate,
        description = "Illinois V2 (A12 3456)",
        defaultFont = usatextfont,
        defaultTextColor = textcolorred,
        defaultScale = usatextscale,  
		defaultTextOffset = illinoistextposition,
        defaultSkin = illinoisskin,
    },	
	["usanewyork"] = {
        pattern = "ABC  5329",
        model = usasmallplate,
        description = "New York (ABC  5329)",
        defaultFont = usatextfont,
        defaultTextColor = {r = 3, g = 4, b = 67, a = 255},
        defaultScale = 0.36,  
		defaultTextOffset = Vector(0.2, 0, -0.2),
        defaultSkin = 5,
    },		
	["usaoklahomav1"] = {
        pattern = "   123ABC",
        model = usasmallplate,
        description = "Oklahoma V1 (   123ABC)",
        defaultFont = usatextfont,
        defaultTextColor = textcolorred,
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, 0),
        defaultSkin = 6,
    },			
	["usaoklahomav2"] = {
        pattern = "   ABC123",
        model = usasmallplate,
        description = "Oklahoma V2 (   ABC123)",
        defaultFont = usatextfont,
        defaultTextColor = textcolorred,
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, 0),
        defaultSkin = 6,
    },		
	["usatexas"] = {
        pattern = "AB1  C234",
        model = usasmallplate,
        description = "Texas (AB1  C234)",
        defaultFont = usatextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = 0.3594,  
		defaultTextOffset = Vector(0.2, 0, -0.2),
        defaultSkin = 7,
    },		
	["usawisconsin"] = {
        pattern = "ABC-1234",
        model = usasmallplate,
        description = "Wisconsin (ABC-1234)",
        defaultFont = usatextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = usatextscale,  
		defaultTextOffset = Vector(0.2, 0, -0.4),
        defaultSkin = 8,
    },			
	["usawyoming"] = {
        pattern = "   123456",
        model = usasmallplate,
        description = "Wyoming (   123456)",
        defaultFont = usatextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = 0.36,  
		defaultTextOffset = Vector(0.2, 0, 0),
        defaultSkin = 9,
    },	
	
--Europe	
	["europealbaniav1"] = {
        pattern = "AB 1234 C",
        model = europelongplate,
        description = "Albania V1 (AB 1234 C)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 0,
    },		
	["europealbaniav2"] = {
        pattern = "AB 123 CD",
        model = europelongplate,
        description = "Albania V2 (AB 123 CD)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 0,
    },		
	["europeaustria"] = {
        pattern = "A 123 BC",
        model = europelongplate,
        description = "Austria (A 123 BC)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 1,
    },			
	["europebelgium"] = {
        pattern = "1-ABC-234",
        model = europelongplate,
        description = "Belgium (1-ABC-234)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorred,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 2,
    },
	["europebulgaria"] = {
        pattern = "A 1234 BC",
        model = europelongplate,
        description = "Bulgaria (A 1234 BC)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 3,
    },		
	["europeczech"] = {
        pattern = "1A2 3456",
        model = europelongplate,
        description = "Czech Republic (1A2 3456)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 4,
    },		
	["europedenmark"] = {
        pattern = "AB 12 345",
        model = europelongplate,
        description = "Denmark (AB 12 345)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 5,
    },		
	["europefinland"] = {
        pattern = "ABC-123",
        model = europelongplate,
        description = "Finland (ABC-123)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 6,
    },		
	["europefrance"] = {
        pattern = "AB-123-BC",
        model = europelongplate,
        description = "France (AB-123-BC)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 7,
    },		
	["europegermany"] = {
        pattern = "AB CD 1234",
        model = europelongplate,
        description = "Germany (AB CD 1234)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 8,
    },	
	["europegreatbritain"] = {
        pattern = "ABC 1234",
        model = europelongplate,
        description = "UK EU (ABC 1234)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 9,
    },		
	["greatbritain"] = {
        pattern = "AB1C DEF",
        model = europelongplate,
        description = "UK (AB1C DEF)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = Vector(0.2, -0.15, 0),
        defaultSkin = 10,
    },		
	["europegreece"] = {
        pattern = "ABC-1234",
        model = europelongplate,
        description = "Greece (ABC-1234)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 11,
    },		
	["europehungary"] = {
        pattern = "AB CD-123",
        model = europelongplate,
        description = "Hungary (AB CD-123)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 12,
    },		
	["europeireland"] = {
        pattern = "123-A-45678",
        model = europelongplate,
        description = "Ireland (123-A-45678)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = 0.31,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 13,
    },		
	["europeitaly"] = {
        pattern = "AB 123C4",
        model = europelongplate,
        description = "Italy (AB 123C4)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 14,
    },		
	["europenetherlands"] = {
        pattern = "ABC-12-D",
        model = europelongplate,
        description = "Netherlands (ABC-12-D)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 15,
    },		
	["europenorway"] = {
        pattern = "AB 12345",
        model = europelongplate,
        description = "Norway (AB 12345)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition,
        defaultSkin = 16,
    },		
	["europepoland"] = {
        pattern = "AB-1234C",
        model = europelongplate,
        description = "Poland (AB-1234C)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 17,
    },		
	["europeportugalv1"] = {
        pattern = "AB12CD",
        model = europelongplate,
        description = "Portugal V1 (AB12CD)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 18,
    },		
	["europeportugalv2"] = {
        pattern = "12 AB 34",
        model = europelongplate,
        description = "Portugal V2 (12 AB 34)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 18,
    },	
	["europeportugalv3"] = {
        pattern = "12 34 AB",
        model = europelongplate,
        description = "Portugal V3 (12 34 AB)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 18,
    },		
	["europeromania"] = {
        pattern = "A 12 BCD",
        model = europelongplate,
        description = "Romania (A 12 BCD)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 19,
    },		
	["russia"] = {
        pattern = "A123CD",
        model = europelongplate,
        description = "Russia (A123CD)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = Vector(0.2, -1.7, 0),
        defaultSkin = 20,
    },	
	["europespain"] = {
        pattern = "1234 ABC",
        model = europelongplate,
        description = "Spain (1234 ABC)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 21,
    },		
	["europeswedenv1"] = {
        pattern = "ABC 123",
        model = europelongplate,
        description = "Sweden V1 (ABC 123)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 22,
    },			
	["europeswedenv2"] = {
        pattern = "ABC 12D",
        model = europelongplate,
        description = "Sweden V2 (ABC 12D)",
        defaultFont = mercosureuropetextfont,
        defaultTextColor =  textcolorblack,
        defaultScale = europetextscale,  
		defaultTextOffset = europetextposition2,
        defaultSkin = 22,
    },	
--Fictional
	--GTA SA
	["gtasalossantos"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "Los Santos SA (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 10,
    },		
	["gtasasanfierro"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "San Fierro SA (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 11,
    },		
	["gtasalasventuras"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "Las Venturas SA (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 12,
    },		
	-- GTA V
	["gtavsanandreasblack"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "San Andreas - Black (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor2,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 13,
    },	
	["gtavsanandreasblue"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "San Andreas - Blue (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor2,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 14,
    },		
	["gtavsanandreaswhite"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "San Andreas - White (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 15,
    },		
	["gtavsanandreasalt"] = {
        pattern = "1ABC234",
        model = usasmallplate,
        description = "San Andreas - Alternative (1ABC234)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 16,
    },		
	["gtavnorthyankton"] = {
        pattern = "12ABC345",
        model = usasmallplate,
        description = "North Yankton (12ABC345)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = usatextscale,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 17,
    },		
	--GTA IV
	["gtaivlibertycity"] = {
        pattern = "12ABC345",
        model = usasmallplate,
        description = "Liberty City (12ABC345)",
        defaultFont = usatextfont,
        defaultTextColor = gtatextcolor1,
        defaultScale = 0.35,  
		defaultTextOffset = gtatextposition,
        defaultSkin = 18,
    },		
}

-- This allows developers to use a single string (e.g., "usaplates") instead of listing all IDs.
GlideLicensePlates.PlateGroups = {
    ["usaplates"] = {
        "usacalifornia",
        "usacoloradov1",
        "usacoloradov2",
        "usadelaware",
        "usafloridav1",
        "usafloridav2",
        "usafloridav3",
        "usafloridav4",
        "usafloridav5",
        "usaillinoisv1",
        "usaillinoisv2",
        "usanewyork",
        "usaoklahomav1",
        "usaoklahomav2",
        "usatexas",
        "usawisconsin",
        "usawyoming"
    },    
	["mercosurplates"] = {
        "argmercosur",
        "brasilmercosur",
        "paraguaymercosur",
        "uruguaymercosur"
    },	
	["argentinaplates"] = {
        "argmercosur",
        "argold",
        "argvintage"
    },	
	["europeplates"] = {
        "europealbaniav1",
        "europealbaniav2",
        "europeaustria",
        "europebelgium",
        "europebulgaria",
        "europeczech",
        "europedenmark",
        "europefinland",
        "europefrance",
        "europegermany",
        "europegreatbritain",
        "greatbritain",
        "europegreece",
        "europehungary",
        "europeireland",
        "europeitaly",
        "europenetherlands",
        "europenorway",
        "europepoland",
        "europeportugalv1",
        "europeportugalv2",
        "europeportugalv3",
        "europeromania",
        "russia",
        "europespain",
        "europeswedenv1",
        "europeswedenv2",
    },
	["gtasaplates"] = {
        "gtasalasventuras",
        "gtasalossantos",
        "gtasasanfierro"
    },		
	["gtavplates"] = {
        "gtavnorthyankton",
        "gtavsanandreasalt",
        "gtavsanandreasblack",
        "gtavsanandreasblue",
        "gtavsanandreaswhite"
    },	
}



-- Function to get the default text color
function GlideLicensePlates.GetPlateTextColor(plateType, customTextColor)
    -- Priority: custom color from config > plate type default color > system default (black)
    if customTextColor and type(customTextColor) == "table" then
        return {
            r = customTextColor.r or 0,
            g = customTextColor.g or 0, 
            b = customTextColor.b or 0,
            a = customTextColor.a or 255
        }
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig and plateConfig.defaultTextColor then
        return {
            r = plateConfig.defaultTextColor.r or 0,
            g = plateConfig.defaultTextColor.g or 0,
            b = plateConfig.defaultTextColor.b or 0,
            a = plateConfig.defaultTextColor.a or 255
        }
    end
    
    return {r = 0, g = 0, b = 0, a = 255} -- Default black
end

-- Get the default scale for a plate type
function GlideLicensePlates.GetPlateScale(plateType, customScale)
    -- Priority: custom scale from vehicle config > plate type default scale > system default
    if customScale and type(customScale) == "number" and customScale > 0 then
        return customScale
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig and plateConfig.defaultScale and plateConfig.defaultScale > 0 then
        return plateConfig.defaultScale
    end
    
    return GlideLicensePlates.Config.DefaultScale
end

-- Get the text offset for a plate type
function GlideLicensePlates.GetPlateTextOffset(plateType, customOffset)
    -- Priority: custom offset from vehicle config > plate type default > system default (0,0,0)
    if customOffset and type(customOffset) == "Vector" then
        return customOffset
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig and plateConfig.defaultTextOffset then
        return plateConfig.defaultTextOffset
    end
    
    return Vector(0, 0, 0)
end

-- Get the skin for a plate type
function GlideLicensePlates.GetPlateSkin(plateType, customSkin)
    -- Priority: custom skin from vehicle config > plate type default skin > system default
    if customSkin and type(customSkin) == "number" and customSkin >= 0 then
        return customSkin
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig and plateConfig.defaultSkin and plateConfig.defaultSkin >= 0 then
        return plateConfig.defaultSkin
    end
    
    return GlideLicensePlates.Config.DefaultSkin
end

-- Function to get the appropriate font for a plate type
function GlideLicensePlates.GetPlateFont(plateType, customFont)
    -- Priority: custom font from vehicle config > plate type custom font > plate type default font > system default
    if customFont and customFont ~= "" then
        return customFont
    end
    
    local plateConfig = GlideLicensePlates.PlateTypes[plateType]
    if plateConfig then
        if plateConfig.customFont and plateConfig.customFont ~= "" then
            return plateConfig.customFont
        elseif plateConfig.defaultFont and plateConfig.defaultFont ~= "" then
            return plateConfig.defaultFont
        end
    end
    
    return GlideLicensePlates.Config.DefaultFont
end

-- Function to set custom font for a plate type
function GlideLicensePlates.SetPlateTypeFont(plateType, fontName)
    if not plateType or not GlideLicensePlates.PlateTypes[plateType] then
        return false
    end
    
    if not fontName or fontName == "" then
        GlideLicensePlates.PlateTypes[plateType].customFont = nil
    else
        GlideLicensePlates.PlateTypes[plateType].customFont = fontName
    end
    return true
end

-- Generate random plates
function GlideLicensePlates.GeneratePlate(plateType)
    local selectedType = plateType
    
    -- If plateType is a table (multiple types), choose one randomly
    if type(plateType) == "table" and #plateType > 0 then
        selectedType = plateType[math.random(1, #plateType)]
    elseif type(plateType) == "table" and #plateType == 0 then
        -- If the table is empty, use default type
        selectedType = "argmercosur"
    end
    
    -- Verify that the selected type exists
    local config = GlideLicensePlates.PlateTypes[selectedType]
    if not config then
        selectedType = "argmercosur"
        config = GlideLicensePlates.PlateTypes[selectedType]
    end
    
    local pattern = config.pattern
    local result = ""
    
    for i = 1, string.len(pattern) do
        local char = string.sub(pattern, i, i)
        
        -- Verify if it is a letter (A-Z)
        if string.match(char, "[A-Z]") then
            -- Generate random letter
            result = result .. string.char(math.random(65, 90)) -- A-Z
        -- Verify if it is a number (0-9)  
        elseif string.match(char, "[0-9]") then
            -- Generate random number
            result = result .. tostring(math.random(0, 9))
        else
            -- Keep special characters
            result = result .. char
        end
    end
    
    return result, selectedType -- Return also the selected type
end

-- Validate vehicle's license plate configuration
function GlideLicensePlates.ValidateVehicleConfig(vehicle)
    if not IsValid(vehicle) then return false end
    if not vehicle.IsGlideVehicle then return false end
    
    if not vehicle.LicensePlateConfigs then return false end
    
    -- Validate each license plate configuration
    for i, config in ipairs(vehicle.LicensePlateConfigs) do
        if config.textColor then
            if type(config.textColor) ~= "table" then
                config.textColor = nil
                print("[GLIDE License Plates] Invalid textColor config, will use plate type default")
            else
                -- Validate color values
                if not config.textColor.r then config.textColor.r = 0 end
                if not config.textColor.g then config.textColor.g = 0 end  
                if not config.textColor.b then config.textColor.b = 0 end
                if not config.textColor.a then config.textColor.a = 255 end
                
                -- Clamp values to valid range
                config.textColor.r = math.Clamp(config.textColor.r, 0, 255)
                config.textColor.g = math.Clamp(config.textColor.g, 0, 255)
                config.textColor.b = math.Clamp(config.textColor.b, 0, 255)
                config.textColor.a = math.Clamp(config.textColor.a, 0, 255)
            end
        end
		
        if type(config.plateType) == "string" and string.lower(config.plateType) == "anytype" then
            local allTypes = {}
            for typeId, _ in pairs(GlideLicensePlates.PlateTypes) do
                table.insert(allTypes, typeId)
            end
            config.plateType = allTypes
        end
		
		-- Check if plateType matches a defined Group
-- We normalize input to a table, then expand any groups found into a single flat list.
        local rawTypes = config.plateType
        if type(rawTypes) == "string" then
            rawTypes = { rawTypes } -- Convert single string to table for uniform handling
        elseif type(rawTypes) ~= "table" then
            rawTypes = {} 
        end

        local expandedTypes = {}
        for _, typeOrGroup in ipairs(rawTypes) do
            if type(typeOrGroup) == "string" and GlideLicensePlates.PlateGroups[typeOrGroup] then
                -- It is a group: insert all plates from this group
                for _, plateId in ipairs(GlideLicensePlates.PlateGroups[typeOrGroup]) do
                    table.insert(expandedTypes, plateId)
                end
            else
                -- It is a single ID (or invalid, will be filtered later): insert directly
                table.insert(expandedTypes, typeOrGroup)
            end
        end
        
        -- Update the config with the expanded list
        config.plateType = expandedTypes

        -- Validate plate type (Now acts purely as a filter for invalid IDs)
        if type(config.plateType) == "table" then
            -- Verify that the elements in the expanded list are valid PlateTypes
            local validTypes = {}
            for _, pType in ipairs(config.plateType) do
                if type(pType) == "string" and GlideLicensePlates.PlateTypes[pType] then
                    table.insert(validTypes, pType)
                end
            end
            
            if #validTypes == 0 then
                print("[GLIDE License Plates] WARNING: Couldn't find valid types in configuration, using argmercosur (default)")
                config.plateType = "argmercosur"
            else
                config.plateType = validTypes
            end
        else
            -- Fallback if something went wrong or list is empty
            config.plateType = "argmercosur"
        end
		
        -- Validate plate type (can be string or table)
        if not config.plateType then
            config.plateType = "argmercosur"
        elseif type(config.plateType) == "table" then
            -- If it's a table, verify that at least has a valid element
            local validTypes = {}
            for _, pType in ipairs(config.plateType) do
                if type(pType) == "string" and GlideLicensePlates.PlateTypes[pType] then
                    table.insert(validTypes, pType)
                end
            end
            
            if #validTypes == 0 then
                print("[GLIDE License Plates] WARNING: Couldn't find valid types in configuration, using argmercosur (default)")
                config.plateType = "argmercosur"
            else
                config.plateType = validTypes
            end
        elseif type(config.plateType) == "string" then
            -- If it is a string, verify that exists
            if not GlideLicensePlates.PlateTypes[config.plateType] then
                print("[GLIDE License Plates] WARNING: Type '" .. config.plateType .. "' not found, using argmercosur (default)")
                config.plateType = "argmercosur"
            end
        else
            -- If invalid type
            config.plateType = "argmercosur"
        end
        
        if not config.position or type(config.position) ~= "Vector" then
            config.position = Vector(0, 0, 0)
        end
        
        if not config.angles or type(config.angles) ~= "Angle" then
            config.angles = Angle(0, 0, 0)
        end
        
        if not config.modelRotation or type(config.modelRotation) ~= "Angle" then
            config.modelRotation = Angle(0, 0, 0)
        end
		
        -- Validate text offset
        if config.textOffset then
            if type(config.textOffset) ~= "Vector" then
                config.textOffset = nil
                print("[GLIDE License Plates] Invalid textOffset, using default (0,0,0)")
            end
        end
		
        if config.scale ~= nil then
            if type(config.scale) ~= "number" or config.scale <= 0 then
                config.scale = nil -- Will be determined by the plate type
            end
        end
        
        -- Validate custom skin
        if config.customSkin ~= nil then
            if type(config.customSkin) ~= "number" or config.customSkin < 0 then
                config.customSkin = nil -- Will be determined by the plate type
                print("[GLIDE License Plates] Invalid customSkin, using plate type default")
            end
        end
        
        if config.customModel then
            if type(config.customModel) ~= "string" or config.customModel == "" then
                config.customModel = nil
            elseif not util.IsValidModel(config.customModel) then
                config.customModel = nil
            end
        end
        
        -- Validate custom font configuration
        if config.font then
            if type(config.font) ~= "string" or config.font == "" then
                config.font = nil
            else
                print("[GLIDE License Plates] Validated font parameter: " .. config.font)
            end
        end
        
        -- Also validate customFont parameter
        if config.customFont then
            if type(config.customFont) ~= "string" or config.customFont == "" then
                config.customFont = nil
            else
                print("[GLIDE License Plates] Validated customFont parameter: " .. config.customFont)
            end
        end 
        
        if config.textColor then
            if type(config.textColor) ~= "table" then
                config.textColor = nil
            else
                if not config.textColor.r then config.textColor.r = 0 end
                if not config.textColor.g then config.textColor.g = 0 end
                if not config.textColor.b then config.textColor.b = 0 end
                if not config.textColor.a then config.textColor.a = 255 end
            end
        end
        
        if not config.id then
            config.id = "plate_" .. i
        end
        
        if config.customText then
            if type(config.customText) ~= "string" then
                config.customText = nil
            end
        end
    end
    
    return true
end

-- SERVER FUNCTIONS
if SERVER then
    -- Create all the license plates for the vehicle 
	function GlideLicensePlates.CreateLicensePlates(vehicle)
		if not IsValid(vehicle) then return false end
		if not GlideLicensePlates.ValidateVehicleConfig(vehicle) then return false end
		
		-- Check if we're in duplication restore mode
		if vehicle._RestoreFromDupe then
			return false
		end
        
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        
        if not vehicle.LicensePlateEntities then
            vehicle.LicensePlateEntities = {}
        end
        
        if not vehicle.LicensePlateTexts then
            vehicle.LicensePlateTexts = {}
        end

        if not vehicle.SelectedPlateTypes then
            vehicle.SelectedPlateTypes = {}
        end

        if not vehicle.SelectedPlateFonts then
            vehicle.SelectedPlateFonts = {}
        end
        
        -- Store selected scales
        if not vehicle.SelectedPlateScales then
            vehicle.SelectedPlateScales = {}
        end
        
        -- Store selected skins
        if not vehicle.SelectedPlateSkins then
            vehicle.SelectedPlateSkins = {}
        end
        
        local globalPlateText = nil
        local globalPlateType = nil
        local needsGlobalText = true
        local useGlobalType = true
        
        -- Verify if a plate has customText
        for i, config in ipairs(vehicle.LicensePlateConfigs) do
            if config.customText and config.customText ~= "" then
                needsGlobalText = false
                break
            end
        end
        
        -- Verify if all plates have the same type set
        local firstConfigType = vehicle.LicensePlateConfigs[1].plateType
        for i = 2, #vehicle.LicensePlateConfigs do
            local currentConfigType = vehicle.LicensePlateConfigs[i].plateType
            -- Compare types (can be strings or tables)
            if type(firstConfigType) ~= type(currentConfigType) then
                useGlobalType = false
                break
            elseif type(firstConfigType) == "table" then
                -- If they're tables, verify if they have the same elements
                if #firstConfigType ~= #currentConfigType then
                    useGlobalType = false
                    break
                else
                    for j, plateType in ipairs(firstConfigType) do
                        if plateType ~= currentConfigType[j] then
                            useGlobalType = false
                            break
                        end
                    end
                    if not useGlobalType then break end
                end
            elseif firstConfigType ~= currentConfigType then
                useGlobalType = false
                break
            end
        end
        
        -- If we need global text and all the plates have the same type, generate a global one
        if needsGlobalText and useGlobalType then
            local firstPlateType = vehicle.LicensePlateConfigs[1].plateType or "argmercosur"
            globalPlateText, globalPlateType = GlideLicensePlates.GeneratePlate(firstPlateType)
        end
        
        local createdCount = 0
        
        -- Create every plate
        for i, config in ipairs(vehicle.LicensePlateConfigs) do
            local plateId = config.id or "plate_" .. i
            
            -- Verify if there's already a valid plate for this id
            if IsValid(vehicle.LicensePlateEntities[plateId]) then
                createdCount = createdCount + 1
                continue
            end
            
            -- Set plate type and SPECIFIC text for this plate
            local plateType = nil
            local plateText = nil
            local plateFont = nil
            local plateScale = nil
            local plateSkin = nil
            
            -- Generate consistent text
            if not vehicle.LicensePlateTexts[plateId] then
                if config.customText and config.customText ~= "" then
                    -- Use custom text
                    plateText = config.customText
                    -- For custom text, we still need to set model's type
                    if type(config.plateType) == "table" then
                        plateType = config.plateType[math.random(1, #config.plateType)]
                    else
                        plateType = config.plateType or "argmercosur"
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                else
                    -- Use global text or generate a specific one
                    if globalPlateType and globalPlateText then
                        -- If we already have a type and global text, use them
                        plateText = globalPlateText
                        plateType = globalPlateType
                    else
                        -- Generate specific for this plate
                        plateText, plateType = GlideLicensePlates.GeneratePlate(config.plateType or "argmercosur")
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                end
                
                vehicle.LicensePlateTexts[plateId] = plateText
            else
                -- If we already have text, get the stored type
                plateText = vehicle.LicensePlateTexts[plateId]
                plateType = vehicle.SelectedPlateTypes[plateId]
                -- If we don't have stored type, generate a new one
                if not plateType then
                    if type(config.plateType) == "table" then
                        plateType = config.plateType[math.random(1, #config.plateType)]
                    else
                        plateType = config.plateType or "argmercosur"
                    end
                    vehicle.SelectedPlateTypes[plateId] = plateType
                end
            end
            
            -- Determine the font for this plate
			local configFont = nil
            
            -- First check if the specific plate config has a font
            if config.font and config.font ~= "" then
                configFont = config.font
            end
            
            -- If no font in config, check if there's a customFont parameter
            if not configFont and config.customFont and config.customFont ~= "" then
                configFont = config.customFont
            end
            
            -- Determine final font using the hierarchy
            plateFont = GlideLicensePlates.GetPlateFont(plateType, configFont)
            vehicle.SelectedPlateFonts[plateId] = plateFont
            
            -- Determine the scale for this plate using hierarchy
            plateScale = GlideLicensePlates.GetPlateScale(plateType, config.scale)
            vehicle.SelectedPlateScales[plateId] = plateScale
            
            -- Determine the skin for this plate using hierarchy
            plateSkin = GlideLicensePlates.GetPlateSkin(plateType, config.customSkin)
            vehicle.SelectedPlateSkins[plateId] = plateSkin
			
			-- Determine the text offset for this plate
            local plateTextOffset = GlideLicensePlates.GetPlateTextOffset(plateType, config.textOffset)
			
            -- Create plate entity
            local plateEntity = ents.Create("glide_license_plate")
            if not IsValid(plateEntity) then 
                print("[GLIDE License Plates] Error: Couldn't create plate entity " .. plateId)
                continue 
            end
            
            -- Configure model based on the selected type
            local plateModel = nil
            
            if config.customModel and config.customModel ~= "" and util.IsValidModel(config.customModel) then
                plateModel = config.customModel
            else
                -- Use the selected type specifically for this plate
                local actualPlateType = plateType -- plateType already contains the selected type for this plate
                
                if GlideLicensePlates.PlateTypes[actualPlateType] and GlideLicensePlates.PlateTypes[actualPlateType].model then
                    plateModel = GlideLicensePlates.PlateTypes[actualPlateType].model
                else
                    plateModel = GlideLicensePlates.Config.DefaultModel
                    print("[GLIDE License Plates] WARNING: Type " .. actualPlateType .. " doesn't have defined model, using default model: " .. plateModel)
                end
            end
            
            plateEntity:SetModel(plateModel)
            plateEntity:SetSkin(plateSkin)
            plateEntity:Spawn()
            plateEntity:Activate()
            
            -- Configure physical properties 
            plateEntity:SetMoveType(MOVETYPE_NONE)
            plateEntity:SetSolid(SOLID_NONE)
            plateEntity:SetCollisionGroup(COLLISION_GROUP_WORLD)
            plateEntity.DoNotDuplicate = true
            plateEntity.PhysgunDisabled = false
            plateEntity.PlateId = plateId
            plateEntity.PlateType = plateType 
            
            -- Configure properties after spawn 
            -- Store properties locally FIRST
            plateEntity.PlateText = plateText
            plateEntity.PlateScale = plateScale 
            plateEntity.PlateFont = plateFont
            plateEntity.PlateSkin = plateSkin
            plateEntity.TextOffset = plateTextOffset 
            -- Get color
            local textColor = GlideLicensePlates.GetPlateTextColor(plateType, config.textColor)
            plateEntity.TextColorR = textColor.r
            plateEntity.TextColorG = textColor.g
            plateEntity.TextColorB = textColor.b
            plateEntity.TextColorA = textColor.a
            
            -- Now set network variables (this triggers transmission to clients)
            plateEntity:SetPlateText(plateText)
            plateEntity:SetPlateScale(plateScale) 
            plateEntity:SetPlateFont(plateFont)
            plateEntity:SetPlateSkin(plateSkin)
			plateEntity:SetTextOffset(plateTextOffset) 			
            plateEntity:SetTextColor(Vector(textColor.r, textColor.g, textColor.b))
            plateEntity:SetTextAlpha(textColor.a)

            -- Configure transform after spawn
            timer.Simple(0.1, function()
                if not IsValid(plateEntity) or not IsValid(vehicle) then return end
 
                plateEntity:SetParentVehicle(vehicle)
                plateEntity:SetModelRotation(config.modelRotation or Angle(0, 0, 0))
                plateEntity:SetBaseTransform(config.position or Vector(0, 0, 0), config.angles or Angle(0, 0, 0))
                
                plateEntity.PlateText = plateText
                plateEntity.PlateScale = plateScale
                plateEntity.PlateFont = plateFont
                plateEntity.PlateSkin = plateSkin
                plateEntity.ParentVehicle = vehicle 
                plateEntity.ModelRotation = config.modelRotation or Angle(0, 0, 0)
                
                plateEntity:UpdatePosition()
                plateEntity.GlideInitialized = true
            end)
            
            -- Store references
            vehicle.LicensePlateEntities[plateId] = plateEntity
            vehicle:DeleteOnRemove(plateEntity)
            
            createdCount = createdCount + 1
        end
        
        -- Store vehicle in the global list
        GlideLicensePlates.ActivePlates[vehicle] = vehicle.LicensePlateEntities
        
        return createdCount > 0
    end
    
    -- Remove all license plates
    function GlideLicensePlates.RemoveLicensePlates(vehicle)
        if not IsValid(vehicle) then return end
        
        -- Make sure ActivePlates is initialised
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        
        -- Remove all plates from the vehicle
        if vehicle.LicensePlateEntities then
            for plateId, plateEntity in pairs(vehicle.LicensePlateEntities) do
                if IsValid(plateEntity) then
                    plateEntity:Remove()
                end
            end
            vehicle.LicensePlateEntities = {}
        end
        
        GlideLicensePlates.ActivePlates[vehicle] = nil
    end
    
    -- Remove a specific plate
    function GlideLicensePlates.RemoveSpecificPlate(vehicle, plateId)
        if not IsValid(vehicle) or not vehicle.LicensePlateEntities then return end
        
        local plateEntity = vehicle.LicensePlateEntities[plateId]
        if IsValid(plateEntity) then
            plateEntity:Remove()
            vehicle.LicensePlateEntities[plateId] = nil
            
            if vehicle.LicensePlateTexts then
                vehicle.LicensePlateTexts[plateId] = nil
            end
            
            -- Also clean the selected type
            if vehicle.SelectedPlateTypes then
                vehicle.SelectedPlateTypes[plateId] = nil
            end
            
            -- Clean the selected font
            if vehicle.SelectedPlateFonts then
                vehicle.SelectedPlateFonts[plateId] = nil
            end
            
            -- Clean the selected scale
            if vehicle.SelectedPlateScales then
                vehicle.SelectedPlateScales[plateId] = nil
            end
            
            -- Clean the selected skin
            if vehicle.SelectedPlateSkins then
                vehicle.SelectedPlateSkins[plateId] = nil
            end
            
            print("[GLIDE License Plates] Plate " .. plateId .. " removed")
        end
    end
    
    -- Get a specific plate
    function GlideLicensePlates.GetSpecificPlate(vehicle, plateId)
        if not IsValid(vehicle) or not vehicle.LicensePlateEntities then return nil end
        return vehicle.LicensePlateEntities[plateId]
    end
    
    -- Include server lua file after defining the functions
    include("glide_license_plates/server/sv_license_plates.lua")
    AddCSLuaFile("glide_license_plates/client/cl_license_plates.lua")
    
elseif CLIENT then
    -- Include client files
    include("glide_license_plates/client/cl_license_plates.lua")
end

-- Hook - For when a vehicle is created
hook.Add("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated", function(ent)
    if not IsValid(ent) then return end
    
    timer.Simple(0.1, function()
        if not IsValid(ent) then return end
        if not ent.IsGlideVehicle then return end
        
        if SERVER and GlideLicensePlates.CreateLicensePlates then
            GlideLicensePlates.CreateLicensePlates(ent)
        end
    end)
end)

-- Hook - Clean plates when a vehicle is removed
hook.Add("EntityRemoved", "GlideLicensePlates.OnVehicleRemoved", function(ent)
    if not IsValid(ent) then return end
    if not ent.IsGlideVehicle then return end
    
    if SERVER and GlideLicensePlates.RemoveLicensePlates then
        GlideLicensePlates.RemoveLicensePlates(ent)
    end
end)

-- Cleanup when map is changed
hook.Add("PreCleanupMap", "GlideLicensePlates.MapCleanup", function()
    if SERVER then
        GlideLicensePlates.ActivePlates = {}
    end
end)

-- Duplicator support
if SERVER then
    -- Duplication control variables
    local duplicatingEntities = {}
    local pendingRestores = {}
    local restoringVehicles = {}
    
    -- Enhanced plate data storage that includes colors, scales and skins
    local function SaveCompletePlateData(vehicle)
        if not IsValid(vehicle) or not vehicle.IsGlideVehicle then return false end
        
        local plateData = {
            timestamp = CurTime(),
        }
        
        local hasData = false
        
        -- Save plate texts
        if vehicle.LicensePlateTexts and not table.IsEmpty(vehicle.LicensePlateTexts) then
            plateData.plateTexts = table.Copy(vehicle.LicensePlateTexts)
            hasData = true
        elseif vehicle.LicensePlateText and vehicle.LicensePlateText ~= "" then
            plateData.plateText = vehicle.LicensePlateText
            hasData = true
        end
        
        -- Save selected plate types
        if vehicle.SelectedPlateTypes and not table.IsEmpty(vehicle.SelectedPlateTypes) then
            plateData.selectedPlateTypes = table.Copy(vehicle.SelectedPlateTypes)
            hasData = true
        end
        
        -- Save selected fonts
        if vehicle.SelectedPlateFonts and not table.IsEmpty(vehicle.SelectedPlateFonts) then
            plateData.selectedPlateFonts = table.Copy(vehicle.SelectedPlateFonts)
            hasData = true
        end
        
        -- Save selected scales
        if vehicle.SelectedPlateScales and not table.IsEmpty(vehicle.SelectedPlateScales) then
            plateData.selectedPlateScales = table.Copy(vehicle.SelectedPlateScales)
            hasData = true
        end
        
        -- Save selected skins
        if vehicle.SelectedPlateSkins and not table.IsEmpty(vehicle.SelectedPlateSkins) then
            plateData.selectedPlateSkins = table.Copy(vehicle.SelectedPlateSkins)
            hasData = true
        end
        
        -- Save the actual colors from the physical plate entities
        if vehicle.LicensePlateEntities and not table.IsEmpty(vehicle.LicensePlateEntities) then
            plateData.actualTextColors = {}
            for plateId, plateEntity in pairs(vehicle.LicensePlateEntities) do
                if IsValid(plateEntity) then
                    -- Get color from the actual entity
                    local colorVector = plateEntity:GetTextColor()
                    local alpha = plateEntity:GetTextAlpha()
                    
                    if colorVector then
                        plateData.actualTextColors[plateId] = {
                            r = math.Round(colorVector.x),
                            g = math.Round(colorVector.y),
                            b = math.Round(colorVector.z),
                            a = alpha or 255
                        }
                        hasData = true
                    end
                end
            end
        end
        
        -- Save configurations (for reference)
        if vehicle.LicensePlateConfigs then
            -- Ensure we save textOffset from the original configuration
            plateData.plateConfigs = table.Copy(vehicle.LicensePlateConfigs)
            -- We only copy the data, we need to check if the data exists
            for i, config in ipairs(plateData.plateConfigs) do
                if config.textOffset and type(config.textOffset) == "Vector" then
                    hasData = true -- Mark as having data if textOffset is present
                end
            end
            hasData = true
        elseif vehicle.LicensePlateConfig then
            plateData.plateConfig = table.Copy(vehicle.LicensePlateConfig)
            hasData = true
        end
        
        if hasData then
            duplicator.StoreEntityModifier(vehicle, "glide_license_plate_data", plateData)
            return true
        end
        
        return false
    end
    
    -- Enhanced plate creation with proper color, scale and skin restoration
    local function CreatePlatesWithRestoredData(vehicle, plateData)
        if not IsValid(vehicle) or not plateData then return false end
        
        -- Prevent automatic creation during restoration
        vehicle._RestoreFromDupe = true
        
        -- Initialize storage
        if not vehicle.LicensePlateEntities then
            vehicle.LicensePlateEntities = {}
        end
        
        -- Restore basic data
        if plateData.plateTexts then
            vehicle.LicensePlateTexts = table.Copy(plateData.plateTexts)
        end
        
        if plateData.plateText then
            vehicle.LicensePlateText = plateData.plateText
        end
        
        if plateData.selectedPlateTypes then
            vehicle.SelectedPlateTypes = table.Copy(plateData.selectedPlateTypes)
        end
        
        if plateData.selectedPlateFonts then
            vehicle.SelectedPlateFonts = table.Copy(plateData.selectedPlateFonts)
        end
        
        -- Restore selected scales
        if plateData.selectedPlateScales then
            vehicle.SelectedPlateScales = table.Copy(plateData.selectedPlateScales)
        end
        
        -- Restore selected skins
        if plateData.selectedPlateSkins then
            vehicle.SelectedPlateSkins = table.Copy(plateData.selectedPlateSkins)
        end
        
        -- Store restored colors for use during creation
        if plateData.actualTextColors then
            vehicle._RestoredColors = table.Copy(plateData.actualTextColors)
        end
        
        -- Now create the plates
        local createdCount = 0
        
        if vehicle.LicensePlateConfigs then
            for i, config in ipairs(vehicle.LicensePlateConfigs) do
                local plateId = config.id or "plate_" .. i
                
                if IsValid(vehicle.LicensePlateEntities[plateId]) then
                    continue
                end
                
                -- Get restored data for this plate
                local plateText = vehicle.LicensePlateTexts and vehicle.LicensePlateTexts[plateId]
                local plateType = vehicle.SelectedPlateTypes and vehicle.SelectedPlateTypes[plateId]
                local plateFont = vehicle.SelectedPlateFonts and vehicle.SelectedPlateFonts[plateId]
                local plateScale = vehicle.SelectedPlateScales and vehicle.SelectedPlateScales[plateId]
                local plateSkin = vehicle.SelectedPlateSkins and vehicle.SelectedPlateSkins[plateId]
                
                if not plateText or not plateType then
                    continue
                end
                
                if not plateFont then
                    plateFont = GlideLicensePlates.GetPlateFont(plateType, config.font or config.customFont)
                end
                
                -- If no scale was restored, use hierarchy
                if not plateScale then
                    plateScale = GlideLicensePlates.GetPlateScale(plateType, config.scale)
                end
                
                -- If no skin was restored, use hierarchy
                if not plateSkin then
                    plateSkin = GlideLicensePlates.GetPlateSkin(plateType, config.customSkin)
                end
				
				-- Determine the text offset for this plate
                local plateTextOffset = GlideLicensePlates.GetPlateTextOffset(plateType, config.textOffset)
                
                -- Create plate entity
                local plateEntity = ents.Create("glide_license_plate")
                if not IsValid(plateEntity) then continue end
                
                -- Set model
                local plateModel = GlideLicensePlates.Config.DefaultModel
                if config.customModel and util.IsValidModel(config.customModel) then
                    plateModel = config.customModel
                elseif GlideLicensePlates.PlateTypes[plateType] and GlideLicensePlates.PlateTypes[plateType].model then
                    plateModel = GlideLicensePlates.PlateTypes[plateType].model
                end
                
                plateEntity:SetModel(plateModel)
                plateEntity:SetSkin(plateSkin)
                plateEntity:Spawn()
                plateEntity:Activate()
                
                -- Basic entity setup
                plateEntity:SetMoveType(MOVETYPE_NONE)
                plateEntity:SetSolid(SOLID_NONE)
                plateEntity:SetCollisionGroup(COLLISION_GROUP_WORLD)
                plateEntity.DoNotDuplicate = true
                plateEntity.PhysgunDisabled = false
                plateEntity.PlateId = plateId
                plateEntity.PlateType = plateType
                
                -- Store reference immediately
                vehicle.LicensePlateEntities[plateId] = plateEntity
                vehicle:DeleteOnRemove(plateEntity)
                
                -- Set basic properties IMMEDIATELY
                plateEntity:SetPlateText(plateText)
                plateEntity:SetPlateScale(plateScale) 
                plateEntity:SetPlateFont(plateFont)
                plateEntity:SetPlateSkin(plateSkin)
				plateEntity:SetTextOffset(plateTextOffset)				
                
                -- Set the correct color IMMEDIATELY
                local textColor = nil
                
                -- Priority 1: Use actual restored color
                if vehicle._RestoredColors and vehicle._RestoredColors[plateId] then
                    textColor = vehicle._RestoredColors[plateId]
                else
                    -- Priority 2: Use color hierarchy
                    textColor = GlideLicensePlates.GetPlateTextColor(plateType, config.textColor)
                end
                
                -- Apply the color IMMEDIATELY
                plateEntity:SetTextColor(Vector(textColor.r, textColor.g, textColor.b))
                plateEntity:SetTextAlpha(textColor.a)
                
                -- Store color values locally IMMEDIATELY
                plateEntity.TextColorR = textColor.r
                plateEntity.TextColorG = textColor.g
                plateEntity.TextColorB = textColor.b
                plateEntity.TextColorA = textColor.a
				plateEntity.TextOffset = plateTextOffset				
                
                -- Configure transform after spawn
                timer.Simple(0.1, function()
                    if not IsValid(plateEntity) or not IsValid(vehicle) then return end
                    
                    -- Set parent and transform
                    plateEntity:SetParentVehicle(vehicle)
                    plateEntity:SetModelRotation(config.modelRotation or Angle(0, 0, 0))
                    plateEntity:SetBaseTransform(config.position or Vector(0, 0, 0), config.angles or Angle(0, 0, 0))
                    
                    -- Store properties
                    plateEntity.PlateText = plateText
                    plateEntity.PlateScale = plateScale
                    plateEntity.PlateFont = plateFont
                    plateEntity.PlateSkin = plateSkin
                    plateEntity.ParentVehicle = vehicle
                    plateEntity.ModelRotation = config.modelRotation or Angle(0, 0, 0)
                    
                    plateEntity:UpdatePosition()
                end)
                
                createdCount = createdCount + 1
            end
        end
        
        -- Store in global list
        GlideLicensePlates.ActivePlates = GlideLicensePlates.ActivePlates or {}
        GlideLicensePlates.ActivePlates[vehicle] = vehicle.LicensePlateEntities
        
        -- Clean up restoration data
        timer.Simple(1, function()
            if IsValid(vehicle) then
                vehicle._RestoreFromDupe = nil
                vehicle._RestoredColors = nil
            end
        end)
        
        return createdCount > 0
    end
    
    -- Enhanced save hook that ensures colors, scales and skins are saved
    hook.Add("OnEntityCreated", "GlideLicensePlates.SaveCompleteData", function(ent)
        timer.Simple(1, function()
            if IsValid(ent) and ent.IsGlideVehicle then
                SaveCompletePlateData(ent)
            end
        end)
    end)
    
    -- Hook to save data when plates are modified
    local function SaveDataOnPlateChange(vehicle)
        if IsValid(vehicle) and vehicle.IsGlideVehicle then
            timer.Simple(0.2, function()
                if IsValid(vehicle) then
                    SaveCompletePlateData(vehicle)
                end
            end)
        end
    end
    
    -- Save data when plate text is changed
    local originalUpdatePlateText = nil
    if glide_license_plate then
        local meta = FindMetaTable("Entity")
        originalUpdatePlateText = meta.UpdatePlateText
        
        meta.UpdatePlateText = function(self, newText)
            if originalUpdatePlateText then
                originalUpdatePlateText(self, newText)
            end
            
            if self.ParentVehicle then
                SaveDataOnPlateChange(self.ParentVehicle)
            end
        end
    end
    
    -- Register the duplicator restore function
    duplicator.RegisterEntityModifier("glide_license_plate_data", function(ply, ent, data)
        if not IsValid(ent) or not ent.IsGlideVehicle then 
            print("[GLIDE License Plates] Invalid entity for restoration")
            return 
        end
        
        if not data or type(data) ~= "table" then
            print("[GLIDE License Plates] Invalid restoration data")
            return
        end
        
        -- Mark as restoring
        restoringVehicles[ent] = true
        
        -- Remove existing plates
        if GlideLicensePlates.RemoveLicensePlates then
            GlideLicensePlates.RemoveLicensePlates(ent)
        end
        
        -- Restore after delay
        timer.Simple(0.3, function()
            if not IsValid(ent) then 
                restoringVehicles[ent] = nil
                return 
            end
            
            CreatePlatesWithRestoredData(ent, data)
            restoringVehicles[ent] = nil
        end)
    end)
    
    -- Prevent automatic creation during restoration
    hook.Remove("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated")
    hook.Add("OnEntityCreated", "GlideLicensePlates.OnVehicleCreated", function(ent)
        if not IsValid(ent) then return end
        
        timer.Simple(0.1, function()
            if not IsValid(ent) then return end
            if not ent.IsGlideVehicle then return end
            
            -- Skip if restoring
            if restoringVehicles[ent] or ent._RestoreFromDupe then
                return
            end
            
            if SERVER and GlideLicensePlates.CreateLicensePlates then
                GlideLicensePlates.CreateLicensePlates(ent) 
            end
        end)
    end)
    
    -- Clean up on map change
    hook.Add("PreCleanupMap", "GlideLicensePlates.DupeColorCleanup", function()
        duplicatingEntities = {}
        pendingRestores = {}
        restoringVehicles = {}
    end)
    
    -- Advanced Duplicator 2 support
    if AdvDupe2 then
        hook.Add("AdvDupe2_PrePaste", "GlideLicensePlates.AdvDupe2Pre", function(data)
        end)
        
        hook.Add("AdvDupe2_PostPaste", "GlideLicensePlates.AdvDupe2Post", function(data)
            timer.Simple(1, function()
                duplicatingEntities = {}
            end)
        end)
    end
end

print("[GLIDE License Plates] License Plate system loaded correctly.")