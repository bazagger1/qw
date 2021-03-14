

if IsValid(icefusePlayerAvatar) then
	icefusePlayerAvatar:Remove()
end
icefusePlayerAvatar = false

local hp = 100
local armour = 0
local hunger = 0
local level = 0
local levelProg = 0
local money = 0
local salary = 100
local isWanted = false
local arrested = false
local job = ""
local name = ""

//Micro optimisations
local ply = LocalPlayer()
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local round = math.Round
local timedsin = TimedSin
local scrw, scrh = icefuse.scrw, icefuse.scrh
local spacing = icefuse.config.barelementspacing
local iconspacing = icefuse.config.bariconspacing
local barH = icefuse.config.barheight
local barUH = icefuse.config.barunderlineheight

hook.Add("Tick", "icefuseGetBar", function()
    if !icefuse.config.barhud then return end

	hp = ply:Health()
	armour = ply:Armor()
	if icefuse.config.enableHungermod then hunger = ply:getDarkRPVar("Energy") end
	if icefuse.config.enableLevellingSystem and LevelSystemConfiguration then
        level = ply:getDarkRPVar("level") or 0
        local curXP = ply:getDarkRPVar("xp") or 0

        levelProg = math.min(100, ((curXP)/(((10+(((level)*((level)+1)*90))))*LevelSystemConfiguration.XPMult))*100)
    end
	money = ply:getDarkRPVar("money") or 0
	salary = ply:getDarkRPVar("salary") or 0
	isWanted = ply:getDarkRPVar("wanted") or false
    arrested = ply:getDarkRPVar("Arrested")
	job = ply:getDarkRPVar("job") or "ERROR"
	name = ply:Name()

	scrw, scrh = icefuse.scrw, icefuse.scrh
end)

local smoothHp = 100
local smoothArmour = 0
local smoothHunger = 0
local smoothLevel = 0
local smoothMoney = 0
local smoothOut = 0

local blurMat = Material("pp/blurscreen")
blurMat:SetFloat("$blur", 5 * .33)

hook.Add("HUDPaint", "icefuseShowBar", function()
    if !icefuse.config.barhud then return end

    local ft = frametime()*10
    if hp < 1 or arrested then
        smoothOut = lerp(ft, smoothOut, icefuse.config.barbottom and scrh or -barH)
    else
        smoothOut = lerp(ft, smoothOut, icefuse.config.barbottom and (scrh-barH) or 0)
    end

    smoothHp = lerp(ft, smoothHp, hp)
	smoothArmour = lerp(ft, smoothArmour, armour)
	smoothHunger = lerp(ft, smoothHunger, hunger or 0)
    smoothLevel = lerp(ft, smoothLevel, levelProg or 0)
	smoothMoney = lerp(ft, smoothMoney, money)

    //Draw Bar
    surface.SetDrawColor(color_white)
	surface.SetMaterial(blurMat)

	render.SetScissorRect(0, smoothOut, scrw, barH, true)

    blurMat:Recompute()
    render.UpdateScreenEffectTexture()

    surface.DrawTexturedRect(0, smoothOut, scrw, scrh)

	render.SetScissorRect(0, 0, 0, 0, false)

    surface.SetDrawColor(icefuse.theme.barHudbgCol)
    surface.DrawRect(0, smoothOut, scrw, barH)

    //Draw Bar Underline
    surface.SetDrawColor(icefuse.theme.barHudUnderlineCol)
    surface.DrawRect(0, icefuse.config.barbottom and smoothOut or (smoothOut+barH-barUH), scrw, barUH)

    local offX = spacing
	local textY = icefuse.config.barbottom and smoothOut+barUH+(barH-barUH)*.5 or smoothOut+(barH-barUH)*.5
    local iconY = icefuse.config.barbottom and smoothOut+barUH+(barH-barUH)*.2 or smoothOut+(barH-barUH)*.2
	local iconSize = (barH-barUH)*.6

	//Draw Server Logo
	surface.SetDrawColor(icefuse.theme.iconCol)
    surface.SetMaterial(icefuse.mats["logo"])
    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

    offX = offX + iconSize + iconspacing

	offX = offX + drawtext(icefuse.config.serverName, "icefuseBar", offX, textY, icefuse.theme.textCol, nil, TEXT_ALIGN_CENTER) + spacing

    //Player Avatar
	if !icefuse.config.hideAvatar then
		local avatarSize = (barH-barUH)*.8

		if !icefusePlayerAvatar then
	    	icefusePlayerAvatar = vgui.Create("icefuseAvatar")
			icefusePlayerAvatar:SetPlayer(ply, avatarSize)
		
			icefusePlayerAvatar:SetMaskSize(avatarSize*.49)
			icefusePlayerAvatar:SetSize(avatarSize, avatarSize)
	    	icefusePlayerAvatar:ParentToHUD()
		end
		
		icefusePlayerAvatar:SetPos(offX, icefuse.config.barbottom and smoothOut+barUH+(barH-barUH)*.1 or smoothOut+(barH-barUH)*.1) --{{ user_id }}
		offX = offX + avatarSize + iconspacing
	else
		if icefusePlayerAvatar then
			icefusePlayerAvatar:Remove()
			icefusePlayerAvatar = false
		end

		surface.SetDrawColor(icefuse.theme.iconCol)
	    surface.SetMaterial(icefuse.mats["player"])
	    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

	    offX = offX + iconSize + iconspacing
	end

	//Draw Name
	offX = offX + drawtext(name, "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing

	//Draw Health
    surface.SetDrawColor(icefuse.theme.hpCol)
    surface.SetMaterial(icefuse.mats["health"])
    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

    offX = offX + iconSize + iconspacing

	offX = offX + drawtext(round(smoothHp).."HP", "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing

	//Draw Armour
	if !(icefuse.config.hideArmourWhenNone and smoothArmour < 1) then
	    surface.SetDrawColor(icefuse.theme.armCol)
	    surface.SetMaterial(icefuse.mats["armour"])
	    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

	    offX = offX + iconSize + iconspacing

		offX = offX + drawtext(round(smoothArmour).."%", "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing --{{ user_id }}
	end

	//Draw Hunger
	if icefuse.config.enableHungermod and hunger and !(icefuse.config.hideHungerWhenNone and smoothHunger < 1) then
	    surface.SetDrawColor(icefuse.theme.hungerCol)
	    surface.SetMaterial(icefuse.mats["hunger"])
	    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

	    offX = offX + iconSize + iconspacing

		offX = offX + drawtext(round(smoothHunger).."%", "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing
    end

    //Draw Level
    if icefuse.config.enableLevellingSystem then
	    surface.SetDrawColor(icefuse.theme.levelIconCol)
	    surface.SetMaterial(icefuse.mats["level"])
	    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

	    offX = offX + iconSize + iconspacing

		offX = offX + drawtext(icefuse.lang.level.." "..level.." - "..round(levelProg).."%", "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing --{{ script_version_name }}
    end

	//Draw Job
	surface.SetDrawColor(icefuse.theme.iconCol)
    surface.SetMaterial(icefuse.mats["job"])
    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

    offX = offX + iconSize + iconspacing

	offX = offX + drawtext(job, "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing

	//Draw Money + Salary
	surface.SetDrawColor(icefuse.theme.iconCol)
    surface.SetMaterial(icefuse.mats["salary"])
    surface.DrawTexturedRect(offX, iconY, iconSize, iconSize)

    offX = offX + iconSize + iconspacing

	offX = offX + drawtext(DarkRP.formatMoney(round(smoothMoney)), "icefuseBar", offX, textY, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	offX = offX + drawtext("  + "..DarkRP.formatMoney(salary), "icefuseBar", offX, textY, icefuse.theme.salaryCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) + spacing

	//Draw Wanted
	if isWanted then
    	drawtext(icefuse.lang.wanted, "icefuseBar", scrw-spacing, textY, icefuse.config.wantedFlash and (icefuse.theme.wantedCol:ToVector() * timedsin(.7, .5, 1.5, 0)):ToColor() or icefuse.theme.wantedCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) --{{ user_id sha256 key }}
    end
end) --{{ script_version_name }}

-- vk.com/urbanichka