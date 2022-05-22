module lang::jimple::tests::TestPrettyPrinter

import lang::jimple::core::Syntax;
import lang::jimple::core::Context;
import lang::jimple::decompiler::Decompiler;
import lang::jimple::toolkit::BasicMetrics;
import lang::jimple::toolkit::PrettyPrinter;
import lang::jimple::util::JPrettyPrinter; 

import IO;

test bool testField() {
	f1 = field([Public()], TBoolean(), "flag");
	assert prettyPrint(f1) == "public boolean flag;";

	f2 = field([Private()], TCharacter(), "msg");
	assert prettyPrint(f2) == "private char msg;";
	
	return true;	
}

test bool myTest() {
	loc demo = |project://JimpleFramework/target/classes/demo/Vanilla.class|;
	writeFile(|file:///tmp/vanilla_decompile.jimple|, prettyPrint(decompile(demo)));
}

test bool testClassDecl() {
	
	f1 = field([Public()], TBoolean(), "flag");			
	f2 = field([Private()], TCharacter(), "msg");
	class1 = classDecl(TObject("samples.MyArrayListTest"), [Public(), Static()], TObject("java.util.List"), [], [f1,f2], []);
	class2 = classDecl(TObject("samples.MyObjectTest"), [Private(), Static()], object(), [], [], []);
	class3 = classDecl(TObject("samples.MyObjectTest"), [Private(), Static()], object(), [TObject("java.util.ArrayList")], [], []);
	assert prettyPrint(class1) != "error";
	assert prettyPrint(class2) != "error";
	assert prettyPrint(class3) != "error";
	
	//TODO: compare generated file with file generated by soot	
	writeFile(|file:///tmp/class1.jimple|, prettyPrint(class1));
	writeFile(|file:///tmp/class2.jimple|, prettyPrint(class2));
	writeFile(|file:///tmp/class3.jimple|, prettyPrint(class3));
		
	return true;
}

test bool testInterfaceDecl() {
	inf1 = interfaceDecl(TObject("samples.IObject"), [Private(), Static()], [object(), TObject("java.lang.ArrayList")], [], []);
	inf2 = interfaceDecl(TObject("samples.IObject"), [Public(), Final()], [object()], [], []);
	assert prettyPrint(inf1) != "error";
	assert prettyPrint(inf2) != "error";
	
	//TODO: compare generated file with file generated by soot	
	writeFile(|file:///tmp/inf1.jimple|, prettyPrint(inf1));
	writeFile(|file:///tmp/inf2.jimple|, prettyPrint(inf2));	
	return true;	
}

test bool testClassWithFields() {
	x = decompile(|project://JimpleFramework/target/test-classes/samples/AbstractClassSample.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/AbstractClassSample.jimple|, prettyPrint(x));
		
	x = decompile(|project://JimpleFramework/target/test-classes/samples/AutoIncrementSample.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/AutoIncrementSample.jimple|, prettyPrint(x));

	x = decompile(|project://JimpleFramework/target/test-classes/samples/InterfaceSample.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/InterfaceSample.jimple|, prettyPrint(x));		

	x = decompile(|project://JimpleFramework/target/test-classes/samples/LongValueSample.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/LongValueSample.jimple|, prettyPrint(x));		

	x = decompile(|project://JimpleFramework/target/test-classes/samples/WhileStmtSample.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/WhileStmtSample.jimple|, prettyPrint(x));		

	x = decompile(|project://JimpleFramework/target/test-classes/samples/ControlStatements.class|);
	//TODO: compare generated file with file generated by soot		
	writeFile(|file:///tmp/ControlStatements.jimple|, prettyPrint(x));		
		
	return true;
}

test bool testClassWithMethod() {
	x = decompile(|project://JimpleFramework/target/test-classes/slf4j/org/slf4j/helpers/MessageFormatter.class|);
	//TODO: compare generated file with file generated by soot
	writeFile(|file:///tmp/MessageFormatter.jimple|, prettyPrint(x));
		
	return true;
}

test bool testProcessAllFiles() {
	list[str] es = [];
	x = execute([|project://JimpleFramework/target/test-classes/samples/|], es, Analysis(PrettyPrint));		
	for(k <- x) {
		println(k);
		writeFile(|file:///tmp/jimpleframework/<k>.jimple|, x[k]);		
	}
	return true;
}
