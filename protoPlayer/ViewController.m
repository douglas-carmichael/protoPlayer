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
    ourModule = [[Module alloc] init];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPosition) name:@"dcXmpPlayer" object:nil];
    
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC),dispatch_get_global_queue(QOS_CLASS_BACKGROUND,0), ^{
                    [musicSlider setMaxValue:[ourModule modTotalTime]];
                    NSLog(@"totalTime: %d", [ourModule modTotalTime]);
                    while([ourPlayer isPlaying])
                    {
                        usleep(10000);
                        if ([self dragTimeline])
                        {
                            NSInteger sliderValue = [ourPlayer playerTime];
                            [musicSlider setIntegerValue:sliderValue];
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
        
        
        [moduleName setStringValue:[ourModule moduleName]];
        
    }
    return;
}

-(IBAction)volumeSlider:(id)sender
{
    float me = [sender floatValue];
    float you = [self scaleRange:me];
    NSLog(@"volumeSlider scaled: %f", you);
    [ourPlayer setMasterVolume:you];
}

-(void)setModPosition:(int)ourValue
{
    [ourPlayer seekPlayerToTime:ourValue];
}

-(float)scaleRange:(float)ourNumber
{
    
    // From:
    // http://stackoverflow.com/questions/10696794/objective-c-map-one-number-range-to-another
    
    CGFloat const inMin = 0.0;
    CGFloat const inMax = 10.0;
    
    CGFloat const outMin = 0.0;
    CGFloat const outMax = 1.0;
    
    CGFloat in = ourNumber;
    CGFloat out = outMin + (outMax - outMin) * (in - inMin) / (inMax - inMin);
    
    return out;
}

-(void)showPosition
{
    [patternRow setStringValue:
     [ourPlayer getTimeString:[ourPlayer playerTime]]];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

