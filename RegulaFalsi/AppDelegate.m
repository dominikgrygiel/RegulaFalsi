//
//  AppDelegate.m
//  RegulaFalsi
//
//  Created by Dominik Grygiel on 12.12.2013.
//  Copyright (c) 2013 Dominik Grygiel. All rights reserved.
//

#import "AppDelegate.h"

typedef long double precision;
double coeffs[6];
precision sinXbyX(precision x) {
    return sinl(x) / x;
}
precision cosXbyX(precision x) {
    return cosl(x) / x;
}
precision xMinus2TanXPlus1(precision x) {
    return x - 2*tanl(x) + 1;
}
precision arctanXplus1By2(precision x) {
    return atanl((x+1)/2);
}
precision sinXMinusEToX(precision x) {
    return sinl(x) - powl(M_E, x);
}
precision tanXByX(precision x) {
    return tanl(x) / x;
}
precision horner(precision x) {
    precision ret = 0;
    for (int i = 5; i >= 0; i--) {
        ret = ret * x + coeffs[i];
    }

    return ret;
}
precision (*fs[7]) (precision x) = { sinXbyX, cosXbyX, xMinus2TanXPlus1, arctanXplus1By2, sinXMinusEToX, tanXByX, horner };



@interface AppDelegate () {
    NSUInteger _selectedEquation;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _selectedEquation = 1;
    [[self.solveButton.superview viewWithTag:1] setState:NSOnState];
}

- (IBAction)selectedRadio:(id)sender {
    NSButton *button = sender;
    _selectedEquation = button.tag;

    for (int i = 1; i <= 7; i++) {
        if (i != button.tag) {
            NSButton *radio = [button.superview viewWithTag:i];
            radio.state = NSOffState;
        }
    }
}

- (IBAction)solve:(id)sender {
    if (_selectedEquation == 7) {
        coeffs[0] = [self.constParamField doubleValue];
        coeffs[1] = [self.xParamField doubleValue];
        coeffs[2] = [self.x2ParamField doubleValue];
        coeffs[3] = [self.x3ParamField doubleValue];
        coeffs[4] = [self.x4ParamField doubleValue];
        coeffs[5] = [self.x5ParamField doubleValue];
    }

    precision a = [self.intervalAField doubleValue];
    precision b = [self.intervalBField doubleValue];
    precision (*f)(precision) = *fs[_selectedEquation - 1];
    precision x = (a * f(b) - b * f(a)) / (f(b) - f(a));
    precision x0 = f(x);

    long maxIterations = [self.maxIterationsField integerValue];
    long currIteration = 0;
    precision delta = [self.deltaField doubleValue];

    while ((currIteration < maxIterations) && (fabsl(x0) > delta)) {
        if (f(a)*f(x) <= 0) {
            x = (x * f(a) - a * f(x)) / (f(a) - f(x));
        } else {
            x = (x * f(b) - b * f(x)) / (f(b) - f(x));
        }
        currIteration++;
    }

    [self.solutionField setStringValue:[NSString stringWithFormat:@"%0.15Lf", x]];
}

@end
