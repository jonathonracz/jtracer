//
//  JTTypes.h
//  jtracer
//
//  Created by Jonathon Racz on 1/4/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#ifdef __METAL_VERSION__
    #define JT_DEVICE device
    #define JT_THREADGROUP threadgroup
    #define JT_CONSTANT constant
    #define JT_THREAD thread
    #include <metal_stdlib>
#else
    #define JT_DEVICE
    #define JT_THREADGROUP
    #define JT_CONSTANT
    #define JT_THREAD
    #include <cstdint>
    #include <cmath>
    #include <array>
    #include <iostream>
    #include <cassert>
#endif

#define JT_UINT32_MAX 0xffffffffUL
#define JT_UINT64_MAX 0xffffffffffffffffULL

#include <simd/simd.h>
using namespace simd;

#ifdef __METAL_VERSION__
// Redefine SIMD functions that are missing in Metal...
namespace metal
{
    constexpr inline float2 make_float2(float x, float y) { return float2(x, y); }
    constexpr inline float3 make_float3(float x, float y, float z) { return float3(x, y, z); }
    constexpr inline float4 make_float4(float x, float y, float z, float w) { return float4(x, y, z, w); }

    constexpr inline float4 make_float4(float3 xyz, float w) { return float4(xyz, w); }

    inline bool equal(float2 x, float2 y) { return (x.x == y.x && x.y == y.y); }
    inline bool equal(float3 x, float3 y) { return (equal(x.xy, y.xy) && x.z == y.z); }
    inline bool equal(float4 x, float4 y) { return (equal(x.xyz, y.xyz) && x.w == y.w); }
}
#endif

namespace jt
{

// Define fixed width integer types - because the world still hasn't agreed on
// how to name them or which ones to define.
#ifdef __METAL_VERSION__
    #define JT_DBG(x)

    using int8 = int8_t;
    using int16 = int16_t;
    using int32 = int32_t;
    using int64 = ptrdiff_t;

    using uint8 = uint8_t;
    using uint16 = uint16_t;
    using uint32 = uint32_t;
    using uint64 = size_t;

    template <class T, size_t N>
    using array = metal::array<T, N>;
#else
    #define JT_DBG(x) std::cout << x << std::endl;

    using int8 = std::int8_t;
    using int16 = std::int16_t;
    using int32 = std::int32_t;
    using int64 = std::int64_t;

    using uint8 = std::uint8_t;
    using uint16 = std::uint16_t;
    using uint32 = std::uint32_t;
    using uint64 = std::uint64_t;

    template <class T, size_t N>
    using array = std::array<T, N>;
#endif

    namespace Math
    {
#ifdef __METAL_VERSION__
        using metal::sqrt;
        using metal::cos;
        using metal::acos;
#else
        using std::sqrt;
        using std::cos;
        using std::acos;
#endif

        template<typename T>
        inline T square(T x)
        {
            return x * x;
        }

        template<typename T, typename V>
        inline T angleBetween(V v1, V v2)
        {
            return acos(dot(v1, v2) / (length(v1) * length(v2)));
        }

        template<typename T>
        inline T reflect(T i, T n)
        {
            // Assert because I know I'm going to mess this up at some point...
            assert(normalize(n) == n);
            return i - (2 * dot(n, i) * n);
        }

        inline float power(float x, uint32 n)
        {
            // Use iterative exponentiation by squaring.
            if (n == 0)
            {
                return 1.0f;
            }

            float y = 1.0f;
            while (n > 1)
            {
                if (n % 2)
                {
                    x *= x;
                    n /= 2;
                }
                else
                {
                    y *= x;
                    x *= x;
                    n = (n - 1) / 2;
                }
            }

            return x * y;
        }

        float3 slerp(float3 x, float3 y, float t);
        {
            assert(normalize(x) == x);
            assert(normalize(y) == y);
            assert(0.0f <= t && t <= 1.0f);
            float omega = acos(dot(x, y));
            float comp1 = (sin((1 - t) * omega) / sin(omega)) * x;
            float comp2 = (sin(t * omega) / sin(omega)) * y;
            return comp1 + comp2;
        }

        namespace Fast
        {
            inline float floor(float x)
            {
                int64 xInt = static_cast<int64>(x);
                if (xInt == x)
                    return x;
                else if (x > 0)
                    return static_cast<float>(x);
                else
                    return static_cast<float>(xInt - 1);
            }

            // log2, pow2, pow are based on
            // http://www.dctsystems.co.uk/Software/power.c
            // and I'm not going to pretend I understand how they work.
            inline float log2(float x)
            {
                const float logBodge = 0.346607f;
                float y, z;
                y = *(JT_THREAD int*)&x;
                y *= 1.0 / (1 << 23);
                y = y - 127;
                z = y - floor(y);
                z = (z - z * z) * logBodge;
                return y + z;
            }

            inline float pow2(float x)
            {
                const float powBodge = 0.33971f;
                float y, z;
                z = x - floor(x);
                z = (z - z * z) * powBodge;
                y = x + 127 - z;
                y *= (1 << 23);
                *(JT_THREAD int*)&y = (int)y;
                return y;
            }

            inline float pow(float x, float y)
            {
                return pow2(y * log2(x));
            }
        }

        namespace Constants
        {
#ifdef __METAL_VERSION__
            JT_CONSTANT const float pi = M_PI_F;
#else
            const float pi = M_PI;
#endif
        }
    }

}
