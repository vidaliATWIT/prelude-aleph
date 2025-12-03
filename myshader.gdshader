shader_type spatial;

uniform sampler2D noise_texture : repeat_enable;
uniform float noise_scale = 0.1;
uniform float displacement_strength = 0.5;
uniform vec3 dirt_color_dark : source_color = vec3(0.3, 0.2, 0.1);
uniform vec3 dirt_color_light : source_color = vec3(0.5, 0.35, 0.2);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.9;

void vertex() {
    // Get global position
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Combine local UV with global position offset
    vec2 sample_pos = UV + world_pos.xz * noise_scale;

    // Sample noise and displace vertex along normal
    float noise_value = texture(noise_texture, sample_pos).r;
    VERTEX += NORMAL * noise_value * displacement_strength;
}

void fragment() {
    // Get global position from the model matrix
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Combine UV (local) with global position offset
    vec2 sample_pos = UV + world_pos.xz * noise_scale;

    // Sample the noise
    float noise_value = texture(noise_texture, sample_pos).r;

    // Mix between two dirt colors based on noise
    ALBEDO = mix(dirt_color_dark, dirt_color_light, noise_value);

    // Make it rough like dirt
    ROUGHNESS = roughness_value;
}