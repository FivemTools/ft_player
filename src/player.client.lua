--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

Player = {}

--
-- Get player atributs
--
function GetPlayer(...)

    local args = {...}
    local count = #args

    if count == 1 and type(args[1]) == "table" then

        local table = {}
        for _, name in pairs(args[1]) do
            table[name] = Player[name]
        end
        return table

    elseif count == 1 then

        local name = args[1]
        return Player[name]

    end
    return false

end

--
-- Set player atributs
--
function SetLocalPlayer(...)

    local args = {...}
    local count = #args
    local update = {}

    if count == 1 and type(args[1]) == "table" then

        for name, value in pairs(args[1]) do
            Player[name] = value
            update[name] = value
        end
        return update

    elseif count == 2 then

        local name = args[1]
        local value = args[2]
        Player[name] = value
        update[name] = value
        return update

    end
    return false

end

--
-- Set player data
--
function SetPlayer(...)

    local update = Player.SetLocal(...)
    if update ~= false and update ~= nil then
        TriggerServerEvent('ft_player:SetPlayer', update)
    end

end

--
-- Save data in Database
--
function SavePlayer(...)

    local args = {...}
    local count = #args
    local update = {}

    if count == 1 and type(args[1]) == "table" then

        for _, name in pairs(args[1]) do
            update[name] = Player[name]
        end
        TriggerServerEvent('ft_player:SetPlayer', update)

    elseif count == 1 then

        local name = args[1]
        update[name] = Player[name]
        TriggerServerEvent('ft_player:SetPlayer', update)

    end
    return false

end

--
-- Get Palyer pos
--
function PlayerPos()

    local playerPed = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(playerPed, true)
    local heading = GetEntityHeading(playerPed)
    local data = {
        posX = pedPos.x,
        posY = pedPos.y,
        posZ = pedPos.z,
        heading = heading,
    }
    return data

end

--
-- Return player
--
function GetPlayer()
    return Player
end

--
-- Update Player
--
RegisterNetEvent("ft_player:SetPlayer")
AddEventHandler('ft_player:SetPlayer', function(data)

    if source == -1 then
        print("Server only")
    end
    SetPlayer(data)

end)

--
-- Update Local Player
--
RegisterNetEvent("ft_player:SetLocalPlayer")
AddEventHandler('ft_player:SetLocalPlayer', function(data)

    local data = data
    if source == -1 then
        print("Server only")
    end
    SetPlayerLocal(data)

end)

--
-- Init client
--
RegisterNetEvent("ft_player:InitPlayer")
AddEventHandler('ft_player:InitPlayer', function(data)

    if data ~= nil then
        exports.ft_libs:DebugPrint(data)
        SetLocalPlayer(data)
    end

end)
