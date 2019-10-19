--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependencies {
    "ghmattimysql",
    "ft_core",
}

files {
    -- Client
    "src/player.client.js",

    -- Server
    "src/player.class.js",
    "src/player.server.js",
}

server_scripts {}

client_scripts {}
