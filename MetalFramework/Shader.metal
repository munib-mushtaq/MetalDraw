//
//  Shader.metal
//  MetalFramework
//
//  Created by Arslan Raza on 16/01/2024.
//
//
#include <metal_stdlib>
using namespace metal;

struct Constant {
    float animatedBy;
};

vertex float4 vertex_shader(const device packed_float3 * vertices [[ buffer(0) ]],
                            constant Constant &constants [[ buffer(1) ]],
                            uint vertexId [[ vertex_id ]]) {
    float4 position = float4(vertices[vertexId], 3);
    position.y += constants.animatedBy;
    position.x += constants.animatedBy;
    position.x += constants.animatedBy;
    return  position;
}

fragment half4 fragment_shader() {
    return half4(1, 1, 1, 1);
}
