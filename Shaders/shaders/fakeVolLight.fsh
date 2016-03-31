uniform sampler2D source;
varying vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float dividerValue;
uniform float width;
uniform float height;

void main() 
{
	vec2 uv = qt_TexCoord0.xy;
	vec4 color = texture2D(source,qt_TexCoord0); 
	vec3 resolution = vec3(width,height,1);

	if(uv.x < dividerValue) {
		vec3 p = gl_FragCoord.xyz/resolution -0.5;
		vec4 T = texture2D(source,.5+(color.xy* 0.992)); 
  
		vec3 o = T.rbb;
		for (float i=0.;i<100.;i++) 
			p.z += pow(max(0.0,0.5-length(T.rg)),2.0)*exp(-i*.08);
	
		gl_FragColor=vec4(o*o+p.z,1) * qt_Opacity;
	}
	else {
		gl_FragColor = color * qt_Opacity;
	}
 
}