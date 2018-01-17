//
//  JTSphere.h
//  jtracer
//
//  Created by Jonathon Racz on 1/16/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"
#include "JTRay.h"

namespace jt
{

class Sphere
{
public:
    struct HitRecord
    {
        float t;
        float3 p;
        float3 normal;
    };

    Sphere() = default;
    Sphere(float3 _center, float _radius) :
        center(_center), radius(_radius) {}
    ~Sphere() = default;

    bool hitTest(JT_THREAD const Ray& ray, JT_THREAD HitRecord& record, float tMin = 0.0f, float tMax = INFINITY) const
    {
        float3 originCenter = ray.origin() - center;
        float a = dot(ray.direction(), ray.direction());
        float b = dot(originCenter, ray.direction());
        float c = dot(originCenter, originCenter) - (radius * radius);
        float discriminant = (b * b) - (a * c);
        if (discriminant > 0)
        {
            float root1 = (-b - sqrt((b * b) - (4 * a * c))) / (2 * a);
            if (root1 < tMax && root1 > tMin)
            {
                record.t = root1;
                record.p = ray.pointAtParam(root1);
                record.normal = (record.p - center) / radius;
                return true;
            }

            float root2 = (-b + sqrt((b * b) - (4 * a * c))) / (2 * a);
            if (root2 < tMax && root2 > tMin)
            {
                record.t = root2;
                record.p = ray.pointAtParam(root2);
                record.normal = (record.p - center) / radius;
                return true;
            }
        }

        return false;
    }

    float3 center;
    float radius;
};

}
