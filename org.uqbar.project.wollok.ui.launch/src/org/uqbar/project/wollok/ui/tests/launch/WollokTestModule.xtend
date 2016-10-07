package org.uqbar.project.wollok.ui.tests.launch

import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherModule
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.ui.tests.model.WollokLocalTestReporter

class WollokTestModule  extends WollokLauncherModule {
	new(WollokLauncherParameters params) {
		super(params)
	}

//	override Class<? extends WollokInterpreterConsole> bindWollokInterpreterConsole() {
//		WollokServerConsole
//	}	

	override Class<? extends WollokTestsReporter> bindWollokTestsReporter() {
		WollokLocalTestReporter 	
	}
	
	def Class<? extends WollokChecker> bindWollokChecker() {
		WollokChecker
	}
	
}