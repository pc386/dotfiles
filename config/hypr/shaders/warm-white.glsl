#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// Lower the temperature for warmer whites; raise it for a cooler appearance.
// This is an approximate filter setting, not a measured panel white point.
const float temperature = 6200.0;
const float strength = 1.0;

// Temperature conversion adapted from Hyprshade's blue-light-filter.glsl:
// https://www.shadertoy.com/view/4sc3D7
vec3 colorTemperatureToRGB(float kelvin) {
    float t = clamp(kelvin, 1000.0, 40000.0);
    mat3 m = (t <= 6500.0)
        ? mat3(vec3(0.0, -2902.1955373783176, -8257.7997278925690),
               vec3(0.0, 1669.5803561666639, 2575.2827530017594),
               vec3(1.0, 1.3302673723350029, 1.8993753891711275))
        : mat3(vec3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690),
               vec3(-2666.3474220535695, -2173.1012343082230, 2575.2827530017594),
               vec3(0.55995389139931482, 0.70381203140554553, 1.8993753891711275));

    return clamp(m[0] / (vec3(t) + m[1]) + m[2], 0.0, 1.0);
}

void main() {
    vec4 pixel = texture(tex, v_texcoord);
    vec3 gain = mix(vec3(1.0), colorTemperatureToRGB(temperature), strength);
    fragColor = vec4(pixel.rgb * gain, pixel.a);
}
