uniform lowp sampler2D source;
uniform lowp sampler2D value;
uniform lowp float qt_Opacity;
varying highp vec2 qt_TexCoord0;
uniform float dividerValue;
vec3 invert(vec3 p){ return vec3(1,1,1) - p; }
float blendColorDodge(float base, float blend) { return (blend==1.0)?blend:min(base/(1.0-blend),1.0); }
vec3 blendColorDodge(vec3 base, vec3 blend) {
        return vec3(blendColorDodge(base.r,blend.r),blendColorDodge(base.g,blend.g),blendColorDodge(base.b,blend.b));
}
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 desat(vec3 p){
    vec3 fragHSV = rgb2hsv(p) ;
    fragHSV.xyz *= vec3(0,0,1);                 //desaturate
    return hsv2rgb(fragHSV);
}
void main()
{
    vec2 uv   = qt_TexCoord0.xy;
    vec4 copy = texture2D(source, qt_TexCoord0.st).rgba;        //get rgba
    vec4 orig = texture2D(value , qt_TexCoord0.st).rgba;        //get rgba
    if(uv.x < dividerValue) {
        orig.xyz = desat(blendColorDodge(orig.xyz, invert(copy.xyz)));
    }
    else
        orig.xyz = copy.xyz;
    gl_FragColor = orig * qt_Opacity;
}