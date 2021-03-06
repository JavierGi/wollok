package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.Image
import org.junit.Before

class ImageTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String convention

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		WollokConventionExtensions.IMAGE_CONVENTIONS.asParameters
	}

	var image = '''"image.png"'''
	var gameboard = Gameboard.getInstance

	@Before
	def void init() {
		gameboard.clear
	}
	
	@Test
	def void imageCanBeAccessedByGetterMethod() {
		'''
		object aVisual {
			method get«convention.toFirstUpper»() = «image»
		}
		
		object otherVisual {
			method «convention»() = «image»
		}

		program p {
			new Position(0,0).drawElement(aVisual)
			new Position(0,0).drawElement(otherVisual)
		}'''.interpretPropagatingErrors
		
		validateImage
	}

	@Test
	def void imageCanBeAccessedByProperty() {
		'''
		object visual {
			var «convention» = «image»
		}

		program p {
			new Position(0,0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		validateImage
	}

	@Test
	def void visualsWithoutImageDefaultIsAssigned() {
		'''
		object visual { }
		
		program p {
			new Position(0,0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		validateDefaultImage
	}
	
	def validateImage() {
		validateImage("image.png")
	}
	
	def validateDefaultImage() {
		validateImage("wko.png")
	}
	
	def validateImage(String path) {
		components.forEach[
			assertEquals(new Image(path), it.image)
		]
	}
	
	def components() {
		gameboard.components
	}
}
