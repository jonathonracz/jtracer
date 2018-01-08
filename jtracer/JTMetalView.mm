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

#include "OpenSimplex/OpenSimplex.h"
#include "JTShaderTypes.h"
#include "JTBindPoints.h"

@interface JTMetalView () {
    __weak CAMetalLayer *_metalLayer;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLComputePipelineState> _pipelineState;
    BOOL _needsFramebufferResize;
    jt::Uniforms _uniforms;

#ifdef TARGET_OS_MAC
    CVDisplayLinkRef _displayLink;
    dispatch_source_t _displaySource;
#endif
}

@end

@implementation JTMetalView

#ifdef TARGET_OS_MAC
static CVReturn dispatchRefreshLoop(CVDisplayLinkRef displayLink,
                                    const CVTimeStamp *now,
                                    const CVTimeStamp *outputTime,
                                    CVOptionFlags flagsIn,
                                    CVOptionFlags *flagsOut,
                                    void *displayLinkContext)
{
    __weak dispatch_source_t source = (__bridge dispatch_source_t)displayLinkContext;
    dispatch_source_merge_data(source, 1);
    return kCVReturnSuccess;
}
#endif

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        _uniforms.frameCount = 0;

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

        // Setup our refresh via a displaylink.
#ifdef TARGET_OS_MAC
        _displaySource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
        __block JTMetalView *weakSelf = self;
        dispatch_source_set_event_handler(_displaySource, ^{
            [weakSelf render];
        });
        dispatch_resume(_displaySource);

        CVReturn cvRet;
        cvRet = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        assert(cvRet == kCVReturnSuccess);
        cvRet = CVDisplayLinkSetOutputCallback(_displayLink, &dispatchRefreshLoop, (__bridge void *)_displaySource);
        assert(cvRet == kCVReturnSuccess);

        CVDisplayLinkStart(_displayLink);
#endif
    }

    return self;
}

- (void)render {
    @autoreleasepool {
        OpenSimplex::Seed::computeContextForSeed(_uniforms.context, _uniforms.frameCount);
        _uniforms.random = arc4random();

        if (_needsFramebufferResize) {
            CGSize newFramebufferSize = self.bounds.size;

#ifdef TARGET_OS_MAC
            NSScreen *screen = self.window.screen ?: [NSScreen mainScreen];

            CVReturn cvRet;
            cvRet = CVDisplayLinkSetCurrentCGDisplay(_displayLink, (CGDirectDisplayID)((NSNumber *)screen.deviceDescription[@"NSScreenNumber"]).intValue);
            assert(cvRet == kCVReturnSuccess);

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
        [commandEncoder setBytes:&_uniforms length:sizeof(jt::Uniforms) atIndex:jt::BufferIndex::uniforms];
        [commandEncoder setTexture:texture atIndex:jt::TextureIndex::output];

        MTLSize threadsPerThreadGroup = MTLSizeMake(_pipelineState.threadExecutionWidth, _pipelineState.maxTotalThreadsPerThreadgroup / _pipelineState.threadExecutionWidth, 1);
        MTLSize threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1);
        [commandEncoder dispatchThreads:threadsPerGrid threadsPerThreadgroup:threadsPerThreadGroup];

        [commandEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];
        [commandBuffer commit];

        _uniforms.frameCount++;
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
