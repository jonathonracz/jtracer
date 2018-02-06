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
#include "JTCamera.h"
#include "JTRandom.h"
#include "JTBackgroundGradient.h"
#include "JTBSDF.h"

namespace jt
{

namespace Trace
{

float4 runTrace(JT_CONSTANT const Uniforms& uniforms, uint2 pos, uint2 dimensions)
{
    //uint32 seedInt = seed * JT_UINT32_MAX;
    PRNG random(pos.x, pos.y);

    // Create a sphere world.
    Camera camera;
    SphereList world(uniforms.spheres, sizeof(uniforms.spheres) / sizeof(uniforms.spheres[0]));
    BackgroundGradient gradient { make_float3(0.5f, 0.7f, 1.0f), make_float3(1.0f, 1.0f, 1.0f) };

    // Perform Path trace with a fallback to drawing the background.
    float3 pixelColor = make_float3(0.0f, 0.0f, 0.0f);
    size_t samplesPerPixel = 128;
    for (size_t i = 0; i < samplesPerPixel; ++i) {
        float u = (pos.x + (random.generateNormal() - 0.5f)) / static_cast<float>(dimensions.x);
        float v = (pos.y + (random.generateNormal() - 0.5f)) / static_cast<float>(dimensions.y);
        Ray ray = camera.makeRay(u, v);
        Sphere::HitRecord hitRecord;
        float3 rayColor = make_float3(0.0f, 0.0f, 0.0f);
        bool didHit = false;
        uint64 numBounces = 0;
        do
        {
            didHit = world.hitTest(ray, hitRecord, 0.001f);
            if (didHit)
            {
                numBounces++;
                float3 incidentRay = normalize(ray.directionAtOrigin());
                float3 normal = hitRecord.normal;
                float3 scattered = BSDF::scatter(random, hitRecord.materialParams, incidentRay, normal);
                float3 target = hitRecord.p + scattered;
                ray = Ray(hitRecord.p, target - hitRecord.p);
            }
            else
            {
                rayColor = gradient.color(ray);
                if (numBounces > 0)
                {
                    rayColor *= (0.5f / numBounces);
                }
            }
        }
        while (didHit);

        pixelColor += rayColor;
    }

    pixelColor /= samplesPerPixel;

    // Gamma correct the pixel by converting to linear space lighting.
    // Based on http://frictionalgames.blogspot.com/2013/11/
    for (int i = 0; i < 3; ++i)
        pixelColor[i] = Math::Fast::pow(pixelColor[i], 1.0f / 2.2f);

    return make_float4(pixelColor, 1.0f);
}

}

}
