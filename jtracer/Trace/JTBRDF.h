//
//  JTBRDF.h
//  jtracer
//
//  Created by Jonathon Racz on 1/11/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//


#include <simd/simd.h>

namespace jt
{

// Based on the disney microfacet model.
class BRDF
{
public:
    static float calcBRDF(simd::vec3 light, simd::vec3 view, simd::vec3 normal)
    {
        simd::vec3 half = (light + view) /
    }

private:
};

}
