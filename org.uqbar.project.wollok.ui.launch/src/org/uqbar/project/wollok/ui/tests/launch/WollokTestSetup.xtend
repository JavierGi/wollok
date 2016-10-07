package org.uqbar.project.wollok.ui.tests.launch

import com.google.inject.Guice
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

class WollokTestSetup extends WollokLauncherSetup {
	
	new(WollokLauncherParameters parameters) {
		super(parameters)
	}

	override createInjector() {
		return Guice.createInjector(new WollokTestModule(params), this);
	}
}