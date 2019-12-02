//
// @Project: FivemTools
// @Author: Samuelds
// @License: GNU General Public License v3.0
// @Source: https://github.com/FivemTools/ft_core
//

const glob = require("glob");
module.exports = {
    entry: glob.sync("./src/**/*.js"),
    output: {
        filename: 'server.js',
        path: __dirname + '/dist/',
    },
};
