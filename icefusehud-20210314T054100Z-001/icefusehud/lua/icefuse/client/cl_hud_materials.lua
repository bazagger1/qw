
icefuse.mats = {}

local materialIDs = {
	["cFzSdn8"] = "agenda",
	["BuHvOFo"] = "laws",
	["OdMtqUq"] = "ammo",
	["w2ziFAd"] = "armour",
	["Ln7j8ng"] = "cleanup",
	["3mqihOr"] = "error",
	["Jt7clKq"] = "generic",
	["zqGuOxl"] = "health",
	["EnbeJ2I"] = "hint",
	["zwZqvjf"] = "hunger",
	["HuDZosb"] = "level",
	["nSt9vPT"] = "job",
	["gihvV77"] = "lockdown",
	["K8AUIzL"] = "player",
	["ao1sNDK"] = "salary",
	["KP364RO"] = "speaker1",
	["X16FBEy"] = "speaker2",
	["4aiIgVu"] = "speaker3",
	["a6F2XBh"] = "speaker4",
	["tO6KRD2"] = "undo",
	["tjY2Lkn"] = "wanted",
	["bEgEz5r"] = "close",
	["VCvpbDm"] = "logo"
}

local function getMatFromUrl(url, name)
	icefuse.mats[name] = Material("nil")

	if file.Exists("icefuse/" .. name .. ".png", "DATA") then
		icefuse.mats[name] = Material("../data/icefuse/" .. name .. ".png", "noclamp smooth")
		return
	end
	
	http.Fetch(url, function(body)
		file.Write("icefuse/" .. name .. ".png", body)
		icefuse.mats[name] = Material("../data/icefuse/" .. name .. ".png", "noclamp smooth")
	end)
end
--{{ script_version_name }}
if icefuse.config.useimgur then
	for k,v in pairs(materialIDs) do
		getMatFromUrl("https://i.imgur.com/" .. k .. ".png", v)
	end
elseif icefuse.config.customdlurl != "" then
	for k,v in pairs(materialIDs) do
		getMatFromUrl(icefuse.config.customdlurl .. "/" .. v .. ".png", v)
	end
else
	for k,v in pairs(materialIDs) do
		icefuse.mats[v] = Material("icefuse/" .. v .. ".png", "noclamp smooth")
	end
end

-- vk.com/urbanichka