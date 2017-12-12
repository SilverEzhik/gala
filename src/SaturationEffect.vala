public class Gala.SaturationEffect : Clutter.ShaderEffect { 
	private const string FRAG_SHADER = """
		uniform sampler2D texture;
		uniform float saturation;
		uniform float brightness;

		vec3 saturate (vec3 rgb, float adjustment) {
			const vec3 W = vec3(0.2125, 0.7154, 0.0721);
			vec3 intensity = vec3(dot(rgb, W));
			return mix (intensity, rgb, adjustment);
		}

		void main () {
			vec4 sum = texture2D (texture, cogl_tex_coord0_in.xy);
			vec3 mixed = saturate (sum.rgb, saturation) + vec3 (brightness, brightness, brightness);
			cogl_color_out = vec4 (mixed, sum.a);
		}
	""";

	public float saturation { get; construct set; }
	public float brightness { get; construct set; }

	construct {
		set_shader_source (FRAG_SHADER);
		set_uniform_value ("texture", 0);
		set_uniform_value ("saturation", saturation);
		set_uniform_value ("brightness", brightness);
	}

	public SaturationEffect (float saturation, float brightness) {
		Object (shader_type: Clutter.ShaderType.FRAGMENT_SHADER, saturation: saturation, brightness: brightness);
	}
}