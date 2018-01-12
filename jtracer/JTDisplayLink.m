//
//  JTDisplayLink.m
//  jtracer
//
//  Created by Jonathon Racz on 1/11/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import "JTDisplayLink.h"

@interface JTDisplayLink () {
#ifdef TARGET_OS_MAC
    CVDisplayLinkRef _displayLink;
    dispatch_source_t _displaySource;
#endif
}

@end

@implementation JTDisplayLink

#ifdef TARGET_OS_MAC
- (void)setScreen:(NSScreen *)screen {
    [self setDisplayID:(CGDirectDisplayID)((NSNumber *)screen.deviceDescription[@"NSScreenNumber"]).intValue];
}

- (void)setDisplayID:(CGDirectDisplayID)displayID {
    CVReturn cvRet;
    cvRet = CVDisplayLinkSetCurrentCGDisplay(_displayLink, displayID);
    assert(cvRet == kCVReturnSuccess);
}
#endif

+ (JTDisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel {
    return [[JTDisplayLink alloc] initWithTarget:target selector:sel];
}

#ifdef TARGET_OS_MAC
static CVReturn dispatchRefreshLoop(CVDisplayLinkRef displayLink,
                                    const CVTimeStamp *now,
                                    const CVTimeStamp *outputTime,
                                    CVOptionFlags flagsIn,
                                    CVOptionFlags *flagsOut,
                                    void *displayLinkContext)
{
    __weak dispatch_source_t source = (__bridge dispatch_source_t)displayLinkContext;
    dispatch_source_merge_data(source, 1);
    return kCVReturnSuccess;
}
#endif

- (id)initWithTarget:(id)target selector:(SEL)sel {
    self = [super init];
    if (self) {
#ifdef TARGET_OS_MAC
        // Setup our refresh via a displaylink.
        _displaySource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
        __block JTDisplayLink *weakSelf = self;
        dispatch_source_set_event_handler(_displaySource, ^{
            IMP imp = [target methodForSelector:sel];
            void (*func)(id, SEL, JTDisplayLink *) = (void *)imp;
            func(target, sel, weakSelf);
        });
        dispatch_resume(_displaySource);

        CVReturn cvRet;
        cvRet = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        assert(cvRet == kCVReturnSuccess);
        cvRet = CVDisplayLinkSetOutputCallback(_displayLink, &dispatchRefreshLoop, (__bridge void *)_displaySource);
        assert(cvRet == kCVReturnSuccess);

        CVDisplayLinkStart(_displayLink);
#endif
    }

    return self;
}

@end
