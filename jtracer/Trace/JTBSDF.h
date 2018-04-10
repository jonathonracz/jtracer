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
    float3 albedo = make_float3(1.0f, 1.0f, 1.0f);
    float roughness = 1.0f;
    float reflectivity = 0.5f;
    float ior = 1.1f;
    float transparency = 0.0f;
};

inline float3 scatter(JT_THREAD PRNG& random, JT_THREAD const Parameters& params, JT_THREAD const float3& incident, JT_THREAD const float3& normal)
{
    bool isReflection = random.generateNormalNotIncluding1() > params.transparency;

    float3 scattered = make_float3(0.0f, 0.0f, 0.0f);

    //if (isReflection)
    {
        float3 reflection = Math::reflect(incident, normal);
        float3 diffuse = random.generateInUnitSphere();
        // Make sure the diffuse ray is actually a reflection - i.e. leaving the
        // object.
        if (dot(diffuse, normal) < 0)
            diffuse *= -1.0f;

        // TODO: This may be better off as a slerp so there isn't a lopsided
        // resolution between the center and edges of the interpolation...
        scattered = Math::lerp(reflection, diffuse, params.roughness);
    }
    //else
    {
        // Refraction
    }

    assert(!equal(scattered, make_float3(0.0f, 0.0f, 0.0f)));

    return scattered;
}

};

}
