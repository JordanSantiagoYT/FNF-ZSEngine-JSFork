package shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * Base effect class for shader effects (Psych / JS Engine compatible Lua API).
 */
interface CameraStackShader {
	public var shader:flixel.system.FlxAssets.FlxShader;
}

class Effect {
	public function new() {
	}

	public function setValue(shader:flixel.system.FlxAssets.FlxShader, variable:String, value:Float) {
		Reflect.setProperty(Reflect.getProperty(shader, variable), 'value', [value]);
	}
}