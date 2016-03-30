uniform sampler2D source;
varying vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float sampleDist;
uniform float sampleStrength;
uniform float dividerValue;


void main() 
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

		vec4 radBlur = mix( color, sum, t ) * qt_Opacity;
		
		///NEW CODE AFTER RADIAL BLURRING
		
		vec4 T = texture2D(source,.5+(radBlur.xy* 0.992)); 
  
		vec3 o = T.rbb;
		for (float i=0.;i<100.;i++) 
			p.z += pow(max(0.0,0.5-length(T.rg)),2.0)*exp(-i*.08);
	
		gl_FragColor=vec4(o*o+p.z,1);
		
		
		///
		
		
	}
	else {
		gl_FragColor = color;
	}
 
}