require "TimedActions/ISInventoryTransferAction"

local MSDexterity = {}

--MSDexterity.modData = nil
MSDexterity.OGCode_ISITAStart =  ISInventoryTransferAction.start
MSDexterity.OGCode_ISITAPerform = ISInventoryTransferAction.perform

--╭────────────────────────╮
--|       Functions        |
--╰────────────────────────╯
MSDexterity.GetOldLevel = function()
    for i = 0, getNumActivePlayers()-1 do
        local _player = getSpecificPlayer(i)
        if _player and not _player:isNPC() and not _player:isDead() then
            local DexPerk = Perks.Dexterity
            local getOldLevel = _player:getModData().DexterityLevel
            local getNewLevel = _player:getXp():getXP(DexPerk)
            if getOldLevel and getNewLevel ~= getOldLevel then
                print("MoreSkills- Dexterity: Seems that this mod was deactivated since last save, let's get that level back.")
                print("MoreSkills- Dexterity: Levels do not match. Old level: ",getOldLevel," New Level: ",getNewLevel)
                print("MoreSkills- Dexterity: Setting old level back")
                _player:getXp():AddXP(DexPerk,(getOldLevel*4))
                print("MoreSkills- Dexterity: Level reset to: ",_player:getXp():getXP(DexPerk))
            else
                print("MoreSkills- Dexterity: Levels seem to match, you are all good.")
            end
        end
    end
end
MSDexterity.CheckPerkLvl = function(player)
    local getDexLevel = player:getPerkLevel(Perks.Dexterity)
    if getDexLevel < 3 and not player:HasTrait("AllThumbs") then
        player:getTraits():add("AllThumbs")
        if player:HasTrait("Dextrous") then
            player:getTraits():remove("Dextrous")
        end
    elseif getDexLevel >= 3
            and getDexLevel <= 7
            and (player:HasTrait("AllThumbs")
            or player:HasTrait("Dextrous")) then
        player:getTraits():remove("AllThumbs")
        player:getTraits():remove("Dextrous")
    elseif getDexLevel >= 6 and not player:HasTrait("Dextrous") then
        player:getTraits():add("Dextrous")
        if player:HasTrait("AllThumbs") then
            player:getTraits():remove("AllThumbs")
        end
    elseif getDexLevel >= 9 and not player:HasTrait("Organized") then
        player:getTraits():add("Organized")
    end
end
MSDexterity.GetTime = function(player,time)
    local getDexXP = player:getXp():getXP(Perks.Dexterity)
    if getDexXP > 0 then
        if player:HasTrait("AllThumbs") then
            time = time - ((time/4)*getDexXP/10500)
        elseif not player:HasTrait("AllThumbs") and not player:HasTrait("Dextrous") then
            time = time - ((time/2)*(getDexXP-10500)/(127500-10500))
        elseif player:HasTrait("Dextrous") then
            time = time - ((time/2)*(getDexXP-127500)/(487500-127500))
        end
    else
        time = time
    end
    return time
end
MSDexterity.giveXP = function(player, weight, container)
    local tWeight = player:getModData().MSDexWeightToday
    local DexPerk = Perks.Dexterity
    local DexLevel = player:getPerkLevel(DexPerk)
    if not tWeight then
        player:getModData().MSDexWeightToday = 0
        tWeight = player:getModData().MSDexWeightToday
    end
    if container == "floor" then
        player:getXp():AddXP(DexPerk, (weight))
    else
        player:getXp():AddXP(DexPerk, (weight*4))
    end
    player:getModData().MSDexWeightToday = tWeight + weight
    tWeight = player:getModData().MSDexWeightToday
    if tWeight > 0 and tWeight <= 1000 then
        player:getXp():addXpMultiplier(DexPerk,((14*((DexLevel+1)/10))*(tWeight/1000))+1,DexLevel,10)
    elseif tWeight > 1000 and tWeight < 2000 then
        player:getXp():addXpMultiplier(DexPerk,(((14*((DexLevel+1)/10))+1)-(((14*((DexLevel+1)/10))*((tWeight-1000)/1000))+1)),DexLevel,10)
    elseif tWeight > 2000 then
        player:getXp():addXpMultiplier(DexPerk,0,DexLevel,10)
    end
    player:getModData().DexterityLevel = player:getPerkLevel(DexPerk)
end
MSDexterity.ResetTotalWeight = function()
    for i = 0,getNumActivePlayers()-1 do
        local _player = getSpecificPlayer(i)
        if _player and not _player:isDead() then
            _player:getModData().MSDexWeightToday = 0
        end
    end
end
--╭────────────────────────╮
--|          Code          |
--╰────────────────────────╯
function ISInventoryTransferAction:start()
    local _player = self.character
    MSDexterity.OGCode_ISITAStart(self)
    MSDexterity.CheckPerkLvl(_player)
    local time = MSDexterity.GetTime(_player,self.maxTime)
    --print(time)
    self.action:setTime(time)
    --print(self.destContainer:getCharacter())
    --print("XP TOTAL: "..tostring(_player:getXp():getXP(Perks.Dexterity)))
end

function ISInventoryTransferAction:perform()
    local _player = self.character
    MSDexterity.giveXP(_player,self.item:getActualWeight(),self.destContainer:getType())
    MSDexterity.CheckPerkLvl(_player)
    MSDexterity.OGCode_ISITAPerform(self)
    if #self.queueList > 0 then
        local time = MSDexterity.GetTime(_player,self.maxTime)
        --print(time)
        self.action:setTime(time)
    end
end

--╭────────────────────────╮
--|         Events         |
--╰────────────────────────╯
Events.EveryDays.Add(MSDexterity.ResetTotalWeight)
Events.OnGameStart.Add(MSDexterity.GetOldLevel)
