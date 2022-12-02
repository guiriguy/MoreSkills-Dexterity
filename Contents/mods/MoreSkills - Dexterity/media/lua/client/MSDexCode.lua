require "TimedActions/ISInventoryTransferAction"

local MSDexterity = {}

--MSDexterity.modData = nil
MSDexterity.OGCode_ISITAStart =  ISInventoryTransferAction.start
MSDexterity.OGCode_ISITAPerform = ISInventoryTransferAction.perform

--╭────────────────────────╮
--|       Functions        |
--╰────────────────────────╯
MSDexterity.CheckPerkLvl = function(player)
    if player:getXp():getXP(Perks.Dexterity) < 10500 and not player:HasTrait("AllThumbs") then
        player:getTraits():add("AllThumbs")
        if player:HasTrait("Dextrous") then
            player:getTraits():remove("Dextrous")
        end
    elseif player:getXp():getXP(Perks.Dexterity) >= 10500
            and player:getXp():getXP(Perks.Dexterity) <= 127500
            and (player:HasTrait("AllThumbs")
            or player:HasTrait("Dextrous")) then
        player:getTraits():remove("AllThumbs")
        player:getTraits():remove("Dextrous")
    elseif player:getXp():getXP(Perks.Dexterity) >= 127500 and not player:HasTrait("Dextrous") then
        player:getTraits():add("Dextrous")
        if player:HasTrait("AllThumbs") then
            player:getTraits():remove("AllThumbs")
        end
    end
end
MSDexterity.GetTime = function(player,time)
    if player:getXp():getXP(Perks.Dexterity) > 0 then
        if player:HasTrait("AllThumbs") then
            time = time - ((time/4)*player:getXp():getXP(Perks.Dexterity)/10500)
        elseif not player:HasTrait("AllThumbs") and not player:HasTrait("Dextrous") then
            time = time - ((time/2)*(player:getXp():getXP(Perks.Dexterity)-10500)/(127500-10500))
        elseif player:HasTrait("Dextrous") then
            time = time - ((time/2)*(player:getXp():getXP(Perks.Dexterity)-127500)/(487500-127500))
        end
    else
        time = time
    end
    return time
end
MSDexterity.giveXP = function(player, weight, container)
    if weight < 0 then
        weight = weight * -1
    end
    local tWeight = player:getModData().MSDexWeightToday
    if not tWeight then
        player:getModData().MSDexWeightToday = 0
    end
    if container == "floor" then
        player:getXp():AddXP(Perks.Dexterity, (weight))
    else
        player:getXp():AddXP(Perks.Dexterity, (weight*4))
    end
    player:getModData().MSDexWeightToday = player:getModData().MSDexWeightToday + weight
    if player:getModData().MSDexWeightToday > 0 and player:getModData().MSDexWeightToday <= 1000 then
        player:getXp():addXpMultiplier(Perks.Dexterity,((14*((player:getPerkLevel(Perks.Dexterity)+1)/10))*(player:getModData().MSDexWeightToday/1000))+1,player:getPerkLevel(Perks.Dexterity),10)
    elseif player:getModData().MSDexWeightToday > 1000 and player:getModData().MSDexWeightToday < 2000 then
        player:getXp():addXpMultiplier(Perks.Dexterity,(((14*((player:getPerkLevel(Perks.Dexterity)+1)/10))+1)-(((14*((player:getPerkLevel(Perks.Dexterity)+1)/10))*((player:getModData().MSDexWeightToday-1000)/1000))+1)),player:getPerkLevel(Perks.Dexterity),10)
    elseif player:getModData().MSDexWeightToday > 2000 then
        player:getXp():addXpMultiplier(Perks.Dexterity,0,player:getPerkLevel(Perks.Dexterity),10)
    end
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
