//
//  JTBSDF.h
//  jtracer
//
//  Created by Jonathon Racz on 1/26/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"
#include "JTRandom.h"

namespace jt
{

namespace BSDF
{

struct Parameters
{
    float3 baseColor;
    float roughness = 0.5f;
};

inline float3 scatter(JT_THREAD PRNG& random, JT_THREAD const Parameters* params, float3 incident, float3 normal)
{
    float3 reflection = Math::reflect(incident, normal);
    float3 diffuse = random.generateInUnitSphere();
    float3 scattered = Math::slerp(reflection, diffuse, params->roughness);
    return scattered;
}

};

}
