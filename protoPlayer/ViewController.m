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
            [ourPlayer setPosition:0];
            break;
        }
        case 1:
        {
            [ourPlayer prevPosition];
            break;
        }
        case 2:
        {
            if ([ourPlayer isLoaded])
            {
                [self setDragTimeline:YES];
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0), ^{
                    [ourPlayer playModule:nil];
                });
                usleep(1000);
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                    [musicSlider setMaxValue:[[ourPlayer.moduleInfo objectForKey:@"moduleTotalTime"] intValue]];
                    while([ourPlayer isPlaying])
                    {
                        usleep(10000);
                        if ([self dragTimeline])
                        {
                            [musicSlider setIntValue:ourPlayer->time];
                        }
                        [patternRow setStringValue:[ourPlayer getTimeString:ourPlayer->time]];
                    }
                    [musicSlider setIntValue:0];
                    [patternRow setStringValue:@""];
                });
                break;
            }
            else
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"No module loaded."];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            }
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
            [ourPlayer setPosition:[[ourPlayer.moduleInfo objectForKey:@"moduleTotalTime"] intValue]];
            break;
        }
        default:
            break;
    }
}

-(IBAction)loadProto:(id)sender
{
    NSError *ourError = nil;
    NSOpenPanel *ourPanel = [NSOpenPanel openPanel];
    
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        [ourPlayer loadModule:[ourPanel URL] error:&ourError];
        if(ourError)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        [moduleName setStringValue:ourPlayer.moduleInfo[@"moduleName"]];
    }
    return;
}

-(void)setModPosition:(int)ourValue
{
    NSLog(@"setModPosition: %i", ourValue);
    [ourPlayer setPosition:ourValue];
}

@end

