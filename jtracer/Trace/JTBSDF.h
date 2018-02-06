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
    float roughness;
};

inline float3 scatter(JT_THREAD PRNG& random, JT_THREAD const Parameters* params, float3 incidentRay, float3 normal)
{
    float3 ret = make_float3(0.0f, 0.0f, 0.0f);
    ret += random.generateInUnitSphere();
    
    return ret;
}

};

}
