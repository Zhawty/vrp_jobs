

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

--- [ CONEXÃO ]-------------------------------------------------------------------------

vSERVER = Tunnel.getInterface("vrpx_jobs")

--- [ VARIABLES ] ----------------------------------------------------------------------

local inService = false
local cooldown = 0
local service = ''
local selectService = 1
local blip = false

--- [ STARTJOB ] -----------------------------------------------------------------------

RegisterCommand('start', function()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    for k,v in pairs(Config.getRoute) do
        local coords = vector3(v[1],v[2],v[3])
        local distance = #(playerCoords - coords)
        local job = v[4]
        if distance <= 5 then 
            if not inService then
                if vSERVER.checkPermission(v[5]) then
                    inService = true

                    print('[jobs] reward type '..Config.Jobs[job]['payment']['type'])
                    print('[jobs] job '..job..' started')

                    service = v[4]
                    addBlip()
                end
            end
        end
    end
end)

--- [ STOPJOB ] -----------------------------------------------------------------------

RegisterCommand('exit', function()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    for k,v in pairs(Config.getRoute) do
        local coords = vector3(v[1],v[2],v[3])
        local distance = #(playerCoords - coords)
        local job = v[4]
        if distance <= 5 then 
            if inService then
                inService = false
                service = ''
                print('[jobs] job '..job..' end')
            end
        end
    end
end)

--[ REWARDJOB ]------------------------------------------------------------------------

Citizen.CreateThread(function()
	while true do
		local idle = 1000
		local ped = PlayerPedId()
		if inService then
            if not IsPedInAnyVehicle(ped) then
                local x,y,z = table.unpack(GetEntityCoords(ped))
                local distance = Vdist(Config.Jobs[service]['routes'][selectService].x,Config.Jobs[service]['routes'][selectService].y,Config.Jobs[service]['routes'][selectService].z,x,y,z)
                if distance < 10.1 then
                    idle = 5
                    DrawMarker(21, Config.Jobs[service]['routes'][selectService].x,Config.Jobs[service]['routes'][selectService].y,Config.Jobs[service]['routes'][selectService].z-0.3, 0, 0, 0, 0, 180.0, 130.0, 0.6, 0.8, 0.5, 255, 0, 0, 180, 1, 0, 0, 1)
                    if distance <= 1.1  then
                        if IsControlJustPressed(1,38) then
                            print('[jobs] recived the reaward')
                            if Config.Jobs[service]['MaxRoutes'] <= selectService  then
                                selectService = 1
                                print('[jobs] finish the route, restarting')
                            else
                                selectService = selectService + 1 
                            end
                                vSERVER.payment(Config.Jobs[service]['payment']['type'],Config.Jobs[service]['payment']['itemName'],Config.Jobs[service]['payment']['amount'])
                                print('[jobs] recived '..Config.Jobs[service]['payment']['amount']..' dollars')
                            RemoveBlip(blip)
                            addBlip()
                        end
                    end
                end
            end
		end
		Citizen.Wait(idle)
	end
end)

function addBlip()
	blip = AddBlipForCoord(Config.Jobs[service]['routes'][selectService].x,Config.Jobs[service]['routes'][selectService].y,Config.Jobs[service]['routes'][selectService].z)
	SetBlipSprite(blip,484)
	SetBlipAsShortRange(blip,true)
	SetBlipColour(blip,4)
	SetBlipScale(blip,0.6)
	return blip
end