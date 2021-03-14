
local alerts = {}

net.Receive("icefuseSendAlert", function()
	local alert = {
		title = net.ReadString(),
		message = net.ReadString(),
		dietime = net.ReadUInt(16),
		alpha = 0
	}

	alerts[#alerts + 1] = alert
end)

local arrested = false
local timeLeft = 0

net.Receive("icefuseSendArrest", function()
	timeLeft = net.ReadUInt(32)

	timer.Create("icefuseArrestTimer", 1, timeLeft - 1, function()
		timeLeft = timeLeft - 1
	end)
end)
--{{ script_version_name }}
local batteryAlerted = false
local vehicleList = false
local vehicleName = false
local vehicleOwnership = ""

//Micro optimisations
local ply = LocalPlayer()
local frametime = FrameTime
local lerp = Lerp
local drawtext = draw.SimpleText
local drawtextwrapped = draw.DrawText
local stringreplace = string.Replace
local scrw, scrh = icefuse.scrw, icefuse.scrh
local pad = icefuse.config.padding
local spacing = icefuse.config.elementspacing

hook.Add("Tick", "icefuseGetCentre", function()
	arrested = ply:getDarkRPVar("Arrested")

	if system.BatteryPower() < 10 and !batteryAlerted then
		alerts[#alerts + 1] = {
			title = icefuse.lang.lowbattery,
			message = icefuse.lang.lowbatterymessage,
			dietime = CurTime() + 30,
			alpha = 0
		}

		batteryAlerted = true
		--{{ user_id sha256 key }}
		timer.Simple(60, function()
			batteryAlerted = false
		end)
	end

	vehicleList = vehicleList or list.Get("Vehicles")

	if !ply:InVehicle() then
		local ent = ply:GetEyeTrace().Entity
		if IsValid(ent) and ent:IsVehicle() and ent:GetClass() != "prop_vehicle_prisoner_pod" then
			if ply:GetPos():DistToSqr(ent:GetPos()) < 40000 then
				local vehicleData = ent:getDoorData()
				vehicleName = ""
				vehicleOwnership = ""

				local vehicleClass = ent:GetVehicleClass()

				if vehicleData.title then
					vehicleName = vehicleData.title
				elseif vehicleClass and vehicleList[vehicleClass] then
					vehicleName = vehicleList[vehicleClass].Name
				else
					vehicleName = "Vehicle"
				end

				if vehicleData.groupOwn then
					vehicleOwnership = vehicleData.groupOwn
				elseif vehicleData.nonOwnable then
					vehicleOwnership = icefuse.lang.notownable
				elseif vehicleData.teamOwn then
					vehicleOwnership = stringreplace(icefuse.lang.jobonly, "%J", vehicleData.teamOwn)
				elseif vehicleData.owner then
					local vehicleOwner = Player(vehicleData.owner)
					if IsValid(vehicleOwner) then
						vehicleOwnership = stringreplace(icefuse.lang.ownedby, "%N", vehicleOwner:Name())
					else
						vehicleOwnership = stringreplace(icefuse.lang.ownedby, "%N", icefuse.lang.unknown)
					end
				else
					vehicleOwnership = icefuse.lang.unowned
				end
			else
				vehicleName = false
				vehicleOwnership = ""
			end
		else
			vehicleName = false
			vehicleOwnership = ""
		end
	else
		vehicleName = false
		vehicleOwnership = ""
	end

    scrw, scrh = icefuse.scrw, icefuse.scrh
end)


local smoothOutArrest = 0
hook.Add("HUDPaint", "icefuseShowCentre", function()
	local yOff = (icefuse.config.barhud and !icefuse.config.barbottom) and (icefuse.config.barheight + spacing) or pad
	local boxW = scrw*.28

	local ft = frametime()*2
	local time = CurTime()
	for k,v in ipairs(alerts) do
		if time > v.dietime then
			v.alpha = math.max(v.alpha - ft, 0)

			if v.alpha == 0 then
				table.remove(alerts, k)
				continue
			end
		else
			v.alpha = math.min(v.alpha + ft, 1)
		end

		surface.SetAlphaMultiplier(v.alpha)

		surface.SetFont("icefuseAlertMessage")
		local msgw, msgh = surface.GetTextSize(v.message)
		local boxH = msgh + scrh*0.05
		local thisBoxW = math.Max(boxW, msgw + scrw*.02)
		local xOff = scrw*.5 - thisBoxW*0.5

		draw.RoundedBox(icefuse.theme.cornerRadius, xOff, yOff, thisBoxW, boxH, icefuse.theme.bgCol)

		draw.RoundedBoxEx(icefuse.theme.cornerRadius, xOff, yOff, thisBoxW, scrh*.034, icefuse.theme.headCol, true, true, false, false)

		drawtext(v.title, "icefuseAlertTitle", xOff+thisBoxW*.5, yOff+scrh*0.016, icefuse.theme.headerTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) --{{ user_id }}
		drawtextwrapped(v.message, "icefuseAlertMessage", xOff+thisBoxW*.5, yOff+scrh*0.04, icefuse.theme.textCol, TEXT_ALIGN_CENTER)
		
		yOff = yOff + boxH + spacing

		surface.SetAlphaMultiplier(1)
	end

	ft = ft*4
	smoothOutArrest = lerp(ft, smoothOutArrest, arrested and 0 or scrh*.15)

	local arrestText = stringreplace(icefuse.lang.arrestedExpires, "%s", timeLeft)

	surface.SetFont("icefuseArrestMessage")
	local msgw, msgh = surface.GetTextSize(arrestText)

	local boxW, boxH = math.Max(scrw*.24, msgw+scrw*.02), scrh*0.07
	local xOff, yOff = scrw*.5 - boxW*0.5, smoothOutArrest + scrh - pad - boxH

	draw.RoundedBox(icefuse.theme.cornerRadius, xOff, yOff, boxW, boxH, icefuse.theme.bgCol)

	draw.RoundedBoxEx(icefuse.theme.cornerRadius, xOff, yOff, boxW, scrh*.034, icefuse.theme.headCol, true, true, false, false)

	drawtext(icefuse.lang.arrested, "icefuseArrestTitle", xOff+boxW*.5, yOff+scrh*0.016, icefuse.theme.headerTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	drawtext(arrestText, "icefuseArrestMessage", xOff+boxW*.5, yOff+scrh*0.04, icefuse.theme.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

	if !vehicleName then return end
	surface.SetFont("icefuseVehicleTitle")
	local nameTextWidth = surface.GetTextSize(vehicleName)

	surface.SetFont("icefuseVehicleSubtitle")
	local ownerTextWidth = surface.GetTextSize(vehicleOwnership)

	local offY = scrh*.3
	local boxW, boxH = math.max(nameTextWidth, ownerTextWidth) + scrw*.015, scrh*.05

	draw.RoundedBox(icefuse.theme.cornerRadius, scrw / 2 - boxW / 2, scrh/2 + offY - boxH, boxW, boxH, icefuse.theme.bgCol)

	draw.RoundedBoxEx(icefuse.theme.cornerRadius, scrw / 2 - boxW / 2, scrh/2 + offY - boxH, boxW, boxH*.5, icefuse.theme.headCol, true, true, false, false)

	drawtext(vehicleName, "icefuseVehicleTitle", scrw / 2, offY + scrh/2 - boxH*.98, icefuse.theme.headerTextCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	drawtext(vehicleOwnership, "icefuseVehicleSubtitle", scrw / 2, offY + scrh/2 - boxH*.07, icefuse.theme.textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)

-- vk.com/urbanichka