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
    CGContextRef _context;
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
    size_t bitsPerComponent = sizeof(float) * 8;
    size_t bitsPerPixel = bitsPerComponent * 4;
    size_t bytesPerRow = (bitsPerPixel / 8) * width;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapFloatComponents | kCGBitmapByteOrder32Host;

    if (renderer.frameBufferResized) {
        if (_context)
            CGContextRelease(_context);

        _context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);

        CGFloat red[4] = { 1.0f, 0.0f, 0.0f, 1.0f };
        CGContextSetFillColorSpace(_context, colorSpace);
        CGContextSetFillColor(_context, red);
        CGContextFillRect(_context, CGRectMake(0, 0, width, height));
    }

    simd::packed::float4 *pixelData = (simd::packed::float4 *)CGBitmapContextGetData(_context);
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

    CGColorSpaceRelease(colorSpace);
    [_backingLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    assert(layer == _backingLayer);
    CGImageRef currentContext = CGBitmapContextCreateImage(_context);
    CGContextDrawImage(ctx, layer.bounds, currentContext);
    CGImageRelease(currentContext);
}

@end
