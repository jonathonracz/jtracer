//
//  JTRandom.h
//  jtracer
//
//  Created by Jonathon Racz on 1/4/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include <simd/simd.h>
#include "JTTypes.h"
#include "JTShaderTypes.h"

namespace jt
{

class PRNG
{
public:
    PRNG()
    {
    }

    ~PRNG() = default;

    uint32 generate()
    {
        uint32 t = (x ^ (x >> 2));
        x = y;
        y = z;
        z = w;
        w = v;
        v = (v ^ (v << 4)) ^ (t ^ (t << 1));
        return (d += 362437) + v;
    }

    float generateNormal()
    {
        // TODO: in a distributed raytracing situation, this should be
        // 0 <= x < 1, but currently it's 0 <= x <= 1.
        return generate() / static_cast<float>(JT_UINT32_MAX);
    }

private:
    uint32 x = 123456789;
    uint32 y = 362436069;
    uint32 z = 521288629;
    uint32 w = 88675123;
    uint32 v = 5783321;
    uint32 d = 6615241;
};

};
