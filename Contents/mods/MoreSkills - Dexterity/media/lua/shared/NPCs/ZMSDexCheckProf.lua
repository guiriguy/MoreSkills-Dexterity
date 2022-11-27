local MSDexCheck = {}

MSDexCheck.BasicLoad = function()
    local AllThumbs = TraitFactory.getTrait("AllThumbs")
    AllThumbs:addXPBoost(Perks.Dexterity, -3)
    local Destroux = TraitFactory.getTrait("Dextrous")
    Destroux:addXPBoost(Perks.Dexterity, 4)
    local profList = ProfessionFactory.getProfessions()
    for i = 1, profList:size() do
        local prof = profList:get(i - 1):getType()
        local profDes = profList:get(i-1)
        print("MSD Profession: "..tostring(prof))
        ProfessionFactory.getProfession(prof):addXPBoost(Perks.Dexterity, 3)
        BaseGameCharacterDetails.SetProfessionDescription(profDes)
    end
end

Events.OnGameBoot.Add(MSDexCheck.BasicLoad)
Events.OnCreateLivingCharacter.Add(MSDexCheck.BasicLoad)