//
//  JTMetalView.m
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTMetalView.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "JTShaderTypes.h"
#include "JTBindPoints.h"

@interface JTMetalView () {
    __weak CAMetalLayer *_metalLayer;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLComputePipelineState> _pipelineState;
    BOOL _needsFramebufferResize;
}

@end

@implementation JTMetalView

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();

#ifdef TARGET_OS_MAC
        self.layer = [CAMetalLayer new];
        self.wantsLayer = YES;
        _metalLayer = (CAMetalLayer *)self.layer;
#endif

        _metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        _metalLayer.framebufferOnly = NO;

        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> jtKernel = [defaultLibrary newFunctionWithName:@"jtMetal"];

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

- (void)render:(JTRenderState *)state sender:(JTDisplayLink *)sender {
    @autoreleasepool {
        if (_needsFramebufferResize) {
            CGSize newFramebufferSize = self.bounds.size;

#ifdef TARGET_OS_MAC
            NSScreen *screen = self.window.screen ?: [NSScreen mainScreen];

            [sender setScreen:screen];

            newFramebufferSize.width *= screen.backingScaleFactor;
            newFramebufferSize.height *= screen.backingScaleFactor;
#endif

            _metalLayer.drawableSize = newFramebufferSize;
            _needsFramebufferResize = NO;
        }

        id<CAMetalDrawable> drawable = [_metalLayer nextDrawable];
        id<MTLTexture> texture = drawable.texture;
        NSLog(@"drawable w: %lu h: %lu", texture.width, texture.height);

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
        [commandBuffer commit];
    }
}

#ifdef TARGET_OS_MAC
- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    _needsFramebufferResize = YES;
}

- (void)setBoundsSize:(NSSize)newSize {
    [super setBoundsSize:newSize];
    _needsFramebufferResize = YES;
}
- (void)viewDidChangeBackingProperties {
    [super viewDidChangeBackingProperties];
    _needsFramebufferResize = YES;
}
#endif

@end
