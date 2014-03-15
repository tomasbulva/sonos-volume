//
//  AppDelegate.m
//  sonos-objc-test
//
//  Created by Tomas Bulva on 3/5/14.
//  Copyright (c) 2014 Tomas Bulva. All rights reserved.
//

#import "SonosManager.h"
#import "SonosController.h"

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize SliderVolume;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[SonosManager sharedInstance] addObserver:self forKeyPath:@"allDevices" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)awakeFromNib{
    NSImage *image = [NSImage imageNamed:@"status"];
	NSImage *alternateImage = [NSImage imageNamed:@"status-selected"];
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	
	//[_statusItem setupView];
    
	[_statusItem setHighlightMode:YES];
	
	[_statusItem setImage:image];
	[_statusItem setAlternateImage:alternateImage];
    
    
    NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom" action:NULL keyEquivalent:@""];
    NSMenu *newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom"];
    // this menu item will have a view with a gradient backbround and a slider
	newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom Item 3" action:nil keyEquivalent:@""];
    [newItem setEnabled:YES];
	[newItem setView:SliderVolume];
    [newMenu addItem:newItem];
    [_statusItem setTarget:self];
	[_statusItem setMenu:newMenu];
    [_statusItem setAction:@selector(findVolumeLevel:)];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SonosController *controller = [[SonosManager sharedInstance] currentDevice];
//    [controller trackInfo:^(NSString *artist, NSString *title, NSString *album, NSURL *albumArt, NSInteger time, NSInteger duration, NSInteger queueIndex, NSString *trackURI, NSString *protocol, NSError *error){
//        
//        NSLog(@"Artist: %@", artist);
//        NSLog(@"Title: %@", title);
//        NSLog(@"Album: %@", album);
//        NSLog(@"Album Art: %@", albumArt);
//        NSLog(@"Time: %ld", (long)time);
//        NSLog(@"Duration: %ld", (long)duration);
//        NSLog(@"Place in queue: %ld", (long)queueIndex);
//        NSLog(@"Track URI: %@", trackURI);
//        NSLog(@"Protocol: %@", protocol);
//        NSLog(@"Protocol: %@", protocol);
//        
//    }];
    
    [controller getVolume:^(NSInteger volume, NSDictionary *response, NSError *error){
        //NSLog(@"response: %@", response);
        NSLog(@"volume: %ld", (long)volume);
        //NSLog(@"error: %@", error);
    }];
    
}

- (IBAction)SliderVolumeChanged:(id)sender {
    //SonosController *controller = [[SonosManager sharedInstance] currentDevice];
    
    //setVolume:(NSInteger)volume completion:(void (^)(NSDictionary *response, NSError *error))block;
    //[controller setVolume:SliderVolume.value];
}

- (IBAction)findVolumeLevel:(id)sender {
    
    NSLog(@"menu clicked");
    SonosController *controller = [[SonosManager sharedInstance] currentDevice];
    
    [controller getVolume:^(NSInteger volume, NSDictionary *response, NSError *error){
        //NSLog(@"response: %@", response);
        NSLog(@"volume: %ld", (long)volume);
        SliderVolume.minValue = 0;
        SliderVolume.maxValue = 100;
        SliderVolume.intValue = volume;
        //NSLog(@"error: %@", error);
    }];
}

@end
