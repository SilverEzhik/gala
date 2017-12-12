//
//  Copyright (C) 2017 Adam Bieńkowski
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public class Gala.VerticalBlurEffect : Clutter.OffscreenEffect {
	Cogl.Program program;

	public VerticalBlurEffect (BlurShader shader, float height)
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
		CoglFixes.set_uniform_1f (program, uniform_no, 0.0f);
		set_height (height);
	}

	public void set_height (float height) 
	{
		int uniform_no = program.get_uniform_location ("texelHeightOffset");
		CoglFixes.set_uniform_1f (program, uniform_no, 1.0f / height);
	}

	public override void paint_target ()
	{
		var material = get_target ();
		Cogl.Material.set_layer_wrap_mode (material, 0, Cogl.MaterialWrapMode.CLAMP_TO_EDGE);
		CoglFixes.set_user_program (material, program);
		base.paint_target ();
	}
}
