import whiley.lang.System
import whiley.lang.Any
import nat from whiley.lang.Int
import string from whiley.lang.ASCII
import char from whiley.lang.ASCII

// Represents a transition from one 
// state to another for a given character.
type Transition is {
    int from,
    int to,
    char character
} where 
    from >= 0 && to >= 0 &&
    from < to

// A Finite State Machine representation of a Trie
type Trie is {
    [Transition] transitions
} 

// Define the Empty Trie
constant EmptyTrie is { transitions: [] }

// Add a complete string into a Trie starting from the root node.
function add(Trie trie, string str) -> Trie:
    return add(trie,0,str)

// Add a string into a Trie from a given state, producing an 
// updated Trie.
function add(Trie trie, int state, string str) -> Trie
requires state >= 0:
    //
    if |str| == 0:
        return trie
    else:
        //
        // Check whether transition exists for first 
        // character of str already.
        char c = str[0]
        int i = 0
        //
        while i < |trie.transitions| where i >= 0:
            Transition t = trie.transitions[i]
            if t.from == state && t.character == c:
                // Yes, existing transition for character
                return add(trie,t.to,str[1..])
            i = i + 1
        // 
        // No existing transition, so make a new one.
        int target = |trie.transitions| + 1
        Transition t = { from: state, to: target, character: c }
        trie.transitions = trie.transitions ++ [t]
        return add(trie,target,str[1..])

// Check whether a given string is contained in the trie, 
// starting from the root state.
function contains(Trie trie, string str) -> bool:        
    return contains(trie,0,str)

// Check whether a given string is contained in the trie, 
// starting from a given state.
function contains(Trie trie, int state, string str) -> bool
requires state >= 0:
    //
    if |str| == 0:
        return true
    else:
        // Check whether transition exists for first 
        // character of str.
        char c = str[0]
        int i = 0
        //
        while i < |trie.transitions| where i >= 0:
            Transition t = trie.transitions[i]
            if t.from == state && t.character == c:
                // Yes, existing transition for character
                return contains(trie,t.to,str[1..])
            i = i + 1
        //
        return false
    
method main(System.Console console):
    Trie t = EmptyTrie
    [string] inputs = ["hello","world","help"]
    // First, initialise trie    
    nat i = 0
    while i < |inputs|:
        console.out.println_s("ADDING: " ++ inputs[i])
        t = add(t,inputs[i])   
        i = i + 1
    // Second, check containment
    [string] checks = ["hello","blah","hel","dave"]
    i = 0 
    while i < |checks|:
        bool r = contains(t,checks[i])
        console.out.println_s("CONTAINS: " ++ checks[i] ++ " = " ++ Any.toString(r))
        i = i + 1
    