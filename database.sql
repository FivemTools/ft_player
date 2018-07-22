/**
 * @Project: FiveM Tools
 * @Author: Samuelds
 * @License: GNU General Public License v3.0
 * @Source: https://github.com/FivemTools/ft_players
 */

CREATE TABLE `players` (
    `id` int(11) NOT NULL,
    `identifier` varchar(255) NOT NULL,
    `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `players`
    ADD PRIMARY KEY (`id`),
    ADD UNIQUE KEY `identifier` (`identifier`);

ALTER TABLE `players`
    MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;