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

        """
    return pattern