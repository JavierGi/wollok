package org.uqbar.project.wollok.ui.tests.model

import com.google.inject.Inject
import org.uqbar.project.wollok.launch.tests.WollokRemoteTestReporter

class WollokLocalTestReporter extends WollokRemoteTestReporter {
	
	@Inject	
	override init() {
		remoteTestNotifier = new WollokTestResults 
	}
}
