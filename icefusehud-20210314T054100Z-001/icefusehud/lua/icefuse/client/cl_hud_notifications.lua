
local notifications = {}

//Micro optimisations
local frametime = FrameTime
local scrw, scrh = icefuse.scrw, icefuse.scrh
local pad = icefuse.config.padding
local spacing = icefuse.config.elementspacing

local function getYOff()
    return (icefuse.config.barhud and icefuse.config.barbottom) and scrh-icefuse.config.barheight-spacing-scrh*.1-spacing or scrh-pad-scrh*.1-spacing --{{ user_id sha256 key }}
end

local function getIconMat(type)
    if type == NOTIFY_CLEANUP then return icefuse.mats["cleanup"] end
    if type == NOTIFY_ERROR then return icefuse.mats["error"] end
    if type == NOTIFY_GENERIC then return icefuse.mats["generic"] end
    if type == NOTIFY_HINT then return icefuse.mats["hint"] end
    if type == NOTIFY_UNDO then return icefuse.mats["undo"] end
    return Material("nil")
end

function notification.AddLegacy(text, type, time)
    local notif = {
        text = text,
        type = type,
        dietime = CurTime() + time,
        x = scrw,
        y = getYOff()
    }

    notifications[table.Count(notifications) + 1] = notif
end

function notification.AddProgress(id, text, frac)

end

function notification.Kill(id)
    if not notifications[id] then return end
    notifications[id].deleting = true
end

hook.Add("Tick", "icefuseGetNotifications", function()
    scrw, scrh = icefuse.scrw, icefuse.scrh
end)

hook.Add("HUDPaint", "icefuseShowNotifications", function()
    local offX = scrw-pad
    local offY = getYOff()

    local ft = frametime()*10
    local time = CurTime()

    local nh = scrh*.038

    surface.SetFont("icefuseNotify")

    local count = 1
    for k,v in pairs(notifications) do
        local nw = nh + surface.GetTextSize(v.text) + scrw*.01
        local desiredx, desiredy = offX-nw, offY-((nh*count)+(spacing*(count-1)))
        
        if !v.isprogress and time >= v.dietime then
            v.x = Lerp(ft, v.x, scrw+nw*.1)

            if v.x > scrw then
                notifications[k] = nil
                count = count + 1
                continue
            end
        else
            if v.isprogress and v.deleting then
                v.x = Lerp(ft, v.x, scrw+nw*.1)

                if v.x > scrw then
                    notifications[k] = nil
                    count = count + 1
                    continue
                end
            else
                v.x = Lerp(ft, v.x, desiredx)
            end
        end
        v.y = Lerp(ft, v.y, desiredy)

        draw.RoundedBox(icefuse.theme.cornerRadius, v.x, v.y, nw, nh, icefuse.theme.bgCol)


        draw.SimpleText(v.text, "icefuseNotify", v.x + nw - scrw*.006, v.y+nh/2, icefuse.theme.textCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) --{{ user_id }}

        draw.RoundedBoxEx(icefuse.theme.cornerRadius, v.x, v.y, nh, nh, icefuse.theme.headCol, true, false, true, false)

        local iconSize = nh*.6

        if v.isprogress then
            local iconOff = nh*.5
            surface.SetDrawColor(icefuse.theme.headerIconCol)
            surface.SetMaterial(getIconMat(NOTIFY_CLEANUP))
            surface.DrawTexturedRectRotated(iconOff+v.x, iconOff+v.y, iconSize, iconSize, time*80)
            count = count + 1
            continue
        end
        --{{ script_version_name }}
        local iconOff = nh*.2
        surface.SetDrawColor(icefuse.theme.headerIconCol)
        surface.SetMaterial(getIconMat(v.type))
        surface.DrawTexturedRect(iconOff+v.x, iconOff+v.y, iconSize, iconSize)

        count = count + 1
    end
end)

-- vk.com/urbanichka