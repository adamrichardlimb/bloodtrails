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
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(0, 255, 0, 100)) -- Transparent green
    self:SetRenderMode(RENDERMODE_TRANSALPHA)

    --self:PhysicsInitBox(Vector(-1, -1, -0.1), Vector(1, 1, 0.1))
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
end

