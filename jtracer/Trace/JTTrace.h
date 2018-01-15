//
//  JTTrace.h
//  jtracer
//
//  Created by Jonathon Racz on 1/13/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTShaderTypes.h"
#include <simd/simd.h>

namespace jt
{

class Trace
{
public:
    Trace() {}
    ~Trace() {}

    simd::float4 runTrace(JT_CONSTANT const Uniforms& uniforms, simd::uint2 pos, simd::uint2 dimensions)
    {
        float randomSeed = OpenSimplex::Noise::noise2(uniforms.context, pos.x, pos.y);
        simd::float4 ret;
        ret.r = randomSeed;
        ret.g = randomSeed;
        ret.b = randomSeed;
        ret.a = 1.0f;
        return ret;
    }
};

}
