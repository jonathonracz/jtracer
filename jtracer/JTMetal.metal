//
//  JTMain.metal
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

#include "OpenSimplex/OpenSimplex.h"

kernel void jtMetal(texture2d<half, access::write> output [[texture(jt::TextureIndex::output)]],
                    JT_CONSTANT jt::Uniforms& uniforms [[buffer(jt::BufferIndex::uniforms)]],
                    simd::uint2 gid [[thread_position_in_grid]])
{
    jt::PRNG random(gid, uniforms);

    // Check if the pixel is within the bounds of the output texture.
    if((gid.x >= output.get_width()) || (gid.y >= output.get_height()))
        return;

    float value = OpenSimplex::Noise::noise2(uniforms.context, gid.x, gid.y);

    output.write(half4(value, value, value, 1.0f), gid);
}
