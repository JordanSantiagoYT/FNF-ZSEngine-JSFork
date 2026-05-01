package shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * Base effect class for shader effects (Psych / JS Engine compatible Lua API).
 */
class Effect {
	public function setValue(shader:FlxShader, variable:String, value:Float) {
		Reflect.setProperty(Reflect.getProperty(shader, variable), 'value', [value]);
	}
}
