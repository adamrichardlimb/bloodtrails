if not util then return end

local bloodtrails = {}

-- Override DoBleed to capture player info
local function DoBleed(ent)
    if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror())) then
        return
    end

    local jitter = VectorRand() * 30
    jitter.z = 20

    -- Call PaintDown with player entity for later fingerprint use
    util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
end

-- Override util.PaintDown to create DNA entities and log the player
function util.PaintDown(start, effname, source)
    local btr = util.TraceLine({
        start = start,
        endpos = start + Vector(0, 0, -256),
        filter = source,
        mask = MASK_SOLID
    })

    util.Decal(effname, btr.HitPos + btr.HitNormal, btr.HitPos - btr.HitNormal)

    if SERVER and effname == "Blood" and IsValid(source) and source:IsPlayer() then
        print("[BloodDNA] Blood decal from player:", source:Nick(), "(", source:SteamID(), ")")

        local ent = ents.Create("ent_blood_dna")
        if IsValid(ent) then
            ent:SetPos(btr.HitPos + btr.HitNormal * 0.2)
            ent.fingerprints = { source }
            ent:Spawn()

            timer.Simple(30, function()
                if IsValid(ent) then ent:Remove() end
            end)
        end
    end
end

-- Inject override into util
util.StartBleeding = function(ent, dmg, t)
    if dmg < 5 or not IsValid(ent) then return end
    if ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror()) then return end

    local times = math.Clamp(math.Round(dmg / 15), 1, 20)
    local delay = math.Clamp(t / times , 0.1, 2)

    if ent:IsPlayer() then
        times = times * 2
        delay = delay / 2
    end

    timer.Create("bleed" .. ent:EntIndex(), delay, times,
        function() DoBleed(ent) end)
end
