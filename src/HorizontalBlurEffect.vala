
public class Gala.HorizontalBlurEffect : Clutter.OffscreenEffect {
	Cogl.Program program;

	public HorizontalBlurEffect (BlurShader shader, float width)
	{
		program = new Cogl.Program ();

		var vertex = shader.vertex_shader;
		var frag = shader.fragment_shader;

		program.attach_shader (vertex);
		program.attach_shader (frag);
		program.link ();

		int uniform_no = program.get_uniform_location ("texture");
		CoglFixes.set_uniform_1i (program, uniform_no, 0);

		uniform_no = program.get_uniform_location ("texelWidthOffset");
		CoglFixes.set_uniform_1f (program, uniform_no, 1.0f / width);
		uniform_no = program.get_uniform_location ("texelHeightOffset");
		CoglFixes.set_uniform_1f (program, uniform_no, 0.0f);
	}

	public override void paint_target ()
	{
		var material = get_target ();
		Cogl.Material.set_layer_wrap_mode (material, 0, Cogl.MaterialWrapMode.CLAMP_TO_EDGE);
		CoglFixes.set_user_program (material, program);
		base.paint_target ();
	}
}
