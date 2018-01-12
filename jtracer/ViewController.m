//
//  ViewController.m
//  jtracer
//
//  Created by Jonathon Racz on 12/20/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import "ViewController.h"
#import "JTDisplayLink.h"
#import "JTMetalView.h"

@interface ViewController ()

@property (weak) IBOutlet JTMetalView *metalView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
