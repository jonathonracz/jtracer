//
//  ViewController.m
//  jtracer
//
//  Created by Jonathon Racz on 12/20/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import "ViewController.h"
#import "JTDisplayLink.h"
#import "JTMetalRender.h"
#import "JTRenderState.h"

@interface ViewController () {
    JTRenderState *_renderState;
    JTDisplayLink *_displayLink;
    JTMetalRender *_metalView;
}

@property (weak) IBOutlet JTRenderer *renderer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _renderState = [JTRenderState new];
    _displayLink = [JTDisplayLink displayLinkWithTarget:self selector:@selector(renderViews:)];
    _metalView = [JTMetalRender new];

    self.renderer.delegate = _metalView;
}

- (void)renderViews:(JTDisplayLink *)sender {
    [_renderState update:_displayLink.timestamp];
    [self.renderer render:_renderState sender:_displayLink];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
