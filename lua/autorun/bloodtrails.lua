local bloodtrails = {}
local MAX_BLOODTRAILS = 100
local OVERLAP_DIST_SQR = 20 * 20

-- Clear the table on every time the round begins
hook.Add("TTTBeginRound", "ClearDNATable", function()
  bloodtrails = {}
end)

local function RemoveBloodtrail(ent)
    for i, e in ipairs(bloodtrails) do
        if e == ent then
            table.remove(bloodtrails, i)
            if IsValid(e) then e:Remove() end
            break
        end
    end
end

local function AddBloodtrail(ent)
    -- Overlap check
    for i = #bloodtrails, 1, -1 do
        local existing = bloodtrails[i]
        if IsValid(existing) and existing:GetPos():DistToSqr(ent:GetPos()) < OVERLAP_DIST_SQR then
            print("[BloodDNA] Overlapping blood trail removed.")
            RemoveBloodtrail(existing)
        end
    end

    -- Cap total
    if #bloodtrails >= MAX_BLOODTRAILS then
        print("[BloodDNA] Blood trail cap hit. Removing oldest.")
        RemoveBloodtrail(bloodtrails[1])
    end

    table.insert(bloodtrails, ent)

    timer.Simple(30, function()
        RemoveBloodtrail(ent)
    end)
end

hook.Add("Initialize", "BloodDNAOverride", function()
    print("[BloodDNA] Overriding bleeding logic...")

    -- Override DoBleed to capture player info
    local function DoBleed(ent)
        if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or not ent:IsTerror())) then
            return
        end

        local jitter = VectorRand() * 30
        jitter.z = 20

        util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
    end

    -- Override util.PaintDown to spawn DNA entities
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
                ent:SetPos(btr.HitPos)
                ent.fingerprints = { source }
                ent:Spawn()

                AddBloodtrail(ent)
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
end)
