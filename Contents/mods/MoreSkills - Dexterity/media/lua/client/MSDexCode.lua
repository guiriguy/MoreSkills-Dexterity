require "TimedActions/ISInventoryTransferAction"

local MSDexterity = {}

MSDexterity.modData = nil
MSDexterity.OGCode_ISITAStart =  ISInventoryTransferAction.start
MSDexterity.OGCode_ISITAPerform = ISInventoryTransferAction.perform

--╭────────────────────────╮
--|       Functions        |
--╰────────────────────────╯
MSDexterity.CheckPerkLvl = function(player)
    if player:getXp():getXP(Perks.Dexterity) < 10500 and not player:HasTrait("AllThumbs") then
        player:getTraits():add("AllThumbs")
    elseif player:getXp():getXP(Perks.Dexterity) >= 10500
            and player:getXp():getXP(Perks.Dexterity) <= 127500
            and (player:HasTrait("AllThumbs")
            or player:HasTrait("Dextrous")) then
        --print("Eliminados")
        player:getTraits():remove("AllThumbs")
        player:getTraits():remove("Dextrous")
    elseif player:getXp():getXP(Perks.Dexterity) >= 127500 and not player:HasTrait("Dextrous") then
        player:getTraits():add("Dextrous")
    end
    --[[if _player:getXp():getXP(Perks.Dexterity) > 10500 then
        _player:getTraits():add("AllThumbs")
    elseif _player:getXp():getXP(Perks.Dexterity) < 10500 then
        _player:getTraits():remove("AllThumbs")
    end]]--
end
MSDexterity.GetTime = function(player,time)
    if player:getXp():getXP(Perks.Dexterity) > 0 then
        --print("Entran: "..time)
        if player:HasTrait("AllThumbs") then
            --print("PT1")
            time = time - ((time/4)*player:getXp():getXP(Perks.Dexterity)/10500)
        elseif not player:HasTrait("AllThumbs") and not player:HasTrait("Dextrous") then
            --print("PT2")
            time = time - ((time/2)*(player:getXp():getXP(Perks.Dexterity)-10500)/(127500-10500))
        elseif player:HasTrait("Dextrous") then
            --print("PT3")
            time = time - ((time/2)*(player:getXp():getXP(Perks.Dexterity)-127500)/(487500-127500))
        end
    else
        time = time
    end
    --print("Salen: "..time)
    return time
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
    print("XP TOTAL: "..tostring(_player:getXp():getXP(Perks.Dexterity)))
end

function ISInventoryTransferAction:perform()
    local _player = self.character
    if self.destContainer:getType() == "floor" then
        _player:getXp():AddXP(Perks.Dexterity, (self.item:getActualWeight()*4))
    else
        _player:getXp():AddXP(Perks.Dexterity, (self.item:getActualWeight()*16))
    end
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