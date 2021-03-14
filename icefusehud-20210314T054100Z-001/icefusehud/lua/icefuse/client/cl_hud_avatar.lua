
local PANEL = {}

AccessorFunc(PANEL, "m_masksize", "MaskSize", FORCE_NUMBER)

function PANEL:Init() --{{ script_version_name }}
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)
    self.LocalPlayer = LocalPlayer()
end

function PANEL:PerformLayout()
    self.Avatar:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:SetPlayer(id, size)
    self.Avatar:SetPlayer(id, size)
end

function PANEL:Think()    
    local wep = self.LocalPlayer:GetActiveWeapon()

    if IsValid(wep) and wep:GetClass() == "gmod_camera" then
        self.hide = true
        return
    end
    --{{ user_id sha256 key }}
    self.hide = false
end

function PANEL:Paint(w, h)
    if self.hide then return end

    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)

    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO) --{{ user_id sha256 key }}
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
    
    local _m = self.m_masksize
    
    local circle, t = {}, 0
    for i = 1, 360 do
        t = math.rad(i*720)/720
        circle[i] = {x = w/2 + math.cos(t)*_m, y = h/2 + math.sin(t)*_m}
    end
    draw.NoTexture()
    surface.SetDrawColor(color_white)
    surface.DrawPoly(circle)

    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL) --{{ user_id }}
    render.SetStencilReferenceValue(1)

    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)

    render.SetStencilEnable(false)
    render.ClearStencil()
end

vgui.Register("icefuseAvatar", PANEL)

-- vk.com/urbanichka