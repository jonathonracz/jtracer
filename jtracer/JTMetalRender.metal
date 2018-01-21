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

#include "Trace/JTTrace.h"

kernel void runTraceMetal(texture2d<half, access::write> output [[texture(jt::TextureIndex::output)]],
                          JT_CONSTANT const jt::Uniforms& uniforms [[buffer(jt::BufferIndex::uniforms)]],
                          uint2 gid [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture.
    if((gid.x >= output.get_width()) || (gid.y >= output.get_height()))
        return;

    uint2 texDims;
    texDims.x = output.get_width();
    texDims.y = output.get_height();
    uint2 pixelCoordFlippedY = gid; // Move (0, 0) from upper left to lower left
    pixelCoordFlippedY.y = texDims.y - pixelCoordFlippedY.y;
    float4 value = jt::Trace::runTrace(uniforms, pixelCoordFlippedY, texDims);
    output.write(half4(value), gid);
}
