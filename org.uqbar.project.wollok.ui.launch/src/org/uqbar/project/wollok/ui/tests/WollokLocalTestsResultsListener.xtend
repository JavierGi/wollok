package org.uqbar.project.wollok.ui.tests

import com.google.inject.Inject
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults

class WollokLocalTestsResultsListener {
	
	val WollokTestResults testResults
	
	@Inject
	new(WollokTestResults testResults) {
		this.testResults = testResults
	}
	
	def getListeningPort() { 0 }
	
}