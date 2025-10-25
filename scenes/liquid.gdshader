// Godot 4.x (CanvasItem)
shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 0.5) = 0.06; // wave height (in UV)
uniform float frequency : hint_range(0.0, 20.0) = 8.0; // waves across width
uniform float speed = 1.0;                             // wave speed
uniform float top_offset = 0.0;                        // raises/lowers baseline
uniform vec4 fill_color : source_color = vec4(1.0);    // color if no texture
uniform bool use_texture = false;                      // sample TEXTURE or use fill_color

// Edge softness to avoid jaggies; higher = softer
uniform float edge_softness = 1.5;

void fragment() {
    vec2 uv = UV;
    float t = TIME * speed;

    // Wavy top curve (in UV space; y=0 is top for ColorRect/Sprite)
    float wave_y = top_offset + amplitude * sin(uv.x * TAU * frequency + t * TAU);

    // Positive when pixel is BELOW the wave => keep; negative => cut away
    float edge = uv.y - wave_y;

    // Anti-aliased cut using screen-space derivative
    float w = fwidth(edge) * edge_softness;
    float mask = smoothstep(0.0, w, edge);

    vec4 base = use_texture ? texture(TEXTURE, uv) * COLOR : fill_color;
    COLOR = base * mask;
}
