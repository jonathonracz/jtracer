//
//  ViewController.m
//  jtracer
//
//  Created by Jonathon Racz on 12/20/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import "ViewController.h"
#import <MetalKit/MetalKit.h>

@interface ViewController ()

@property (weak) IBOutlet MTKView *viewport;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.viewport initWithFrame:self.view.frame device:MTLCreateSystemDefaultDevice()];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
