//
//  JTTypes.h
//  jtracer
//
//  Created by Jonathon Racz on 1/4/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#ifdef __AIR64__
    #define JT_DEVICE device
    #define JT_THREADGROUP threadgroup
    #define JT_CONSTANT constant
    #define JT_THREAD thread
#elif OPENCL_COMPILER
    #define JT_DEVICE global
    #define JT_THREADGROUP local
    #define JT_CONSTANT constant
    #define JT_THREAD private
#else
    #define JT_DEVICE
    #define JT_THREADGROUP
    #define JT_CONSTANT
    #define JT_THREAD
    #include <cstdint>
    #include <array>
#endif

namespace jt
{
// Define fixed width integer types - because the world still hasn't agreed on
// how to name them or which ones to define.
#ifdef __AIR64__
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
#elif OPENCL_COMPILER

#else
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
}
