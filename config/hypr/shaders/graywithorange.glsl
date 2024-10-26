precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

// Define the threshold for switching to orangescale (between 0.0 and 1.0)
const float THRESHOLD = 0.33;

// Define the orange color for bright areas
const vec3 ORANGE = vec3(1.0, 0.5, 0.0);

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);

    // Calculate the luminance (brightness) of the pixel for threshold comparison
    float luminance = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114)); // standard grayscale luminance

    vec3 finalColor;
    if (luminance < THRESHOLD) {
        // Below the threshold, use grayscale
        finalColor = vec3(luminance);
    } else {
        // Above the threshold, switch to orangescale
        finalColor = mix(vec3(0.0), ORANGE, luminance);
    }

    gl_FragColor = vec4(finalColor, pixColor.a);
}
