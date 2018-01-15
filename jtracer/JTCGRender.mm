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

@interface JTCGRender () <CALayerDelegate> {
    std::vector<float> _frameBufferData;
    CGDataProviderRef _frameBufferDataProvider;
    CGImageRef _frameBuffer;
    CALayer *_backingLayer;
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

    simd::packed::float4 *pixelData = (simd::packed::float4 *)_frameBufferData.data();
    for (size_t y = 0; y < height; ++y) {
        for (size_t x = 0; x < width; ++x) {
            simd::uint2 pos;
            pos.x = (unsigned int)x;
            pos.y = (unsigned int)y;
            simd::uint2 dimensions;
            dimensions.x = (unsigned int)width;
            dimensions.y = (unsigned int)height;
            jt::Trace trace;
            *pixelData = trace.runTrace(*state.uniforms, pos, dimensions);
            pixelData++;
        }
    }

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
