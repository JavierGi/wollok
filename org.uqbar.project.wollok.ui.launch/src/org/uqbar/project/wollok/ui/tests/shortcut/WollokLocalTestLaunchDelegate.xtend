package org.uqbar.project.wollok.ui.tests.shortcut

import com.google.inject.Inject
import com.google.inject.Provider
import java.io.ByteArrayInputStream
import java.io.File
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.ILaunchConfigurationDelegate
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.xtext.resource.IResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.console.WollokReplConsole
import org.uqbar.project.wollok.ui.tests.WollokTestResultView
import org.uqbar.project.wollok.ui.tests.launch.WollokTestSetup

import static extension org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*

class WollokLocalTestLaunchDelegate implements ILaunchConfigurationDelegate {
	val parameters = new WollokLauncherParameters()
	val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration => [
		injectMembers(this)
	]

	@Inject
	private Provider<XtextResourceSet> resourceSetProvider

	@Inject
	private IResourceFactory resourceFactory

	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch,
		IProgressMonitor monitor) throws CoreException {

		val consoleManager = ConsolePlugin.getDefault().consoleManager
		var console = consoleManager.consoles.findFirst[name == WollokReplConsole.consoleName] as WollokReplConsole
		if (console == null) {
			console = new WollokReplConsole
			consoleManager.addConsoles(#[console])
		}

		val interpreter = injector.getInstance(WollokInterpreter)
		//val evaluator = interpreter.evaluator as WollokLauncherInterpreterEvaluator
		//val testReporter = evaluator.wollokTestsReporter as WollokLocalTestReporter
		val resource = this.parseString(configuration.wollokFile)
		interpreter.interpret(resource, true)

		RunInUI.runInUI [
			PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
		]

	}

	def parseString(String testPath) {
		val programType = "wtest"
		new ByteArrayInputStream(test.getBytes("UTF-8")).parse(programType)
		
		val testFile = new File("/home/fernando/workspace/wollok-dev/runtime-EclipseApplication/prueba/" + testPath)
		val resourceSet = injector.getInstance(XtextResourceSet)
		val checker = injector.getInstance(WollokChecker)
		checker.parse(testFile)				
	}


}
