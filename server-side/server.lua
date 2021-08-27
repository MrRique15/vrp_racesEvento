-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_racesEvento",cRP)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local primeiro = nil
local segundo = nil
local terceiro = nil
local checkPoint = 0
local terminado = 0
local corredores = 0
local corredorId = {}
local carroEvento = "bnr34"
local posicaoCorredores = false
local names = {}

local checkPointsPos = {}
	
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISHRACES
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkTicket()
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		return true
	end
end

function cRP.startRace()
	local source = source	
	local user_id = vRP.getUserId(source)
	corredores = corredores + 1
	corredorId[user_id] = corredores
	if user_id then
		return true
	end
end

function cRP.returnCorredorId()
	local source = source	
	local user_id = vRP.getUserId(source)
	if user_id then
		return corredorId[user_id]
	end
end

function cRP.finishRaces()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		
		if terminado == 0 then
			terminado = 1
			local identity = vRP.getUserIdentity(user_id)
			names[1] = identity.name.." "..identity.name2
			if corredores == 1 then
				TriggerClientEvent('smartphone:createSMS',-1,'EVENTO',"Os ganhadores da corrida foram: \n#1: "..names[1])
				SetTimeout(240000, function()
					TriggerClientEvent("event:clearPlacar",-1)
				end)
			end
			vRP.giveInventoryItem(user_id,"dollars",15000,true)
		elseif terminado == 1 then
			terminado = 2
			local identity = vRP.getUserIdentity(user_id)
			names[2] = identity.name.." "..identity.name2
			if corredores == 2 then
				TriggerClientEvent('smartphone:createSMS',-1,'EVENTO',"Os ganhadores da corrida foram: \n#1: "..names[1]..",#2: "..names[2])
				SetTimeout(240000, function()
					TriggerClientEvent("event:clearPlacar",-1)
				end)
			end
			vRP.giveInventoryItem(user_id,"dollars",10000,true)
		elseif terminado == 2 then
			terminado = 3
			local identity = vRP.getUserIdentity(user_id)
			names[3] = identity.name.." "..identity.name2
			if corredores == 3 then
				TriggerClientEvent('smartphone:createSMS',-1,'EVENTO',"Os ganhadores da corrida foram: \n#1: "..names[1]..",#2: "..names[2]..",#3: "..names[3])
				SetTimeout(240000, function()
					TriggerClientEvent("event:clearPlacar",-1)
				end)
			end
			vRP.giveInventoryItem(user_id,"dollars",5000,true)
			if corredores > 3 then
				TriggerClientEvent('smartphone:createSMS',-1,'EVENTO',"Os ganhadores da corrida foram: \n#1: "..names[1]..",#2: "..names[2]..",#3: "..names[3])
			end
		elseif terminado == 3 then
			terminado = 4
			SetTimeout(240000, function()
				TriggerClientEvent("event:clearPlacar",-1)
			end)
			
			vRP.giveInventoryItem(user_id,"dollars",1000,true)
		else
			terminado = terminado + 1
			vRP.giveInventoryItem(user_id,"dollars",1000,true)
		end
	end
end

function cRP.finishBlip()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		Citizen.Wait(200)
		corredores = corredores - 1
		TriggerClientEvent("event:atualizaCorredores",-1,corredores,false,true)
		
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("vrp_races:explosivePlayers")
AddEventHandler("vrp_races:explosivePlayers",function()
	local source = source
	
end)

RegisterServerEvent("event:spawnCar")
AddEventHandler("event:spawnCar",function()
	local source = source
	local user_id = vRP.getUserId(source)
 	if user_id then
      	local plate = "55DTA141"
		TriggerClientEvent("adminVehicle",source,carroEvento,plate)
      	TriggerEvent("setPlateEveryone",plate)
		TriggerEvent("setPlatePlayers",plate,user_id)
		TriggerClientEvent("event:fuel",source)
	end
end)

RegisterServerEvent("event:posServ")
AddEventHandler("event:posServ",function(finalCorrida,checkP)
	local source = source
	local user_id = vRP.getUserId(source)
	
	if checkPointsPos[checkP] == nil then
		checkPointsPos[checkP] = 1
		local nomeFull = vRP.getUserIdentity(user_id)
		local nome = nomeFull.name.." "..nomeFull.name2.." ~r~("..user_id..")"
		TriggerClientEvent("event:checkPosition",-1,1,nome)
		TriggerClientEvent("event:atualizaCorredores",source,corredores,1,true)
	elseif checkPointsPos[checkP] == 1 then
		checkPointsPos[checkP] = 2
		local nomeFull = vRP.getUserIdentity(user_id)
		local nome = nomeFull.name.." "..nomeFull.name2.." ~r~("..user_id..")"
		TriggerClientEvent("event:checkPosition",-1,2,nome)
		TriggerClientEvent("event:atualizaCorredores",source,corredores,2,true)
	elseif checkPointsPos[checkP] == 2 then
		checkPointsPos[checkP] = 3
		local nomeFull = vRP.getUserIdentity(user_id)
		local nome = nomeFull.name.." "..nomeFull.name2.." ~r~("..user_id..")"
		TriggerClientEvent("event:checkPosition",-1,3,nome)
		TriggerClientEvent("event:atualizaCorredores",source,corredores,3,true)
	else
		checkPointsPos[checkP] = checkPointsPos[checkP] + 1
		TriggerClientEvent("event:atualizaCorredores",source,corredores,checkPointsPos[checkP],true)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("posicionarcorredores",function(source, args, rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"Admin") then
		posicaoCorredores = true
		TriggerClientEvent("event:teleportPlayer",-1)
		TriggerClientEvent("Notify",source,"importante","Corredores Posicionados!",5000)
	end
end)

RegisterCommand("liberarevento",function(source, args, rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	
	if vRP.hasPermission(user_id,"Admin") then
		if posicaoCorredores then
			TriggerClientEvent("event:liberar",-1,corredores)
			TriggerClientEvent("Notify",source,"importante","Evento Liberado!",5000)
		else
			TriggerClientEvent("Notify",source,"importante","Posicione os corredores primeiro com /posicionarcorredores!",5000)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------