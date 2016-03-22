class Player():
    def __init__(self, name="NA", active="NA", url="NA", fromYear="NA", toYear="NA", position="NA",
                 height="NA", weight="NA", dob="NA", college = "NA", shootingHand="NA", experience="NA",
                 totals=[], perGame=[], per36Minutes=[], per100Possessions=[], advanced=[], salary=[]):
        self._name = name
        self._active = active
        self._url = url
        self._fromYear = fromYear
        self._toYear = toYear
        self._position = position
        self._height = height
        self._weight = weight
        self._dob = dob
        self._college = college
        self._shootingHand = shootingHand
        self._experience = experience
        self._totals = totals
        self._perGame = perGame
        self._per36Minutes = per36Minutes
        self._per100Possessions = per100Possessions
        self._advanced = advanced
        self._salary = salary

    @property
    def name(self):
        return self._name

    @property
    def active(self):
        return self._active

    @property
    def url(self):
        return self._url

    @property
    def fromYear(self):
        return self._fromYear

    @property
    def toYear(self):
        return self._toYear

    @property
    def position(self):
        return self._position

    @property
    def height(self):
        return self._height

    @property
    def weight(self):
        return self._weight

    @property
    def dob(self):
        return self._dob

    @property
    def college(self):
        return self._college

    @property
    def shootingHand(self):
        return self._shootingHand

    @property
    def experience(self):
        return self._experience

    @property
    def totals(self):
        return self._totals

    @property
    def perGame(self):
        return self._perGame

    @property
    def per36Minutes(self):
        return self._per36Minutes

    @property
    def per100Possessions(self):
        return self._per100Possessions

    @property
    def advanced(self):
        return self._advanced

    @property
    def salary(self):
        return self._salary

    @name.setter
    def name(self, name):
        print "setter getting called"
        self._name = name

    @active.setter
    def active(self, active):
        if active is not True or active is not False:
            print "Warning: active is set to false by default"
            active = False
        self._active = active

    @url.setter
    def url(self, url):
        self._url = url

    @fromYear.setter
    def fromYear(self, fromYear):
        self._fromYear = fromYear

    @toYear.setter
    def toYear(self, toYear):
        self._toYear = toYear

    @position.setter
    def position(self, position):
        self._position =  position

    @height.setter
    def height(self, height):
        self._height = height

    @weight.setter
    def weight(self, weight):
        self._weight = weight

    @dob.setter
    def dob(self, dob):
        self._dob = dob

    @college.setter
    def college(self, college):
        self._college = college

    @shootingHand.setter
    def shootingHand(self, shootingHand):
        self._shootingHand = shootingHand

    @experience.setter
    def experience(self, experience):
        self._experience = experience

    @totals.setter
    def totals(self, totals):
        self._totals = totals

    @perGame.setter
    def perGame(self, perGame):
        return self._perGame

    @per36Minutes.setter
    def per36Minutes(self, per36Minutes):
        self._per36Minutes = per36Minutes

    @per100Possessions.setter
    def per100Possessions(self, per100Possessions):
        self._per100Possessions = per100Possessions

    @advanced.setter
    def adnvanced(self, advanced):
        self._advanced = advanced

    @salary.setter
    def salary(self, salary):
        self._salary = salary