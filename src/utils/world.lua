local world = {
    flags = {
        metmvirus = false,
        trashCleared = false,
    },
    shards = {
        active = false,
        needed = 3,
        collected = 0,
        spawned = false,
        done = false,
        collectedIds = {},
    },
    player = { health = 100 },
    gun = { ammo = 30 }
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

return world