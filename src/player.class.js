/*
 * @Project: FiveM Tools
 * @Author: Samuelds
 * @License: GNU General Public License v3.0
 * @Source: https://github.com/FivemTools/ft_players
*/

class Player {

    /**
     * @param {array} player
     */
    constructor(player) {
        for (const index in player) {
            this[index] = player[index];
        }
    }

    /**
     * @param {array|string} column
     */
    save(column) {
        if (typeof column === "object") {
            let req = "";
            const values = [];
            let name;

            for (let index in column) {
                name = column[index];
                if (req !== "") {
                    req += ", ";
                }
                req += "?? = ?";
                values.push(name);
                values.push(this[name]);
            }
            values.push(this.id);
            mysql.execute("UPDATE players SET " + req + " WHERE id = ?", values);
        } else {
            mysql.execute("UPDATE players SET ?? = ? WHERE id = ?", [column, this[column], this.id]);
        }
    }

    /**
     *
     * @param {string} column
     * @param {object|number|string|boolean} value
     */
    set(column, value) {
        this[column] = value;
        mysql.execute("UPDATE players SET ?? = ? WHERE id = ?", [column, value, this.id]);
    }
}
