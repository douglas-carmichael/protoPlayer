//
//  ViewController.h
//  protoPlayer
//
//  Created by Douglas Carmichael on 1/22/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "xmpPlayer.h"

xmpPlayer *ourPlayer;

@interface ViewController : NSViewController

{
    IBOutlet NSTextField *moduleName;
    IBOutlet NSTextField *patternRow;
    IBOutlet NSSlider *musicSlider;
    
}
-(IBAction)playbackControl:(id)sender;
-(IBAction)loadProto:(id)sender;

@end

