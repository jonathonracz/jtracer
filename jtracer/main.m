//
//  main.m
//  jtracer
//
//  Created by Jonathon Racz on 12/19/17.
//  Copyright © 2017 jonathonracz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        AppDelegate *appDelegate = [AppDelegate new];
        [NSApplication sharedApplication].delegate = appDelegate;
        return NSApplicationMain(argc, argv);
    }
}
