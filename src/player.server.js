/*
 * @Project: FiveM Tools
 * @Author: Samuelds
 * @License: GNU General Public License v3.0
 * @Source: https://github.com/FivemTools/ft_players
*/

const mysql = exports.ghmattimysql;

let playersList = {};
let onNewPlayerCallback = [];
let onPlayerConnectingCallback = [];
let onPlayerLeavingCallback = [];

/**
 * @description Return player Identifiers
 * @param {number} source
 * @return {array}
 */
export function GetPlayerIdentifiers(source) {
    let identifiers = [];
    const numIdentifiers = GetNumPlayerIdentifiers(source);
    for (let index = 0; index < numIdentifiers; index++) {
        identifiers[index] = GetPlayerIdentifier(source, index);
    }
    return identifiers;
}

/**
 * @description Return player Identifier
 * @param {number} source
 * @return {string}
 */
export function GetIdentifier(source) {
    return GetPlayerIdentifiers(source).find(function (index) {
        return index.startsWith(Settings.system.identifier + ":");
    });
}

/**
 * @description Check if is in the list player
 * @param {number} source
 * @return {boolean}
 */
export function IsPlayerExist(source) {
    return playersList[source] !== undefined;
}

/**
 * @description Return playersList
 * @return {object} playersList
 */
export function GetPlayers() {
    return playersList;
}

/**
 * @description Return player connected by identifier
 * @param {string} identifier
 * @return {Player|boolean} player
 */
export function GetOnlinePlayerFormIdentifier(identifier) {
    for (let player in playersList) {
        if (player.identifier === identifier) {
            return player;
        }
    }
    return false;
}

/**
 * @description Return player connected by server id
 * @param {string} source
 * @return {Player|boolean} player
 */
export function GetOnlinePlayerFormSource(source) {
    if (IsPlayerExist(source)) {
        return playersList[source];
    } else {
        return false;
    }
}

/**
 * @description Return player on database by identifier
 * @param {string} identifier
 * @param {function} callback
 * @return {Player|boolean} player
 */
export function GetPlayerFormIdentifier(identifier, callback) {
    mysql.execute("SELECT * FROM players WHERE identifier = ?", [identifier], function (result) {
        if (result[0] !== undefined) {
            callback(new Player(result[0]));
        } else {
            callback(false);
        }
    });
}

/**
 * @description Return player on database by identifier
 * @param {string} identifier
 * @param {function} callback
 * @return {Player|boolean} player
 */
export function CreatePlayerFormIdentifier(identifier, callback) {
    mysql.execute("INSERT IGNORE INTO players (`identifier`, `createdAt`) VALUES (?, NOW())", [identifier], function (result) {
        GetPlayerFormId(result.insertId, callback);
    });
}

/**
 * @description Return player on database by id on database
 * @param {number} id
 * @param {function} callback
 * @return {Player|boolean} player
 */
export function GetPlayerFormId(id, callback) {
    mysql.execute("SELECT * FROM players WHERE id = ?", [id], function (result) {
        if (result[0] !== undefined) {
            callback(new Player(result[0]));
        } else {
            callback(false);
        }
    });
}

/**
 * @description Add execute function on player connecting
 * @param {function} callback
 * @return {void}
 */
export function OnPlayerConnecting(callback) {
    onPlayerConnectingCallback.push(callback);
}

/**
 * @description Run new player callback
 * @param {Player} player
 * @param {function} callback
 * @return {void}
 */
function RunPlayerConnecting(player, callback) {
    const count = onPlayerConnectingCallback.length;
    if (count > 0) {
        for (let index in onPlayerConnectingCallback) {
            onPlayerConnectingCallback[index](player);
            if (index == count - 1) {
                callback();
            }
        }
    } else {
        callback();
    }
}

/**
 * @description Add execute function on player leaving
 * @param {function} callback
 * @return {void}
 */
export function OnPlayerLeaving(callback) {
    onPlayerLeavingCallback.push(callback);
}

/**
 * @description Add execute function on new player
 * @param {function} callback
 * @return {void}
 */
export function OnNewPlayer(callback) {
    onNewPlayerCallback.push(callback);
}

/**
 * @description Run new player callback
 * @param {Player} player
 * @param {function} callback
 * @return {void}
 */
function RunNewPlayer(player, callback) {
    const count = onNewPlayerCallback.length;
    if (count > 0) {
        for (let index in onNewPlayerCallback) {
            onNewPlayerCallback[index](player);
            if (index == count - 1) {
                callback();
            }
        }
    } else {
        callback();
    }
}

/**
 * @description player connecting event
 */
AddEventHandler("playerConnecting", function (name, setKickReason, deferrals) {
    deferrals.defer();
    deferrals.presentCard(Settings.messages.waitCard);

    const identifier = GetIdentifier(source);
    if (identifier === undefined) {
        deferrals.done(Settings.messages.noIdentifier);
    }

    GetPlayerFormIdentifier(identifier, function (player) {
        if (player === false) {
            CreatePlayerFormIdentifier(identifier, function (player) {
                if (player === false) {
                    deferrals.done(Settings.messages.playerNotFound);
                } else {
                    RunPlayerConnecting(player, function () {
                        RunNewPlayer(player, function () {
                            playersList[identifier] = player;
                            deferrals.done();
                        });
                    });
                }
            });
        } else {
            RunPlayerConnecting(player, function () {
                playersList[identifier] = player;
                deferrals.done();
            });
        }
    });

});

/**
 * @description player leave event
 */
AddEventHandler("playerDropped", function () {
    if (playersList[source] !== undefined) {
        let player = playersList[source];
        for (let index in onPlayerLeavingCallback) {
            onPlayerLeavingCallback[index](player);
            if (index == OnPlayerLeavingCallback.length - 1) {
                delete playersList[source];
            }
        }
    }
    const identifier = GetIdentifier(source);
    if (playersList[identifier] !== undefined) {
        delete playersList[identifier];
    }
});

/**
 * @description player is ready
 */
RegisterNetEvent("ft_player:ClientReady");
AddEventHandler("ft_player:ClientReady", function () {
    const identifier = GetIdentifier(source);
    playersList[source] = playersList[identifier];
    delete playersList[identifier];
});