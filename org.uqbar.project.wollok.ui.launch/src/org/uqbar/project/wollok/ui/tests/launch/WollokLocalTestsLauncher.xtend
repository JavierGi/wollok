package org.uqbar.project.wollok.ui.tests.launch

import com.google.inject.Inject
import com.google.inject.Provider
import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.IResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile

class WollokLocalTestsLauncher {

	val parameters = new WollokLauncherParameters()

	@Inject
	private Provider<XtextResourceSet> resourceSetProvider

	@Inject
	private IResourceFactory resourceFactory
	
	val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration => [
		injectMembers(this)
	]

	def launch(String projectName, String wollokFile) {
		val interpreter = injector.getInstance(WollokInterpreter)
		//val evaluator = interpreter.evaluator as WollokLauncherInterpreterEvaluator
		//evaluator.wollokTestsReporter = testReporter
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
		//val root = ResourcesPlugin.workspace.root

		//val File testFile = new File(root.locationURI.path + "/" + projectName + "/" + testPath)
		//if (!testFile.exists) {
		//	throw new RuntimeException("File " + testFile + " does not exist!")
		//}

		//this.createClassPath(testFile, resourceSet)
		//val testInput = Files.asByteSource(testFile).openStream
		//val resource = resourceFactory.createResource(resourceSet.computeUnusedUri("wtest"))
		val resource = resourceFactory.createResource(URI.createURI("platform:/resource/" + projectName + "/" + testPath))
		resourceSet.resources.add(resource)
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
	
	def URI computeUnusedUri(ResourceSet resourceSet, String fileExtension) {
		val String name = "__synthetic"
		for (var i = 0; i < Integer.MAX_VALUE; i++) {
			val syntheticUri = URI.createURI(name + i + "." + fileExtension)
			if (resourceSet.getResource(syntheticUri, false) == null)
				return syntheticUri
		}
		throw new IllegalStateException()
	}

}
