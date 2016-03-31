Feature Engineering  and Data Preparation for Questions 2 & 3

/*
Q.2. Selecting Basic features of the player statistics from TOTALS table
*/
CREATE TABLE T_TBL_INIT_PLAYER AS
SELECT PLAYER_ID,
SEASON_ID,
POSITION,
TEAM_ID,
GAMES,
FREE_THROWS,
FREE_THROWS_ATTEMPTS,
THREE_POINTS_FG,
THREE_POINTS_FG_ATTEMPTS,
TWO_POINTS_FG,
TWO_POINTS_FG_ATTEMPTS,
OFFESNIVE_REBOUNDS,
DEFENSIVE_REBOUNDS,
ASSISTS,
STEALS,
POINTS,
MINUTES_PLAYED,
FIELD_GOALS,
FIELD_GOALS_ATTEMPTS,
EFF_FIELD_GOAL_PERCENT,
BLOCKS,
TURNOVERS,
PERSONAL_FOULS
FROM T_TBL_PLAYERS_TOTALS;


/*
Deleting the rows where the player has attributes as “NA”
*/
DELETE FROM T_TBL_INIT_PLAYER WHERE GAMES = ”NA”;

/*
Alter & update the tables to add the columns we require
*/
ALTER TABLE T_TBL_INIT_PLAYER
ADD FREE_THROWS_PERGAME REAL;

UPDATE T_TBL_INIT_PLAYER
SET FREE_THROWS_PERGAME = (1.0 *FREE_THROWS) / GAMES;

/*STRING OF ALTER COMMANDS*/

ALTER TABLE T_TBL_INIT_PLAYER
ADD FTA_PG REAL REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD THREEPFG_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD THREEPFGA_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD TWOPFG_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD TWOPFGA_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD OFFRB_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD DFSVRB_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD TRB REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD TRB_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD ASSISTS_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD STEALS_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD POINTS_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD MINPL_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD FG_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD FGA_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD BLOCKS_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD TURNOVERS_PG REAL;

ALTER TABLE T_TBL_INIT_PLAYER
ADD PFOULS_PG REAL;

/*Setting the values for per game statistics*/

UPDATE T_TBL_INIT_PLAYER SET
FTA_PG = (1.0 *FREE_THROWS_ATTEMPTS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
THREEPFG_PG = (1.0 * THREE_POINTS_FG) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
THREEPFGA_PG = (1.0 * THREE_POINTS_FG_ATTEMPTS)/GAMES;

UPDATE T_TBL_INIT_PLAYER SET
TWOPFG_PG = (1.0 * TWO_POINTS_FG) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
TWOPFGA_PG = (1.0 * TWO_POINTS_FG_ATTEMPTS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
OFFRB_PG = (1.0 * OFFESNIVE_REBOUNDS / GAMES);

UPDATE T_TBL_INIT_PLAYER SET
DFSVRB_PG = (1.0 * DEFENSIVE_REBOUNDS / GAMES);

UPDATE T_TBL_INIT_PLAYER SET
TRB = (1.0 * (OFFESNIVE_REBOUNDS + DEFENSIVE_REBOUNDS));

UPDATE T_TBL_INIT_PLAYER SET
TRB_PG = (1.0 * TRB) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
ASSISTS_PG = (1.0 * ASSISTS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
STEALS_PG = (1.0 * STEALS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
POINTS_PG =  (1.0 * POINTS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
MINPL_PG = (1.0 * MINUTES_PLAYED / GAMES);

UPDATE T_TBL_INIT_PLAYER SET
FG_PG = (1.0 * FIELD_GOALS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
FGA_PG = (1.0 * FIELD_GOALS_ATTEMPTS) / GAMES;


UPDATE T_TBL_INIT_PLAYER SET
BLOCKS_PG = (1.0 * BLOCKS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
TURNOVERS_PG = (1.0 * TURNOVERS) / GAMES;

UPDATE T_TBL_INIT_PLAYER SET
PFOULS_PG = (1.0 * PERSONAL_FOULS) / GAMES;

/* Plug in experience of the player on a per-season basis */
  /*Insert a column and populate 0’s initially*/
 ALTER TABLE T_TBL_INIT_ PLAYER
ADD EXPERIENCE INT;

UPDATE T_TBL_INIT_PLAYER
SET EXPERIENCE = 0;

/* Computing the experience of a player at any season based on the no. of seasons he played earlier */
CREATE TABLE T_TBL_EXP AS
select t1.player_id AS PLAYER_ID, t1.season_id AS SEASON_ID, count(distinct t2.season_id) AS EXP ,max(t2.season_id) AS PRV_SEASON
FROM T_TBL_PLAYERS_TOTALS t1, T_TBL_PLAYERS_TOTALS t2
where t1.player_id = t2.player_id and t1.season_id > t2.season_id
group by t1.player_id, t1.season_id;

CREATE TABLE T_TBL_INIT_PLAYER_EXP AS
SELECT T1.*, T2.EXP
FROM T_TBL_init_PLAYER T1 left outer join t_tbl_EXP T2 ON
T1.PLAYER_ID = T2.PLAYER_ID AND T1.SEASON_ID = T2.SEASON_ID;

UPDATE T_TBL_INIT_PLAYER_EXP
SET EXP = 0
WHERE EXP IS NULL;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD PF_FLAG BOOLEAN;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD SF_FLAG BOOLEAN;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD SG_FLAG BOOLEAN;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD C_FLAG BOOLEAN;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD NA_FLAG BOOLEAN;

ALTER TABLE T_TBL_INIT_PLAYER_EXP
ADD PG_FLAG BOOLEAN;


DROP TABLE t_tbl_init_PLAYER;


/* Maintaining in this table, the position at which a player played for any season */
CREATE TABLE PLAYER_SEASON_POSITION AS
SELECT DISTINCT T1.PLAYER_ID, T1.SEASON_ID, T2.POSITION
FROM T_TBL_INIT_PLAYER_EXP T1, T_TBL_INIT_PLAYER_EXP T2
WHERE T1.PLAYER_ID = T2.PLAYER_ID AND T1.SEASON_ID >= T2.SEASON_ID AND T1.TEAM_ID IS NOT NULL; 


/* Updating the flags for the current season*/

UPDATE T_TBL_INIT_PLAYER_EXP
SET PF_FLAG = 1
WHERE POSITION LIKE "%PF%";

UPDATE T_TBL_INIT_PLAYER_EXP
SET SF_FLAG = 1
WHERE POSITION LIKE "%SF%";

UPDATE T_TBL_INIT_PLAYER_EXP
SET SG_FLAG = 1
WHERE POSITION LIKE "%SG%";

UPDATE T_TBL_INIT_PLAYER_EXP
SET C_FLAG = 1
WHERE POSITION LIKE "%C%";

UPDATE T_TBL_INIT_PLAYER_EXP
SET NA_FLAG = 1
WHERE POSITION LIKE "%NA%";

UPDATE T_TBL_INIT_PLAYER_EXP
SET PG_FLAG = 1
WHERE POSITION LIKE "%PG%";


/* This is to help finding how many positions a player has played so far until the current season */
CREATE TABLE PLAYER_SEASON_POSITION AS
SELECT DISTINCT T1.PLAYER_ID, T1.SEASON_ID, T2.POSITION
FROM T_TBL_INIT_PLAYER_EXP T1, T_TBL_INIT_PLAYER_EXP T2
WHERE T1.PLAYER_ID = T2.PLAYER_ID AND T1.SEASON_ID >= T2.SEASON_ID AND T1.TEAM_ID IS NOT NULL; 

create table player_season_positionwise as
select t1.player_id as player_id, t1.season_id as season_id, max(t1.PG_FLAG) pg, max(t1.SF_FLAG) sf, max(t1.SG_FLAG) sg, max(t1.C_FLAG) c, max(t1.NA_FLAG) na, max(t1.PF_FLAG) pf
from T_TBL_INIT_PLAYER_EXP t1, T_TBL_INIT_PLAYER_EXP t2
where t1.player_id = t2.player_id and t1.season_id >= t2.season_id and t1.player_id = 1382
group by t1.player_id, t1.season_id;

/* Setting the flags for all the positions in which a player has played earlier or this season*/
create table player_season_positionwise as
select t1.player_id as player_id, t1.season_id as season_id, max(t2.PG_FLAG) pg, max(t2.SF_FLAG) sf, max(t2.SG_FLAG) sg, max(t2.C_FLAG) c, max(t2.NA_FLAG) na, max(t2.PF_FLAG) pf
from T_TBL_INIT_PLAYER_EXP t1, T_TBL_INIT_PLAYER_EXP t2
where t1.player_id = t2.player_id and t1.season_id >= t2.season_id
group by t1.player_id, t1.season_id;

/* Setting to 0 for whichever position player hasn’t played until the current season*/
update T_TBL_INIT_PLAYER_EXP set PG_FLAG = 0 where PG_FLAG is null;
update T_TBL_INIT_PLAYER_EXP set PF_FLAG = 0 where PF_FLAG is null;
update T_TBL_INIT_PLAYER_EXP set SG_FLAG = 0 where SG_FLAG is null;
update T_TBL_INIT_PLAYER_EXP set SF_FLAG = 0 where SF_FLAG is null;
update T_TBL_INIT_PLAYER_EXP set C_FLAG = 0 where C_FLAG is null;
update T_TBL_INIT_PLAYER_EXP set NA_FLAG = 0 where NA_FLAG is null;

/* Moving this information to the main table*/
create table T_TBL_INIT_PLAYER_EXP_POS as
select t1.*, t2.sf as sf, t2.pf as pf,t2.sg as sg, t2.pg as pg, t2.c as c, t2.na as na, sf+sg+pf+pg+c+na as noOfPos
from T_TBL_INIT_PLAYER_EXP t1, player_season_positionwise t2
where t1.player_id = t2.player_id and t1.season_id = t2.season_id;

CREATE TABLE TEMP_PLAYER_SEASON_GAMES AS 
SELECT PLAYER_ID, SEASON_ID, MAX(GAMES) AS GAMES FROM T_TBL_INIT_PLAYER_EXP GROUP BY PLAYER_ID, SEASON_ID;

/* Maintaining the total games played by a player in a season across all the teams. This is to help adjusting the salaries*/
create table T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES as
select t1.*, t2.GAMES as MAX_GAMES
from T_TBL_INIT_PLAYER_EXP_POS t1, TEMP_PLAYER_SEASON_GAMES t2
where t1.player_id = t2.player_id and t1.season_id = t2.season_id;

/*Percentage derived features */

ALTER TABLE T_TBL_INIT_PLAYER_EXP_POS
ADD FTP REAL;

ALTER TABLE T_TBL_INIT_PLAYER_EXP_POS
ADD THREEFGP REAL;

ALTER TABLE T_TBL_INIT_PLAYER_EXPL_POS
ADD TWOFGP REAL;

UPDATE T_TBL_INIT_PLAYER_EXP_POS
SET FTP = (1.0 * FREE_THROWS_PERGAME) /  FTA_PG;

UPDATE T_TBL_INIT_PLAYER_EXP_POS
SET THREEFGP = (1.0 * THREEPFG_PG) / THREEPFGA_PG;

UPDATE T_TBL_INIT_PLAYER_EXP_POS
SET TWOFGP = (1.0 * TWOPFG_PG) / TWOPFGA_PG;


/* Joining salary information along with the measures collected so far*/
create table T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY as
SELECT t1.* , SALARY
FROM T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES t1 LEFT OUTER JOIN PLAYER_SALARY_PER_SEASON t2
ON t1.PLAYER_ID = t2.PLAYER_ID AND
t1.SEASON_ID = t2.SEASON_ID;


/* Adjusting the salaries for the players who have ben loaned from one team to another team in the same season*/
create table T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_CORRECTED as
select t1.*, salary * (1.0 * GAMES) / MAX_GAMES as corrected_salary
FROM T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY t1
where salary is not null;


/* Flags to know whether a player has played in the front court or back court or both*/
ALTER TABLE T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_ CORRECTED
ADD FRONT_POSITION BOOLEAN DEFAULT 0;
ALTER TABLE T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_ CORRECTED
ADD BACK_POSITION BOOLEAN DEFAULT 0;

update T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_corrected
set FRONT_POSITION = 1
where pf = 1 or sf = 1 or c = 1; 

update T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_corrected
set BACK_POSITION = 1
where pg = 1 or sg = 1; 

select sum(FRONT_POSITION), sum(BACK_POSITION)
from T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_corrected;
/* This will be used for further modelling for Q2 and Q3 */
create table T_TBL_FINAL_TABLE_FOR_REGRESSION as
select * from T_TBL_INIT_PLAYER_EXP_POS_MAXGAMES_SALARY_corrected;













