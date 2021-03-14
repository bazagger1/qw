
local shouldDrawAmmo = false
local isLicensed = false
local dead = false
local clip = 0
local maxClip = 0
local arrested = false
local agenda = false
local agendaText = ""

//Micro optimisations
local ply = LocalPlayer()
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local drawtextwrapped = draw.DrawText
local scrw, scrh = icefuse.scrw, icefuse.scrh
local pad = icefuse.config.padding
local spacing = icefuse.config.elementspacing

hook.Add("Tick", "icefuseGetRight", function()
    isLicensed = ply:getDarkRPVar("HasGunlicense")

    local hp = ply:Health()
    dead = hp < 1
	local curWeapon = ply:GetActiveWeapon()
    if hp > 0 and IsValid(curWeapon) then
        shouldDrawAmmo = true
        clip = curWeapon:Clip1()
        maxClip = tostring(ply:GetAmmoCount(curWeapon:GetPrimaryAmmoType()))
        if clip < 0 then shouldDrawAmmo = false end
    else
        shouldDrawAmmo = false
    end

    arrested = ply:getDarkRPVar("Arrested")

    scrw, scrh = icefuse.scrw, icefuse.scrh

    agenda = ply:getAgendaTable()
    if !agenda then agenda = false return end
    agendaText = DarkRP.textWrap((ply:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "icefuseAgendaDescription", 300) --{{ script_version_name }}
end)

local smoothHp = 0
local smoothArmour = 0
local smoothMoney = 0
local smoothOutAmmo = 0
local smoothOutAgenda = 0

hook.Add("HUDPaint", "icefuseShowRight", function()    
    local ft = frametime()*10

    if dead or arrested then
        smoothOutAmmo = lerp(ft, smoothOutAmmo, icefuse.config.barhud and icefuse.config.barbottom and scrw*.14 or scrh*.15)
        smoothOutAgenda = lerp(ft, smoothOutAgenda, scrw*.24)
    else
        smoothOutAmmo = lerp(ft, smoothOutAmmo, icefuse.config.barhud and icefuse.config.barbottom and (shouldDrawAmmo and 0 or scrw*.14) or (shouldDrawAmmo and 0 or scrh*.15)) --{{ user_id }}
        smoothOutAgenda = lerp(ft, smoothOutAgenda, (!agenda or (#agendaText < 1 and icefuse.config.hideAgendaWhenNone)) and scrw*.24 or 0)
    end

    //Draw weapon ammo
    local title = icefuse.lang.ammo .. (isLicensed and " - " .. icefuse.lang.licensed or "")
    surface.SetFont("icefuseAmmoTitle")
    local ammoW = math.max(scrw*.1, surface.GetTextSize(title) + scrh*0.016+scrw*.012)
    local ammoH = scrh*.06
    local xOff = icefuse.config.barhud and icefuse.config.barbottom and (smoothOutAmmo + (scrw - pad - ammoW)) or (scrw - pad - ammoW)
    local yOff = icefuse.config.barhud and icefuse.config.barbottom and (scrh - icefuse.config.barheight - spacing - ammoH) or (smoothOutAmmo + scrh - pad - ammoH)

    draw.RoundedBox(icefuse.theme.cornerRadius, xOff, yOff, ammoW, ammoH, icefuse.theme.bgCol)

    draw.RoundedBoxEx(icefuse.theme.cornerRadius, xOff, yOff, ammoW, scrh*.024, icefuse.theme.headCol, true, true, false, false)

    surface.SetDrawColor(icefuse.theme.headerIconCol)
	surface.SetMaterial(icefuse.mats["ammo"])
	surface.DrawTexturedRect(xOff+scrw*.004, yOff+ammoH*.06, scrh*0.016, scrh*0.016)

    drawtext(title, "icefuseAmmoTitle", xOff+scrh*0.016+scrw*.007, yOff+ammoH*.03, icefuse.theme.headerTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) --{{ user_id sha256 key }}
    
    surface.SetFont("icefuseAmmoStat")
    local aw = surface.GetTextSize(clip) + scrh*0.005

    surface.SetFont("icefuseAmmoStatSmall")
    aw = aw + surface.GetTextSize("/ " .. maxClip)

    drawtext(clip, "icefuseAmmoStat", xOff+ammoW*.5-aw*.5, yOff+ammoH*.36, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    drawtext("/ " .. maxClip, "icefuseAmmoStatSmall", xOff+ammoW*.5+aw*.5, yOff+ammoH*.52, icefuse.theme.textCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    //Draw the agenda
    surface.SetFont("icefuseAgendaDescription")
    local textw, texth = surface.GetTextSize(agendaText)

    local agendaW = math.Max(scrw*.15, textw + scrw*.03)
    local agendaH = texth + scrh*0.04
    local agendaX = scrw - agendaW - pad
    local agendaY = icefuse.config.barhud and !icefuse.config.barbottom and (icefuse.config.barheight + spacing) or pad --{{ user_id }}

    draw.RoundedBox(icefuse.theme.cornerRadius, smoothOutAgenda+agendaX, agendaY, agendaW, agendaH, icefuse.theme.bgCol)

    draw.RoundedBoxEx(icefuse.theme.cornerRadius, smoothOutAgenda+agendaX, agendaY, agendaW, scrh*.028, icefuse.theme.headCol, true, true, false, false)

    surface.SetDrawColor(icefuse.theme.headerIconCol)
	surface.SetMaterial(icefuse.mats["agenda"])
	surface.DrawTexturedRect(smoothOutAgenda+agendaX+scrw*.003, agendaY+scrh*.007, scrh*0.016, scrh*0.016)

	if !agenda then return end
    drawtext(agenda.Title, "icefuseAgendaTitle", smoothOutAgenda+agendaX+scrw*.014, agendaY+scrh*.006, icefuse.theme.headerTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) --{{ user_id sha256 key }}
    drawtextwrapped(agendaText, "icefuseAgendaDescription", smoothOutAgenda+agendaX+agendaW*.5, agendaY+scrh*.032, icefuse.theme.textCol, TEXT_ALIGN_CENTER)
end)

-- vk.com/urbanichka