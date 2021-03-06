package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.uqbar.project.wollok.wollokDsl.WMixin
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * @author jfernandes
 */
@Accessors
class MixinModel extends Shape {
	WMixin mixin
	public static int mixinsCount = 0
	public static int PADDING_LEFT = 10
	public static int VERTICAL_TOP = 10
	
	static def void init() {
		mixinsCount = 0
	}
	
	new(WMixin mixin) {
		this.mixin = mixin
		mixinsCount++
	}

	override toString() {
		"Mixin<" + mixin.name + ">"		
	}
	
	def void locate() {
		location = new Point(PADDING_LEFT + ((mixinsCount + NamedObjectModel.objectsCount) * width), VERTICAL_TOP)
	}
	
	def width() {
		110
	}
	
	def height() {
		120
	}
	
}