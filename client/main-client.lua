ESX = nil

local typeTest = nil
local vehicleTest = nil
local instructorPed = nil
local CheckPointTest = 1
local LastCheckPointTest = 0
local ExamErrors = 0

-- Active de ESX
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

-- Create the mark in the map and text for use
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(GetPlayerPed(-1))

        if GetDistanceBetweenCoords(playerCoords,Config.LicensePoint.Pos.x, Config.LicensePoint.Pos.y, Config.LicensePoint.Pos.z, true) < Config.DrawDistance then 
        
            DrawMarker(Config.LicensePoint.Type,Config.LicensePoint.Pos.x,Config.LicensePoint.Pos.y,Config.LicensePoint.Pos.z,       
            0,0,0,0,0,0,Config.LicensePoint.Size,Config.LicensePoint.Size,Config.LicensePoint.Size,    
            Config.LicensePoint.Color.R,Config.LicensePoint.Color.G,Config.LicensePoint.Color.B, 155,       
            0,0,2,0,0,0,0)
        end

    end

end)

-- Menu license items
function DrivingSchoolMenu()

    local items = {
        {label = _U('item_car_license'), value = 'carLicense'},
        {label = _U('item_moto_license'), value = 'motorcycleLicense'},
        {label = _U('item_truck_license'), value = 'truckLicense'}
    }

    ESX.UI.Menu.Open('default',GetCurrentResourceName(),'school_driving_menu', {
        title = _U('menu_license_title'),
        align = 'left',
        elements = items

        }, function(data,menu)
            local item = data.current.value
            TriggerServerEvent('stahl_drivingschool:pay',item)
            menu.close()
        end, 
        function(data,menu) 
            menu.close()
    end)
end

-- Create de function about the driving license test
RegisterNetEvent('stahl_drivingschool:StartDrivingTest')
AddEventHandler('stahl_drivingschool:StartDrivingTest',function(type) 

    ESX.Game.SpawnVehicle(Config.vehicleRespawn.Model[type],Config.vehicleRespawn.Pos,Config.vehicleRespawn.Rotation, function(vehicle)

        SetVehicleColours(vehicle,0,0)
        SetVehicleFuelLevel(vehicle, 100.0)

        instructorPed = CreatePedInsideVehicle(vehicle,0,GetHashKey('s_m_m_gentransport'), 0, true, false)
        vehicleTest = vehicle
        typeTest  = type
        print (typeTest )
        SetPedCombatMovement(instructorPed,0)
        
        TriggerEvent('nui:ExamNotifications', true)
    end)

end)

-- Open/close the NUI exams
RegisterNetEvent('nui:ExamNotifications')
AddEventHandler('nui:ExamNotifications', function()

    if (display) then 
        display = false 
    else
        display = true
    end

  SendNUIMessage({
    type = "ui",
    display = true,
    TextExam = _U('exam_initial') 
  })

end)

-- Revise the point during the test
Citizen.CreateThread(function()

    while true do
        if typeTest ~= nil then 
        
            Citizen.Wait(0)

            local playerCoords = GetEntityCoords(GetPlayerPed(-1))

            if IsPedInVehicle(GetPlayerPed(-1),vehicleTest, false) then 
                if GetDistanceBetweenCoords(playerCoords,Config.TheoricalPoint[CheckPointTest].Pos.x,Config.TheoricalPoint[CheckPointTest].Pos.y,Config.TheoricalPoint[CheckPointTest].Pos.z, true) < Config.PointSize then 

                    SendNUIMessage({TextExam = _U('exam_instructions' .. tostring(CheckPointTest))})

                    if CheckPointTest == #Config.TheoricalPoint then

                        TriggerServerEvent('stahl_drivingschool:givelicense', typeTest)
                        FinishExam(true)
                    end
                    CheckPointTest = CheckPointTest + 1
                end
            end
        else 
            Citizen.Wait(1000)
        end
    end
end)

-- Revise the time to don't take a checkpoint
Citizen.CreateThread(function()
    while true do 
        if typeTest ~= nil then 
            
            if LastCheckPointTest == CheckPointTest then
                SendNUIMessage({TextExam = _U('fail_exam_time')})
                FinishExam(true)
            else
                LastCheckPointTest = CheckPointTest
            end
            Citizen.Wait(60000)
        else
            Citizen.Wait(61000)
        end
    end
end)

-- Revise the posible Exam Fails
Citizen.CreateThread (function()

    while true do 
        if typeTest ~= nil then

            local VehicleSpeed = GetEntitySpeed(vehicleTest) * 3.6
            local VehicleHealth = GetEntityHealth(vehicleTest)
            local FailExam = false
    
            if ExamErrors >= Config.MaximumErrors then
                SendNUIMessage({TextExam = _U('fail_exam_maximun')})
                FailExam = true
            elseif VehicleHealth <= 900 then
                SendNUIMessage({TextExam = _U('fail_exam_health')})
                FailExam = true
            elseif VehicleSpeed >= 85 then 
                SendNUIMessage({TextExam = _U('error_sum')})
                ExamErrors = ExamErrors + 1 
            end
            FinishExam(FailExam)
            Citizen.Wait(4000)
        else 
            Citizen.Wait(8000)
        end
    end
end)

-- Function finish exam test
function FinishExam(final)
    if final then
        DeleteEntity(instructorPed)
        ESX.Game.DeleteVehicle(vehicleTest)
        SetEntityCoords(GetPlayerPed(-1),Config.LicensePoint.Pos.x, Config.LicensePoint.Pos.y,Config.LicensePoint.Pos.z,0,0,0,0)

        CheckPointTest = 1
        LastCheckPointTest = 0
        ExamErrors = 0
        typeTest = nil 
    end     
end

-- In this part, we open the menu by key U
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(GetPlayerPed(-1))

        if IsControlJustPressed(1,Config.ControlKey) then   
            if GetDistanceBetweenCoords(playerCoords,Config.LicensePoint.Pos.x, Config.LicensePoint.Pos.y,Config.LicensePoint.Pos.z, true) < Config.LicensePoint.Size then
                if typeTest == nil then 
                    DrivingSchoolMenu()
                else
                    TriggerEvent('chat:addMessage', {
                        color = { 255, 0, 0},
                        multiline = true,
                        args = {'Sistema', _U('error_in_exam')}
                      }) 
                end
            end
        end
    end
end)