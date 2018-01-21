//
//  JTRenderViewController.mm
//  jtracer
//
//  Created by Jonathon Racz on 12/20/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import "JTRenderViewController.h"
#import "JTDisplayLink.h"
#import "JTMetalRender.h"
#import "JTCGRender.h"
#import "JTRenderState.h"

@interface JTRenderViewController () {
    JTRenderState *_renderState;
    JTDisplayLink *_displayLink;
    JTMetalRender *_metalView;
    JTCGRender *_cgView;
}

@property (weak) IBOutlet JTRenderer *metalRenderer;
@property (weak) IBOutlet JTRenderer *cgRenderer;

@end

@implementation JTRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _renderState = [JTRenderState new];
    _displayLink = [JTDisplayLink displayLinkWithTarget:self selector:@selector(renderViews:)];
    _metalView = [JTMetalRender new];
    _cgView = [JTCGRender new];

    self.metalRenderer.delegate = _metalView;
    self.cgRenderer.delegate = _cgView;
}

- (void)renderViews:(JTDisplayLink *)sender {
    [_renderState update:_displayLink.timestamp];
    [self.metalRenderer render:_renderState sender:_displayLink];
    [self.cgRenderer render:_renderState sender:_displayLink];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
