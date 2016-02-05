class Statistics():
    """
        This class models the basic Statistics class
        There are many tables like Totals Per game and others that derive from this and define additional attributes
        as necessary
    """
    def __init__(self, season = 'NA', age='NA', team='NA', league='NA', positions='NA', games='NA', gamesStarted='NA',
                 minutesPlayed='NA',fieldGoals='NA', fieldGoalsAverage='NA', fileGoalsPercentage='NA', threePoints='NA',
                 threePointsAverage='NA',threePointsPercentage='NA', twoPoints='NA', twoPointsAverage='NA',
                 twoPointsPercentage='NA', effectiveFieldGoalPercentage='NA', freeThrows='NA', freeThrowsAverage='NA',
                 freeThrowsPercentage='NA', offensiveRebounds='NA',defensiveRebounds='NA', totalRebounds='NA', assist='NA',
                 steals='NA', blocks='NA', turnOvers='NA', personalFouls='NA', points='NA'):
        self._season = season
        self._age = age
        self._team = team
        self._league = league
        self._position = positions
        self._games = games
        self._gamesStarted = gamesStarted
        self._minutesPlayed = minutesPlayed
        self._fieldGoals = fieldGoals
        self._fieldGoalsAverage = fieldGoalsAverage
        self._fieldGoalsPercentage = fileGoalsPercentage
        self._threePoints = threePoints
        self._threePointsAverage = threePointsAverage
        self._threePointsPercentage = threePointsPercentage
        self._twoPoints = twoPoints
        self._twoPointsAverage = twoPointsAverage
        self._twoPointsPercentage = twoPointsPercentage
        self._effectiveFieldGalPercentage = effectiveFieldGoalPercentage
        self._freeThrows = freeThrows
        self._freeThrowsAverage = freeThrowsAverage
        self._freeThrowsPercentage = freeThrowsPercentage
        self._offensiveRebounds =  offensiveRebounds
        self._defensiveRebounds = defensiveRebounds
        self._totalRebounds = totalRebounds
        self._assist = assist
        self._steals = steals
        self._blocks = blocks
        self._turnOvers = turnOvers
        self._personalFouls = personalFouls
        self._points = points

    @property
    def season(self):
        return self._season

    @season.setter
    def season(self, season):
        self._season = season

    @property
    def age(self):
        return self._age

    @age.setter
    def age(self, age):
        self._age = age

    @property
    def team(self):
        return self._team

    @team.setter
    def team(self, team):
        self._team = team

    @property
    def league(self):
        return self._league

    @league.setter
    def league(self, league):
        self._league = league

    @property
    def position(self):
        return self._position

    @position.setter
    def positions(self, position):
        self._position = position

    @property
    def games(self):
        return self._games

    @games.setter
    def games(self, games):
        self._games = games

    @property
    def gamesStarted(self):
        return self._gamesStarted

    @gamesStarted.setter
    def gamesStarted(self, gamesStarted):
        self._gamesStarted = gamesStarted

    @property
    def minutesPlayed(self):
        return self._minutesPlayed

    @minutesPlayed.setter
    def minutesPlayed(self, minutesPlayed):
        self._minutesPlayed = minutesPlayed

    @property
    def fieldGoals(self):
        return self._fieldGoals

    @fieldGoals.setter
    def fieldGoals(self, fieldGoals):
        self._fieldGoals = fieldGoals

    @property
    def fieldGoalsAverage(self):
        return self._fieldGoalsAverage

    @fieldGoalsAverage.setter
    def fieldGoalsAverage(self, fieldGoalsAverage):
        self._fieldGoalsAverage = fieldGoalsAverage

    @property
    def fieldGoalsPercentage(self):
        return self._fieldGoalsPercentage

    @fieldGoalsPercentage.setter
    def fieldGoalsPercentage(self, fieldGoalsPercentage):
        self._fieldGoalsPercentage = fieldGoalsPercentage

