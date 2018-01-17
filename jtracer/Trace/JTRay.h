//
//  JTRay.h
//  jtracer
//
//  Created by Jonathon Racz on 1/15/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"

namespace jt
{

class Ray
{
public:
    Ray() = default;
    Ray(JT_THREAD const float3& origin, JT_THREAD const float3& direction) :
        a(origin), b(direction) {}
    ~Ray() = default;

    float3 origin() const { return a; }
    float3 direction() const { return b; }
    float3 pointAtParam(float t) const { return a + (b * t); }
    float3 directionAtOrigin() const { return b - a; }

    void moveToOrigin() { b -= a; a = make_float3(0.0f, 0.0f, 0.0f); }
    void normalize() { b = simd::normalize(b - a) + a; }

    bool isAtOrigin() const { return equal(a, make_float3(0.0f, 0.0f, 0.0f)); }

    Ray normalized() const { Ray ret = *this; ret.normalize(); return ret; }

    float3 a;
    float3 b;
};

}
