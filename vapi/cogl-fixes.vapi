namespace CoglFixes
{
	[CCode (cname = "cogl_texture_get_data")]
	public int texture_get_data (Cogl.Texture texture, Cogl.PixelFormat format, uint rowstride, [CCode (array_length = false)] uint8[] pixels);

	[CCode (cname = "cogl_set_draw_buffer")]
	public void set_draw_buffer (Cogl.BufferTarget target, Cogl.Offscreen offscreen);

	[CCode (cname = "cogl_material_set_user_program")]
	public void set_user_program (Cogl.Material material, Cogl.Handle program);

	[CCode (cname = "cogl_program_set_uniform_1f")]
	public void set_uniform_1f (Cogl.Program program, int uniform_no, float value);
	[CCode (cname = "cogl_program_set_uniform_1i")]
	public void set_uniform_1i (Cogl.Program program, int uniform_no, int value);	

	[CCode (cname = "cogl_get_projection_matrix")]
	public void get_projection_matrix (out Cogl.Matrix matrix);
}

