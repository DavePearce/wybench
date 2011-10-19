import * from whiley.lang.System
import * from whiley.lang.*
import * from ClassFile
import * from CodeAttr
import * from whiley.io.File

void ::main(System sys, [string] args):
    if |args| == 0:
        sys.out.println("usage: jasm [options] file(s)")
        return
    file = File.Reader(args[0])
    contents = file.read()
    //cf = ClassFileReader.readClassFile(contents)
    cf = JasmFileReader.read(String.fromASCII(contents))
    JasmFileWriter.print(sys,cf)
    bytes = ClassFileWriter.write(cf)
    file = File.Writer("jasm.out")
    file.write(bytes)
    debug "GOT HERE"        

