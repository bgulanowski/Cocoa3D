#version 300 es

precision mediump float;

in vec4 vColor;

layout(location=0) out vec4 vFragColor;

void main()
{
	vFragColor = vColor;
}