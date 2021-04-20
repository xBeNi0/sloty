-- This resource was made by plesalex100#7387
-- Please respect it, don't repost it without my permission
-- This Resource started from: https://codepen.io/AdrianSandu/pen/MyBQYz
-- SMX Version: saNhje & wUNDER

SMX = nil
TriggerEvent('smx:getSharedObject', function(obj) SMX = obj end)

RegisterServerEvent("smx_slots:checkChipsCount")
AddEventHandler("smx_slots:checkChipsCount", function(bets)
    local _source   = source
    local xPlayer   = SMX.GetPlayerFromId(_source)
    if xPlayer then
        if xPlayer.getInventoryItem('chips').count >= bets then
            TriggerEvent('smx_discordlog:logs', 'casino_slots', _source, "postawił/a **"..bets.."** żetonów")
            xPlayer.removeInventoryItem('chips', bets)
            xPlayer.setChips(bets)
            TriggerClientEvent("smx_slots:UpdateSlots", _source, bets)
        else
            TriggerClientEvent('smx_notify:clientNotify', _source, {text="Nie posiadasz tyle żetonów!", type='casino'})
            TriggerClientEvent("smx_slots:enterBets", _source)
        end
    end
end)

RegisterServerEvent("smx_slots:checkDirtyMoney")
AddEventHandler("smx_slots:checkDirtyMoney", function(bets)
    local _source   = source
    local xPlayer   = SMX.GetPlayerFromId(_source)
    if xPlayer then
        if xPlayer.getBlack() >= bets then
            xPlayer.removeInventoryItem('chips', bets)
            TriggerClientEvent("smx_slots:UpdateSlots", _source, bets)
        else
            TriggerClientEvent('smx_notify:clientNotify', _source, {text="Nie posiadasz tyle brundej gotówki!", type='casino'})
            TriggerClientEvent("smx_slots:enterBets", _source)
        end
    end
end)

RegisterServerEvent("smx_slots:updateChips")
AddEventHandler("smx_slots:updateChips", function(amount)
    local _source   = source
    local xPlayer   = SMX.GetPlayerFromId(_source)
    xPlayer.setChips(amount)
end)

RegisterServerEvent("smx_slots:giveBackChips")
AddEventHandler("smx_slots:giveBackChips", function(amount)
    local _source   = source
    local xPlayer   = SMX.GetPlayerFromId(_source)
    if xPlayer then
        amount = tonumber(amount)
        if amount > 0 then
            xPlayer.addInventoryItem('chips', amount)
            TriggerEvent('smx_discordlog:logs', 'casino_slots', _source, "wygrał/a **"..amount.."** żetonów")
            TriggerClientEvent('smx_notify:clientNotify', _source, {text="Maszyna zwróciła "..amount.." żetonów. Gratulacje!", type='casino'})
        else
            TriggerClientEvent('smx_notify:clientNotify', _source, {text="Skończyły Ci się żetony. Powodzenia następnym razem!", type='casino'})
        end
        xPlayer.setChips(0)
    end
end)
