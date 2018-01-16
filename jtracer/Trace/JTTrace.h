//
//  JTTrace.h
//  jtracer
//
//  Created by Jonathon Racz on 1/13/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include <simd/simd.h>
using namespace simd;

#include "JTShaderTypes.h"
#include "JTRay.h"

namespace jt
{

class Trace
{
public:
    Trace() = default;
    ~Trace() = default;

    float4 runTrace(JT_CONSTANT const Uniforms& uniforms, uint2 pos, uint2 dimensions)
    {
        //float randomSeed = OpenSimplex::Noise::noise2(uniforms.context, pos.x, pos.y);

        float u = pos.x / static_cast<float>(dimensions.x);
        float v = pos.y / static_cast<float>(dimensions.y);

        float3 lowerLeftCorner = make_float3(-2.0f, -1.0f, -1.0f);
        float3 horizontalSpan = make_float3(4.0f, 0.0f, 0.0f);
        float3 verticalSpan = make_float3(0.0f, 2.0f, 0.0f);
        float3 origin = make_float3(0.0f, 0.0f, 0.0f);

        Ray mainRay(origin, lowerLeftCorner + (u * horizontalSpan) + (v * verticalSpan));

        float4 ret;
        return ret;
    }
};

}
