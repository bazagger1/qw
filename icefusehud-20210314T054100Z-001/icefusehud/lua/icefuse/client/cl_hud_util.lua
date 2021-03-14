
icefuse.scrw, icefuse.scrh = ScrW(), ScrH()

local function loadFonts()
    surface.CreateFont("icefusePlayerVitals", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 600,
    })

    surface.CreateFont("icefusePlayerInfo", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 500,
    })

    surface.CreateFont("icefusePlayerInfoBold", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 700,
    })

    surface.CreateFont("icefuseLockdownTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 700,
    })

    surface.CreateFont("icefuseLockdownDescription", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.009,
        weight = 500,
    })

    surface.CreateFont("icefuseAgendaTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 700,
    })

    surface.CreateFont("icefuseAgendaDescription", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.009,
        weight = 500,
    })

    surface.CreateFont("icefuseAmmoTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 700,
    })

    surface.CreateFont("icefuseAmmoStat", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.021,
        weight = 500,
    })

    surface.CreateFont("icefuseAmmoStatSmall", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.014,
        weight = 500,
    })

    surface.CreateFont("icefuseNotify", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 500,
    })

    surface.CreateFont("icefuseBar", {
        font = icefuse.config.customfont,
        size = icefuse.config.barfontsize,
        weight = 700,
    })

    surface.CreateFont("icefuseVoteTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.012,
        weight = 600,
    })

    surface.CreateFont("icefuseVoteQuestion", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 350,
    })

    surface.CreateFont("icefuseVoteButton", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.0084,
        weight = 500,
    })

    surface.CreateFont("icefuseAlertTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.016,
        weight = 800,
    })

    surface.CreateFont("icefuseAlertMessage", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.01,
        weight = 700,
    })

    surface.CreateFont("icefuseArrestTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.016,
        weight = 800,
    })

    surface.CreateFont("icefuseArrestMessage", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.011,
        weight = 500,
    })

    surface.CreateFont("icefuseVehicleTitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.012,
        weight = 600,
    })

    surface.CreateFont("icefuseVehicleSubtitle", {
        font = icefuse.config.customfont,
        size = icefuse.scrw*0.011,
        weight = 500,
    })

    surface.CreateFont("icefuseOverheadName", {
        font = icefuse.config.customfont,
        size = 50,
        weight = 700,
    })

    surface.CreateFont("icefuseOverheadJob", {
        font = icefuse.config.customfont,
        size = 44,
        weight = 600,
    })

    surface.CreateFont("icefuseOverheadLicense", {
        font = icefuse.config.customfont,
        size = 32,
        weight = 500,
    })

    surface.CreateFont("icefuseOverheadTyping", {
        font = icefuse.config.customfont,
        size = 180,
        weight = 1000,
    })

    surface.CreateFont("icefuseDoorLarge", {
        font = icefuse.config.customfont,
        size = 150,
        weight = 700,
    })
    --{{ script_version_name }}
    surface.CreateFont("icefuseDoorMedium", {
        font = icefuse.config.customfont,
        size = 90,
        weight = 500,
    })

    surface.CreateFont("icefuseDoorSmall", {
        font = icefuse.config.customfont,
        size = 65,
        weight = 500,
    })

    surface.CreateFont("icefuseDermaTitle", {
        font = icefuse.config.customfont,
        size = 21,
        weight = 700,
    })

    surface.CreateFont("icefuseDermaButton", {
        font = icefuse.config.customfont,
        size = 20,
        weight = 700,
    })
end
loadFonts()

hook.Add("OnScreenSizeChanged", "icefuseResChanger", function()
    icefuse.scrw, icefuse.scrh = ScrW(), ScrH()
    loadFonts()
end)

local hiddenHUDElements = {
    DarkRP_HUD = true,
    DarkRP_EntityDisplay = true,
    DarkRP_ZombieInfo = true,
    DarkRP_LocalPlayerHUD = true,
    DarkRP_Hungermod = true,
    DarkRP_Agenda = true,
    CHudHealth = true,
    CHudBattery = true,
    CHudDamageIndictator = true,
    CHudZoom = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudDeathNotice = true
}

hook.Add("HUDShouldDraw", "icefuseHideDefault", function(name)
    if (hiddenHUDElements[name]) then return false end
end)

hook.Add("HUDDrawTargetID", "icefuseRemoveTargetID", function()
    return false
end)

usermessage.Hook("_Notify", function(msg) --From DarkRP hud/cl_hud.lua L360-371
    local txt = msg:ReadString()
    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")
--{{ user_id }}
    -- Log to client console
    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end)

if icefuse.config.enableLevellingSystem then
	hook.Remove("HUDPaint","manolis:MVLevels:HUDPaintA")
end

local function getLanguages()
    local langs = {}

    for k, v in pairs(file.Find("icefuse/lang/*.lua", "LUA")) do
        langs[#langs+1] = string.Left(v, #v-4)
    end

   return langs
end

local function showAvailableLanguages()
    print("Available languages:\n" .. table.concat(getLanguages(), "\n"))
end

concommand.Add("icefuse_available_languages", showAvailableLanguages)

concommand.Add("icefuse_get_language", function()
    print("Your icefuse language is currently set as '" .. icefuse.config.language .. "'")
end)

concommand.Add("icefuse_set_language", function(ply, cmd, args)
    if !args[1] then showAvailableLanguages() return end

    local avail = getLanguages()

    if !table.HasValue(avail, args[1]) then
        print("Invalid language '" .. args[1] .. "'")
        showAvailableLanguages()
        return
    end
--{{ user_id sha256 key }}
    icefuse.config.language = args[1]

    if file.Exists("icefuse/lang/" .. icefuse.config.language .. ".lua", "LUA") then
        file.Write("icefuse/language.txt", args[1])        
        icefuse.lang = include("icefuse/lang/" .. icefuse.config.language .. ".lua")
    else
        print("The specified language file has gone missing, try rejoining?")
        return
    end

    print("Set icefuse language to '" .. args[1] .. "'")
end)

-- vk.com/urbanichka