local CooldownData = {}

Core.RPC.Register('bcc-stables:BuyHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    local maxHorses = tonumber(Config.maxPlayerHorses)
    if params.isTrainer then
        maxHorses = tonumber(Config.maxTrainerHorses)
    end

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?', { char.id, 0 })
    if #horses >= maxHorses then
        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'horseLimit') .. maxHorses .. Core.Locale.translate(src, 'horses'), 4000)
        res(false)
        return
    end

    local model = params.ModelH
    for _, horseCfg in pairs(Horses) do
        for color, colorCfg in pairs(horseCfg.colors) do
            if color == model then
                if params.IsCash then
                    if tonumber(char.dollars) >= colorCfg.cashPrice then
                        res(true)
                    else
                        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortCash'), 4000)
                        res(false)
                    end
                else
                    if tonumber(char.gold) >= colorCfg.goldPrice then
                        res(true)
                    else
                        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortGold'), 4000)
                        res(false)
                    end
                end
            end
        end
    end
end)

Core.RPC.Register('bcc-stables:RegisterHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    local maxHorses = tonumber(Config.maxPlayerHorses)
    if params.isTrainer then
        maxHorses = tonumber(Config.maxTrainerHorses)
    end

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?', { char.id, 0 })
    if #horses >= maxHorses then
        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'horseLimit') .. maxHorses .. Core.Locale.translate(src, 'horses'), 4000)
        res(false)
        return
    end

    if params.IsCash and params.origin == 'tameHorse' then
        if tonumber(char.dollars) >= Config.regCost then
            res(true)
        else
            Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortCash'), 4000)
            res(false)
        end
    end
end)

RegisterNetEvent('bcc-stables:BuyTack', function(data)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    if tonumber(data.cashPrice) > 0 and tonumber(data.goldPrice) > 0 then
        if tonumber(data.currencyType) == 0 then
            if tonumber(char.dollars) >= data.cashPrice then
                character:Subtract('dollars', data.cashPrice)
            else
                Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortCash'), 4000)
                return
            end
        else
            if tonumber(char.gold) >= data.goldPrice then
                character:Subtract('gold', data.goldPrice)
            else
                Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortGold'), 4000)
                return
            end
        end
        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'purchaseSuccessful'), 4000)
    end
    TriggerClientEvent('bcc-stables:SaveComps', src)
end)

Core.RPC.Register('bcc-stables:SaveNewHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local model = params.ModelH

    for _, horseCfg in pairs(Horses) do
        for color, colorCfg in pairs(horseCfg.colors) do
            if color == model then
                if (params.IsCash) and (tonumber(char.dollars) >= colorCfg.cashPrice) then
                    character:Subtract('dollars', colorCfg.cashPrice)
                elseif (not params.IsCash) and (tonumber(char.gold) >= colorCfg.goldPrice) then
                    character:Subtract('gold', colorCfg.goldPrice)
                else
                    if params.IsCash then
                        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortCash'), 4000)

                    elseif not params.IsCash then
                        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortGold'), 4000)

                    end
                    return res(true)
                end
                MySQL.query.await('INSERT INTO `player_horses` (character_id, name, model, gender, captured) VALUES (?, ?, ?, ?, ?)',
                { char.id, tostring(params.name), params.ModelH, params.gender,  params.captured })
                break
            end
        end
    end
    res(true)
end)

Core.RPC.Register('bcc-stables:SaveTamedHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    if params.IsCash and params.origin == 'tameHorse' then
        if tonumber(char.dollars) >= Config.regCost then
            character:Subtract('dollars', Config.regCost)
        else
            Core.Notify.RightNotify(src, Core.Locale.translate(src, 'shortCash'), 4000)
            return res(false)
        end
    end
    MySQL.query.await('INSERT INTO `player_horses` (character_id, name, model, gender, captured) VALUES (?, ?, ?, ?, ?)',
    { char.id, tostring(params.name), params.ModelH, params.gender,  params.captured })
    res(true)
end)

Core.RPC.Register('bcc-stables:UpdateHorseNamee', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `name` = ? WHERE `id` = ? AND `character_id` = ?',
    { params.name, params.horseId, char.id })
    res(true)
end)

RegisterServerEvent('bcc-stables:UpdateHorseXp', function(Xp, horseId)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `xp` = ? WHERE `id` = ? AND `character_id` = ?',
    { Xp, horseId, char.id })
end)

RegisterServerEvent('bcc-stables:SaveHorseStats', function(data, horseId)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `health` = ?, `stamina` = ? WHERE id = ? AND `character_id` = ?',
    { data.health, data.stamina, horseId, char.id })
end)

RegisterServerEvent('bcc-stables:SelectHorse', function(data)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local id = tonumber(data.horseId)

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?',
    { char.id, 0 })
    for i = 1, #horses do
        local horseId = horses[i].id
        MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `character_id` = ? AND `id` = ?',
        { 0, char.id, horseId })
        if horses[i].id == id then
            MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `character_id` = ? AND `id` = ?',
            { 1, char.id, id })
        end
    end
end)

Core.RPC.Register('bcc-stables:DeselectHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `selected` = ? WHERE `id` = ? AND `character_id` = ?',
    { 0, params.myHorseId, char.id })
    res(true)
end)

Core.RPC.Register('bcc-stables:SetHorseDead', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `selected` = ?, `dead` = ? WHERE `id` = ? AND `character_id` = ?',
    { 0, 1, params.myHorseId, char.id })
    res(true)
end)

Core.RPC.Register('bcc-stables:GetHorseData', function(params, res, src)
    print('Enters GetHorseData')
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local data = nil

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?',
    { char.id, 0 })
    if #horses ~= 0 then
        for i = 1, #horses do
            if horses[i].selected == 1 then
                print('Horse Found')
                data = {
                    model = horses[i].model,
                    name = horses[i].name,
                    components = horses[i].components,
                    id = horses[i].id,
                    gender = horses[i].gender,
                    xp = horses[i].xp,
                    captured = horses[i].captured,
                    health = horses[i].health,
                    stamina = horses[i].stamina
                }
                print('Send Horse Data')
                res(data)
                break
            end
        end
        if data == nil then
            Core.Notify.RightNotify(src, Core.Locale.translate(src, 'noSelectedHorse'), 4000)
            res(false)
        end
    else
        Core.Notify.RightNotify(src, Core.Locale.translate(src, 'noHorses'), 4000)
        res(false)
    end
end)

RegisterNetEvent('bcc-stables:GetMyHorses', function()
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?',
    { char.id, 0 })
    TriggerClientEvent('bcc-stables:ReceiveHorsesData', src, horses)
end)

RegisterNetEvent('bcc-stables:UpdateComponents', function(encodedComponents, horseId, MyHorse_entity)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    MySQL.query.await('UPDATE `player_horses` SET `components` = ? WHERE `id` = ? AND `character_id` = ?',
    { encodedComponents, horseId, char.id })
    TriggerClientEvent('bcc-stables:SetComponents', src, MyHorse_entity, encodedComponents)
end)

Core.RPC.Register('bcc-stables:SellMyHorse', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local model = nil
    local id = tonumber(params.horseId)
    local captured = params.captured

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?',
    { char.id, 0 })
    for i = 1, #horses do
        if tonumber(horses[i].id) == id then
            model = horses[i].model
            MySQL.query.await('DELETE FROM `player_horses` WHERE `id` = ? AND `character_id` = ?',
            { id, char.id })
            break
        end
    end
    for _, horseCfg in pairs(Horses) do
        for color, colorCfg in pairs(horseCfg.colors) do
            if color == model then
                local sellPrice = (Config.sellPrice * colorCfg.cashPrice)
                if captured then
                    sellPrice = (Config.tamedSellPrice * colorCfg.cashPrice)
                end
                character:Add('dollars', sellPrice)
                Core.Notify.RightNotify(src, Core.Locale.translate(src, 'soldHorse') .. sellPrice, 4000)
                res(true)
                break
            end
        end
    end
end)

local function SetPlayerCooldown(type, charid)
    CooldownData[type .. tostring(charid)] = os.time()
end

RegisterServerEvent('bcc-stables:SellTamedHorse', function(hash)
    local src = source
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char

    for _, horseCfg in pairs(Horses) do
        for color, colorCfg in pairs(horseCfg.colors) do
            local colorHash = joaat(color)
            if colorHash == hash then
                local sellPrice = (Config.tamedSellPrice * colorCfg.cashPrice)
                character:Add('dollars', math.floor(sellPrice))
                Core.Notify.RightNotify(src, Core.Locale.translate(src, 'soldHorse') .. sellPrice, 4000)
                SetPlayerCooldown('sellTame', char.id)
            end
        end
    end
end)

Core.RPC.Register('bcc-stables:CheckPlayerCooldown', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local type = params.sellTame
    local cooldown = Config.cooldown[type]
    local onList = false
    local typeId = type .. tostring(char.id)

    for id, time in pairs(CooldownData) do
        if id == typeId then
            onList = true
            if os.difftime(os.time(), time) >= cooldown * 60 then
                res(false) -- Not on Cooldown
                break
            else
                res(true)
                break
            end
        end
    end
    if not onList then
        res(false)
    end
end)

RegisterServerEvent('bcc-stables:SaveHorseTrade', function(serverId, horseId)
    -- Current Owner
    local src = source
    local curCharacter = Core.Character.GetCharacter({ src = src })
    local curChar = curCharacter.char
    local curOwnerName = curChar.first_name .. " " .. curChar.last_name
    -- New Owner
    local newCharacter = Core.Character.GetCharacter({ src = serverId })
    local newChar = newCharacter.char
    local newOwnerName = newChar.first_name .. " " .. newChar.last_name

    local horses = MySQL.query.await('SELECT * FROM `player_horses` WHERE `character_id` = ? AND `dead` = ?',
    { curChar.id, 0 })
    for i = 1, #horses do
        if tonumber(horses[i].id) == horseId then
            MySQL.query.await('UPDATE `player_horses` SET `character_id` = ?, `selected` = ? WHERE `id` = ?',
            { newChar.id, 0, horseId })
            Core.Notify.RightNotify(src, Core.Locale.translate(src, 'youGave') .. newOwnerName .. Core.Locale.translate(src, 'aHorse'), 4000)
            Core.Notify.RightNotify(serverId, curOwnerName .. Core.Locale.translate(src, 'gaveHorse'), 4000)
            break
        end
    end
end)

CreateThread(function()
    Feather.Inventory.RegisterForeignKey('player_horses', 'INT', 'id')
end)

RegisterServerEvent('bcc-stables:RegisterInventory', function(id, model)
    local src = source

    Feather.Inventory.RegisterInventory('player_horses', id, 'Saddlebags', true, 250, nil)
end)

RegisterServerEvent('bcc-stables:OpenInventory', function(id)
    local src = source
    Feather.Inventory.OpenInventory(src, id)
end)

-- Iterate over each item in the Config.horseFood array to register them as usable items
for _, food in ipairs(Config.horseFood) do
    Feather.Items.RegisterUsableItem(food, function (item) -- Item stores the database entry for the item
        local src = source
        Feather.Inventory.CloseInventory(src)
        TriggerClientEvent('bcc-stables:FeedHorse', src, item)
    end)
end

RegisterServerEvent('bcc-stables:RemoveItem', function(item)
    local src = source
    Feather.Items.RemoveItemByName(item, 1, src)
end)

Feather.Items.RegisterUsableItem(Config.horsebrush, function (item)
    local src = source

    --local item = exports.vorp_inventory:getItem(src, Config.horsebrush)
    Feather.Inventory.CloseInventory(src)
    TriggerClientEvent('bcc-stables:BrushHorse', src)

    -- if not Config.horsebrushDurability then return end

    -- if not next(item.metadata) then
    --     local newData = {
    --         description = _U('horsebrushDesc') .. '</br>' .. _U('durability') .. 100 - 1 .. '%',
    --         durability = 100 - 1,
    --         id = item.id
    --     }
    --     exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    -- else
    --     if item.metadata.durability < 1 then
    --         exports.vorp_inventory:subItemID(src, item.id)
    --     else
    --         local newData = {
    --             description = _U('horsebrushDesc') .. '</br>' .. _U('durability') .. item.metadata.durability - 1 .. '%',
    --             durability = item.metadata.durability - 1,
    --             id = item.id
    --         }
    --         exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    --     end
    -- end
end)

Feather.Items.RegisterUsableItem(Config.lantern, function (item)
    local src = source

    --local item = exports.vorp_inventory:getItem(src, Config.lantern)
    Feather.Inventory.CloseInventory(src)
    TriggerClientEvent('bcc-stables:UseLantern', src)

    -- if not Config.lanternDurability then return end

    -- if not next(item.metadata) then
    --     local newData = {
    --         description = _U('durability') .. 100 - 1 .. '%',
    --         durability = 100 - 1,
    --         id = item.id
    --     }
    --     exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    -- else
    --     if item.metadata.durability < 1 then
    --         exports.vorp_inventory:subItemID(src, item.id)
    --     else
    --         local newData = {
    --             description = _U('durability') .. item.metadata.durability - 1 .. '%',
    --             durability = item.metadata.durability - 1,
    --             id = item.id
    --         }
    --         exports.vorp_inventory:setItemMetadata(src, item.id, newData, 1)
    --     end
    -- end
end)

Core.RPC.Register('bcc-stables:HorseReviveItem', function(params, res, src)
    local reviveItem = Config.reviver
    local count = Feather.Items.GetItemCount(reviveItem, src)
    if count <= 0 then
        res(false)
        return
    end
    Feather.Items.RemoveItemByName(reviveItem, 1, src)
    res(true)
end)

local function CheckPlayerJob(charJob, jobGrade, jobConfig)
    for _, job in pairs(jobConfig) do
        --if (charJob == job.name) and (tonumber(jobGrade) >= tonumber(job.grade)) then
            return true
        --end
    end
end

Core.RPC.Register('bcc-stables:CheckJob', function(params, res, src)
    local character = Core.Character.GetCharacter({ src = src })
    local char = character.char
    local charJob = char.job
    local jobGrade = char.jobGrade

    if not charJob then return res(false) end

    local jobConfig
    if params.trainer then
        jobConfig = Config.trainerJob
    else
        jobConfig = Stables[params.site].shop.jobs
    end

    local hasJob = false
    hasJob = CheckPlayerJob(charJob, jobGrade, jobConfig)
    if hasJob then
        res({true, charJob})
    else
        res({false, charJob})
    end
end)

RegisterNetEvent('vorp_core:instanceplayers', function(setRoom)
    local src = source

    if setRoom == 0 then
        Wait(3000)
        TriggerClientEvent('bcc-stables:UpdateMyHorseEntity', src)
    end
end)

--- Check if properly downloaded
function file_exists(name)
    local f = LoadResourceFile(GetCurrentResourceName(), name)
    return f ~= nil
end

if not file_exists('./ui/index.html') then
    print('^1 INCORRECT DOWNLOAD!  ^0')
    print(
        '^4 Please Download: ^2(bcc-stables.zip) ^4from ^3<https://github.com/BryceCanyonCounty/bcc-stables/releases/latest>^0')
end
