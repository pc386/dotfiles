precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// Define a subtle orange color for the tint
const vec3 ORANGE = vec3(0.8, 0.4, 0.0);

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Calculate the luminance (brightness) of the pixel for shading
    float luminance = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114)); // standard luminance calculation

    // Grayscale value
    vec3 grayscale = vec3(luminance);

    // Apply a subtle orange tint by blending with grayscale
    vec3 orangescaleColor = mix(grayscale, ORANGE, 0.1); // Adjust 0.1 for subtlety (increase for more orange)

    gl_FragColor = vec4(orangescaleColor, pixColor.a);
}
