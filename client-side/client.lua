-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPserver = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_racesEvento",cRP)
vSERVER = Tunnel.getInterface("vrp_racesEvento")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local inRunners = false
local inSelected = 0
local inCheckpoint = 0
local inLaps = 1
local inTimers = 0
local primeiro = nil
local segundo = nil
local terceiro = nil
local positionCheck = false
local liberado = false
local idInicio = nil
local veiculoCongelado = nil
local quantidadeCorredores = 0
local blips = false
local spawned = false
local travado = false
local myPosition = false
local apertouE = false

local anticheatm = "~y~Iniciado"
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local comeco = {
	[1] = {595.57,604.12,128.92,328.22},
	[2] = {605.64,600.42,128.92,340.74}
}
local runners = {
	[1] = {
		["laps"] = 1,
		["init"] = { 599.16,619.55,128.92,329.99 },
		["coords"] = {
			{ 910.000,527.890,121.47,179.90 },
			{ 566.910,243.750,103.17,145.02 },
			{ 303.220,261.990,105.37,88.250 }
		}
	}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADRUNNERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local vehicle = GetVehiclePedIsUsing(ped)
			local class = GetVehicleClass(vehicle)

			if inRunners and liberado then
				if not IsPedInAnyVehicle(PlayerPedId()) then
					inRunners = false
					RemoveBlip(blips)
					vSERVER.finishBlip()
					return
				end
				timeDistance = 4

				dwText2("~y~CHECKPOINT:~w~ "..inCheckpoint.." / "..#runners[inSelected]["coords"],7,0.040,0.54,0.45,255,255,255,255)
				dwText2("~y~TEMPO:~w~ "..inTimers.."s",7,0.040,0.51,0.51,255,255,255,255)
				if myPosition and quantidadeCorredores then
					dwText2("~y~Colocação:  ~w~"..myPosition.."/"..quantidadeCorredores,7,0.040,0.57,0.45,255,255,255,255)
				end
				
				local distance = #(coords - vector3(runners[inSelected]["coords"][inCheckpoint][1],runners[inSelected]["coords"][inCheckpoint][2],runners[inSelected]["coords"][inCheckpoint][3]))
				if distance <= 200 then
					DrawMarker(1,runners[inSelected]["coords"][inCheckpoint][1],runners[inSelected]["coords"][inCheckpoint][2],runners[inSelected]["coords"][inCheckpoint][3]-3,0,0,0,0,0,0,12.0,12.0,8.0,255,255,255,25,0,0,0,0)
					DrawMarker(21,runners[inSelected]["coords"][inCheckpoint][1],runners[inSelected]["coords"][inCheckpoint][2],runners[inSelected]["coords"][inCheckpoint][3]+1,0,0,0,0,180.0,130.0,3.0,3.0,2.0,255,0,0,50,1,0,0,1)

					if distance <= 10 then
						if inCheckpoint >= #runners[inSelected]["coords"] then
							if inLaps >= runners[inSelected]["laps"] then
								RemoveBlip(blips)
								PlaySoundFrontend(-1,"RACE_PLACED","HUD_AWARDS",false,inCheckpoint)
								TriggerServerEvent("event:posServ",true,inCheckpoint)
								vSERVER.finishRaces()
								inRunners = false
							else
								RemoveBlip(blips)
								TriggerServerEvent("event:posServ",false,inCheckpoint)
								inCheckpoint = inCheckpoint + 1
								inLaps = inLaps + 1
								
								CriandoBlip(runners,inSelected,inCheckpoint)
							end
						else
							RemoveBlip(blips)
							TriggerServerEvent("event:posServ",false,inCheckpoint)
							inCheckpoint = inCheckpoint + 1
							
							CriandoBlip(runners,inSelected,inCheckpoint)
						end
					end
				end
			elseif not inRunners and not apertouE then
				for k,v in pairs(runners) do
					local distance = #(coords - vector3(v["init"][1],v["init"][2],v["init"][3]))
					if distance <= 50 then
						timeDistance = 4
						DrawMarker(23,v["init"][1],v["init"][2],v["init"][3]-0.95,0,0,0,0,0,0,10.5,10.5,1.5,255,0,0,50,0,0,0,0)
						
						if IsControlJustPressed(1,38) and distance <= 10 and vSERVER.checkTicket() then
							if vSERVER.startRace() then
								apertouE = true
								inSelected = parseInt(k)
								idInicio = vSERVER.returnCorredorId()
								inRunners = true
								inCheckpoint = 1
								inTimers = 0
								inLaps = 1
							end
						end
					end
				end
			end

		Citizen.Wait(timeDistance)
	end
end)

RegisterNetEvent("event:checkPosition")
AddEventHandler("event:checkPosition", function(position, name)
	if position == 1 then
		if segundo == name then
			segundo = primeiro
		elseif terceiro == name then
			terceiro = segundo
			segundo = primeiro
		end
		primeiro = name
	elseif position == 2 then
		if primeiro == name then
			primeiro = segundo
		elseif terceiro == name then
			terceiro = segundo
		end
		segundo = name
	elseif position == 3 then
		if segundo == name then
			segundo = terceiro
		elseif primeiro == name then
			primeiro = segundo
			segundo = terceiro
		end
		terceiro = name
	end
end)

RegisterNetEvent("event:liberar")
AddEventHandler("event:liberar", function(quantidade)
	liberado = true
	if inRunners and not correndo then
		correndo = true
		if IsEntityAVehicle(veiculoCongelado) then
			FreezeEntityPosition(veiculoCongelado, false)
			veiculoCongelado = nil
			PlaySoundFrontend(-1,"RACE_PLACED","HUD_AWARDS",false,inCheckpoint)
    	end
		quantidadeCorredores = parseInt(quantidade)
		msgShow()
		CriandoBlip(runners,inSelected,inCheckpoint)
	else
		return
	end
end)

RegisterNetEvent("event:clearPlacar")
AddEventHandler("event:clearPlacar", function()
	primeiro = nil
	segundo = nil
	terceiro = nil
end)

RegisterNetEvent("event:atualizaCorredores")
AddEventHandler("event:atualizaCorredores", function(quantidade,posicao,status)
	if inRunners then
		quantidadeCorredores = parseInt(quantidade)
		if status then
			myPosition = parseInt(posicao)
		end
	end
end)

RegisterNetEvent("event:teleportPlayer")
AddEventHandler("event:teleportPlayer", function()
	local ped = PlayerPedId()

	if inRunners then
		if not spawned then
			spawned = true
			DoScreenFadeOut(500)
			Citizen.Wait(500)
			SetEntityCoords(ped,comeco[idInicio][1]+0.0001,comeco[idInicio][2]+0.0001,comeco[idInicio][3]+0.0001,1,0,0,1)
			SetEntityHeading(ped,comeco[idInicio][4])
			Citizen.Wait(100)
			TriggerServerEvent("event:spawnCar")
			Citizen.Wait(300)
			DoScreenFadeIn(800)
		else
			return
		end
	end
end)

RegisterNetEvent('event:fuel')
AddEventHandler('event:fuel',function()
	if inRunners and not travado then
		travado = true
		Citizen.Wait(300)
		local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    	if IsEntityAVehicle(vehicle) then
			Citizen.Wait(300)
    	    SetVehicleFuelLevel(vehicle,100.0)
			FreezeEntityPosition(vehicle, true)
			veiculoCongelado = vehicle
    	end
	else
		return
	end
end)

function msgShow()
	if inRunners then
		local ativadomsg = true
		SetTimeout(2000, function()
			ativadomsg = false
		end)
		while ativadomsg do
			Citizen.Wait(1)
			local scaleform = triatlonInitialize("mp_big_message_freemode")
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
		end
    end
end

function triatlonInitialize(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end
    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieFunctionParameterString(anticheatm)
    PopScaleformMovieFunctionVoid()
    return scaleform
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if inRunners and liberado then
			timeDistance = 1000
			inTimers = inTimers + 1
		end

		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if primeiro then
			timeDistance = 5
			dwText2("~y~[PLACAR EVENTO]",7,0.040,0.30,0.45,255,255,255,255)
			dwText2("~y~#1  ~w~"..primeiro,7,0.040,0.34,0.45,255,255,255,255)
		end
		if segundo then
			timeDistance = 5
			dwText2("~y~#2  ~w~"..segundo,7,0.040,0.37,0.45,255,255,255,255)
		end
		if terceiro then
			timeDistance = 5
			dwText2("~y~#3  ~w~"..terceiro,7,0.040,0.40,0.45,255,255,255,255)
		end
		Citizen.Wait(timeDistance)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DWTEXT
-----------------------------------------------------------------------------------------------------------------------------------------
function dwText2(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function dwText(text,height)
	SetTextFont(4)
	SetTextScale(0.50,0.50)
	SetTextColour(255,255,255,180)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.5,0.5,height)
end

function CriandoBlip(races,racepoint,racepos)
	blips = AddBlipForCoord(races[racepoint]["coords"][racepos][1],races[racepoint]["coords"][racepos][2],races[racepoint]["coords"][racepos][3])
	SetBlipSprite(blips,1)
	SetBlipColour(blips,1)
	SetBlipScale(blips,0.8)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Corrida")
	EndTextCommandSetBlipName(blips)
end