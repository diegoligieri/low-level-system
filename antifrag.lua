towns = {
    [1] = SOUTH,
    [2] = SOUTH,
    [3] = SOUTH,
}

local LEVEL_DIFF_LIMIT = 200
local STORAGE_NO_FRAG = 100000

function onPrepareDeath(player, killer)
    if not player or not killer or not player:isPlayer() or not killer:isPlayer() then
        return true
    end

    local victimLevel = player:getLevel()
    local killerLevel = killer:getLevel()

    if math.abs(victimLevel - killerLevel) >= LEVEL_DIFF_LIMIT then
        local town = player:getTown()
        local templePos = town:getTemplePosition()

        player:teleportTo(templePos)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:setDirection(towns[player:getTown():getId()] or NORTH)

        -- Cura completa
        player:addHealth(player:getMaxHealth())
        player:addMana(player:getMaxMana())
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
        player:say(" ", TALKTYPE_MONSTER)

        -- Impede frag e white skull
        killer:setStorageValue(STORAGE_NO_FRAG, 1)
        if killer:getSkull() == SKULL_WHITE then
            killer:setSkull(SKULL_NONE)
        end

        return false -- Impede a morte real
    end

    return true
end

function onKill(killer, target)
    if killer:isPlayer() and killer:getStorageValue(STORAGE_NO_FRAG) == 1 then
        killer:setStorageValue(STORAGE_NO_FRAG, -1)
        return false
    end
    return true
end