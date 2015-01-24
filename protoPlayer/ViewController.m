//
//  ViewController.m
//  protoPlayer
//
//  Created by Douglas Carmichael on 1/22/15.
//  Copyright (c) 2015 Douglas Carmichael. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ourPlayer = [[xmpPlayer alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(IBAction)playbackControl:(id)sender
{
    switch ([sender tag]) {
        case 0:
            NSLog(@"Skip Backward.");
            break;
        case 1:
            NSLog(@"Seek Backward.");
            break;
        case 2:
            NSLog(@"Play/Pause.");
            break;
        case 3:
            NSLog(@"Seek Forward.");
            break;
        case 4:
            NSLog(@"Skip Forward.");
            break;
        default:
            break;
    }
}

@end

