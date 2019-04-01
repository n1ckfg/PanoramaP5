uniform vec3 iResolution;
uniform float alpha = 1.0;
uniform sampler2D tex0;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 uv = vec2(fragCoord.x / iResolution.x, 1.0 - (fragCoord.y / iResolution.y));

	vec4 col = vec4(texture2D(tex0, uv).xyz, alpha);

	fragColor = col;
}

void main() {
	mainImage(gl_FragColor, gl_FragCoord.xy);
}