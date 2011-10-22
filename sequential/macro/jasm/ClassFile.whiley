import Bytecode from Bytecode

define ClassFile as {
    int minor_version,
    int major_version,
    {ClassModifier} modifiers,
    JvmType.Class type,
    JvmType.Class super,
    [JvmType.Class] interfaces,
    [FieldInfo] fields,
    [MethodInfo] methods
}

define FieldInfo as {
    {FieldModifier} modifiers,
    string name,
    JvmType.Any type,
    [AttributeInfo] attributes   
}

define MethodInfo as {
    {MethodModifier} modifiers,
    string name,
    JvmType.Fun type,
    [AttributeInfo] attributes   
}

define UnknownAttr as {
    string name,
    [byte] data
}

define TmpCodeAttr as {
    int maxStack,
    int maxLocals,
    [Bytecode] bytecodes
}

// The following is a hack, because we cannot properly define an
// unknown attribute.
define AttributeInfo as UnknownAttr | TmpCodeAttr

define ACC_PUBLIC as 0x0001
define ACC_PRIVATE as 0x0002
define ACC_PROTECTED as 0x0004
define ACC_STATIC as 0x0008
define ACC_FINAL as  0x0010
define ACC_SUPER as  0x0020
define ACC_SYNCHRONIZED as  0x0020
define ACC_VOLATILE as 0x0040
define ACC_BRIDGE as 0x0040
define ACC_TRANSIENT as 0x0080
define ACC_VARARGS as 0x0080
define ACC_NATIVE as 0x0100
define ACC_INTERFACE as 0x0200
define ACC_ABSTRACT as 0x0400
define ACC_STRICT as 0x0800
define ACC_SYNTHETIC as 0x1000
define ACC_ANNOTATION as 0x2000
define ACC_ENUM as 0x4000

define ClassModifier as {
    ACC_PUBLIC,
    ACC_FINAL,
    ACC_SUPER,
    ACC_INTERFACE,
    ACC_ABSTRACT,
    ACC_SYNTHETIC,
    ACC_ANNOTATION,
    ACC_ENUM
}

define FieldModifier as {
    ACC_PUBLIC, 
    ACC_PRIVATE,
    ACC_PROTECTED,
    ACC_STATIC,
    ACC_FINAL,
    ACC_VOLATILE,
    ACC_TRANSIENT,
    ACC_SYNTHETIC,
    ACC_ENUM
}

define MethodModifier as {
    ACC_PUBLIC, 
    ACC_PRIVATE,
    ACC_PROTECTED,
    ACC_STATIC,
    ACC_FINAL,
    ACC_SYNCHRONIZED,
    ACC_BRIDGE,
    ACC_VARARGS,
    ACC_NATIVE,
    ACC_ABSTRACT,
    ACC_STRICT,
    ACC_SYNTHETIC
}

// compute the constant pool for the given class
public [ConstantPool.Item] constantPool(ClassFile cf):
    pool = []
    //    pool = ConstantPool.add(pool,cf.type)
    return pool
