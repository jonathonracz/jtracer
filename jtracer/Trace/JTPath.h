//
//  JTPath.h
//  jtracer
//
//  Created by Jonathon Racz on 1/19/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"
#include "JTRay.h"
#include "JTBackgroundGradient.h"

namespace jt
{

class Path
{
public:
    Path(JT_THREAD PRNG& _random, JT_THREAD const BackgroundGradient& _background, JT_THREAD const SphereList& _sphereList) :
        random(_random), background(_background), sphereList(_sphereList)
    {
    }

    float3 trace(Ray ray)
    {
        Sphere::HitRecord hitRecord;

        uint64 numBounces = 0;
        float3 colorAccumulator = make_float3(0.0f, 0.0f, 0.0f);
        float reflection = 1.0f;
        float currentIOR = 1.0f;

        float3 finalRayColor = make_float3(0.0f, 0.0f, 0.0f);
        bool finalColorComputed = false;

        do
        {
            bool didHit = sphereList.hitTest(ray, hitRecord, 0.001f);
            if (didHit && reflection > 0.0f)
            {
                numBounces++;
                colorAccumulator += hitRecord.materialParams.albedo;
                reflection *= hitRecord.materialParams.reflectivity; // TODO: Fresnel-based reflection
                float3 incident = normalize(ray.directionAtOrigin());
                float3 scattered = BSDF::scatter(random, hitRecord.materialParams, incident, hitRecord.normal);
                float3 target = hitRecord.p + (hitRecord.normal * 0.5f) + scattered;
                ray = Ray(hitRecord.p, target - hitRecord.p);
            }
            else
            {
                float3 lightColor = background.color(ray);
                if (numBounces > 0)
                    finalRayColor = lightColor * (colorAccumulator / numBounces) * reflection;
                else
                    finalRayColor = lightColor;

                finalColorComputed = true;
            }
        }
        while (!finalColorComputed);

        return finalRayColor;
    }

private:
    JT_THREAD PRNG& random;
    JT_THREAD const BackgroundGradient& background;
    JT_THREAD const SphereList& sphereList;
};

}
