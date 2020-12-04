module lang::jimple::analysis::svfa::SparseValueFlowAnalysis


import lang::jimple::core::Context; 
import lang::jimple::core::Syntax; 
import lang::jimple::analysis::dataflow::ReachDefinition;
import lang::jimple::toolkit::ValueFlowGraph;
import lang::jimple::util::Converters; 

import List;
import IO;


data SVFAModel = SVFAModel(ValueFlowGraph cg);

data SVFARuntime = svfaRuntime(ExecutionContext ctx, ValueFlowNodeType (Statement) analyze);


public &T(ExecutionContext) generateSVFGraph(list[str] entrypoints, ValueFlowNodeType (Statement) analyze ){
	return SVFAModel(ExecutionContext ctx) { 
		println("cts");
		
		println("func=<analyze(label("teste"))>");
		
        return computeSVFGraph(ctx, entrypoints, analyze);
    }; 
}




SVFAModel computeSVFGraph(ExecutionContext ctx, list[str] entrypoints, ValueFlowNodeType (Statement) analyze) {	
	println("entrou .....");
	
	list[MethodSignature] methods = []; 		
	 
	// nao usa os entrypoints passados como parametro ainda ... apenas os definidos no ExecutionContext
	top-down visit(ctx) {
     	case classDecl(TObject(cn), _, _, _, _, mss): {
         	for(m: method(_,r,mn,args,_,_) <- mss) {
         		sig = signature(cn, mn, args); 
         		// if the method is an entry point (depending on the strategy specified)         		
         		if(ctx.mt[sig].entryPoint) {
         			// add method to the entry points list
         			methods = methods + methodSignature(cn, r, mn, args);
         		}
            }             
      	}
  	} 

	SVFARuntime rt = svfaRuntime(ctx, analyze);
	
	return computeSVFGraph(methods, rt);
}

private SVFAModel computeSVFGraph(list[MethodSignature] methodsList, SVFARuntime rt) {
	println("computeSVFGraph");
		
	while(!isEmpty(methodsList)){	
		MethodSignature currentMethod = head(methodsList);
		methodsList = drop(1,methodsList);	
		
		traverse(currentMethod, rt);
	}
	
	return SVFAModel({});
}

private void traverse(MethodSignature method, SVFARuntime rt) {
	str currentMethod = signature(method.className, method.methodName, method.formals);
	println("\n\ncurrentMethod=<currentMethod>");
	
	top-down visit(rt.ctx.mt[currentMethod].method.body.stmts) {	 	
  		case a: assign(Variable var, Expression expression): {
  			println("* ASSIGN ==== var=<var> ... expr=<expression>");
  			traverse(a, method, rt);
  		}  
  		case i: invokeStmt(InvokeExp invokeExpression):{
  			println("* INVOKE ==== <invokeExpression>");
  			traverse(i, method, rt);
  			//TODO adicionar o metodo q eh chamado na lista de metodos
  		}	
  		//TODO
  		//case _ if(analyze(unit) == SinkNode) => traverseSinkStatement(v, method, defs)
    	//case _ =>	  		
	}
}
private void traverse(stmt: assign(_, immediate(Immediate i)), MethodSignature method, SVFARuntime rt){
	println("\timmediate= <i>");	
	copyRule(i, stmt, method, rt);
}
private void traverse(stmt: assign(_, invokeExp(expr)), MethodSignature method, SVFARuntime rt){
	println("\tinvokeExpr <expr>");
	traverse(invokeStmt(expr), method, rt);
}
private void traverse(stmt: assign(_, localFieldRef(Name local, _, _, _)), MethodSignature method, SVFARuntime rt){
	println("\tlocalFieldRef= <local>");	
	loadRule();
}
private void traverse(stmt: assign(_, fieldRef(Name className, _, _)), MethodSignature method, SVFARuntime rt){
	println("\tfieldRef= <className>");	
	loadRule();
}
private void traverse(stmt: assign(_, Expression expression), MethodSignature method, SVFARuntime rt) {
	switch(expression){		
		case arraySubscript(n, i):        println("\tarraySubscript <n>");
		case stringSubscript(n, i):       println("\tstringSubscript <n>");
		case newArray(t, _):              println("\tnewArray <t>");
		case newInstance(t):              println("\tnewInstance <t>");
		default: println("\t***** DEFAULT=<expression>");
	}
}

private void traverse(stmt: invokeStmt(_), MethodSignature method, SVFARuntime rt) = invokeRule(stmt, method, rt);

private void traverse(Statement stmt, MethodSignature method, SVFARuntime rt){
	if(sinkNode() == rt.analyze(stmt)){
		traverseSinkStatement();
	}
}

private void traverseSinkStatement(){
	println("\t **** traverseSinkStatement ...");
}



private void copyRule(Immediate local, Statement targetStmt, MethodSignature method, SVFARuntime rt){
	println("\t\t **** COPY_RULE ...");
	for(sourceStmt <- getDefsOfAt(local, targetStmt)){
		source = createNode(method, sourceStmt, rt);
      	target = createNode(method, targetStmt, rt);
      	println("\t\t **** COPY_RULE: <source> TO <target>");
	}
}

private void loadRule(){	
	println("\t\t **** LOAD_RULE ...");
}

private void invokeRule(stmt: invokeStmt(InvokeExp expr), MethodSignature method, SVFARuntime rt){
	println("\t\t **** INVOKE_RULE ...");
	switch(rt.analyze(stmt)){
		case sourceNode(): println("\t\t ******* sourceNode");
		case sinkNode(): println("\t\t ******* sinkNode");
		case simpleNode(): println("\t\t ******* simpleNode");
		case callSiteNode(): println("\t\t ******* callSiteNode");
		default: println("********* ERRO *********");
	}
}



private list[Statement] getDefsOfAt(Immediate local, Statement stmt) {
	//TODO implementar
	return [];
}


private ValueFlowNode createNode(MethodSignature method, Statement stmt, SVFARuntime rt) {	
	return valueFlowNode(method.className, method.methodName, stmt, rt.analyze(stmt));
}

private list[ValueFlowNode] findAllocationSites() {
    return [];
}



private void createCSOpenLabel(){}


private void createCSCloseLabel(){}

