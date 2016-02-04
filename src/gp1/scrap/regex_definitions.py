def reGetAllTrInListPage():
    """
    return the regex to get all the trs in the player list page
    :return: regex
    """
    pattern = r"""
       <tbody>
        (.*)            #Grab anything and everything between tbody
       </tbody>
       """
    return pattern

def reGetInnerHtmlWithinATrInListPage():
    """
        Given a string with a list of trs this return a regex
        that returns all the tds within that
    :return: regex
    """
    pattern = r"""
        <tr\s*class="">
        (.*?)               #Grab everything within the <tr></tr> tags
        </tr>
    """
    return pattern

def reGetTdsWithinTrInListPage():
    """
    <tr><td></td></tr>
    This helps to get all the tds
    :return: regex
    """
    pattern = """
        <td.*?>             # This signifies the beginning of the td tag
        (.*?)               #Grab everything between teh td tag
        </td>               #end of the <td> tag
        """
    return pattern

def reGetIsStrongthere():
    """
    some td has <strong> tags inside them indicating active player
    :return:regex
    """
    pattern = """
        <strong>
        (.*?)
        </strong>
        """
    return pattern

def reGetInnerHtmlAnchorTag():
    """
    This returns
     a) href attribute of an anchor tag
     b) inner html of an anchor tag
    :return:
    """
    pattern = """
        <a\s*href="(.*?)">
        (.*?)
        </a>
        """
    return pattern

def reGetProperDoBFromHref():
    """
        The anchor tag in the dob tag has month and day
        we need to extract that
    :return: regex
    """
    pattern = r"""
        ^\D*					#This can start with anything
        month=(\d{1,2})			# month needs to have either 1 or two digits
        .*?
        day=(\d{1,2})			# Day has to be a digit with either 1 or 2 digits
    """
    return pattern