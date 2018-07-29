--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

Players = {}
PlayerDropCallback = {}
PlayerCreateCallback = {}

--
-- Check if is in the list player
--
function PlayerExist(source)

    if type(Players[source]) == "nil" then
        return false
    end
    return true

end

--
-- Add Plays in player list
--
function AddPlayer(source, player)

    Players[source] = player

end

--
-- Remove Plays in player list
--
function RemovePlayer(source)

    Players[source] = nil

end

--
-- Get All player
--
function GetPlayers()

    return Players

end

--
-- Get Identifier
--
function GetIdentifier(source)

    if Settings.system.identifier == "steam" then
        return exports.ft_libs:GetSteamIDFormSource(source)
    elseif Settings.system.identifier == "ip" then
        return exports.ft_libs:GetIpFormSource(source)
    end
    return false

end

--
-- Retunr player is player is connected
--
function GetPlayerIsConnectedFormIdentifier(identifier)

    local players = exports.ft_player:GetPlayers()
    for _, player in pairs(players) do
        if player.identifier == identifier then
            return player
        end
    end
    return false

end

--
-- Retunr player is player is connected
--
function GetPlayerIsConnectedFormId(id)

    local players = exports.ft_player:GetPlayers()
    for _, player in pairs(players) do
        if player.id == id then
            return player
        end
    end
    return false

end

--
-- Get player by identifier
--
function GetPlayerFromIdentifier(identifier)

    local data = GetPlayerIsConnectedFormIdentifier(identifier)
    if data ~= false then
        return data
    else

        local result = exports.ft_database:QueryFetchAll("SELECT * FROM players WHERE identifier = @identifier", { ['@identifier'] = identifier })
        if result then
            local count = #result
            if count > 1 then
                print("[FT_PLAYER] the player " .. identifier .. " is duplicated in the database")
            end
            if result ~= nil and result[1] ~= nil then
                exports.ft_libs:DebugPrint(result[1], "FT_PLAYER GetPlayerFromIdentifier")
                return player.new(result[1])
            end
        end

    end
    return false

end

--
-- Get player by id
--
function GetPlayerFromId(id)

    local data = GetPlayerIsConnectedFormId(identifier)
    if data ~= false then
        return data
    else
        local result = exports.ft_database:QueryFetchAll("SELECT * FROM players WHERE id = @id", { ['@id'] = id })
        if result then
            local count = #result
            if count > 1 then
                print("[FT_PLAYER] the player " .. identifier .. " is duplicated in the database")
            end
            if result ~= nil and result[1] ~= nil then
                exports.ft_libs:DebugPrint(result[1], "FT_PLAYER GetPlayerFromId")
                return player.new(result[1])
            end
        end
    end
    return false

end

--
-- Get player by serverId (source)
--
function GetPlayerFromServerId(source)

    return Players[source]

end

--
-- Create player in database
--
function CreatePlayer(identifier)

    local result = exports.ft_database:QueryExecute(
        "INSERT IGNORE INTO players (`identifier`, `createdAt`) VALUES (@identifier, NOW())",
        {
            ['@identifier'] = identifier,
        }
    )
    return result

end

--
-- Add callback on player drop
--
function AddPlayerDropCallback(callback)

    table.insert(PlayerDropCallback, callback)

end

--
-- Add callback on player create
--
function AddPlayerCreateCallback(callback)

    table.insert(PlayerCreateCallback, callback)

end

--
-- Set Player
--
RegisterServerEvent("ft_player:SetPlayer")
AddEventHandler('ft_player:SetPlayer', function(clientPlayer, ...)

    local source = source
    if Settings.system.savePlayerClient == false then
        DropPlayer(source, Settings.messages.antiCheat)
        return false
    end

    if PlayerExist(source) then
        local player = Players[source]

        -- Anti Cheat --
        local args = {...}
        local countArgs = #args
        if countArgs == 1 and type(args[1]) == "table" then

            for name, value in pairs(args[1]) do
                if player[name] ~= clientPlayer[name] then
                    DropPlayer(source, Settings.messages.antiCheat)
                    return false
                end
            end

        elseif countArgs == 2 then

            local name = args[1]
            local value = args[2]
            if player[name] ~= clientPlayer[name] then
                DropPlayer(source, Settings.messages.antiCheat)
                return false
            end

        else

            return false

        end
        -- End Anti Cheat --

        player:Set(...)
    end

end)

--
-- Save Player
--
RegisterServerEvent("ft_player:SavePlayer")
AddEventHandler('ft_player:SavePlayer', function(...)

    local source = source
    if Settings.system.savePlayerClient == false then
        DropPlayer(source, Settings.messages.antiCheat)
        return false
    end

    if PlayerExist(source) then
        local player = Players[source]
        player:Save(...)
    end

end)

--
-- Event is emited after client is 100% loaded games
--
RegisterServerEvent("ft_libs:OnClientReady")
AddEventHandler('ft_libs:OnClientReady', function()

    local source = source
    local player = {}

    if not PlayerExist(source) then

        local identifier = GetIdentifier(source)
        if identifier ~= false then
            player = GetPlayerFromIdentifier(identifier)
            if player == false then
                CreatePlayer(identifier) -- Create player in db
                player = GetPlayerFromIdentifier(identifier) -- Select player in db
                if player == false then
                    DropPlayer(source, Settings.messages.playerNotFound)
                    return false
                end

                for _, callback in pairs(PlayerCreateCallback) do
                    callback(player)
                end
            end

            player.source = source
            AddPlayer(source, player)

        else

            if Settings.identifier == "steam" then
                DropPlayer(source, Settings.messages.steamNotFound)
            elseif Settings.identifier == "ip" then
                DropPlayer(source, Settings.messages.ipNotFound)
            end
            return false

        end

    end

    -- Send to client
    TriggerClientEvent("ft_player:SetPlayer", source, player)

    -- Send OnPlayerReadyToJoin event
    TriggerClientEvent("ft_player:OnPlayerReadyToJoin", source)
    TriggerEvent("ft_player:OnPlayerReadyToJoin", source)

    -- Debug values
    -- exports.ft_libs:DebugPrint(Players, "FT_PLAYER Players list")

end)

--
-- Event before player leave
--
AddEventHandler('playerDropped', function()

    local source = source

    -- Remove in player list
    if PlayerExist(source) then

        local player = Players[source]
        for _, callback in pairs(PlayerDropCallback) do
            callback(player)
        end
        RemovePlayer(source)

    end

end)
