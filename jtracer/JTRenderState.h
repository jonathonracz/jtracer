//
//  JTRenderState.h
//  jtracer
//
//  Created by Jonathon Racz on 1/12/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "JTShaderTypes.h"

@interface JTRenderState : NSObject

- (void)update:(float)deltaSeconds;

@property (readonly, nonatomic) jt::Uniforms* uniforms;

@end
