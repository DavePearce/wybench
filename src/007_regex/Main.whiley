import whiley.lang.*
import whiley.lang.System
import whiley.io.File

import wybench.Parser

import char from whiley.lang.ASCII
import string from whiley.lang.ASCII

// match: search for regexp anywhere in text
function match(string regex,string text) -> bool:
    if |regex| > 0 && regex[0] == '^':
        return matchHere(regex[1..],text)
    if matchHere(regex,text):
        return true
    while |text| > 0:
        if matchHere(regex,text):
            return true
        else:
            text = text[1..]
    return false

// matchHere: search for regex at beginning of text
function matchHere(string regex, string text) -> bool:
    if |regex| == 0:
        return true
    else if |regex| > 1 && regex[1] == '*':
        return matchStar(regex[0],regex[2..],text)
    else if |regex| == 1 && regex[0] == '$':
        return |text| == 0
    else if |text| > 0 && (regex[0]=='.' || regex[0] == text[0]):
        return matchHere(regex[1..],text[1..])
    else:
        return false

// matchstar: search for c*regex at beginning of text
function matchStar(char c, string regex, string text) -> bool:
    // first, check for zero matches
    if matchHere(regex,text):
        return true
    // second, check for one or more matches
    while |text| != 0 && (text[0] == c || c == '.'):
        if matchHere(regex,text):    
            return true
        else:
            text = text[1..]
    if matchHere(regex,text):
        return true
    return false

public method main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println_s("usage: regex <input-file>")
    else:
        File.Reader file = File.Reader(sys.args[0])
        string input = ASCII.fromBytes(file.readAll())
        [string] data = Parser.parseStrings(input)
        int i = 0
        int nmatches = 0
        int total = 0
        while (i+1) < |data| where i >= 0:
            string text = data[i]
            string regex = data[i+1]
            if match(regex,text):
                nmatches = nmatches + 1
            total = total + 1
            i = i + 2
        //
        sys.out.println_s("Matched " ++ Int.toString(nmatches) ++ " / " ++ Int.toString(total) ++ " inputs.")
