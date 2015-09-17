package org.uqbar.project.wollok.ui.tests.model

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class WollokTestContainer {
	var URI mainResource
	var List<WollokTestResult> tests = newArrayList
	
	override toString(){
		mainResource.toString
	}
}