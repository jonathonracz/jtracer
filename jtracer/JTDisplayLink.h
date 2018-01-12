//
//  JTDisplayLink.h
//  jtracer
//
//  Created by Jonathon Racz on 1/11/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JTDisplayLink : NSObject

#ifdef TARGET_OS_MAC
- (void)setScreen:(NSScreen *)screen;
@property (nonatomic) CGDirectDisplayID displayID;
#endif

@property (nonatomic) float deltaSeconds;

+ (JTDisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel;

@end
