--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

player = {}
local Player = {}

--
-- Save data in Database
--
function Player:Save(...)

    local args = {...}
    local count = #args
    local secure = {
        ['@identifier'] = self.identifier,
    }

    if count == 1 and type(args[1]) == "table" then

        local number = 0
        local str_query = ""

        for _, name in pairs(args[1]) do
            if name ~= "id" and name ~= "identifier" then

                if number ~= 0 then
                    str_query = str_query .. ", "
                end

                str_query = str_query .. tostring(name) .. " = @" .. tostring(name)
                secure["@" .. tostring(name)] = self[name]
                number = number + 1

            end
        end

        if number >= 1 then
            exports.ft_database:QueryExecute("UPDATE players SET " .. str_query .. " WHERE identifier = @identifier", secure)
            return true
        end

    elseif count == 1 then

        local name = args[1]

        if name ~= "id" and name ~= "identifier" then
            secure["@" .. name] = self[name]
            exports.ft_database:QueryExecute("UPDATE players SET " .. name .. " = @" .. name .. " WHERE identifier = @identifier", secure)
            return true
        end

    end
    return false

end

--
-- Get player atributs
--
function Player:Get(...)

    local args = {...} -- Get all arguments
    local count = #args -- Count number arguments

    if count == 1 and type(args[1]) == "table" then

        local table = {}
        for _, name in pairs(args[1]) do
            table[name] = self[name]
        end
        return table

    elseif count == 1 then

        local name = args[1]
        return self[name]

    end
    return self

end

--
-- Set player atributs in local
--
function Player:SetLocal(...)

    local args = {...} -- Get all arguments
    local count = #args -- Count number arguments
    local save = {}
    local update = {}

    if count == 1 and type(args[1]) == "table" then

        for name, value in pairs(args[1]) do
            table.insert(save, name)
            self[name] = value
            update[name] = value
        end

    elseif count == 2 then

        local name = args[1]
        local value = args[2]
        table.insert(save, name)
        self[name] = value
        update[name] = value

    else

        return false

    end

    return {
        update = update,
        save = save,
    }

end

--
-- Set player atributs
--
function Player:Set(...)

    local data = self:SetLocal(...)
    TriggerClientEvent("ft_player:SetLocalPlayer", self.source, data.update)
    self:Save(data.save)

end

--
-- Create instance of player
--
function player.new(data)

    local self = data
    setmetatable(self, { __index = Player })
    return self

end

--
-- Add method to player class
--
function AddPlayerMethod(name, method)
    Player[name] = method
end
