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
