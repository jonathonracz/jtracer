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
#include <cstdint>

class DoubleBuffer
{
public:
    struct Buffer
    {
        Buffer(size_t width, size_t height, size_t bitsPerComponent,
               size_t bitsPerPixel, size_t bytesPerRow,
               CGColorSpaceRef _Nullable colorSpace, CGBitmapInfo bitmapInfo)
        {
            if (colorSpace)
                CGColorSpaceRetain(colorSpace);
            else
                colorSpace = CGColorSpaceCreateDeviceRGB();

            data = std::vector<std::uint8_t>(bytesPerRow * height);
            provider = CGDataProviderCreateWithData(NULL, data.data(), data.size(), NULL);
            image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel,
                                  bytesPerRow, colorSpace, bitmapInfo, provider,
                                  NULL, NO, kCGRenderingIntentDefault);

            CGColorSpaceRelease(colorSpace);
        }

        ~Buffer()
        {
            CGImageRelease(image);
            CGDataProviderRelease(provider);
        }

        std::vector<std::uint8_t> data;
        CGDataProviderRef provider;
        CGImageRef image;
        std::mutex lock;
    };

    void swap()
    {
        const std::lock_guard<std::mutex> lock(swapLock);
        std::swap(buffers[0], buffers[1]);
    }

private:
    std::mutex swapLock;
    std::array<std::unique_ptr<Buffer>, 2> buffers;
};

@interface JTCGRender () <CALayerDelegate> {
    std::vector<float> _frameBufferData;
    CGDataProviderRef _frameBufferDataProvider;
    CGImageRef _frameBuffer;
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
    size_t width = renderer.frameBufferSize.width;
    size_t height = renderer.frameBufferSize.height;
    size_t numComponents = 4;
    size_t bytesPerComponent = sizeof(float);
    size_t bitsPerComponent = bytesPerComponent * 8;
    size_t bytesPerPixel = bytesPerComponent * numComponents;
    size_t bitsPerPixel = bytesPerPixel * 8;
    size_t bytesPerRow = bytesPerPixel * width;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host;

    if (renderer.frameBufferResized || !_frameBuffer) {
        if (_frameBufferDataProvider)
            CGDataProviderRelease(_frameBufferDataProvider);

        _frameBufferData = std::vector<float>(width * height * numComponents);
        _frameBufferDataProvider = CGDataProviderCreateWithData(NULL, _frameBufferData.data(), _frameBufferData.size(), NULL);
    }

    size_t pixelsToProcess = width * height;
    uint2 dimensions;
    dimensions.x = (unsigned int)width;
    dimensions.y = (unsigned int)height;

    NSDate* startTime = [NSDate new];
    // TODO: This is embarassingly parallel.
    for (size_t i = 0; i < pixelsToProcess; ++i) {
        size_t x = i % width;
        size_t y = (i - x) / width;
        uint2 pos;
        pos.x = (unsigned int)x;
        pos.y = dimensions.y - (unsigned int)y; // Flip vertically to make bottom left (0,0)
        ((packed::float4 *)_frameBufferData.data())[i] = jt::Trace::runTrace(*state.uniforms, pos, dimensions);
    }
    _lastRenderTime = [startTime timeIntervalSinceNow];

    if (_frameBuffer) {
        CGImageRelease(_frameBuffer);
    }

    _frameBuffer = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, _frameBufferDataProvider, NULL, NO, kCGRenderingIntentDefault);

    CGColorSpaceRelease(colorSpace);
    [_backingLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextDrawImage(ctx, layer.bounds, _frameBuffer);
}

@end
