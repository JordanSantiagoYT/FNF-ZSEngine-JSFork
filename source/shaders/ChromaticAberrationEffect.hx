package shaders;

import flixel.system.FlxAssets.FlxShader;
import shaders.Effect;

/**
 * RGB split post-process for cameras or sprites (Psych / JS Engine compatible Lua API).
 */

class ChromaticAberrationShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0));
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0));
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0));
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.g;
			toUse.b = col3.b;

			gl_FragColor = toUse;
		}')
	public function new()
	{
		super();
	}
}

class ChromaticAberrationEffect extends Effect implements CameraStackShader
{
	public var shader:FlxShader;

	public function new(offset:Float = 0.0)
	{
		super();
		shader = new ChromaticAberrationShader();
		cast(shader, ChromaticAberrationShader).rOffset.value = [offset];
		cast(shader, ChromaticAberrationShader).gOffset.value = [0.0];
		cast(shader, ChromaticAberrationShader).bOffset.value = [-offset];
	}

	public function setChrome(chromeOffset:Float):Void
	{
		cast(shader, ChromaticAberrationShader).rOffset.value = [chromeOffset];
		cast(shader, ChromaticAberrationShader).gOffset.value = [0.0];
		cast(shader, ChromaticAberrationShader).bOffset.value = [chromeOffset * -1];
	}
}