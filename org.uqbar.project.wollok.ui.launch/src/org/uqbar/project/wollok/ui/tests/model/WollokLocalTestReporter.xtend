package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Inject
import java.io.PrintWriter
import java.io.StringWriter
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.launch.tests.WollokTestInfo
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * WollokTestReporter implementation that sends the event to a remote
 * WollokRemoteUITestNotifier instance.
 * 
 * It uses RMI to communicate with another process (the UI)
 * 
 * @author tesonep
 */
class WollokLocalTestReporter implements WollokTestsReporter { 

	var WollokRemoteUITestNotifier remoteTestNotifier

	@Inject
	def init() {
		remoteTestNotifier = new WollokTestResults
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		remoteTestNotifier.assertError(test.name, assertionError, lineNumber, resource.toString)
	}

	override reportTestOk(WTest test) {
		remoteTestNotifier.testOk(test.name)
	}

	override testsToRun(WFile file, List<WTest> tests) {
		remoteTestNotifier.testsToRun(file.eResource.URI.toString, new ArrayList(tests.map[new WollokTestInfo(it)]))
	}

	override testStart(WTest test) {
		remoteTestNotifier.testStart(test.name)
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		remoteTestNotifier.error(test.name, exception.convertToString, lineNumber, resource?.toString)
	}
	
	def dispatch String convertToString(Exception exception) {
		val sw = new StringWriter
        exception.printStackTrace(new PrintWriter(sw))
        sw.toString  
	}
	
	def dispatch String convertToString(WollokProgramExceptionWrapper exception) {
		exception.wollokException.call("getStackTraceAsString").wollokToJava(String) as String
	}

	def dispatch void prepareExceptionForTrip(Throwable e) {
		if (e.cause != null)
			e.cause.prepareExceptionForTrip
	}
	
	def dispatch void prepareExceptionForTrip(WollokInterpreterException e) {
		e.sourceElement = null

		if (e.cause != null)
			e.cause.prepareExceptionForTrip
	}
	
	def dispatch void prepareExceptionForTrip(WollokProgramExceptionWrapper e) {
		e.URI = null
		if (e.cause != null)
			e.cause.prepareExceptionForTrip		
	}
	
	override finished() {
	}
	
}
