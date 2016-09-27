uniform highp float time;
uniform sampler2D source;
varying highp vec2 qt_TexCoord0;
uniform highp vec2 center;
uniform lowp float qt_Opacity;
uniform highp float freq;
void main() {
   vec2 tc = qt_TexCoord0.xy;
   highp vec2 p = 1.5 * (tc-center);
   highp float len = length(p);
   highp vec2 uv = fract(tc + (p/len)*freq*max(0.3, 2.-len)*cos(len*24.0-time*4.0)*0.03);
   gl_FragColor = texture2D(source,uv) ;
//   if(time < 0.1) {
//        gl_FragColor = texture2D(source, tc);
//   }
//   else {
//       vec2 p = -1.0 + 2.0 * tc;
//       float len = length(p);
//       vec2 uv = tc + (p/len)*cos(len*12.0-time*4.0)*0.03;
//       vec3 col = texture2D(source,uv).xyz;
//       gl_FragColor = vec4(col,1.0);
//   }
}
