local world = {
    flags = {
        metmvirus = true,
        gottestShard = true,
        trashCleared = false,
    },
    shards = {
        active = true,
        needed = 3,
        collected = 0,
        spawned = false,
        done = false,
        collectedIds = {},
    },
    player = { health = 100 },
}


--SHARDS QUEST

function world.startShardsQuest()
    if world.shards.active then return end
    world.shards.active = true
    world.shards.collected = 0
    Fire("quest_shards_started")
end

function world.onShardCollected(id)
    if id then
        world.shards.collectedIds[id] = true
    end
    world.shards.collected = math.min(world.shards.collected + 1, world.shards.needed)
    world.shards.done = world.shards.active and (world.shards.collected >= world.shards.needed)
    Fire("shard_collected", id, world.shards.collected, world.shards.needed)
end

return world