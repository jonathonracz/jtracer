//
//  JTRenderState.mm
//  jtracer
//
//  Created by Jonathon Racz on 1/12/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTRenderState.h"

@interface JTRenderState () {
    std::unique_ptr<jt::Uniforms> _uniformsInternal;
}

@end

@implementation JTRenderState

- (id)init {
    self = [super init];
    if (self) {
        _uniformsInternal = std::unique_ptr<jt::Uniforms>(new jt::Uniforms);
        _uniformsInternal->spheres[0] = jt::Sphere(make_float3(-1.0f, 0.0f, -1.0f), 0.5f);
        _uniformsInternal->spheres[1] = jt::Sphere(make_float3(0.0f, 0.0f, -1.0f), 0.5f);
        _uniformsInternal->spheres[2] = jt::Sphere(make_float3(1.0f, 0.0f, -1.0f), 0.5f);
        _uniformsInternal->spheres[3] = jt::Sphere(make_float3(0.0f, -100.5f, -1.0f), 100.0f);


        _uniformsInternal->spheres[0].materialParams.albedo = make_float3(1.0f, 0.0f, 0.0f);
        _uniformsInternal->spheres[0].materialParams.roughness = 0.0f;
        _uniformsInternal->spheres[0].materialParams.reflectivity = 1.0f;

        _uniformsInternal->spheres[1].materialParams.albedo = make_float3(0.0f, 1.0f, 0.0f);
        _uniformsInternal->spheres[1].materialParams.roughness = 0.25f;
        _uniformsInternal->spheres[1].materialParams.reflectivity = 0.5f;

        _uniformsInternal->spheres[2].materialParams.albedo = make_float3(0.0f, 0.0f, 1.0f);
        _uniformsInternal->spheres[2].materialParams.roughness = 1.0f;
        _uniformsInternal->spheres[2].materialParams.reflectivity = 1.0f;
    }

    return self;
}

- (jt::Uniforms *)uniforms {
    return _uniformsInternal.get();
}

- (void)update:(float)deltaSeconds {
    _uniformsInternal->frameCount++;
    _uniformsInternal->random = arc4random();
    OpenSimplex::Seed::computeContextForSeed(_uniformsInternal->context, _uniformsInternal->frameCount);
}

@end
