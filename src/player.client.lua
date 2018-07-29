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
    local data = exports.ft_libs:Clone(Player)

    if count == 1 and type(args[1]) == "table" then

        local table = {}
        for _, name in pairs(args[1]) do
            table[name] = data[name]
        end
        return table

    elseif count == 1 then

        local name = args[1]
        return data[name]

    end
    return data

end

--
-- Save data in Database
--
function SetPlayer(...)

    TriggerServerEvent('ft_player:SetPlayer', Player, ...)

end

--
-- Save to BDD
--
function SavePlayer(...)

    TriggerServerEvent('ft_player:SavePlayer', ...)

end

--
-- Update Player
--
RegisterNetEvent("ft_player:SetPlayer")
AddEventHandler('ft_player:SetPlayer', function(...)

    local args = {...}
    local count = #args

    if count == 1 and type(args[1]) == "table" then

        for name, value in pairs(args[1]) do
            Player[name] = value
        end

    elseif count == 2 then

        local name = args[1]
        local value = args[2]
        Player[name] = value

    end

    exports.ft_libs:DebugPrint(Player, "FT_PLAYER SetPlayer")

end)

--
-- Update Player
--
RegisterNetEvent("ft_player:OnPlayerReadyToJoin")
AddEventHandler('ft_player:OnPlayerReadyToJoin', function()

    print("ft_player:OnPlayerReadyToJoin")
    SetPlayer({ ["money"] = 10000 })
    Wait(1000)
    SavePlayer("money")
    SetPlayer({ ["money"] = 0 })
    SetPlayer({ ["money"] = 15945 })

end)

