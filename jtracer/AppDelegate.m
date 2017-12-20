//
//  AppDelegate.m
//  jtracer
//
//  Created by Jonathon Racz on 12/19/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import "AppDelegate.h"
#import <MetalKit/MetalKit.h>

@interface AppDelegate ()

@property NSWindow *window;
@property MTKView *viewport;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 640, 480)
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.showsResizeIndicator = YES;
    self.window.title = [NSRunningApplication currentApplication].localizedName;
    [self.window makeKeyAndOrderFront:self];
    [self.window setFrame:CGRectMake(0, 0, 640, 480) display:NO];

    self.viewport = [[MTKView alloc] initWithFrame:self.window.frame device:MTLCreateSystemDefaultDevice()];
    [self.window.contentView addSubview:self.viewport];

    [self.window.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewport
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.window.contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];

    [self.window.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.viewport
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.window.contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];

    [self.window display];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

@end
