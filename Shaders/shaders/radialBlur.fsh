// http://stackoverflow.com/questions/4579020/how-do-i-use-a-glsl-shader-to-apply-a-radial-blur-to-an-entire-scene

uniform sampler2D source;
varying vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float sampleDist;
uniform float sampleStrength;
uniform float dividerValue;

void main(void)
{
	vec2 uv = qt_TexCoord0.xy;
	vec4 color = texture2D(source,qt_TexCoord0); 

	if(uv.x < dividerValue) {
		float samples[10];
		samples[0] = -0.08;
		samples[1] = -0.05;
		samples[2] = -0.03;
		samples[3] = -0.02;
		samples[4] = -0.01;
		samples[5] =  0.01;
		samples[6] =  0.02;
		samples[7] =  0.03;
		samples[8] =  0.05;
		samples[9] =  0.08;

		vec2 dir = 0.5 - qt_TexCoord0; 
		float dist = sqrt(dir.x*dir.x + dir.y*dir.y); 
		dir = dir/dist; 

		
		vec4 sum = color;

		for (int i = 0; i < 10; i++)
			sum += texture2D( source, qt_TexCoord0 + dir * samples[i] * sampleDist );

		sum *= 1.0/11.0;
		float t = dist * sampleStrength;
		t = clamp( t ,0.0,1.0);

		gl_FragColor = mix( color, sum, t ) * qt_Opacity;
	}
	else {
		gl_FragColor = color  * qt_Opacity;
	}
}