
if IsValid(icefusePlayerAvatar) then
	icefusePlayerAvatar:Remove()
end
icefusePlayerAvatar = false

local hp = 100
local maxHp = 100
local armour = 0
local maxArmour = 100
local hunger = 0
local level = 0
local levelProg = 0
local money = 0
local salary = 100
local isWanted = false
local laws = ""
local showLaws = true
local lockdown = false
local arrested = false
local job = ""
local name = ""

//Micro optimisations
local ply = LocalPlayer()
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local drawwrappedtext = draw.DrawText
local round = math.Round
local timedsin = TimedSin
local getLaws = DarkRP.getLaws
local scrw, scrh = icefuse.scrw, icefuse.scrh
local pad = icefuse.config.padding
local spacing = icefuse.config.elementspacing

local fKeys = {KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F10, KEY_F11, KEY_F12}
local nextPress = 0
hook.Add("PlayerButtonDown", "icefuseToggleLaws", function(ply, btn)
    if btn != fKeys[icefuse.config.toggleLawsKey] then return end
    if CurTime() < nextPress then return end

    showLaws = !showLaws

    nextPress = CurTime() + .2
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "icefuseResetStatMax", function(data)    
    if data.userid != ply:UserID() then return end

    maxHp = 100
    maxArmour = 100
end)

hook.Add("Tick", "icefuseGetLeft", function()
	hp = ply:Health()
    if hp > maxHp then maxHp = hp end
	armour = ply:Armor()
	if armour > maxArmour then maxArmour = armour end
	if icefuse.config.enableHungermod then hunger = ply:getDarkRPVar("Energy") end
    if icefuse.config.enableLevellingSystem and LevelSystemConfiguration then
        level = ply:getDarkRPVar("level") or 0
        local curXP = ply:getDarkRPVar("xp") or 0

        levelProg = math.min(100, ((curXP)/(((10+(((level)*((level)+1)*90))))*LevelSystemConfiguration.XPMult))*100)
    end
	money = ply:getDarkRPVar("money") or 0
	salary = ply:getDarkRPVar("salary") or 0
	isWanted = ply:getDarkRPVar("wanted") or false
    laws = ""
    for k,v in ipairs(getLaws()) do
        laws = laws .. k .. ". " .. v .. "\n"
    end
    laws = string.Left(laws, #laws-1)

	lockdown = GetGlobalBool("DarkRP_LockDown", false)
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
local smoothOutPly = 0
local smoothOutLockdown = 0
local smoothOutLaws = 0
local smoothLockY = 0

hook.Add("HUDPaint", "icefuseShowLeft", function()
    local ft = frametime()*10

    surface.SetFont("icefuseLockdownDescription")
    local textw, texth = surface.GetTextSize(icefuse.lang.lockdowndesc)

    local lockH = texth + scrh*.04
    local lockW = textw + scrw*.03

    local lawsw, lawsh = surface.GetTextSize(laws)

    local lH = lawsh + scrh*.04
    local lW = math.max(scrw*.07, lawsw + scrw*.03)

    if hp < 1 or arrested then
        smoothOutPly = lerp(ft*.6, smoothOutPly, scrh*.28)
        smoothOutLockdown = lerp(ft, smoothOutLockdown, -(lockW*1.1))
        smoothOutLaws = lerp(ft, smoothOutLaws, -(lW*1.1))
    else
        smoothOutPly = lerp(ft*.6, smoothOutPly, 0)
        smoothOutLockdown = lerp(ft, smoothOutLockdown, (!lockdown or icefuse.config.hideLockdownBox) and -(lockW*1.1) or pad)
        smoothOutLaws = lerp(ft, smoothOutLaws, (laws == "" or icefuse.config.hideLawsBox or !showLaws) and -(lW*1.1) or pad)
    end

    smoothLockY = lerp(ft*.6, smoothLockY, (laws == "" or !showLaws or icefuse.config.hideLawsBox) and 0 or lH + spacing)

    local barW = scrh*.3

    local yOff = icefuse.config.barhud and !icefuse.config.barbottom and (icefuse.config.barheight + spacing) or pad

    //Laws
    draw.RoundedBox(icefuse.theme.cornerRadius, smoothOutLaws, yOff, lW, lH, icefuse.theme.bgCol)

    draw.RoundedBoxEx(icefuse.theme.cornerRadius, smoothOutLaws, yOff, lW, scrh*.03, icefuse.theme.headCol, true, true, false, false)

    surface.SetDrawColor(icefuse.theme.headerIconCol)
    surface.SetMaterial(icefuse.mats["laws"])
    surface.DrawTexturedRect(smoothOutLaws+scrw*.004, yOff+scrh*.008, scrh*0.016, scrh*0.016)

    drawtext(string.Replace(icefuse.lang.laws, "%n", icefuse.config.toggleLawsKey), "icefuseLockdownTitle", smoothOutLaws+scrh*0.016+scrw*.007, yOff+scrh*0.007, icefuse.theme.headerTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    drawwrappedtext(laws, "icefuseLockdownDescription", smoothOutLaws+scrw*0.015, yOff+scrh*0.034, icefuse.theme.textCol, TEXT_ALIGN_LEFT)

    yOff = yOff + smoothLockY

    //Lockdown
    draw.RoundedBox(icefuse.theme.cornerRadius, smoothOutLockdown, yOff, lockW, lockH, icefuse.theme.bgCol)

    draw.RoundedBoxEx(icefuse.theme.cornerRadius, smoothOutLockdown, yOff, lockW, scrh*.03, icefuse.theme.headCol, true, true, false, false)

    surface.SetDrawColor(icefuse.theme.headerIconCol)
    surface.SetMaterial(icefuse.mats["lockdown"])
    surface.DrawTexturedRect(smoothOutLockdown+scrw*.004, yOff+scrh*.008, scrh*0.016, scrh*0.016)

    drawtext(icefuse.lang.lockdown, "icefuseLockdownTitle", smoothOutLockdown+scrh*0.016+scrw*.007, yOff+scrh*0.007, icefuse.theme.headerTextCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    drawwrappedtext(icefuse.lang.lockdowndesc, "icefuseLockdownDescription", smoothOutLockdown+lockW*.5, yOff+scrh*0.034, icefuse.theme.textCol, TEXT_ALIGN_CENTER)

    if icefuse.config.barhud then return end
    
	smoothHp = lerp(ft, smoothHp, hp)
	smoothArmour = lerp(ft, smoothArmour, armour)
	smoothHunger = lerp(ft, smoothHunger, hunger or 0)
    smoothLevel = lerp(ft, smoothLevel, levelProg or 0)
	smoothMoney = lerp(ft, smoothMoney, money)

	local barH = scrh*.035
	yOff = scrh - barH - pad

	//Health bar
    draw.RoundedBox(icefuse.theme.outerBarCornerRadius, pad, smoothOutPly+yOff, barW, barH, icefuse.theme.bgCol)

    draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, barW*.964, barH*.72, icefuse.theme.barBgCol)
 
    draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, (barW*smoothHp/maxHp)*.964, barH*.72, icefuse.theme.hpCol)

    surface.SetFont("icefusePlayerVitals")
    local hpw = surface.GetTextSize(hp..icefuse.lang.hp) + scrh*0.019

    surface.SetDrawColor(icefuse.theme.barIconCol)
    surface.SetMaterial(icefuse.mats["health"])
    surface.DrawTexturedRect(pad+barW*.5-hpw*.5, smoothOutPly+yOff+barH*.28, scrh*0.016, scrh*0.016)
    
    drawtext(hp..icefuse.lang.hp, "icefusePlayerVitals", pad+barW*.5+hpw*.5, smoothOutPly+yOff+barH*.48, icefuse.theme.barTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) --{{ script_version_name }}

    //Armour bar
    if !(icefuse.config.hideArmourWhenNone and smoothArmour < 1) then
        yOff = yOff - spacing - barH
        draw.RoundedBox(icefuse.theme.outerBarCornerRadius, pad, smoothOutPly+yOff, barW, barH, icefuse.theme.bgCol)


        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, barW*.964, barH*.72, icefuse.theme.barBgCol)


        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, (barW*smoothArmour/maxArmour)*.964, barH*.72, icefuse.theme.armCol)

        surface.SetFont("icefusePlayerVitals")
	    local apw = surface.GetTextSize(armour.."%") + scrh*0.019

	    surface.SetDrawColor(icefuse.theme.barIconCol)
	    surface.SetMaterial(icefuse.mats["armour"])
	    surface.DrawTexturedRect(pad+barW*.5-apw*.5, smoothOutPly+yOff+barH*.28, scrh*0.016, scrh*0.016)
	    
	    surface.SetTextPos(pad+barW*.5-apw*.18, smoothOutPly+yOff+barH*.25)

	    drawtext(armour.."%", "icefusePlayerVitals", pad+barW*.5+apw*.5, smoothOutPly+yOff+barH*.48, icefuse.theme.barTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) --{{ user_id }}
    end

    //Hunger bar
    if icefuse.config.enableHungermod and !(icefuse.config.hideHungerWhenNone and smoothHunger < 1) then
        yOff = yOff - spacing - barH
        draw.RoundedBox(icefuse.theme.outerBarCornerRadius, pad, smoothOutPly+yOff, barW, barH, icefuse.theme.bgCol)

        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, barW*.964, barH*.72, icefuse.theme.barBgCol)

        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, (barW*smoothHunger/100)*.964, barH*.72, icefuse.theme.hungerCol)

    	surface.SetFont("icefusePlayerVitals")
	    local huw = surface.GetTextSize(hunger.."%") + scrh*0.019

	    surface.SetDrawColor(icefuse.theme.barIconCol)
	    surface.SetMaterial(icefuse.mats["hunger"])
	    surface.DrawTexturedRect(pad+barW*.5-huw*.5, smoothOutPly+yOff+barH*.28, scrh*0.016, scrh*0.016)
	    
	    surface.SetTextPos(pad+barW*.5-huw*.18, smoothOutPly+yOff+barH*.25)

	    drawtext(hunger.."%", "icefusePlayerVitals", pad+barW*.5+huw*.5, smoothOutPly+yOff+barH*.48, icefuse.theme.barTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    //Level bar
    if icefuse.config.enableLevellingSystem then
        yOff = yOff - spacing - barH
        draw.RoundedBox(icefuse.theme.outerBarCornerRadius, pad, smoothOutPly+yOff, barW, barH, icefuse.theme.bgCol)

        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, barW*.964, barH*.72, icefuse.theme.barBgCol)

        draw.RoundedBox(icefuse.theme.innerBarCornerRadius, pad+barW*.02, smoothOutPly+yOff+barH*.14, (barW*smoothLevel/100)*.964, barH*.72, icefuse.theme.levelCol)

        surface.SetFont("icefusePlayerVitals")
        local lText = icefuse.lang.level.." "..level.." - "..round(levelProg).."%"
        local lw = surface.GetTextSize(lText) + scrh*0.019

        surface.SetDrawColor(icefuse.theme.barIconCol)
        surface.SetMaterial(icefuse.mats["level"])
        surface.DrawTexturedRect(pad+barW*.5-lw*.5, smoothOutPly+yOff+barH*.28, scrh*0.016, scrh*0.016)
        
        surface.SetTextPos(pad+barW*.5-lw*.18, smoothOutPly+yOff+barH*.25)

        drawtext(lText, "icefusePlayerVitals", pad+barW*.5+lw*.5, smoothOutPly+yOff+barH*.48, icefuse.theme.barTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    //Player info box
	local infoH = scrh*.09

	yOff = yOff - spacing - infoH

    draw.RoundedBox(icefuse.theme.cornerRadius, pad, smoothOutPly+yOff, barW, infoH, icefuse.theme.bgCol)

    draw.RoundedBoxEx(icefuse.theme.cornerRadius, pad, smoothOutPly+yOff, barW, infoH*.33, icefuse.theme.headCol, true, true, false, false)

    surface.SetDrawColor(icefuse.theme.headerIconCol)
    surface.SetMaterial(icefuse.mats["player"])
    surface.DrawTexturedRect(pad+barW*.02, smoothOutPly+yOff+infoH*.06, scrh*0.02, scrh*0.02)

    drawtext(name, "icefusePlayerInfoBold", pad+barW*.1, smoothOutPly+yOff+infoH*.07, icefuse.theme.headerTextCol, TEXT_ALIGN_LEFT, TEXT_ALING_TOP) --{{ user_id sha256 key }}

    if isWanted then
    	drawtext(icefuse.lang.wanted, "icefusePlayerInfoBold", pad+barW*.97, smoothOutPly+yOff+infoH*.058, icefuse.config.wantedFlash and (icefuse.theme.wantedCol:ToVector() * timedsin(.5, .6, 1.5, 0)):ToColor() or icefuse.theme.wantedCol, TEXT_ALIGN_RIGHT, TEXT_ALING_TOP) --{{ user_id }}
    end
    
	local avatarSize = 0
	local avatarSpacing = 0

    //Player Avatar
	if !icefuse.config.hideAvatar then
		avatarSize = infoH*.55
		avatarSpacing = barW*.02

		if !icefusePlayerAvatar then
            icefusePlayerAvatar = vgui.Create("icefuseAvatar")
            icefusePlayerAvatar:SetPlayer(ply, avatarSize)
        
            icefusePlayerAvatar:SetMaskSize(avatarSize*.49)
            icefusePlayerAvatar:SetSize(avatarSize, avatarSize)
            icefusePlayerAvatar:ParentToHUD()
		end

		icefusePlayerAvatar:SetPos(pad+barW*.02, smoothOutPly+yOff+infoH*.39)
	else
		if icefusePlayerAvatar then
			icefusePlayerAvatar:Remove()
			icefusePlayerAvatar = false
		end
	end

    surface.SetDrawColor(icefuse.theme.iconCol)
    surface.SetMaterial(icefuse.mats["job"])
    surface.DrawTexturedRect(pad+avatarSize+avatarSpacing+barW*.03, smoothOutPly+yOff+infoH*.42, scrh*0.016, scrh*0.016)

    drawtext(job, "icefusePlayerInfo", pad+avatarSize+avatarSpacing+barW*.1, smoothOutPly+yOff+infoH*.4, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    local mon = DarkRP.formatMoney(round(smoothMoney))

    surface.SetDrawColor(icefuse.theme.iconCol)
    surface.SetMaterial(icefuse.mats["salary"])
    surface.DrawTexturedRect(pad+avatarSpacing+avatarSize+barW*.03, smoothOutPly+yOff+infoH*.73, scrh*0.016, scrh*0.016)

    local salOff = drawtext(mon, "icefusePlayerInfo", pad+avatarSize+avatarSpacing+barW*.1, smoothOutPly+yOff+infoH*.7, icefuse.theme.textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    drawtext("+ " .. DarkRP.formatMoney(salary), "icefusePlayerInfo", pad+avatarSize+avatarSpacing+salOff+barW*.12, smoothOutPly+yOff+infoH*.7, icefuse.theme.salaryCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) --{{ script_version_name }}
end)

-- vk.com/urbanichka