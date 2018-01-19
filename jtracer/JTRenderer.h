//
//  JTRenderer.h
//  jtracer
//
//  Created by Jonathon Racz on 1/12/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "JTRenderState.h"
#import "JTDisplayLink.h"

@class JTRenderer;

@protocol JTRendererDelegate

@required
- (CALayer *)backingLayer;
- (void)render:(JTRenderer *)renderer state:(JTRenderState *)state sender:(JTDisplayLink *)sender;
- (CFTimeInterval)lastRenderTime;

@end

@interface JTRenderer : NSView

@property (weak, nonatomic) id<JTRendererDelegate> delegate;
@property (readonly) BOOL frameBufferResized;
@property (readonly) CGSize frameBufferSize;

- (void)render:(JTRenderState *)state sender:(JTDisplayLink *)sender;

@end
