package wollok.lang

import java.util.Collection
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WCallable
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * @author jfernandes
 */
class WCollection<T extends Collection> {
	@Accessors var T wrapped
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	def Object fold(WollokObject acc, WollokObject proc) {
		val c = proc.asClosure
		wrapped.fold(acc) [i, e|
			c.doApply(i, e)
		]
	}
	
	def void add(WollokObject e) { wrapped.add(e) }
	def void remove(WollokObject e) { 
		// This is necessary because native #contains does not take into account Wollok object equality 
		wrapped.remove(wrapped.findFirst[it.wollokEquals(e)])
	}
	def size() { wrapped.size }
	
	def void clear() { wrapped.clear }
	
	def join() { join(",") }
	
	def join(String separator) {
		wrapped.map[ if (it instanceof WCallable) call("toString") else toString ].join(separator)
	}
	
	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped == this.wrapped)		
	}
	
	@NativeMessage("==")
	def wollokEqualsEquals(WollokObject other) { wollokEquals(other) }
	
}