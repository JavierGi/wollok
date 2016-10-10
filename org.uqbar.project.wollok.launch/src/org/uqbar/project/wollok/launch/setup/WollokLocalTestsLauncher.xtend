package org.uqbar.project.wollok.launch.setup

import com.google.common.io.Files
import com.google.inject.Inject
import com.google.inject.Provider
import java.io.File
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.IResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.launch.tests.WollokRemoteTestReporter

class WollokLocalTestsLauncher {

	val parameters = new WollokLauncherParameters()

	@Inject
	private Provider<XtextResourceSet> resourceSetProvider

	@Inject
	private IResourceFactory resourceFactory

	val injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration => [
		injectMembers(this)
	]

	def launch(String projectName, String wollokFile, WollokRemoteTestReporter testReporter) {
		val interpreter = injector.getInstance(WollokInterpreter)
		val evaluator = interpreter.evaluator as WollokLauncherInterpreterEvaluator
		evaluator.wollokTestsReporter = testReporter
		println(testReporter.toString)
		val resource = this.getResource(wollokFile, projectName)
		interpreter.interpret(resource, true)
	}

	def createClassPath(File file, ResourceSet resourceSet) {
		newArrayList => [
			resourceSet.createResource(URI.createURI(file.toURI.toString))
		]
	}

	def getResource(String testPath, String projectName) {
		val resourceSet = resourceSetProvider.get()
		// val resourceSet = injector.getInstance(XtextResourceSet)
		val root = ResourcesPlugin.workspace.root

		val File testFile = new File(root.locationURI.path + "/" + projectName + "/" + testPath)
		if (!testFile.exists) {
			throw new RuntimeException("File " + testFile + " does not exist!")
		}

		this.createClassPath(testFile, resourceSet)
		val resource = resourceSet.getResource(URI.createURI(testFile.toURI.toString), false)
		resourceSet.resources.add(resource)
		//val testInput = Files.asByteSource(testFile).openStream
		//resource.load(testInput, null)
		resource.load(#{})
		
		val issues = newArrayList
		new WollokChecker().validate(
			injector,
			resource,
			[issues.add(it)],
			[]
		)

		resource.contents.head as WFile
	}

}
