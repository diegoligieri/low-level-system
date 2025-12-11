function onLogin(player)
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"

	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Expired Premium
	if player:isPremium() then
		player:setStorageValue(PlayerStorageKeys.expiredPremium, 1)
	end

	if not player:isPremium() and player:getStorageValue(PlayerStorageKeys.expiredPremium) == 1 then
		local town = Town(1)
		if not town then
			town = player:getTown()
		end

		local house = player:getHouse()
		if house then
			house:setOwnerGuid(0)
		end

		player:setTown(town:getId())
		local outfit = player:getOutfit()
		local sexType = player:getSex() == 1 and 128 or 136
		player:setOutfit({lookType = sexType, lookHead = outfit.lookHead, lookBody = outfit.lookBody, lookLegs = outfit.lookLegs, lookFeet = outfit.lookFeet, lookAddons = 0})
		player:setStorageValue(PlayerStorageKeys.expiredPremium, -1)
		player:setDirection(SOUTH)
		player:teleportTo(town:getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendOutfitWindow()
		player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Your premium has expired and you were sent to the temple of the city %s.", town:getName()))
	end

    -- Quest Log
    if player:getStorageValue(QuestPlayerStorageKeys.quests) == -1 then
       player:setStorageValue(QuestPlayerStorageKeys.quests, 1)
    end

	-- Events
	player:registerEvent("PlayerDeath")
	player:registerEvent("DropLoot")
	player:registerEvent("RewardLeveling")
	player:registerEvent("AntiFrag")
	player:registerEvent("AntiFragKill")
	return true
end
