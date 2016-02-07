class Per36Minutes():
    def __init__(self, season = 'NA', age='NA', team='NA', league='NA', positions='NA', games='NA', gamesStarted='NA',
                 minutesPlayed='NA', fieldGoals='NA', fieldGoalsAttempted='NA', fileGoalsPercentage='NA', threePoints='NA',
                 threePointsAttempted='NA', threePointsPercentage='NA', twoPoints='NA', twoPointsAttempted='NA',
                 twoPointsPercentage='NA', freeThrows='NA', freeThrowsAttempted='NA',
                 freeThrowsPercentage='NA', offensiveRebounds='NA', defensiveRebounds='NA', totalRebounds='NA', assist='NA',
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
        self._fieldGoalsAttempted = fieldGoalsAttempted
        self._fieldGoalsPercentage = fileGoalsPercentage
        self._threePoints = threePoints
        self._threePointsAttempted = threePointsAttempted
        self._threePointsPercentage = threePointsPercentage
        self._twoPoints = twoPoints
        self._twoPointsAttempted = twoPointsAttempted
        self._twoPointsPercentage = twoPointsPercentage
        self._freeThrows = freeThrows
        self._freeThrowsAttempted = freeThrowsAttempted
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