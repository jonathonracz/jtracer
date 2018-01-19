//
//  JTBackgroundGradient.h
//  jtracer
//
//  Created by Jonathon Racz on 1/18/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

namespace jt
{

class BackgroundGradient
{
public:
    BackgroundGradient() = default;
    ~BackgroundGradient() = default;

    float3 color(JT_THREAD const Ray& ray) const
    {
        float3 unitDirection = normalize(ray.directionAtOrigin());
        float normalizedY = (unitDirection.y + 1.0f) / 2.0f;
        return ((1.0f - normalizedY) * bottomColor) + (normalizedY * topColor);
    }

    float3 topColor;
    float3 bottomColor;
};

}
