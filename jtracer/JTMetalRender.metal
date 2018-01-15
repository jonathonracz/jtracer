//
//  JTMetalRender.metal
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Trace/JTShaderTypes.h"
#include "Trace/JTBindPoints.h"
#include "Trace/JTNumerics.h"

#include "Trace/JTTrace.h"

#include "OpenSimplex/OpenSimplex.h"

kernel void metalRender(texture2d<half, access::write> output [[texture(jt::TextureIndex::output)]],
                        JT_CONSTANT jt::Uniforms& uniforms [[buffer(jt::BufferIndex::uniforms)]],
                        simd::uint2 gid [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture.
    if((gid.x >= output.get_width()) || (gid.y >= output.get_height()))
        return;

    jt::Trace trace;
    simd::uint2 texDims;
    texDims.x = output.get_width();
    texDims.y = output.get_height();
    simd::float4 value = trace.runTrace(uniforms, gid, texDims);
    output.write(simd::half4(value), gid);
}
