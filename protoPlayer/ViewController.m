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
    // Set up our experimental module loading notification
    NSString *loadNotificationName = @"DCProtoLoadNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useLoadNotification:) name:loadNotificationName object:nil];
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
            [ourPlayer setPlayerPosition:0];
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
                    [musicSlider setMaxValue:[[ourPlayer.moduleInfo objectForKey:@"moduleTotalTime"] intValue]];
                    while([ourPlayer isPlaying])
                    {
                        usleep(10000);
                        if ([self dragTimeline])
                        {
                            [musicSlider setIntValue:(int)[ourPlayer playerTime]];
                        }
                        [patternRow setStringValue:[ourPlayer getTimeString:[ourPlayer playerTime]]];
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
            [ourPlayer setPlayerPosition:[[ourPlayer.moduleInfo objectForKey:@"moduleTotalTime"] intValue]];
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
        
        NSUserNotification *ourNotifier = [[NSUserNotification alloc] init];
        [ourNotifier setTitle:@"protoPlayer"];
        [ourNotifier setInformativeText:ourPlayer.moduleInfo[@"moduleName"]];
        [ourNotifier setSoundName:NSUserNotificationDefaultSoundName];
        
        NSUserNotificationCenter *ourCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        [ourCenter deliverNotification:ourNotifier];
        
        [moduleName setStringValue:ourPlayer.moduleInfo[@"moduleName"]];
    }
    return;
}

-(void)setModPosition:(int)ourValue
{
    [ourPlayer seekPlayerToTime:ourValue];
}

-(void)useLoadNotification:(NSNotification *)modName
{
    NSLog(@"NSNotification load received: %s", [[modName object] UTF8String]);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

