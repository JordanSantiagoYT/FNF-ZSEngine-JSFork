package shaders;

// STOLEN FROM HAXEFLIXEL DEMO LOL
import flixel.system.FlxAssets.FlxShader;

class PulseEffect
{
    public var shader(default, set):PulseShader = new PulseShader();

    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
    public var enabled(default, set):Bool = false;

	public function new():Void
	{
		if (shader != null) {
			shader.uTime.value = [0];
	        shader.uampmul.value = [0];
	        shader.uEnabled.value = [false];
			trace('PulseEffect.new: Initialized shader with uTime=[0], uampmul=[0], uEnabled=[false]');
		} else {
			trace('PulseEffect.new: shader is null during initialization');
		}
	}

    public function update(elapsed:Float):Void
    {
        if (shader != null) {
            shader.uTime.value[0] += elapsed;
            trace('PulseEffect.update: shader.uTime.value[0] = ${shader.uTime.value[0]}');
        } else {
            trace('PulseEffect.update: shader is null, cannot update uTime');
        }
    }

    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        if (shader != null) {
            shader.uSpeed.value = [waveSpeed];
            trace('PulseEffect.set_waveSpeed: shader.uSpeed.value = [${waveSpeed}]');
        } else {
            trace('PulseEffect.set_waveSpeed: shader is null, cannot set uSpeed');
        }
        return v;
    }

    function set_enabled(v:Bool):Bool
    {
        enabled = v;
        if (shader != null) {
            shader.uEnabled.value = [enabled];
            trace('PulseEffect.set_enabled: shader.uEnabled.value = [${enabled}]');
        } else {
            trace('PulseEffect.set_enabled: shader is null, cannot set uEnabled');
        }
        return v;
    }

	function set_shader(v:PulseShader):PulseShader
	{
		shader = v;
		return v;
	}

    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        if (shader != null) {
            shader.uFrequency.value = [waveFrequency];
            trace('PulseEffect.set_waveFrequency: shader.uFrequency.value = [${waveFrequency}]');
        } else {
            trace('PulseEffect.set_waveFrequency: shader is null, cannot set uFrequency');
        }
        return v;
    }

    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        if (shader != null) {
            shader.uWaveAmplitude.value = [waveAmplitude];
            trace('PulseEffect.set_waveAmplitude: shader.uWaveAmplitude.value = [${waveAmplitude}]');
        } else {
            trace('PulseEffect.set_waveAmplitude: shader is null, cannot set uWaveAmplitude');
        }
        return v;
    }
}

class PulseShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform float uampmul;

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec4 sineWave(vec4 pt, vec2 pos)
    {
        if (uampmul > 0.0)
        {
            float offsetX = sin(pt.y * uFrequency + uTime * uSpeed);
            float offsetY = sin(pt.x * (uFrequency * 2) - (uTime / 2) * uSpeed);
            float offsetZ = sin(pt.z * (uFrequency / 2) + (uTime / 3) * uSpeed);
            pt.x = mix(pt.x,sin(pt.x / 2 * pt.y + (5 * offsetX) * pt.z),uWaveAmplitude * uampmul);
            pt.y = mix(pt.y,sin(pt.y / 3 * pt.z + (2 * offsetZ) - pt.x),uWaveAmplitude * uampmul);
            pt.z = mix(pt.z,sin(pt.z / 6 * (pt.x * offsetY) - (50 * offsetZ) * (pt.z * offsetX)),uWaveAmplitude * uampmul);
        }
        
        return vec4(pt.x, pt.y, pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv),uv);
    }')

    public function new()
    {
       super();
    }
}