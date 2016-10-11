package org.uqbar.project.wollok.ui.tests.shortcut

import com.google.inject.Inject
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.ILaunchConfigurationDelegate
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.console.ConsolePlugin
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.console.WollokReplConsole
import org.uqbar.project.wollok.ui.tests.WollokTestResultView
import org.uqbar.project.wollok.ui.tests.launch.WollokLocalTestsLauncher
import org.uqbar.project.wollok.ui.tests.model.WollokLocalTestReporter

import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*

import static extension org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

class WollokLocalTestLaunchDelegate implements ILaunchConfigurationDelegate {
	
	@Inject
	private WollokLocalTestsLauncher testsLauncher
	
	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch,
		IProgressMonitor monitor) throws CoreException {

		val consoleManager = ConsolePlugin.getDefault().consoleManager
		var console = consoleManager.consoles.findFirst[name == WollokReplConsole.consoleName] as WollokReplConsole
		if (console == null) {
			console = new WollokReplConsole
			consoleManager.addConsoles(#[console])
		}

		val projectName = configuration.getAttribute(ATTR_PROJECT_NAME, "X")		
		
		testsLauncher.launch(projectName, configuration.wollokFile)
		
		RunInUI.runInUI [
			PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
		]

	}

}
