module lang::jimple::toolkit::PrettyPrinter

import lang::jimple::Syntax;
import lang::jimple::core::Context; 

/* 
	Modifiers 
*/
str prettyPrint(Modifier::Public()) = "public";
str prettyPrint(Modifier::Protected()) = "protected";
str prettyPrint(Modifier::Private()) = "private";
str prettyPrint(Modifier::Abstract()) = "abstract";
str prettyPrint(Modifier::Static()) = "static";
str prettyPrint(Modifier::Final()) = "final";
str prettyPrint(Modifier::Strictfp()) = "strictfp";
str prettyPrint(Modifier::Native()) = "native";
str prettyPrint(Modifier::Synchronized()) = "synchronized";
str prettyPrint(Modifier::Transient()) = "transient";
str prettyPrint(Modifier::Volatile()) =  "volatile";
str prettyPrint(Modifier::Enum()) =  "enum";
str prettyPrint(Modifier::Annotation()) =  "annotation";

/* 
	Types 
*/
str prettyPrint(Type::TByte()) = "byte";
str prettyPrint(Type::TBoolean()) = "boolean";
str prettyPrint(Type::TShort()) = "short";
str prettyPrint(Type::TCharacter()) = "char";
str prettyPrint(Type::TInteger()) = "int";
str prettyPrint(Type::TFloat()) = "float";
str prettyPrint(Type::TDouble()) = "double";
str prettyPrint(Type::TLong()) = "long";
str prettyPrint(Type::TObject(name)) = name;
str prettyPrint(TArray(baseType)) = "<prettyPrint(baseType)>[]"; 
str prettyPrint(Type::TVoid()) = "void";

/* 
 * Statements
 */
str prettyPrint(Statement::breakpoint()) = "breakpoint";
str prettyPrint(Statement::gotoStmt(Label target)) = "goto <target>";
str prettyPrint(Statement::label(Label label)) = "<label>";
str prettyPrint(Statement::returnEmptyStmt()) = "return";
str prettyPrint(Statement::nop()) = "nop";

/* 
 * Expression
 */
str prettyPrint(Expression::newInstance(Type instanceType)) = "new <prettyPrint(instanceType)>";

/* 
 * Value
 */

/* 
	Functions for printing ClassOrInterfaceDeclaration and its
	related upper parts.
*/
public str prettyPrint(list[Modifier] modifiers) {
  str text = "";
  switch(modifiers) {
    case [] :  text = ""; 
    case [v] : text = prettyPrint(v); 
    case [v, *vs] : text = prettyPrint(v) + " " + prettyPrint(vs);
  }
  return text;
}

public str prettyPrint(list[Type] interfaces, str n) {
  str text = "";
  switch(interfaces) {
    case [] :  text = ""; 
    case [v] : text = n + prettyPrint(v); 
    case [v, *vs] : text = n + prettyPrint(v) + ", " + prettyPrint(vs, n);
  }
  return text;
}

public str prettyPrint(Field f: field(modifiers, fieldType, name)) = 	
	"<prettyPrint(modifiers)> <prettyPrint(fieldType)> <name>;";

public str prettyPrint(list[Field] fields) =
	"<for(f <- fields) {>
	'    <prettyPrint(f)><}>";

public str prettyPrint(Method m: method(modifiers, returnType, name, formals, exceptions, body)) =
	"<prettyPrint(modifiers)> <prettyPrint(returnType)> <name>(<prettyPrint(formals,"")>) <prettyPrint(exceptions,"throws")>
	'{
	'}
	'
	";

public str prettyPrint(list[Method] methods) =
	"<for(m <- methods) {>
	'    <prettyPrint(m)><}>";


public str prettyPrint(ClassOrInterfaceDeclaration unit) {
  switch(unit) {
    case classDecl(name,ms,super,infs,fields,methods): 
    	return 
			"<prettyPrint(ms)> class <prettyPrint(name)> extends <prettyPrint(super)> <prettyPrint(infs, "implements")>
    		'{ 
    		'<prettyPrint(fields)>
    		'
    		'<prettyPrint(methods)>
			'}";
    case interfaceDecl(name,ms,infs,fields,methods):
    	return
			"<prettyPrint(ms)> interface <prettyPrint(name)> extends <prettyPrint(infs,"")>
			'{
        	'<prettyPrint(fields)>
       		'
       		'<prettyPrint(methods)>   			
			'}";    	 
    default: return "error";
  }   
}

/*
	Class or interface format:
		modifiers "class" typeName "extends" superClass  | "implements" interfaces | { }
		modifiers "interface" typeName "extends" superClass { }	
	Example code:
		rascal>ClassOrInterfaceDeclaration x = classDecl(TObject("samples.Test"), [Public()], TObject("java.util.List"), [], [], []);
		rascal>prettyPrint(x);
*/

