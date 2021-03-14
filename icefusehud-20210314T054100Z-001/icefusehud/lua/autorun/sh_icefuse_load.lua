
local folder = "icefuse"

icefuse = icefuse or {}

AddCSLuaFile(folder .. "/config.lua")
include(folder .. "/config.lua")

if !icefuse.config.language then return end
if !icefuse.config.theme then return end

if SERVER then
	if !file.Exists(folder .. "/lang/" .. icefuse.config.language .. ".lua", "LUA") then return end
	icefuse.lang = include(folder .. "/lang/" .. icefuse.config.language .. ".lua")

	if !file.Exists(folder .. "/themes/" .. icefuse.config.theme .. ".lua", "LUA") then return end
	AddCSLuaFile(folder .. "/themes/" .. icefuse.config.theme .. ".lua")

	for k, v in ipairs(file.Find(folder .. "/lang/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/lang/" .. v)
	end

	for k, v in ipairs(file.Find(folder .. "/client/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/client/" .. v)
	end
--{{ user_id }}
	for k, v in ipairs(file.Find(folder .. "/server/*.lua", "LUA")) do
		include(folder .. "/server/" .. v)
	end
else
	local function loadLanguage(lang, checkDefault)
		if file.Exists(folder .. "/lang/" .. lang .. ".lua", "LUA") then
			icefuse.lang = include(folder .. "/lang/" .. lang .. ".lua")
			icefuse.config.language = lang
		else
			if !checkDefault then return end
			loadLanguage(icefuse.config.language)
		end
	end

	local function loadHUD()
		file.CreateDir("icefuse")

		loadLanguage(file.Read("icefuse/language.txt", "DATA") or icefuse.config.language, true)

		include(folder .. "/themes/" .. icefuse.config.theme .. ".lua")

		include(folder .. "/client/cl_hud_util.lua")

		for k, v in ipairs(file.Find(folder .. "/client/*.lua", "LUA")) do
			if v == "cl_hud_util.lua" then continue end
			include(folder .. "/client/" .. v)
		end
	end

	hook.Add("InitPostEntity", "icefuseLoadAddon", function() timer.Simple(.5, loadHUD) end)
end

-- icefuse [{{ script_id }}] v{{ script_version_name }}
-- LICENSED TO {{ user_id }}
-- {{ user_id sha256 key }}

-- vk.com/urbanichka