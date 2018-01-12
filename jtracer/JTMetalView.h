//
//  JTMetalView.h
//  jtracer
//
//  Created by Jonathon Racz on 1/3/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JTRenderState.h"
#import "JTDisplayLink.h"

@interface JTMetalView : NSView

- (void)render:(JTRenderState *)state sender:(JTDisplayLink *)sender;

@end
