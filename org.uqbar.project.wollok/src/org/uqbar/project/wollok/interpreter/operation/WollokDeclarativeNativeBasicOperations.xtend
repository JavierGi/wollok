package org.uqbar.project.wollok.interpreter.operation

import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import org.uqbar.project.wollok.interpreter.core.LazyWollokObject
import org.uqbar.project.wollok.interpreter.WollokInterpreter

/**
 * WollokBasicBinaryOperations implementations which includes native
 * code for all binary operations, but it also delegates as a regular method
 * call to WollokObjects. This allows you operator overloading in your own objects.
 * 
 * Also this implementations is "declarative", since it uses reflection
 * to look for a method annotation with BinaryOperation("..") which indicates
 * which operator does it implements (as a string in grammar).
 * 
 * On top of that, the operations are implemented as multiple dispatch methods.
 * Allowing to have different behaviors based on the parameter types.
 * 
 * @author jfernandes
 */
// I18N !
class WollokDeclarativeNativeBasicOperations implements WollokBasicBinaryOperations {
		
	override asBinaryOperation(String operationSymbol) {
		val op = class.methods.findFirst[hasAnnotationForOperation(operationSymbol)]
		if (op != null) {
			[a, b| 
				try {
					op.invoke(this, a, b).javaToWollok
				}
				catch(InvocationTargetException e) {
					if (e.cause instanceof WollokProgramExceptionWrapper)
						throw e.cause
					else
						throw new WollokRuntimeException('''Error while resolving «a» «operationSymbol» «b»''', e.cause)
				}
			]
		}
		else
			[a, b | 
				a.call(operationSymbol, b.apply)
			]
	}
	
	def hasAnnotationForOperation(Method m, String op) {
		m.isAnnotationPresent(BinaryOperation) && m.getAnnotation(BinaryOperation).value == op
	}
	
	// ********************************************************************************************
	// ** Math
	// ********************************************************************************************
	
	@BinaryOperation('+') // needed 2 methods: 1st for the annotation, then the multi-dispatch
	def WollokObject sumOperation(WollokObject a, ()=>WollokObject e) {
		val b = e.apply;
		if (a == null) b 
		else if (b == null) a
		else sum(a, b)
	}  
	def sum(WollokObject a, WollokObject b) { a.call("+", b) }
	
	def zero(WollokObject nonNull) { minusOperation(nonNull, [nonNull]) }
	
	@BinaryOperation('-')	
	def WollokObject minusOperation(WollokObject a, ()=>WollokObject eb) {
		val b = eb.apply
		if (a == null) { 
			if (b != null) b.zero.call("-", b)
			else null
		}
		else if (b == null) a
		else a.call("-", b)
	}
	
	@BinaryOperation('*')  
	def multiplyOperation(WollokObject a, ()=>WollokObject eb) { 
		val b = eb.apply
		if (a == null || b == null) null
		else a.call("*", b)
	}
	
	// ********************************************************************************************
	// ** Booleans
	// ********************************************************************************************	
	
	@BinaryOperation('&&')
	//TODO: hack we are sending the xtend closure here to the wollok object for shortcircuit
	//   the WBoolean implementation. If someone overloads the && message he will receive this 
	//   non-wollok object. I think that we should send a WollokClosure
	//   or have some language-level construction for "lazy" parameters
	def andOperation(WollokObject a, ()=>WollokObject b) { a.call("&&", b.lazyObject ) }
	
	def WollokObject getLazyObject(()=>WollokObject closure) { new LazyWollokObject(interpreter, null, closure) }
	def getInterpreter() { WollokInterpreter.getInstance }
	
	@BinaryOperation('and')	
	def andPhrase(WollokObject a, ()=>WollokObject b) { andOperation(a, b) }
	
	@BinaryOperation('||')
	def orOperation(WollokObject a, ()=>WollokObject b) { a.call("||", b.lazyObject) }
	@BinaryOperation('or')	
	def orPhrase(WollokObject a, ()=>WollokObject b) { orOperation(a, b) }

	@BinaryOperation('==')
	def equalsOperation(WollokObject a, ()=>WollokObject eb) {
		val b = eb.apply 
		if (bothNull(a,b)) evaluator.theTrue		// Two nulls => they are equal
		else if (noneAreNull(a,b)) a.call("==", b) 	// Two not nulls => they can handle => dispatch
		else evaluator.theFalse						// Only one is null => they aren't equal
	}
	
	@BinaryOperation('!=')
	def notEqualsOperation(WollokObject a, ()=>WollokObject eb) {
		val b = eb.apply
		if  (bothNull(a,b)) evaluator.theFalse  				// Two nulls => they are equal => false
		else if (noneAreNull(a,b)) a.call("!=", b)	// Two not nulls => they can handle => dispatch
		else evaluator.theTrue 								// Only one is null => they aren't equal
	}	

}