//
//  JTNumerics.h
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
        explicit PRNG(uint64 seed[2])
        {
            state[0] ^= seed[0];
            state[1] ^= seed[1];
            next();
        }

        explicit PRNG(simd::uint2 gid, JT_CONSTANT Uniforms& uniforms)
        {
            uint64 seedGid = gid.x;
            seedGid <<= sizeof(seedGid) / 2;
            seedGid |= gid.y;
            state[0] ^= seedGid;

            uint64 seedUni = uniforms.frameCount;
            seedUni <<= sizeof(seedUni) / 2;
            seedUni |= uniforms.random;
            state[1] ^= seedUni;

            next();
        }

        ~PRNG() = default;

        uint64 next()
        {
            uint64 s1 = state[0];
            const uint64 s0 = state[1];
            const uint64 result = s0 + s1;
            state[0] = s0;
            s1 ^= s1 << 23;
            state[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5);
            return result;
        }

        float nextNormalized()
        {
            return next() / static_cast<float>(0xffffffffffffffff);
        }

    private:
        uint64 state[2] = { 0xb5d3a12c54b8eb9c, 0x8a4462672a6bdba7 };
    };
};
