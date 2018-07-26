--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

dependencies {

  "ft_libs",
  "ft_database",

}

client_scripts {

  "settings.lua",
  "src/player.client.lua",

}

server_scripts {

  "settings.lua",
  "src/player.server.lua",
  "src/players.server.lua",

}

exports {

    "GetPlayer",
    "SetPlayer",

}

server_exports {

    "GetPlayerFromIdentifier",
    "GetPlayerFromServerId",
    "GetPlayerFromId",
    "GetIdentifier",
    "GetPlayers",
    "PlayerCall",
    "AddPlayerCreateCallback",
    "GetPlayerIsConnectedFormIdentifier",
    "GetPlayerIsConnectedFormId",

}
