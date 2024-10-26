precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// Define the orange color as the base color
const vec3 ORANGE = vec3(1, 0.5, 0.0);

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Calculate the luminance (brightness) of the pixel to use for shading
    float luminance = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114)); // standard luminance calculation

    // Scale the luminance to an "orangescale" by mixing from black to the ORANGE color
    vec3 orangescaleColor = mix(vec3(0.0), ORANGE, luminance);

    gl_FragColor = vec4(orangescaleColor, pixColor.a);
}
