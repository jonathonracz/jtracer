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
#include "JTPath.h"

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
    const BackgroundGradient gradient { make_float3(0.5f, 0.7f, 1.0f), make_float3(1.0f, 1.0f, 1.0f) };
    Path path(random, gradient, world);

    // Perform Path trace with a fallback to drawing the background.
    float3 pixelColor = make_float3(0.0f, 0.0f, 0.0f);
    size_t samplesPerPixel = 128;
    for (size_t i = 0; i < samplesPerPixel; ++i)
    {
        float u = (pos.x + (random.generateNormal() - 0.5f)) / static_cast<float>(dimensions.x);
        float v = (pos.y + (random.generateNormal() - 0.5f)) / static_cast<float>(dimensions.y);
        Ray ray = camera.makeRay(u, v);

        pixelColor += path.trace(ray);
    }

    pixelColor /= samplesPerPixel;

    // Gamma correct the pixel by converting to linear space lighting.
    // Based on http://frictionalgames.blogspot.com/2013/11/
    pixelColor = pow(pixelColor, float3(1.0f / 2.2f));

    return make_float4(pixelColor, 1.0f);
}

}

}
