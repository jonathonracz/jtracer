//
//  JTCamera.h
//  jtracer
//
//  Created by Jonathon Racz on 1/18/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#include "JTRay.h"

namespace jt
{

class Camera
{
public:
    Camera() = default;
    ~Camera() = default;

    // Eye-space ray for the given image-space (u, v).
    Ray makeRay(float u, float v) const
    {
        return Ray(origin, bottomLeft + (u * horizontalSpan) + (v * verticalSpan));
    }

    float3 origin = make_float3(0.0f, 0.0f, 0.0f);
    float3 bottomLeft = make_float3(-2.0f, -1.0f, -1.0f);
    float3 horizontalSpan = make_float3(4.0f, 0.0f, 0.0f);
    float3 verticalSpan = make_float3(0.0f, 2.0f, 0.0f);
};

}
