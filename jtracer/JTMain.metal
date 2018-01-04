//
//  JTMain.metal
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "JTShaderTypes.h"

kernel void jtMain(texture2d<half, access::write> output [[texture(JTTextureIndex::output)]],
                   uint2 gid [[thread_position_in_grid]])
{
    // Check if the pixel is within the bounds of the output texture.
    if((gid.x >= output.get_width()) || (gid.y >= output.get_height()))
        return;

    output.write(half4(1.0f, 0.0f, 0.0f, 1.0f), gid);
}
