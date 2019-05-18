import std::ascii
import std::filesystem
import std::io

import wybench::parser

type nat is (int x) where x >= 0

// ========================================================
// Benchmark
// ========================================================

function average(int[] data) -> int
// Input list cannot be empty
requires |data| > 0:
    //
    int sum = 0
    nat i = 0
    while i < |data|:
        sum = sum + data[i]
        i = i + 1
    return sum / |data|

// ========================================================
// Main
// ========================================================

method main(ascii::string[] args):
    if |args| == 0:
        io::println("usage: average <file>")
    else:
        // first, read the input data
        filesystem::File file = filesystem::open(args[0],filesystem::READONLY)
        ascii::string input = ascii::from_bytes(file.read_all())
        int[]|null data = parser::parseInts(input)
        // second, run the benchmark
        if data is null:
            io::println("error parsing input")
        else if |data| == 0:
            io::println("no data provided!")
        else:
            int avg = average(data)
            io::println(avg)
