package org.uqbar.project.wollok.ui.tests.shortcut

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.ui.PlatformUI
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchDelegate
import org.uqbar.project.wollok.ui.tests.WollokTestResultView
import org.uqbar.project.wollok.ui.tests.model.WollokLocalTestReporter

class WollokLocalTestLaunchDelegate extends WollokLaunchDelegate {

	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch,
		IProgressMonitor monitor) throws CoreException {
		RunInUI.runInUI [
			PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
		]
		super.launch(configuration, mode, launch, monitor)
	}

	override configureLaunchParameters(ILaunchConfiguration config, int requestPort, int eventPort) {
		println("Configurando ")
		super.configureLaunchParameters(config, requestPort, eventPort) => [
			tests = true
			testPort = 0
			testsReporter = WollokLocalTestReporter
		]
	}

}
