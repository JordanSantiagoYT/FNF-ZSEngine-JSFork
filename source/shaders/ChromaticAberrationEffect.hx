package shaders;

import shaders.flixel.system.FlxShader;

/**
 * RGB split post-process for cameras or sprites (Psych / JS Engine compatible Lua API).
 */
typedef CameraStackShader = {
	var shader:FlxShader;
};

class ChromaticAberrationShader extends shaders.flixel.system.FlxShader
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

class ChromaticAberrationEffect
{
	public var shader:ChromaticAberrationShader;

	public function new(offset:Float = 0.0)
	{
		shader = new ChromaticAberrationShader();
		shader.rOffset.value = [offset];
		shader.gOffset.value = [0.0];
		shader.bOffset.value = [-offset];
	}

	public function setChrome(chromeOffset:Float):Void
	{
		shader.rOffset.value = [chromeOffset];
		shader.gOffset.value = [0.0];
		shader.bOffset.value = [chromeOffset * -1];
	}
}
