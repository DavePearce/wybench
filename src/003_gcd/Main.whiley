import whiley.lang.*
import * from whiley.lang.*
import * from whiley.io.File

define nat as int where $ >= 0

(nat,nat) parseInt(nat pos, string input) throws SyntaxError:
    start = pos
    while pos < |input| && Char.isDigit(input[pos]) where pos >= 0:
        pos = pos + 1
    if pos == start:
        throw SyntaxError("Missing number",start,pos)
    r = Math.abs(Int.parse(input[start..pos]))
    return r,pos

nat skipWhiteSpace(nat pos, string input):
    while pos < |input| && isWhiteSpace(input[pos]) where pos >= 0:
        pos = pos + 1
    return pos

nat gcd(nat a, nat b):
    if(a == 0):
        return b		   
    while(b != 0) where a >= 0:
        if(a > b):
            a = a - b
        else:
            b = b - a
    return a

void ::main(System.Console sys):
    if |sys.args| == 0:
        sys.out.println("usage: gcd <input-file>")
    else:
        file = File.Reader(sys.args[0])
        input = String.fromASCII(file.read())
        try:
            pos = 0
            data = []
            pos = skipWhiteSpace(pos,input)
            // first, read data
            while pos < |input| where all { d in data | d >= 0 } && pos >= 0:
                i,pos = parseInt(pos,input)
                data = data + [i]
                pos = skipWhiteSpace(pos,input)
            // second, compute gcds
            for i in 0..|data|:
                for j in i+1..|data|:
                    sys.out.println(gcd(data[i],data[j]))
        catch(SyntaxError e):
            sys.out.println("error - " + e.msg)

