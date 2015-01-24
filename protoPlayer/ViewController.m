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
        {
            NSLog(@"Skip Backward.");
            break;
        }
        case 1:
        {
            [ourPlayer prevPosition];
            break;
        }
        case 2:
        {
            [sender setState:1];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0), ^{
                [ourPlayer playModule:nil];
            });
            usleep(1000);
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                [musicSlider setMaxValue:ourPlayer->total_time];
                while([ourPlayer isPlaying])
                {
                    usleep(10000);
                    NSString *ourTime = [ourPlayer getTimeString:ourPlayer->time];
                    [patternRow setStringValue:ourTime];
                    [musicSlider setIntValue:ourPlayer->time];
                }
                [musicSlider setIntValue:0];
                [patternRow setStringValue:@""];
            });
            break;
        }
        case 3:
        {
            [ourPlayer stopPlayback];
            break;
        }
        case 4:
        {
            [ourPlayer nextPosition];
            break;
        }
        case 5:
        {
            NSLog(@"Skip Forward.");
            break;
        }
        default:
            break;
    }
}

-(IBAction)loadProto:(id)sender
{
    NSError *ourError = nil;
    NSString *ourModule = @"/Users/dcarmich/true.xm";
    [ourPlayer loadModule:[[NSURL alloc] initFileURLWithPath:ourModule] error:&ourError];
    [moduleName setStringValue:ourPlayer.moduleInfo[@"moduleName"]];
}

@end

