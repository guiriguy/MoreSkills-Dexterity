local MSDexCheck = {}

MSDexCheck.BasicLoad = function()
    local profList = ProfessionFactory.getProfessions()
    for i = 1, profList:size() do
        local prof = profList:get(i - 1):getType()
        ProfessionFactory.getProfession(prof):addXPBoost(Perks.Dexterity, 3)
    end
    local AllThumbs = TraitFactory.getTrait("AllThumbs")
    AllThumbs:addXPBoost(Perks.Dexterity, -3)
    local Destroux = TraitFactory.getTrait("Dextrous")
    Destroux:addXPBoost(Perks.Dexterity, 4)
end

Events.OnGameBoot.Add(MSDexCheck.BasicLoad)