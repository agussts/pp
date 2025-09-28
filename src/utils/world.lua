local world = {
    flags = {
        metmvirus = false,
    },
    shards = {
        active = false,
        needed = 3,
        collected = 0,
        spawned = false,
        done = false,
        collectedIds = {},
    },
    player = {
        health = 100
    },
    gun = {
        ammo = 30
    }
}

--SHARDS QUEST

function world.startShardsQuest()
    if world.shards.active then return end
    world.shards.active = true
    world.shards.collected = 0
    Fire("quest_shards_started")
end

function world.onShardCollected(id)
    if not world.shards.active then return end
    if id then
        world.shards.collectedIds[id] = true
    end
    world.shards.collected = math.min(world.shards.collected + 1, world.shards.needed)
    world.shards.done = world.shards.active and (world.shards.collected >= world.shards.needed)
    Fire("shard_collected", world.shards.collected, world.shards.needed)
end

-- Devuelve una lista de {pos, sprite, id} de los shards que faltan
function world.getRemainingShardPositions()
    local all = {
        { UDim2.fromScale(0.30, 0.62), "assets/sprites/shard.png", 1 },
        { UDim2.fromScale(0.55, 0.45), "assets/sprites/shard.png", 2 },
        { UDim2.fromScale(0.78, 0.70), "assets/sprites/shard.png", 3 },
    }
    local remaining = {}
    for _, def in ipairs(all) do
        local id = def[3]
        if not world.shards.collectedIds[id] then
        table.insert(remaining, def)
        end
    end
    return remaining
end


return world