package lang.jimple.internal.generated;

import lang.jimple.internal.JimpleAbstractDataType; 
import java.util.List; 

import lombok.*; 

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IList;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory; 

@Builder
@EqualsAndHashCode
public  class Method extends JimpleAbstractDataType {
   @Override 
   public String getBaseType() { 
     return "Method";
   } 

   
     
      
       public List<Modifier> modifiers;
      
       public Type returnType;
      
       public String name;
      
       public List<Type> formals;
      
       public List<Type> exceptions;
      
       public MethodBody body;
      
     
      public static Method method(List<Modifier> modifiers, Type returnType, String name, List<Type> formals, List<Type> exceptions, MethodBody body)  {
        return new Method(modifiers, returnType, name, formals, exceptions, body);
      }
      
        public Method(List<Modifier> modifiers, Type returnType, String name, List<Type> formals, List<Type> exceptions, MethodBody body) {
         
           this.modifiers = modifiers;  
         
           this.returnType = returnType;  
         
           this.name = name;  
         
           this.formals = formals;  
         
           this.exceptions = exceptions;  
         
           this.body = body;  
           
        } 
      @Override
      public IConstructor createVallangInstance(IValueFactory vf) {
      
        
          IList iv_modifiers = vf.list();
          
          for(Modifier v: modifiers) {
           iv_modifiers = iv_modifiers.append(v.createVallangInstance(vf));   
          }
                  
        
          IValue iv_returnType = returnType.createVallangInstance(vf);
        
          IValue iv_name = vf.string(name);
        
          IList iv_formals = vf.list();
          
          for(Type v: formals) {
           iv_formals = iv_formals.append(v.createVallangInstance(vf));   
          }
                  
        
          IList iv_exceptions = vf.list();
          
          for(Type v: exceptions) {
           iv_exceptions = iv_exceptions.append(v.createVallangInstance(vf));   
          }
                  
        
          IValue iv_body = body.createVallangInstance(vf);
        
          
        return vf.constructor(getVallangConstructor()
                 
                 , iv_modifiers 
                
                 , iv_returnType 
                
                 , iv_name 
                
                 , iv_formals 
                
                 , iv_exceptions 
                
                 , iv_body 
                
                 ); 
      }
     
     
      @Override
      public io.usethesource.vallang.type.Type[] children() {
        return new io.usethesource.vallang.type.Type[] { 
            tf.listType(), returnType.getVallangConstructor(), tf.stringType(), tf.listType(), tf.listType(), body.getVallangConstructor()
        };
      } 
     
      @Override
      public String getConstructor() {
         return "method";
      }
       
                                  
    
}