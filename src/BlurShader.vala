/* 
 * Copyright (c) 2012, Brad Larson, Ben Cochran, Hugues Lismonde, Keitaroh Kobayashi, Alaric Cole, Matthew Clark, Jacob Gundersen, Chris Williams.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials * provided with the distribution.
 * Neither the name of the GPUImage framework nor the names of its contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// GLSL shaders based on the GPUImage library: https://github.com/BradLarson/GPUImage

public class BlurShader : Object {
	public Cogl.Shader vertex_shader { get; construct; }
	public Cogl.Shader fragment_shader { get; construct; }

	public int radius { get; construct; }

	public BlurShader (int radius) {
		Object (radius: radius);
	}

	construct {
		int sample_radius = 0;
		float minimum_weight_edge = 1.0f / 256.0f;
		sample_radius = (int)Math.floor(Math.sqrt(-2.0 * Math.pow(radius, 2.0) * Math.log(minimum_weight_edge * Math.sqrt(2.0 * Math.PI * Math.pow(radius, 2.0))) ));
		sample_radius += sample_radius % 2;

		string vertex_string = construct_vertex_for_blur (sample_radius, radius);
		string fragment_string = construct_fragment_for_blur (sample_radius, radius);

		vertex_shader = new Cogl.Shader (Cogl.ShaderType.VERTEX);
		vertex_shader.source (vertex_string);

		fragment_shader = new Cogl.Shader (Cogl.ShaderType.FRAGMENT);
		fragment_shader.source (fragment_string);
	}

	private static string construct_vertex_for_blur (int blur_radius, float sigma)
	{
		float[] standard_gaussian_weights = new float[blur_radius + 1];
		float sum_of_weights = 0.0f;
		for (int current_gaussian_weight_index = 0; current_gaussian_weight_index < blur_radius + 1; current_gaussian_weight_index++) {
			standard_gaussian_weights[current_gaussian_weight_index] = (float)
			((1.0 / Math.sqrt (2.0 * Math.PI * Math.pow (sigma, 2.0))) * Math.exp (-Math.pow(current_gaussian_weight_index, 2.0) / (2.0 * Math.pow (sigma, 2.0))));

			if (current_gaussian_weight_index == 0) {
				sum_of_weights += standard_gaussian_weights[current_gaussian_weight_index];
			} else {
				sum_of_weights += 2.0f * standard_gaussian_weights[current_gaussian_weight_index];
			}
		}

		for (int current_gaussian_weight_index = 0; current_gaussian_weight_index < blur_radius + 1; current_gaussian_weight_index++) {
			standard_gaussian_weights[current_gaussian_weight_index] = standard_gaussian_weights[current_gaussian_weight_index] / sum_of_weights;
		}

		int number_of_optimized_offsets = int.min (blur_radius / 2 + (blur_radius % 2), 7);
		float[] optimized_gaussian_offsets = new float[number_of_optimized_offsets];

		for (int current_optimized_offset = 0; current_optimized_offset < number_of_optimized_offsets; current_optimized_offset++) {
			float first_weight = standard_gaussian_weights[current_optimized_offset * 2 + 1];
			float second_weight = standard_gaussian_weights[current_optimized_offset * 2 + 2];

			float optmized_weight = first_weight + second_weight;
			optimized_gaussian_offsets[current_optimized_offset] = (first_weight * (current_optimized_offset * 2 + 1) + second_weight * (current_optimized_offset * 2 + 2)) / optmized_weight;
		}

		var builder = new StringBuilder ("uniform float texelWidthOffset;\n");
		builder.append ("uniform float texelHeightOffset;\n");
		builder.append_printf ("varying vec2 blurCoordinates[%lu];\n", (1 + (number_of_optimized_offsets * 2)));
		builder.append ("""
				void main () {
				cogl_position_out = cogl_modelview_projection_matrix * cogl_position_in;

				vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
				blurCoordinates[0] = cogl_tex_coord0_in.xy;
			""");

		for (int current_optimized_offset = 0; current_optimized_offset < number_of_optimized_offsets; current_optimized_offset++) {
			builder.append_printf ("blurCoordinates[%lu] = cogl_tex_coord0_in.xy + singleStepOffset * %f;\n",
									((long)(current_optimized_offset * 2) + 1),
									optimized_gaussian_offsets[current_optimized_offset]);

			builder.append_printf ("blurCoordinates[%lu] = cogl_tex_coord0_in.xy - singleStepOffset * %f;\n",
									((long)(current_optimized_offset * 2) + 2),
									optimized_gaussian_offsets[current_optimized_offset]);
		}

		builder.append ("}\n");
		return builder.str;
	}
	
	private static string construct_fragment_for_blur (int blur_radius, float sigma)
	{
		float[] standard_gaussian_weights = new float[blur_radius + 1];
		float sum_of_weights = 0.0f;
		for (int current_gaussian_weight_index = 0; current_gaussian_weight_index < blur_radius + 1; current_gaussian_weight_index++) {
			standard_gaussian_weights[current_gaussian_weight_index] = (float)
			((1.0 / Math.sqrt (2.0 * Math.PI * Math.pow (sigma, 2.0))) * Math.exp (-Math.pow(current_gaussian_weight_index, 2.0) / (2.0 * Math.pow (sigma, 2.0))));

			if (current_gaussian_weight_index == 0) {
				sum_of_weights += standard_gaussian_weights[current_gaussian_weight_index];
			} else {
				sum_of_weights += 2.0f * standard_gaussian_weights[current_gaussian_weight_index];
			}
		}

		for (int current_gaussian_weight_index = 0; current_gaussian_weight_index < blur_radius + 1; current_gaussian_weight_index++) {
			standard_gaussian_weights[current_gaussian_weight_index] = standard_gaussian_weights[current_gaussian_weight_index] / sum_of_weights;
		}

		int number_of_optimized_offsets = int.min (blur_radius / 2 + (blur_radius % 2), 7);
		
		int true_number_optimized_offsets = blur_radius / 2 + (blur_radius % 2);
		
		var builder = new StringBuilder ("uniform sampler2D texture;\n");
		builder.append ("uniform float texelWidthOffset;\n");
		builder.append ("uniform float texelHeightOffset;\n");
		builder.append_printf ("varying vec2 blurCoordinates[%lu];\n", (1 + (number_of_optimized_offsets * 2)));

		builder.append ("""
			void main()
			{
				vec3 sum = vec3(0.0);
				vec4 fragColor = texture2D(texture, cogl_tex_coord0_in.xy);
			""");

		builder.append_printf ("sum += texture2D(texture, blurCoordinates[0]).rgb * %s;\n", float_to_cstr (standard_gaussian_weights[0]));
		
		for (int blur_coord_index = 0; blur_coord_index < number_of_optimized_offsets; blur_coord_index++)
		{
			float first_weight = standard_gaussian_weights[blur_coord_index * 2 + 1];
			float second_weight = standard_gaussian_weights[blur_coord_index * 2 + 2];
			float optimized_weight = first_weight + second_weight;

			builder.append_printf ("sum += texture2D(texture, blurCoordinates[%lu]).rgb * %s;\n",
								((blur_coord_index * 2) + 1),
								float_to_cstr (optimized_weight));

			builder.append_printf ("sum += texture2D(texture, blurCoordinates[%lu]).rgb * %s;\n",
								((blur_coord_index * 2) + 2),
								float_to_cstr (optimized_weight));
		}
		
		if (true_number_optimized_offsets > number_of_optimized_offsets)
		{
			builder.append ("vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n");
			for (int currentOverlowTextureRead = number_of_optimized_offsets; currentOverlowTextureRead < true_number_optimized_offsets; currentOverlowTextureRead++)
			{
				float first_weight = standard_gaussian_weights[currentOverlowTextureRead * 2 + 1];
				float second_weight = standard_gaussian_weights[currentOverlowTextureRead * 2 + 2];
				
				float optimized_weight = first_weight + second_weight;
				float optimizedOffset = (first_weight * (currentOverlowTextureRead * 2 + 1) + second_weight * (currentOverlowTextureRead * 2 + 2)) / optimized_weight;
				
				builder.append_printf ("sum += texture2D(texture, blurCoordinates[0] + singleStepOffset * %f).rgb * %s;\n",
									 optimizedOffset,
									 float_to_cstr (optimized_weight));

				builder.append_printf ("sum += texture2D(texture, blurCoordinates[0] - singleStepOffset * %f).rgb * %s;\n",
									 optimizedOffset,
									 float_to_cstr (optimized_weight));
			}
		}
		
		builder.append ("cogl_color_out = vec4(sum,fragColor.a);\n");
		builder.append ("}\n");
		return builder.str;
    }
    
    private static string float_to_cstr (float val) {
        return val.to_string ().replace (",", ".");
    }
}