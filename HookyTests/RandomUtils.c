//
//  RandomUtils.c
//  Hooky
//
//  Created by Suewon Bahng on 3/19/16.
//  Copyright © 2016 bsw_corporation. All rights reserved.
//

#include <stdlib.h>

float randomBetweenZeroAndOne() {
    return (rand() % 0xffff) / (float)0xffff;
}

int randomInteger(int lowerBound, int upperBound) {
    int range = upperBound - lowerBound;
    return lowerBound + range * randomBetweenZeroAndOne();
}

float randomFloat(float lowerBound, float upperBound) {
    float range = upperBound - lowerBound;
    return lowerBound + range * randomBetweenZeroAndOne();
}
