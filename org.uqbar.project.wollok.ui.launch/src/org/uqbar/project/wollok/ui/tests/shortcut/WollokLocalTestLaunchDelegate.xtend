package org.uqbar.project.wollok.ui.tests.shortcut

import com.google.common.io.Files
import com.google.inject.Inject
import com.google.inject.Provider
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.ILaunchConfigurationDelegate
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
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
import org.uqbar.project.wollok.wollokDsl.WFile
import static org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants.*
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
		val project = configuration.getAttribute(ATTR_PROJECT_NAME, "X")		
		val resource = this.getResource(configuration.wollokFile, project)
		interpreter.interpret(resource, true)

		RunInUI.runInUI [
			PlatformUI.workbench.activeWorkbenchWindow.activePage.showView(WollokTestResultView.NAME)
		]

	}

	def createClassPath(File file, ResourceSet resourceSet) {
		newArrayList => [
			resourceSet.createResource(URI.createURI(file.toURI.toString))
		]
	}

	def getResource(String testPath, String projectName) {
		val resourceSet = resourceSetProvider.get()
		//val resourceSet = injector.getInstance(XtextResourceSet)
		val root = ResourcesPlugin.workspace.root
		
		val File testFile = new File(root.locationURI.path + "/" + projectName + "/" + testPath)
		if (!testFile.exists) {
			throw new RuntimeException("File " + testFile + " does not exist!")
		}


		this.createClassPath(testFile, resourceSet)
		val resource = resourceSet.getResource(URI.createURI(testFile.toURI.toString), false)
		resourceSet.resources.add(resource)
		
		val testInput = Files.asByteSource(testFile).openStream
		resource.load(testInput, null)
		//resource.load(#{})
		new WollokChecker().validate(injector, resource)

		resource.contents.head as WFile
	}
 

}
