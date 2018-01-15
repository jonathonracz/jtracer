//
//  JTRenderer.m
//  jtracer
//
//  Created by Jonathon Racz on 1/12/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTRenderer.h"

@implementation JTRenderer

@synthesize delegate = _delegate;
@synthesize frameBufferResized = _frameBufferResized;
@synthesize frameBufferSize = _frameBufferSize;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
#ifdef TARGET_OS_MAC
        self.wantsLayer = YES;
#endif
    }

    return self;
}

- (void)setDelegate:(id<JTRendererDelegate>)delegate {
    _delegate = delegate;
    self.layer = delegate.backingLayer;
}

- (void)render:(JTRenderState *)state sender:(JTDisplayLink *)sender {
    if (_frameBufferResized) {
        CGSize newFramebufferSize = self.bounds.size;

#ifdef TARGET_OS_MAC
        NSScreen *screen = self.window.screen ?: [NSScreen mainScreen];

        [sender setScreen:screen];

        newFramebufferSize.width *= screen.backingScaleFactor;
        newFramebufferSize.height *= screen.backingScaleFactor;
        self.layer.contentsScale = screen.backingScaleFactor;
#endif

        _frameBufferSize = newFramebufferSize;
    }

    if (_delegate) {
        [_delegate render:self state:state sender:sender];
    }

    _frameBufferResized = NO;
}

#ifdef TARGET_OS_MAC
- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    _frameBufferResized = YES;
}

- (void)setBoundsSize:(NSSize)newSize {
    [super setBoundsSize:newSize];
    _frameBufferResized = YES;
}
- (void)viewDidChangeBackingProperties {
    [super viewDidChangeBackingProperties];
    _frameBufferResized = YES;
}
#endif

@end
