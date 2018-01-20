//
//  JTMetalRender.m
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTMetalRender.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "JTShaderTypes.h"
#include "JTBindPoints.h"

@interface JTMetalRender () {
    CAMetalLayer *_metalLayer;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLComputePipelineState> _pipelineState;
    CFTimeInterval _renderTime;
}

@end

@implementation JTMetalRender

- (id)init {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _metalLayer = [CAMetalLayer new];
        _renderTime = INFINITY;

        _metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        _metalLayer.framebufferOnly = NO;

        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> jtKernel = [defaultLibrary newFunctionWithName:@"runTraceMetal"];

        NSError *error = nil;
        _pipelineState = [_device newComputePipelineStateWithFunction:jtKernel error:&error];
        if (!_pipelineState) {
            NSLog(@"Compute pipeline creation failed! %@", error);
            return nil;
        }

        _commandQueue = [_device newCommandQueue];
    }

    return self;
}

- (CALayer *)backingLayer {
    return _metalLayer;
}

- (CFTimeInterval)lastRenderTime {
    return _renderTime;
}

- (void)render:(JTRenderer *)renderer state:(JTRenderState *)state sender:(JTDisplayLink *)sender {
    @autoreleasepool {
        if (renderer.frameBufferResized) {
            _metalLayer.drawableSize = renderer.frameBufferSize;
        }

        id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
        if (!drawable)
            return;

        id<MTLTexture> texture = drawable.texture;

        id<MTLCommandBuffer> commandBuffer = _commandQueue.commandBuffer;
        id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
        [commandEncoder setComputePipelineState:_pipelineState];
        [commandEncoder setBytes:state.uniforms length:sizeof(jt::Uniforms) atIndex:jt::BufferIndex::uniforms];
        [commandEncoder setTexture:texture atIndex:jt::TextureIndex::output];

        MTLSize threadsPerThreadGroup = MTLSizeMake(_pipelineState.threadExecutionWidth, _pipelineState.maxTotalThreadsPerThreadgroup / _pipelineState.threadExecutionWidth, 1);
        MTLSize threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1);
        [commandEncoder dispatchThreads:threadsPerGrid threadsPerThreadgroup:threadsPerThreadGroup];

        [commandEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];

        __block NSDate* renderStartTime = [NSDate new];
        [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
            _renderTime = [renderStartTime timeIntervalSinceNow];
        }];
        [commandBuffer commit];
    }
}

@end
