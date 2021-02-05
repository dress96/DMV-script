ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- Event to obtain your license
RegisterNetEvent('stahl_drivingschool:givelicense')
AddEventHandler('stahl_drivingschool:givelicense', function (typeTest)

    local _source = source 

    TriggerEvent('esx_license:addLicense',_source,typeTest)
    
end)

-- Event to pay for your license
RegisterNetEvent('stahl_drivingschool:pay')
AddEventHandler('stahl_drivingschool:pay', function(item)
    
    local _source = source
    local Playerid = ESX.GetPlayerFromId(_source)
    local price = Config.LicensePrices[item]

    if (Playerid.getMoney() >= price) then    
        Playerid.removeMoney(price)   
        TriggerClientEvent('esx:showNotification', _source, _U('paid_licese_test', ESX.Math.GroupDigits(price)))
        TriggerClientEvent('stahl_drivingschool:StartDrivingTest',source,item)
    else
        TriggerClientEvent('esx:showNotification', _source, _U('error_not_money', ESX.Math.GroupDigits(price)))
    end

end)