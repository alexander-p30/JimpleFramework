module TestPrettyPrinter


import lang::jimple::toolkit::PrettyPrinter;
import lang::jimple::Syntax;
import lang::jimple::core::Context;
import lang::jimple::Decompiler;
import IO;



test bool testClassDecl() {
	
	f1 = field([Public()], TBoolean(), "flag");
	f2 = field([Private()], TCharacter(), "msg");	
	class1 = classDecl(TObject("samples.MyArrayListTest"), [Public(), Static()], TObject("java.util.List"), [], [f1,f2], []);
	class2 = classDecl(TObject("samples.MyObjectTest"), [Private(), Static()], object(), [], [], []);
	class3 = classDecl(TObject("samples.MyObjectTest"), [Private(), Static()], object(), [TObject("java.util.ArrayList")], [], []);	
//	writeFile(|file:///tmp/class1.jimple|, prettyPrint(class1));
//	writeFile(|file:///tmp/class2.jimple|, prettyPrint(class2));
//	writeFile(|file:///tmp/class3.jimple|, prettyPrint(class3));
		
	return ((prettyPrint(class1) != "error" || prettyPrint(class2) != "error"));
}

test bool testInterfaceDecl() {
	inf1 = interfaceDecl(TObject("samples.IObject"), [Private(), Static()], [object(), TObject("java.lang.ArrayList")], [], []);
	inf2 = interfaceDecl(TObject("samples.IObject"), [Public(), Final()], [object()], [], []);
	//writeFile(|file:///tmp/inf1.jimple|, prettyPrint(inf1));
	//writeFile(|file:///tmp/inf2.jimple|, prettyPrint(inf2));	
	return ((prettyPrint(inf1) != "error" || prettyPrint(inf2) != "error"));	
}

test bool testClassWithFields() {
	x = decompile(|project://JimpleFramework/target/test-classes/samples/ClassWithFields.class|);
	//writeFile(|file:///tmp/class4.jimple|, prettyPrint(x));		
	return true;
}