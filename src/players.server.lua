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
-- Functions
--

-- Check if is in the list player
function PlayerExist(source)

  if type(Players[source]) == "nil" then
    return false
  else
    return true
  end

end

-- Add Plays in player list
function AddPlayer(source, player)

  Players[source] = player

end

-- Remove Plays in player list
function RemovePlayer(source)

  Players[source] = nil

end

-- Get All player
function GetPlayers()

  return Players

end

-- Get Identifier
function GetIdentifier(source)

  local identifiers = GetPlayerIdentifiers(source)
  return identifiers[1]

end

-- Get player by identifier
function GetPlayerFromIdentifier(identifier)

  local player = nil
  local data = exports.ft_database:QueryFetchAll("SELECT * FROM " .. Database.players .. " WHERE identifier = @identifier", { ['@identifier'] = identifier })

  if data[1] ~= nil then
    player = Player(data[1])
  end

  return player

end

-- Get player by id
function GetPlayerFromId(id)

  local player = nil
  local data = exports.ft_database:QueryFetchAll("SELECT * FROM " .. Database.players .. " WHERE id = @id", { ['@id'] = id })

  if data[1] ~= nil then
    player = Player(data[1])
  end

  return player

end

-- Get player by serverId (source)
function GetPlayerFromServerId(source)
  local player = Players[source]
  return player
end

-- Create player in database
function CreatePlayer(identifier)

  local date = os.date("%Y-%m-%d %X")
  local result = exports.ft_database:QueryExecute("INSERT INTO " .. Database.players .. " (`identifier`, `created_at`) VALUES (@identifier, @created_at)", { ['@identifier'] = identifier, ['@created_at'] = date } )
  return result

end

-- Add callback on player drop
function AddPlayerDropCallback(callback)
  table.insert(PlayerDropCallback, callback)
end

-- Add callback on player create
function AddPlayerCreateCallback(callback)
  table.insert(PlayerCreateCallback, callback)
end

-- Player Methods for export
function PlayerCall(method, source, ...)

  local args = {...}
  local count = #args
  local player = Players[source]

  if count >= 1 then

    local callback = player[method]

    if callback == nil then
      print("[Player] method : " ..method .. " no exist")
      return false
    end

    return callback(player, ...)

  elseif count == 0 then

    local callback = player[method]

    if callback == nil then
      print("[Player] method : " ..method .. " no exist")
      return false
    end

    return callback(player)

  end

  return false

end

--
-- Events
--

-- CellPlayer
RegisterServerEvent("ft_players:PlayerCall")
AddEventHandler('ft_players:PlayerCall', PlayerCall)

-- Update Player
RegisterServerEvent("ft_players:SetPlayer")
AddEventHandler('ft_players:SetPlayer', function(data)

  local source = source
  if source == -1 then
    print("Client only")
  end

  local player = Players[source]
  player:Set(data)

end)

-- Update local Player
RegisterServerEvent("ft_players:SetLocalPlayer")
AddEventHandler('ft_players:SetLocalPlayer', function(data)

  local source = source
  if source == -1 then
    print("Client only")
  end

  local player = Players[source]
  player:SetLocal(data)

end)

-- Event is emited after client is 100% loaded games
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
  TriggerClientEvent("ft_players:InitPlayer", source, player)

  -- Send playerReadyToJoin event
  TriggerClientEvent("ft_players:PlayerReadyToJoin", source)
  TriggerEvent("ft_players:PlayerReadyToJoin", source)

end)

-- Event before player leave
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
