
local renderPlayers = {}
local speakerAnim = 1

//Micro optimisations
local ply = LocalPlayer()
local drawtext = draw.SimpleText
local playergetall = player.GetAll
local ft = FrameTime
local round = math.Round

hook.Add("Tick", "icefuseGetOverhead", function()
	renderPlayers = {}

	local plypos = ply:GetPos()
	for k,v in ipairs(playergetall()) do
		if v == ply then continue end
		if plypos:DistToSqr(v:GetPos()) < 90000 or v:IsSpeaking() then
			table.insert(renderPlayers, v) --{{ user_id sha256 key }}
		end
	end
end)

hook.Add("PostDrawTranslucentRenderables", "icefuseShowOverhead", function() --{{ script_version_name }}
	if icefuse.config.hideOverheads then return end
	
  local previousClip = DisableClipping(true)

	local plyInVehicle = ply:InVehicle()
	local eyeAngs = ply:EyeAngles()

	speakerAnim = speakerAnim + ft()
	if speakerAnim >= 4.49 then speakerAnim = .5 end

	for k,v in ipairs(renderPlayers) do
		if !IsValid(v) then continue end
		if v:Health() < 1 then continue end
		if v:GetColor().a < 100 or v:GetNoDraw() then continue end
		
		local name = v:Name()
		local jobname = v:getDarkRPVar("job") or "ERROR"

		surface.SetFont("icefuseOverheadName")
		local nameTextWidth = surface.GetTextSize(name) + 44

		surface.SetFont("icefuseOverheadJob")
		local jobTextWidth = surface.GetTextSize(jobname) + 44

		local boxW = math.max(nameTextWidth, jobTextWidth) + 40
		local boxPos = -(boxW*.5)

		local inVehicle = v:InVehicle()

		local eyePos = v:EyePos()

		local playerHeightOffset = 0
		if !inVehicle then
			playerHeightOffset = eyePos.z - v:GetPos().z
		end

		local eyeId = v:LookupAttachment("eyes")
		local offset = Vector(-3, 0, 85)
		local ang  = v:EyeAngles()
		local pos

		if (not eyeId) then
				pos = (v:GetPos() + offset + ang:Up())
		else
				local eyes = v:GetAttachment(eyeId)
				if (not eyes) then
						pos = (v:GetPos() + offset + ang:Up())
				else
						offset = Vector(0, 0, 20)
						pos = (eyes.Pos + offset)
				end
		end

		cam.Start3D2D(pos, plyInVehicle and Angle(0,ply:GetVehicle():GetAngles().y + eyeAngs.y - 90,90) or Angle(0,eyeAngs.y - 90,90),0.1) --{{ user_id }}
			draw.RoundedBox(icefuse.theme.cornerRadius, boxPos, 0, boxW, 100, icefuse.theme.bgCol)
			draw.RoundedBoxEx(icefuse.theme.cornerRadius, boxPos, 0, boxW, 50, icefuse.theme.headCol, true, true, false, false)


			if v:IsSpeaking() then
				surface.SetDrawColor(color_white)
				surface.SetMaterial(icefuse.mats["speaker" .. round(speakerAnim)])
				surface.DrawTexturedRect(boxPos+boxW*.5-64, -140, 128, 128)
			elseif v:IsTyping() then
				local time = CurTime()
				drawtext(".", "icefuseOverheadTyping", boxPos+boxW*.5-32, (math.abs(math.sin(time * 3)) * 7)-190, color_white, TEXT_ALIGN_CENTER)
				drawtext(".", "icefuseOverheadTyping", boxPos+boxW*.5+1, (math.abs(math.sin((time + 3) * 3)) * 7)-190, color_white, TEXT_ALIGN_CENTER)
				drawtext(".", "icefuseOverheadTyping", boxPos+boxW*.5+34, (math.abs(math.sin((time + 6) * 3)) * 7)-190, color_white, TEXT_ALIGN_CENTER)
			end

			surface.SetFont("icefuseOverheadName")
    		local npw = surface.GetTextSize(name) + 52

			surface.SetDrawColor(icefuse.theme.headerIconCol)
		    surface.SetMaterial(v:getDarkRPVar("wanted") and icefuse.mats["wanted"] or icefuse.mats["player"])
		    surface.DrawTexturedRect(boxPos+boxW*.5-npw*.5, 3, 44, 44)

			drawtext(name, "icefuseOverheadName", boxPos+boxW*.5+npw*.5, 1, v:getDarkRPVar("wanted") and icefuse.theme.wantedCol or icefuse.theme.headerTextCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP) --{{ user_id sha256 key }}
			
			surface.SetFont("icefuseOverheadJob")
    		local jpw = surface.GetTextSize(jobname) + 52

			surface.SetDrawColor(icefuse.theme.iconCol)
		    surface.SetMaterial(icefuse.mats["job"])
		    surface.DrawTexturedRect(boxPos+boxW*.5-jpw*.5, 53, 44, 44)

			drawtext(jobname, "icefuseOverheadJob", boxPos+boxW*.5+jpw*.5, 98, team.GetColor(v:Team()), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

			if v:getDarkRPVar("HasGunlicense") then
				drawtext(icefuse.lang.licensed, "icefuseOverheadLicense", boxPos+boxW*.5, 134, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM) --{{ user_id sha256 key }}
			end
		cam.End3D2D()
	end

	DisableClipping(previousClip)
end)

hook.Add("Initialize", "icefuseHideTypeIndicator",function()
	hook.Remove("StartChat", "StartChatIndicator")
	hook.Remove("FinishChat", "EndChatIndicator")
	hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
	hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
end)

--{{ script_version_name }}

-- vk.com/urbanichka