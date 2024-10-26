precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    float gray;
    vec4 pixColor = texture2D(tex, v_texcoord);
    gray = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 grayscale = vec3(gray);

    gl_FragColor = vec4(grayscale, pixColor.a);
}

