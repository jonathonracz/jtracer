//
//  Random.mm
//  jtracerTests
//
//  Created by Jonathon Racz on 1/4/18.
//  Copyright © 2018 jonathonracz. All rights reserved.
//

#import <XCTest/XCTest.h>

#include <simd/simd.h>
#include "JTNumerics.h"
#include "JTShaderTypes.h"

@interface jtracerRandom : XCTestCase

@end

@implementation jtracerRandom

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    jt::Uniforms testUniforms;
    testUniforms.frameCount = 1234;
    testUniforms.random = 0xb5d3a12c;
    simd::uint2 gid;
    for (int i = 0; i < 64; ++i)
    {
        for (int j = 0; j < 64; ++j)
        {
            gid.x = i;
            gid.y = j;
            jt::PRNG random = jt::PRNG(gid, testUniforms);
            NSLog(@"PRNG value: %f", random.nextNormalized());
        }
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
