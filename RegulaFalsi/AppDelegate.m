//
//  AppDelegate.m
//  RegulaFalsi
//
//  Created by Dominik Grygiel on 12.12.2013.
//  Copyright (c) 2013 Dominik Grygiel. All rights reserved.
//

#import "AppDelegate.h"
#import "mpfi.h"
#import "mpfi_io.h"

/* Floating arithmetics */
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


/* Interval arithmetics */
void mpfi_sin_d(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_set_d(ret, sinl(mpfi_get_d(x)));
}
void mpfi_cos_d(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_set_d(ret, cosl(mpfi_get_d(x)));
}
void mpfi_tan_d(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_set_d(ret, tanl(mpfi_get_d(x)));
}
void mpfi_atan_d(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_set_d(ret, atanl(mpfi_get_d(x)));
}

void mpfi_sinXbyX(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_sin_d(ret, x);
    mpfi_div(ret, ret, x);
}
void mpfi_cosXbyX(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_cos_d(ret, x);
    mpfi_div(ret, ret, x);
}
void mpfi_xMinus2TanXPlus1(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_tan_d(ret, x);
    mpfi_mul_d(ret, ret, 2);
    mpfi_sub(ret, x, ret);
    mpfi_add_d(ret, ret, 1);
}
void mpfi_arctanXplus1By2(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_add_d(ret, x, 1);
    mpfi_div_d(ret, ret, 2);
    mpfi_atan_d(ret, ret);
}
void mpfi_sinXMinusEToX(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_sin_d(ret, x);
    mpfi_sub_d(ret, ret, powl(M_E, mpfi_get_d(x)));
}
void mpfi_tanXByX(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_tan_d(ret, x);
    mpfi_div(ret, ret, x);
}
void mpfi_horner(mpfi_ptr ret, mpfi_srcptr x) {
    mpfi_set_d(ret, 0);
    for (int i = 5; i >= 0; i--) {
        mpfi_mul(ret, ret, x);
        mpfi_add_d(ret, ret, coeffs[i]);
    }
}
void (*mpfi_fs[7]) (mpfi_ptr, mpfi_srcptr) = { mpfi_sinXbyX, mpfi_cosXbyX, mpfi_xMinus2TanXPlus1, mpfi_arctanXplus1By2, mpfi_sinXMinusEToX, mpfi_tanXByX, mpfi_horner };



@interface AppDelegate () {
    NSUInteger _selectedEquation;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _selectedEquation = 1;
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

    if (self.intervalArithmeticsCheckbox.state == NSOnState) {
        [self solveWithIntervalArithmetics];
    } else {
        [self solveWithFloatingPrecision];
    }
}

- (void)solveWithFloatingPrecision {
    precision a = [self.intervalAField doubleValue];
    precision b = [self.intervalBField doubleValue];
    precision (*f)(precision) = *fs[_selectedEquation - 1];
    precision x = (a * f(b) - b * f(a)) / (f(b) - f(a));

    long maxIterations = [self.maxIterationsField integerValue];
    long currIteration = 0;
    precision delta = [self.deltaField doubleValue];

    while ((currIteration < maxIterations) && (fabsl(f(x)) > delta)) {
        if (f(a)*f(x) <= 0) {
            x = (x * f(a) - a * f(x)) / (f(a) - f(x));
        } else {
            x = (x * f(b) - b * f(x)) / (f(b) - f(x));
        }
        currIteration++;
    }

    [self.solutionField setStringValue:[NSString stringWithFormat:@"%0.18Lf", (long double)x]];
}

- (void)solveWithIntervalArithmetics {
    mpfi_t a, b, x, x0, temp1, temp2;
    mpfi_init(a);
    mpfi_init(b);
    mpfi_init(x);
    mpfi_init(x0);
    mpfi_init(temp1);
    mpfi_init(temp2);

    mpfi_set_d(a, [self.intervalAField doubleValue]);
    mpfi_set_d(b, [self.intervalBField doubleValue]);
    void (*f)(mpfi_ptr, mpfi_srcptr) = *mpfi_fs[_selectedEquation - 1];
    // x = (a * f(b) - b * f(a)) / (f(b) - f(a))
    f(x, b);
    mpfi_mul(x, a, x);
    f(temp1, a);
    mpfi_mul(temp1, b, temp1);
    mpfi_sub(x, x, temp1);

    f(temp1, b);
    f(temp2, a);
    mpfi_sub(temp1, temp1, temp2);
    mpfi_div(x, x, temp1);
    // x0 = f(x)
    f(x0, x);

    long maxIterations = [self.maxIterationsField integerValue];
    long currIteration = 0;
    double delta = [self.deltaField doubleValue];

    while ((currIteration < maxIterations) && (fabsl(mpfi_get_d(x0)) > delta)) {
        f(temp1, a);
        mpfi_mul(temp2, temp1, x0);
        if (mpfi_get_d(temp1) <= 0) {
            // x = (x * f(a) - a * f(x)) / (f(a) - f(x))
            mpfi_mul(x, x, temp1);
            mpfi_mul(temp2, a, x0);
            mpfi_sub(x, x, temp2);

            mpfi_sub(temp2, temp1, x0);
            mpfi_div(x, x, temp2);
        } else {
            // x = (x * f(b) - b * f(x)) / (f(b) - f(x))
            f(temp1, b);
            mpfi_mul(x, x, temp1);
            mpfi_mul(temp2, b, x0);
            mpfi_sub(x, x, temp2);

            mpfi_sub(temp2, temp1, x0);
            mpfi_div(x, x, temp2);
        }

        f(x0, x);
        currIteration++;
    }

    [self.solutionField setStringValue:[NSString stringWithFormat:@"%0.18f", mpfi_get_d(x)]];

    mpfi_clear(temp2);
    mpfi_clear(temp1);
    mpfi_clear(x0);
    mpfi_clear(x);
    mpfi_clear(b);
    mpfi_clear(a);
}

@end
