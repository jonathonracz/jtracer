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
#include "JTNumerics.h"
#include "JTBackgroundGradient.h"

namespace jt
{

namespace Trace
{

float4 runTrace(JT_CONSTANT const Uniforms& uniforms, uint2 pos, uint2 dimensions)
{
    PRNG random = PRNG(OpenSimplex::Noise::noise2(uniforms.context, pos.x, pos.y));

    // Create a sphere world.
    Camera camera;
    SphereList world(uniforms.spheres, sizeof(uniforms.spheres) / sizeof(uniforms.spheres[0]));
    BackgroundGradient gradient { make_float3(0.5f, 0.7f, 1.0f), make_float3(1.0f, 1.0f, 1.0f) };

    // Perform Path trace with a fallback to drawing the background.
    Sphere::HitRecord hitRecord;
    float3 color = make_float3(0.0f, 0.0f, 0.0f);
    size_t samplesPerPixel = 128;
    for (size_t i = 0; i < samplesPerPixel; ++i) {
        float u = (pos.x + random.nextNormalized()) / static_cast<float>(dimensions.x);
        float v = (pos.y + random.nextNormalized()) / static_cast<float>(dimensions.y);
        Ray mainRay = camera.makeRay(u, v);
        if (world.hitTest(mainRay, hitRecord))
            color += 0.5f * (hitRecord.normal + 1);
        else
            color += gradient.color(mainRay);
    }

    color /= samplesPerPixel;

    return make_float4(color, 1.0f);
}

}

}
