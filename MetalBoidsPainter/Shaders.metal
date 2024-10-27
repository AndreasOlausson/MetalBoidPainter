#include <metal_stdlib>
#include <simd/simd.h>
#include "ShaderTypes.h" // Importera de delade konstanterna och strukturerna

using namespace metal;

// Vertex structure with position and texture coordinates
typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

// Output from the vertex shader
typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

// Vertex Shader (flipping Y-axis for the texture)
vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    // Apply transformation to position using the uniform matrices
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;

    // Flip Y-axis of texture coordinates
    out.texCoord = float2(in.texCoord.x, 1.0 - in.texCoord.y);

    return out;
}

// Fragment Shader
fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    // Sample the color from the texture
    half4 colorSample = colorMap.sample(colorSampler, in.texCoord.xy);
    return float4(colorSample);
}
