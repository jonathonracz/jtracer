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
