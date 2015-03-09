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
    __block Module *playModule;
    playModule = [ourModule copy];
    
    NSLog(@"totalTime before block: %i", [ourModule modTotalTime]);
    NSLog(@"name: %@", [ourModule moduleName]);
    
    switch ([sender tag]) {
        case 0:
        {
            [ourPlayer jumpPosition:0];
            break;  
        }
        case 1:
        {
            [ourPlayer prevPlayPosition];
            break;
        }
        case 2:
        {
            if ([ourPlayer isLoaded])
            {
                [self setDragTimeline:YES];
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                    [ourPlayer playModule:nil];
                });
                usleep(1000);
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                    [musicSlider setMaxValue:[playModule modTotalTime]];
                    NSLog(@"totalTime: %d", [playModule modTotalTime]);
                    while([ourPlayer isPlaying])
                    {
                        usleep(10000);
                        if ([self dragTimeline])
                        {
                            NSInteger sliderValue = [ourPlayer playerTime];
                            [musicSlider setIntegerValue:sliderValue];
                            [patternRow setStringValue:
                             [ourPlayer getTimeString:[ourPlayer playerTime]]];
                        }
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
            [ourPlayer stopPlayer];
            break;
        }
        case 4:
        {
            [ourPlayer nextPlayPosition];
            break;
        }
        case 5:
        {
            [ourPlayer jumpPosition:[ourModule modTotalTime]];
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
    Module *ourModule = [[Module alloc] init];
    
    [ourPanel setCanChooseDirectories:NO];
    [ourPanel setCanChooseFiles:YES];
    [ourPanel setCanCreateDirectories:NO];
    [ourPanel setAllowsMultipleSelection:NO];
    if ([ourPanel runModal] == NSModalResponseOK)
    {
        [ourModule setFilePath:[ourPanel URL]];
        [ourPlayer loadModule:ourModule error:&ourError];
        if(ourError)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Cannot load module."];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            return;
        }
        
        NSUserNotification *ourNotifier = [[NSUserNotification alloc] init];
        [ourNotifier setTitle:@"protoPlayer"];
        [ourNotifier setInformativeText:[ourModule moduleName]];
        [ourNotifier setSoundName:NSUserNotificationDefaultSoundName];
        
        NSUserNotificationCenter *ourCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        [ourCenter deliverNotification:ourNotifier];
        
        [moduleName setStringValue:[ourModule moduleName]];
        
    }
    return;
}


-(void)setModPosition:(int)ourValue
{
    [ourPlayer seekPlayerToTime:ourValue];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

