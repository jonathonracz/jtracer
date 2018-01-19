//
//  JTCGRender.m
//  jtracer
//
//  Created by Jonathon Racz on 1/13/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTCGRender.h"
#import <Quartz/Quartz.h>

#include "JTTrace.h"
#include <simd/simd.h>
#include <vector>

// 32-bit float RGBA image buffer.
class FrameBuffer
{
public:
    FrameBuffer(size_t _width, size_t _height) :
        width(_width), height(_height)
    {
        data = std::vector<float>(width * height * numComponents);
        provider = CGDataProviderCreateWithData(NULL, data.data(), data.size() * sizeof(float), NULL);
    }

    ~FrameBuffer()
    {
        CGColorSpaceRelease(colorSpace);
        CGDataProviderRelease(provider);
    }

    CGImageRef getImage()
    {
        return CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, width * numComponents * sizeof(float), colorSpace, bitmapInfo, provider, NULL, NO, renderingIntent);
    }

    const static size_t numComponents = 4;
    const static size_t bytesPerComponent = sizeof(float);
    const static size_t bitsPerComponent = bytesPerComponent * 8;
    const static size_t bytesPerPixel = bytesPerComponent * numComponents;
    const static size_t bitsPerPixel = bytesPerPixel * 8;
    const static CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host;
    const static CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    size_t width;
    size_t height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    std::vector<float> data;
    CGDataProviderRef provider;
};

@interface JTCGRender () <CALayerDelegate> {
    std::shared_ptr<FrameBuffer> _frameBuffer;
    CALayer *_backingLayer;
    CFTimeInterval _lastRenderTime;
}

@end

@implementation JTCGRender

- (id)init {
    self = [super init];
    if (self) {
        _backingLayer = [CALayer new];
        _backingLayer.delegate = self;
        _backingLayer.actions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"contents", nil];
    }

    return self;
}

- (CALayer *)backingLayer {
    return _backingLayer;
}

- (CFTimeInterval)lastRenderTime {
    return _lastRenderTime;
}

- (void)render:(JTRenderer *)renderer state:(JTRenderState *)state sender:(JTDisplayLink *)sender {
    if (renderer.frameBufferResized || !_frameBuffer) {
        _frameBuffer = std::make_shared<FrameBuffer>(renderer.frameBufferSize.width, renderer.frameBufferSize.height);
    }

    size_t pixelsToProcess = _frameBuffer->width * _frameBuffer->height;
    uint2 dimensions;
    dimensions.x = (unsigned int)_frameBuffer->width;
    dimensions.y = (unsigned int)_frameBuffer->height;

    void (^pixelWork)(size_t) = ^(size_t i){
        size_t x = i % _frameBuffer->width;
        size_t y = (i - x) / _frameBuffer->width;
        uint2 pos;
        pos.x = (unsigned int)x;
        pos.y = dimensions.y - (unsigned int)y; // Flip vertically to make bottom left (0,0)
        ((packed::float4 *)_frameBuffer->data.data())[i] = jt::Trace::runTrace(*state.uniforms, pos, dimensions);
    };

    NSDate* startTime = [NSDate new];
    dispatch_apply(pixelsToProcess, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), pixelWork);
    _lastRenderTime = -[startTime timeIntervalSinceNow];
    NSLog(@"Render time: %f", _lastRenderTime);

    [_backingLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGImageRef displayImage = _frameBuffer->getImage();
    CGContextDrawImage(ctx, layer.bounds, displayImage);
    CGImageRelease(displayImage);
}

@end
