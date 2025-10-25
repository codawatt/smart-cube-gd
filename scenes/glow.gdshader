shader_type canvas_item;
render_mode unshaded; // unaffected by 2D lights

uniform vec4 neon_color : source_color = vec4(0.2, 1.0, 0.9, 1.0); // pick in inspector (HDR slider if 2D HDR is on)
uniform float neon_power : hint_range(0.0, 10.0) = 2.5;   // inner energy
uniform float outer_glow_px : hint_range(0.0, 4.0) = 1.0; // halo radius in pixels
uniform float outer_strength : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float a = tex.a;

    // 1-tap halo (cheap): sample neighbors’ alpha
    vec2 px = TEXTURE_PIXEL_SIZE * outer_glow_px;
    float halo = max(max(texture(TEXTURE, UV + vec2(px.x, 0.0)).a,
                         texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
                     max(texture(TEXTURE, UV + vec2(0.0, px.y)).a,
                         texture(TEXTURE, UV - vec2(0.0, px.y)).a));

    float e = a * neon_power + halo * outer_strength; // total brightness

    // Draw the sprite normally…
    COLOR = tex;

    // …then add HDR energy to trigger Glow
    COLOR.rgb += neon_color.rgb * e * a;  // values > 1.0 will bloom
    COLOR.a = tex.a; // keep original alpha
}
