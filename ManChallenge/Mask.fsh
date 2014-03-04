

varying highp vec2 v_texCoord;

uniform sampler2D u_texture;
uniform sampler2D u_colorRampTexture;

void main()
{
    gl_FragColor = texture2D(u_texture, v_texCoord).bgra;
}