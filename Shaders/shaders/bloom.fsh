//http://wp.applesandoranges.eu/?p=14

uniform sampler2D source;
varying vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float dividerValue;
uniform float value;


void main()
{
    vec4 sum = vec4(0);
	vec4 color = texture2D(source, qt_TexCoord0);

    int j;
    int i;
	
	if(qt_TexCoord0.x < dividerValue){
	
		for( i= -4 ;i < 4; i++)
		{
			for (j = -3; j < 3; j++)
			{
				sum += texture2D(source, qt_TexCoord0.st + vec2(j, i)*0.004) * 0.25;
			}
		}
		
		if (color.r < 0.3)
		{
			gl_FragColor = value*sum*sum*0.012 + color;
		}
		else
		{
			if (color.r < 0.5)
			{
				gl_FragColor = value*sum*sum*0.009 + color;
			}
			else
			{
				gl_FragColor = value*sum*sum*0.0075 + color;
			}
		}	
	
	
	}
	else {
	
		gl_FragColor = color * qt_Opacity;
	
	}
	


	
	
	
}

