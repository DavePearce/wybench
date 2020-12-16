import std::array
import std::ascii
import std::io

type nat is (int n) where n >= 0

/**
 * Define coins/notes and their values (in cents)
 */
nat ONE_CENT = 0
nat FIVE_CENTS = 1
nat TEN_CENTS = 2
nat TWENTY_CENTS = 3
nat FIFTY_CENTS = 4
nat ONE_DOLLAR = 5  // 1 dollar
nat FIVE_DOLLARS = 6  // 5 dollars
nat TEN_DOLLARS = 7 // 10 dollars

nat[] Value = [
    1,
    5,
    10,
    20,
    50,
    100,
    500,
    1000
]

/**
 * Define the notion of cash as an array of coins / notes
 */
type Cash is (nat[] ns) where |ns| == |Value|

function Cash() -> Cash:
    return [0,0,0,0,0,0,0,0]

function Cash(nat[] coins) -> Cash
// No coin in coins larger than permitted values
requires all { i in 0..|coins| | coins[i] < |Value| }:
    Cash cash = [0,0,0,0,0,0,0,0]
    nat i = 0
    while i < |coins| 
        where |cash| == |Value| && all {k in 0..|cash| | cash[k] >= 0}:
        nat coin = coins[i]
        cash[coin] = cash[coin] + 1
        i = i + 1
    return cash

/**
 * Given some cash, compute its total
 */ 
function total(Cash c) -> int:
    int r = 0
    nat i = 0
    while i < |c|:
        r = r + (Value[i] * c[i])
        i = i + 1
    return r

/**
 * Checks that a second load of cash is stored entirely within the first.
 * In other words, if we remove the second from the first then we do not
 * get any negative amounts.
 */
function contained(Cash first, Cash second) -> bool:
    nat i = 0
    while i < |first|:
        if first[i] < second[i]:
            return false
        i = i + 1
    return true

/**
 * Adds two bits of cash together
 *
 * ENSURES: the total returned equals total of first plus
 *          the total of the second.
 */
function add(Cash first, Cash second) -> (Cash r)
// Result total must be sum of argument totals
ensures total(r) == total(first) + total(second):
    //
    nat i = 0
    //
    while i < |first|:
        assert first[i] >= 0
        first[i] = first[i] + second[i]
        i = i + 1
    //
    return first

/**
 * Subtracts from first bit of cash a second bit of cash.
 *
 * REQUIRES: second cash is contained in first.
 *
 * ENSURES: the total returned equals total of first less
 *          the total of the second.
 */
function subtract(Cash first, Cash second) -> (Cash r)
// First argument must contain second; for example, if we have 1
// dollar coin and a 1 cent coin, we cannot subtract a 5 dollar note!
requires contained(first,second)
// Total returned must total of first argument less second
ensures total(r) == total(first) - total(second):
    //
    int i = 0
    while i < |first|:
        first[i] = first[i] - second[i]
        i = i + 1
    //
    return first

/**
 * Determine the change to be returned to a customer from a given cash
 * till, assuming a certain cost for the item and the cash that was
 * actually given.  Observe that the specification for this method does 
 * not dictate how the change is to be computed --- only that it must 
 * have certain properties.  Finally, if exact change cannot be given 
 * from the till then null is returned.
 *
 * ENSURES:  if change returned, then it must be contained in till, and 
 *           the amount returned must equal the amount requested.
 */
function calculateChange(Cash till, nat change) -> (null|Cash r)
// If change is given, then it must have been in the till, and must
// equal that requested.
ensures r is Cash ==> (contained(till,r) && total(r) == change):
    //
    if change == 0:
        return Cash()
    else:
        // exhaustive search through all possible coins
        nat i = 0
        while i < |till|:
            if till[i] > 0 && Value[i] <= change:
                Cash tmp = till
                // temporarily take coin out of till
                tmp[i] = tmp[i] - 1 
                null|Cash chg = calculateChange(tmp,change - Value[i])
                if chg is Cash:
                    // we have enough change
                    chg[i] = chg[i] + 1
                    return chg
            i = i + 1
        // cannot give exact change :( 
        return null
/**
 * Print out cash in a friendly format
 */
function to_string(Cash c) -> ascii::string:
    ascii::string r = ""
    bool firstTime = true
    int i = 0
    while i < |c|:
        int amt = c[i]
        if amt != 0:
            if !firstTime:
                r = array::append(r,", ")
            firstTime = false
            r = array::append(r,ascii::to_string(amt))
            r = array::append(r," x ")
            r = array::append(r,Descriptions[i])
        i = i + 1
    if r == "":
        r = "(nothing)"
    return r
    
ascii::string[] Descriptions = [
    "1c",
    "5c",
    "10c",
    "20c",
    "50c",
    "$1",
    "$5",
    "$10"
]

/**
 * Run through the sequence of a customer attempting to purchase an item
 * of a specified cost using a given amount of cash and a current till.
 */
method buy(Cash till, Cash given, int cost) -> Cash:
    io::println("--")
    io::print("Customer wants to purchase item for ")
    io::print(ascii::to_string(cost))
    io::println("c.")
    io::print("Customer gives: ")
    io::println(to_string(given))
    if total(given) < cost:
        io::println("Customer has not given enough cash!")
    else:
        Cash|null change = calculateChange(till,total(given) - cost)
        if change is null:
            io::println("Cash till cannot give exact change!")
        else:
            io::print("Change given: ")
            io::println(to_string(change))
            till = add(till,given)
            till = subtract(till,change)
            io::print("Till: ")
            io::println(to_string(till))
    return till

/**
 * Test Harness
 */
public method main(ascii::string[] args):
    Cash till = [5,3,3,1,1,3,0,0]
    io::print("Till: ")
    io::println(to_string(till))
    // now, run through some sequences...
    till = buy(till,Cash([ONE_DOLLAR]),85)
    till = buy(till,Cash([ONE_DOLLAR]),105)
    till = buy(till,Cash([TEN_DOLLARS]),5)
    till = buy(till,Cash([FIVE_DOLLARS]),305)

