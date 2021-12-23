/*
01 SELECT
 */

-- 1. 
SELECT population 
FROM world
WHERE name = 'Germany'
;

-- 2.
SELECT name, population 
FROM world
WHERE name IN ('Sweden', 'Norway', 'Denmark');

-- 3.
SELECT name, area 
FROM world
WHERE area BETWEEN 200000 AND 250000
;

--------------------------------------------------------------------

/*
06 JOIN
*/

-- 1.
SELECT matchid, player
FROM goal 
WHERE teamid = 'GER'
;

-- 2. 
SELECT id,stadium,team1,team2
FROM game
WHERE id = 2012
;

-- 3.
SELECT goal.player,goal.teamid, game.stadium, game.mdate
FROM game 
JOIN goal ON game.id = goal.matchid
WHERE goal.teamid = 'GER'
;

-- 4.
select team1, team2, player
from game
join goal on id = matchid
where player like 'Mario%'
;

-- 5. 
SELECT player, teamid, coach, gtime
FROM goal 
join eteam on teamid = id
WHERE gtime<=10
;

-- 6.
select mdate, teamname
from game
join eteam on game.team1 = eteam.id
where eteam.coach = 'Fernando Santos'
;

-- 7.
select player
from goal
join game on goal.matchid = game.id
where stadium = 'National Stadium, Warsaw'
;




















