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

  local identifiers = GetPlayerIdentifiers(source)
  return identifiers[1]

end

--
-- Get player by identifier
--
function GetPlayerFromIdentifier(identifier)

  local playerData = nil
  local data = exports.ft_database:QueryFetch("SELECT * FROM players WHERE identifier = @identifier", { ['@identifier'] = identifier })

  if data ~= nil then
    playerData = player.new(data)
  end

  return playerData

end

--
-- Get player by id
--
function GetPlayerFromId(id)

  local playerData = nil
  local data = exports.ft_database:QueryFetch("SELECT * FROM players WHERE id = @id", { ['@id'] = id })

  if data ~= nil then
    playerData = player.new(data)
  end

  return player

end

--
-- Get player by serverId (source)
--
function GetPlayerFromServerId(source)
  local playerData = Players[source]
  return playerData
end

--
-- Create player in database
--
function CreatePlayer(identifier)

  local date = os.date("%Y-%m-%d %X")
  local result = exports.ft_database:QueryExecute("INSERT INTO players (`identifier`, `created_at`) VALUES (@identifier, @created_at)", { ['@identifier'] = identifier, ['@created_at'] = date } )
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
-- CellPlayer
--
RegisterServerEvent("ft_player:PlayerCall")
AddEventHandler('ft_player:PlayerCall', PlayerCall)

--
-- Update Player
--
RegisterServerEvent("ft_player:SetPlayer")
AddEventHandler('ft_player:SetPlayer', function(data)

  local source = source
  if source == -1 then
    print("Client only")
  end

  local player = Players[source]
  player:Set(data)

end)

--
-- Update local Player
--
RegisterServerEvent("ft_player:SetLocalPlayer")
AddEventHandler('ft_player:SetLocalPlayer', function(data)

  local source = source
  if source == -1 then
    print("Client only")
  end

  local player = Players[source]
  player:SetLocal(data)

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
    player = GetPlayerFromIdentifier(identifier)
    if type(player) == "nil" then
      CreatePlayer(identifier) -- Create player in db
      player = GetPlayerFromIdentifier(identifier) -- Select player in db

      for _, callback in pairs(PlayerCreateCallback) do
        callback(player)
      end
    end

    player.source = source
    AddPlayer(source, player)

  end

  -- Send to client
  TriggerClientEvent("ft_player:InitPlayer", source, player)

  -- Send playerReadyToJoin event
  TriggerClientEvent("ft_player:PlayerReadyToJoin", source)
  TriggerEvent("ft_player:PlayerReadyToJoin", source)

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
