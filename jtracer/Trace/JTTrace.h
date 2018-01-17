//
//  JTTrace.h
//  jtracer
//
//  Created by Jonathon Racz on 1/13/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"
#include "JTShaderTypes.h"
#include "JTRay.h"
#include "JTSphere.h"

namespace jt
{

class Trace
{
public:
    Trace() = default;
    ~Trace() = default;

    float4 runTrace(JT_CONSTANT const Uniforms& uniforms, uint2 pos, uint2 dimensions)
    {
        //float randomSeed = OpenSimplex::Noise::noise2(uniforms.context, pos.x, pos.y);

        float u = pos.x / static_cast<float>(dimensions.x);
        float v = pos.y / static_cast<float>(dimensions.y);

        float3 lowerLeftCorner = make_float3(-2.0f, -1.0f, -1.0f);
        float3 horizontalSpan = make_float3(4.0f, 0.0f, 0.0f);
        float3 verticalSpan = make_float3(0.0f, 2.0f, 0.0f);
        float3 origin = make_float3(0.0f, 0.0f, 0.0f);
        Ray mainRay(origin, lowerLeftCorner + (u * horizontalSpan) + (v * verticalSpan));

        // Create a sphere world.
        SphereList world(uniforms.spheres, sizeof(uniforms.spheres) / sizeof(uniforms.spheres[0]));

        // Perform a single path trace with a fallback to drawing the background
        // gradient.
        Sphere::HitRecord hitRecord;
        float3 color;
        if (world.hitTest(mainRay, hitRecord))
        {
            color = 0.5f * (hitRecord.normal + 1);
        }
        else
        {
            // Draw background gradient.
            float3 unitDirection = normalize(mainRay.directionAtOrigin());
            float normalizedY = (unitDirection.y + 1.0f) / 2.0f;
            color = ((1.0f - normalizedY) * make_float3(1.0f, 1.0f, 1.0f)) + (normalizedY * make_float3(0.5f, 0.7f, 1.0f));
        }

        return make_float4(color, 1.0f);
    }
};

}
