//
//  AppDelegate.h
//  RegulaFalsi
//
//  Created by Dominik Grygiel on 12.12.2013.
//  Copyright (c) 2013 Dominik Grygiel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *solveButton;

@property (weak) IBOutlet NSTextField *x5ParamField;
@property (weak) IBOutlet NSTextField *x4ParamField;
@property (weak) IBOutlet NSTextField *x3ParamField;
@property (weak) IBOutlet NSTextField *x2ParamField;
@property (weak) IBOutlet NSTextField *xParamField;
@property (weak) IBOutlet NSTextField *constParamField;

@property (weak) IBOutlet NSTextField *intervalAField;
@property (weak) IBOutlet NSTextField *intervalBField;
@property (weak) IBOutlet NSTextField *maxIterationsField;
@property (weak) IBOutlet NSTextField *deltaField;
@property (weak) IBOutlet NSTextField *solutionField;
@property (weak) IBOutlet NSButton *intervalArithmeticsCheckbox;


- (IBAction)selectedRadio:(id)sender;
- (IBAction)solve:(id)sender;

@end
