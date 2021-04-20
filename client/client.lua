SMX                             = nil
local PlayerData                = {}
local open 						= false
local enableBlackMonneyPlaying = false
local focusLock = false

Citizen.CreateThread(function()
    while SMX == nil do
        Citizen.Wait(10)

        TriggerEvent("smx:getSharedObject", function(xPlayer)
            SMX = xPlayer
        end)
    end

    while not SMX.IsPlayerLoaded() do 
        Citizen.Wait(500)
    end

    if SMX.IsPlayerLoaded() then
        PlayerData = SMX.GetPlayerData()
    end
end)

-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------

function KeyboardInput(textEntry, inputText, maxLength)
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end

-------------------------------------------------------------------------------
-- NET EVENTS
-------------------------------------------------------------------------------
RegisterNetEvent("smx_slots:enterBets")
AddEventHandler("smx_slots:enterBets", function (machineName)
	local title = "Diamond Casino - Sloty"
	if machineName ~= nil then
		title = "Automat "..machineName
	end
	if enableBlackMonneyPlaying then
		SMX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'zetony',
		{
			title    = title,
			align    = 'left',
			elements = {
				{label = "Graj za żetony", value = "chips"},
				{label = "Graj za brudną gotówkę", value = "dirty"}
			}
		},
		function(data, menu)
			local akcja = data.current.value
			if akcja == 'chips' then
				SMX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'chips_count', {
					title = 'Wybierz liczbę żetonów (50 - 1000)'
				}, function(data3, menu3)
					local bets = tonumber(data3.value)
					if bets ~= nil then
						if bets >= 50 and bets <= 1000 then
							if bets % 50 == 0 and bets >= 50 then
								TriggerServerEvent('smx_slots:checkChipsCount', tonumber(bets))
								menu3.close()
							else
								TriggerEvent('smx_notify:clientNotify', {text="Wprowadź krotność liczby 50! Np. 100, 350, 2500", type='casino'})
							end
						else
							TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
						end
					else
						TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
					end
				end, function(data3, menu3)
					menu3.close()
				end)
			elseif akcja == 'dirty' then
				menu3.close()
				TriggerEvent('smx_notify:clientNotify', {text="Ta funkcja jest jeszcze w fazie developingu", type='casino'})
				if true then return end
				SMX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'chips_count', {
					title = 'Wybierz ilość brudnej gotówki (50 - 1000)'
				}, function(data3, menu3)
					local bets = tonumber(data3.value)
					if bets ~= nil then
						if bets >= 50 and bets <= 1000 then
							if bets % 50 == 0 and bets >= 50 then
								TriggerServerEvent('smx_slots:checkDirtyMoney', tonumber(bets))
								menu3.close()
							else
								TriggerEvent('smx_notify:clientNotify', {text="Wprowadź krotność liczby 50! Np. 100, 350, 2500", type='casino'})
							end
						else
							TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
						end
					else
						TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
					end
				end, function(data3, menu3)
					menu3.close()
				end)
			end
		end, function(data, menu)
			menu.close()
			exit()
		end)
	else
		SMX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'chips_count', {
			title = 'Wybierz liczbę żetonów (50 - 1000)'
		}, function(data3, menu3)
			local bets = tonumber(data3.value)
			if bets ~= nil then
				if bets >= 50 and bets <= 1000 then
					if bets % 50 == 0 and bets >= 50 then
						TriggerServerEvent('smx_slots:checkChipsCount', tonumber(bets))
						menu3.close()
					else
						TriggerEvent('smx_notify:clientNotify', {text="Wprowadź krotność liczby 50! Np. 100, 350, 2500", type='casino'})
					end
				else
					TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
				end
			else
				TriggerEvent('smx_notify:clientNotify', {text="Wprowadź liczbę od 50 do 1000!", type='casino'})
			end
		end, function(data3, menu3)
			menu3.close()
			exit()
		end)
	end
end)

RegisterNetEvent("smx_slots:UpdateSlots")
AddEventHandler("smx_slots:UpdateSlots", function(lei)
	focusLock = true
	SetNuiFocus(true, true)
	open = true
	SendNUIMessage({
		showPacanele = "open",
		coinAmount = tonumber(lei)
	})
end)

-------------------------------------------------------------------------------
-- NUI CALLBACKS
-------------------------------------------------------------------------------
RegisterNUICallback('updateChips', function(data, cb)
	TriggerServerEvent('smx_slots:updateChips', data.coinAmount)
	cb('ok')
end)

RegisterNUICallback('exitWith', function(data, cb)
	TriggerServerEvent("smx_slots:giveBackChips", data.coinAmount)
	SetNuiFocus(false, false)
	focusLock = false
	exit()
	open = false
	TriggerServerEvent('smx_slots:updateChips', 0)
	cb('ok')
end)

-------------------------------------------------------------------------------
-- THREADS
-------------------------------------------------------------------------------
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(1)
		if open then
			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisableControlAction(0, 24, true) -- Attack
			DisablePlayerFiring(GetPlayerPed(-1), true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		end
	end
end)

local currentCoords = nil
local currentRot = nil
local seatSideAngle = 30
local lastCam = 0

local slotsObjects = {
	{model = `vw_prop_casino_slot_08a`, label = "Evacuator"},
	{model = `vw_prop_casino_slot_07a`, label = "Diamond Miner"},
	{model = `vw_prop_casino_slot_06a`, label = "Twilight Knife"},
	{model = `vw_prop_casino_slot_05a`, label = "Diety of the Sun"},
	{model = `vw_prop_casino_slot_04a`, label = "Fame or Shame"},
	{model = `vw_prop_casino_slot_03a`, label = "Space Rangers"},
	{model = `vw_prop_casino_slot_02a`, label = "Impotent Rage"},
	{model = `vw_prop_casino_slot_01a`, label = "Vice City P.I."}
}
 
function nearSlots()
	local player = PlayerPedId()
	local playerLoc = GetEntityCoords(player, 0)
	for _, v in ipairs(slotsObjects) do
		local slot = GetClosestObjectOfType(playerLoc, 0.9, v.model, false)
		if DoesEntityExist(slot) then
     		return slot, v.label
		end
	end
	return false, ''
end

function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < -180 and t + 180 or t
end

Citizen.CreateThread(function()
	RequestAnimDict("anim_casino_b@amb@casino@games@shared@player@")
	local waitTime = 500
	while SMX == nil do
		Citizen.Wait(1000)
	end
	while true do
		local playerPed = PlayerPedId()
		if open == false then
			local obj, name = nearSlots()
			if obj ~= false then
				waitTime = 1
				local pCoords = GetEntityCoords(playerPed)
				if GetEntityCoords(obj) ~= vector3(0.0, 0.0, 0.0) then
					slotsChair = 1
					local coords = GetWorldPositionOfEntityBone(obj, GetEntityBoneIndexByName(obj, "Chair_Base_0"..slotsChair))
					local rot = GetWorldRotationOfEntityBone(obj, GetEntityBoneIndexByName(obj, "Chair_Base_0"..slotsChair))
					local dist = GetDistanceBetweenCoords(coords, pCoords, true)
					local g2_coords = coords
					local g2_rot = rot
					local angle = rot.z-findRotation(coords.x, coords.y, pCoords.x, pCoords.y)+90.0
					local seatAnim = "sit_enter_"
					if angle > 0 then seatAnim = "sit_enter_left" end
					if angle < 0 then seatAnim = "sit_enter_right" end
					if angle > seatSideAngle or angle < -seatSideAngle then seatAnim = seatAnim .. "_side" end
					local canSit = true
					local pedNearby, pedDistance = SMX.Game.GetClosestPlayer(g2_coords)
					if pedNearby == -1 or pedNearby == GetPlayerPed(-1) or pedDistance > 1.2 then
						canSit = true
					else
						canSit = false
					end
					if dist < 1.8 and canSit then
						SMX.ShowHelpNotification("~INPUT_CONTEXT~ Zagraj na slotach "..name)
					end
					if canSit then
						if IsControlJustPressed(1, 51) then
							if canSit then
								--SMX.TriggerServerCallback('smx_casino_handler:checkPerm', function(perm)
									--if perm then
										lastCam = GetFollowPedCamViewMode()
										local initPos = GetAnimInitialOffsetPosition("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)
										local initRot = GetAnimInitialOffsetRotation("anim_casino_b@amb@casino@games@shared@player@", seatAnim, coords, rot, 0.01, 2)
										TaskGoStraightToCoord(PlayerPedId(), initPos, 1.0, 5000, initRot.z, 0.01)
										Wait(250)
										SetEntityCoords(PlayerPedId(), initPos)
										SetEntityHeading(PlayerPedId(), initRot)
										Wait(50)
										SetCurrentPedWeapon(GetPlayerPed(-1),GetHashKey("WEAPON_UNARMED"),true)
										local scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
										NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", seatAnim, 2.0, -2.0, 13, 16, 1148846080, 0)
										NetworkStartSynchronisedScene(scene)
										local scene = NetworkConvertSynchronisedSceneToSynchronizedScene(scene)
										repeat Wait(0) until GetSynchronizedScenePhase(scene) >= 0.99 or HasAnimEventFired(PlayerPedId(), 2038294702) or HasAnimEventFired(PlayerPedId(), -1424880317)
										Wait(1000)
										scene = NetworkCreateSynchronisedScene(coords, rot, 2, true, true, 1065353216, 0, 1065353216)
										NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 2.0, -2.0, 13, 16, 1148846080, 0)
										NetworkStartSynchronisedScene(scene)
										repeat Wait(0) until IsEntityPlayingAnim(PlayerPedId(), "anim_casino_b@amb@casino@games@shared@player@", "idle_cardgames", 3) == 1
										SetFollowPedCamViewMode(4)
										currentCoords = g2_coords
										currentRot = g2_rot
										TriggerEvent('smx_slots:enterBets', name)
									--[[else
										SMX.ShowNotification("Kasyno jest teraz w fazie testów!")
									end
								end)]]
							else
								SMX.ShowNotification("Ten automat jest zajęty!")
							end
						end
					end
				end
			else
				waitTime = 500
			end
		else
			waitTime = 500
		end
		Citizen.Wait(waitTime)
	end
end)

function exit()
	local scene = NetworkCreateSynchronisedScene(currentCoords, currentRot, 2, false, false, 1065353216, 0, 1065353216)
	SetFollowPedCamViewMode(lastCam)
	NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, "anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left", 2.0, -2.0, 13, 16, 1148846080, 0)
	NetworkStartSynchronisedScene(scene)
	Wait(math.floor(GetAnimDuration("anim_casino_b@amb@casino@games@shared@player@", "sit_exit_left")*800))
	ClearPedTasks(PlayerPedId())
	currentCoords = nil
	currentRot = nil
	lastCam = 0
	EnableAllControlActions(0)
	EnableAllControlActions(2)
	EnableAllControlActions(3)
end

Citizen.CreateThread(function()
    -- Update every frame
    while true do
        Citizen.Wait(0)
        if focusLock == true then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 4, true)
            DisableControlAction(0, 6, true)
            DisableControlAction(0, 12, true)
            DisableControlAction(0, 13, true)
            DisableControlAction(0, 177, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 202, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 66, true)
            DisableControlAction(0, 67, true)
            DisableControlAction(0, 68, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 70, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 92, true)
            DisableControlAction(0, 95, true)
            DisableControlAction(0, 98, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 114, true)
            DisableControlAction(0, 122, true)
            DisableControlAction(0, 135, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 144, true)
            DisableControlAction(0, 176, true)
            DisableControlAction(0, 177, true)
            DisableControlAction(0, 222, true)
            DisableControlAction(0, 223, true)
            DisableControlAction(0, 229, true)
            DisableControlAction(0, 237, true)
            DisableControlAction(0, 238, true)
		end
	end
end)