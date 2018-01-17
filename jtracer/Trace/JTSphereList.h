//
//  JTSphereList.h
//  jtracer
//
//  Created by Jonathon Racz on 1/16/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTSphere.h"

namespace jt
{

class SphereList
{
public:
    SphereList(JT_CONSTANT const Sphere* _spheres, size_t _num) :
        spheres(_spheres), num(_num) {}

    ~SphereList() = default;

    bool hitTest(JT_THREAD const Ray& ray, JT_THREAD Sphere::HitRecord& record, float tMin = 0.0f, float tMax = INFINITY) const
    {
        Sphere::HitRecord tempRecord;
        bool hitSomething = false;
        float tClosest = tMax;
        for (size_t i = 0; i < num; ++i)
        {
            Sphere sphere = spheres[i];
            if (sphere.hitTest(ray, tempRecord, tMin, tClosest))
            {
                hitSomething = true;
                tClosest = tempRecord.t;
                record = tempRecord;
            }
        }
        return hitSomething;
    }

private:
    JT_CONSTANT const Sphere* spheres;
    size_t num;
};

}
