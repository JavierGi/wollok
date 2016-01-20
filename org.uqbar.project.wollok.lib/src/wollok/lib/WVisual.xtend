package wollok.lib

import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class WVisual extends VisualComponent {

	public WollokObject wObject
	WollokObject wPosition

	new(WollokObject object) {
		wObject = object
	}

	new(WollokObject object, WollokObject position) {
		this(object)
		this.wPosition = position
	}

	override getAttributes() {
		wObject.instanceVariables.entrySet.map[key + ":" /*TODO: value.toString*/].toList
	}

	override getImage() {
		new WImage(wObject)
	}

	override getPosition() {
		objectPosition
	}

	override setPosition(Position position) {
		objectPosition.copyFrom(position)
	}

	def getObjectPosition() {
		if (wPosition != null)
			return new WPosition(wPosition)

		new WPosition(wObject.position)
	}
}
