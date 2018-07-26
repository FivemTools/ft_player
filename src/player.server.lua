--
-- @Project: FiveM Tools
-- @Author: Samuelds, LH_Lawliet
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
    local countArgs = #args
    local secure = {
        ['@id'] = self.id,
    }

    exports.ft_libs:PrintTable(args[1])

    print("save player")
    if countArgs == 1 and type(args[1]) == "table" then

        print("save player table")
        local str_query = ""
        for _, name in pairs(args[1]) do
            if name ~= "id" and name ~= "identifier" then
                if number ~= 0 then
                    str_query = str_query .. ", "
                end
                print("Update : " .. name)
                str_query = str_query .. tostring(name) .. " = @" .. tostring(name)
                secure["@" .. tostring(name)] = self[name]
            end
        end

        if #secure >= 1 then
            exports.ft_libs:PrintTable(secure)
            exports.ft_database:QueryExecute("UPDATE players SET " .. str_query .. " WHERE id = @id", secure)
            return true
        end

    elseif countArgs == 1 then

        print("save player simple")
        local name = args[1]
        if name ~= "id" and name ~= "identifier" then
            secure["@" .. name] = self[name]
            print("Update : " .. name)
            exports.ft_libs:PrintTable(secure)
            exports.ft_database:QueryExecute("UPDATE players SET " .. name .. " = @" .. name .. " WHERE id = @id", secure)
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
    local countArgs = #args -- Count number arguments

    if countArgs == 1 and type(args[1]) == "table" then

        local table = {}
        for _, name in pairs(args[1]) do
            table[name] = self[name]
        end
        return table

    elseif countArgs == 1 then

        local name = args[1]
        return self[name]

    end
    return self

end

--
-- Set player atributs in local
--
function Player:Set(...)

    local args = {...} -- Get all arguments
    local countArgs = #args -- Count number arguments
    local save = {}
    local update = {}

    if countArgs == 1 and type(args[1]) == "table" then

        for name, value in pairs(args[1]) do
            table.insert(save, name)
            self[name] = value
            update[name] = value
        end
        TriggerClientEvent("ft_player:SetPlayer", self.source, update)

    elseif countArgs == 2 then

        local name = args[1]
        local value = args[2]
        self[name] = value
        TriggerClientEvent("ft_player:SetPlayer", self.source, name, value)

    else

        return false

    end

end

--
-- Create instance of player
--
function player.new(data)

    local self = data
    setmetatable(self, { __index = Player })
    return self

end
