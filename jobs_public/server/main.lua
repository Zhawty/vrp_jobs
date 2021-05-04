local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

--- [ CONEXÃO ]-------------------------------------------------------------------------

xRP = {}
Tunnel.bindInterface("vrpx_jobs",xRP)

--- [ PAYMENT ]-------------------------------------------------------------------------

function xRP.payment(type,itemName,amount)
    local user_id = vRP.getUserId(source)
    if user_id then
        if type == 'money' then
            if Config.MoneyItem then
                vRP.giveInventoryItem(user_id,Config.MoneyItemName,amount)
            else
                vRP.giveMoney(user_id,amount)
            end
        elseif type == 'item' then
            vRP.giveInventoryItem(user_id,itemName,amount)
        end
    end
end

--- [ CHECKPERMISSION ]-----------------------------------------------------------------

function xRP.checkPermission(permission)
    local user_id = vRP.getUserId(source)
    if user_id then
        if permission ~= nil then
            if vRP.hasPermission(user_id, permission) then
                return true    
            end
        else
            return true
        end
    end
end