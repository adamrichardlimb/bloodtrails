AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Blood DNA"
ENT.Spawnable = false

-- For DNA scanner
ENT.CanHavePrints = true
ENT.fingerprints = {}

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate05x05.mdl") -- Thin square
    self:SetMaterial("tools/toolsblack")
    self:SetColor(Color(0, 255, 0, 0)) -- Transparent green
    self:SetRenderMode(RENDERMODE_NONE)

    self:SetMoveType(MOVETYPE_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    self:SetSolid(SOLID_BBOX)
    self:AddEffects(EF_NOSHADOW)
    print("btw i made one again")
end

function ENT:OnTakeDamage(dmginfo)
  return true
end

function ENT:StartTouch(ent) end
function ENT:Touch(ent) end
