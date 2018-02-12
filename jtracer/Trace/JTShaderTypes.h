//
//  JTShaderTypes.h
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#pragma once

#include "JTTypes.h"
#include "JTSphereList.h"
#include "OpenSimplex/OpenSimplex.h"

namespace jt
{

struct Uniforms
{
    OpenSimplex::Context context;
    uint32 frameCount = 0;
    uint32 random;
    Sphere spheres[4];
};

}
