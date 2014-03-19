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
@synthesize RoomSelector;

-(void)awakeFromNib{
    [[SonosManager sharedInstance] addObserver:self forKeyPath:@"allDevices" options:NSKeyValueObservingOptionNew context:NULL];
    
    currentRoomIndex = 0;
    
    NSImage *image = [NSImage imageNamed:@"status"];
	NSImage *alternateImage = [NSImage imageNamed:@"status-selected"];
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[_statusItem setHighlightMode:YES];
	[_statusItem setImage:image];
	[_statusItem setAlternateImage:alternateImage];
    [_statusItem setEnabled: YES];
    [_statusItem setTarget: self];
    
    NSMenu *newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Custom"];
    
    NSMenuItem *newItem0 = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Sonos Rooms" action:nil keyEquivalent:@""];
    
    [newItem0 setEnabled:YES];
	[newItem0 setView:RoomSelector];
    [newItem0 setTarget: self];
    [newMenu addItem:newItem0];
    
	NSMenuItem *newItem1 = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Volume Slider" action:nil keyEquivalent:@""];
    [newItem1 setEnabled:YES];
	[newItem1 setView:SliderVolume];
    [newItem1 setTarget: self];
    [newMenu addItem:newItem1];
    
	[_statusItem setMenu:newMenu];
    
    // Start watching events to figure out when to close the window
    NSAssert(_eventMonitor == nil, @"_eventMonitor should not be created yet");
    _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:
                     (NSLeftMouseDownMask | NSRightMouseDownMask | NSOtherMouseDownMask | NSKeyDownMask)
                                                          handler:^(NSEvent *incomingEvent) {
                                                              NSEvent *result = incomingEvent;
                                                              NSWindow *targetWindowForEvent = [incomingEvent window];
                                                              if (targetWindowForEvent != _window) {
                                                                  [self _closeAndSendAction:NO];
                                                              } else if ([incomingEvent type] == NSKeyDown) {
                                                                  if ([incomingEvent keyCode] == 53) {
                                                                      // Escape
                                                                      [self _closeAndSendAction:NO];
                                                                      result = nil; // Don't process the event
                                                                  } else if ([incomingEvent keyCode] == 36) {
                                                                      // Enter
                                                                      [self _closeAndSendAction:YES];
                                                                      result = nil;
                                                                  }
                                                              }
                                                              return result;
                                                          }];
    
    
}

- (void)_closeAndSendAction:(BOOL)sendAction {
    [_window close];
    if (sendAction) {
//        if ([self.delegate respondsToSelector:@selector(colorTableController:didChooseColor:named:)]) {
//            [self.delegate colorTableController:self didChooseColor:self.selectedColor named:self.selectedColorName];
//        }
    } else {
//        if ([self.delegate respondsToSelector:@selector(didCancelColorTableController:)]) {
//            [self.delegate didCancelColorTableController:self];
//        }
        NSMutableDictionary *rooms = [[SonosManager sharedInstance] listOfRooms];
        NSLog(@"rooms %@",rooms);
        
        [RoomSelector setSegmentCount:[rooms count]];
        [[RoomSelector cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
        int myCounter = 0;
        for (NSString *roomName in rooms){
            [RoomSelector setLabel:roomName forSegment:myCounter];
            [RoomSelector setWidth: (195 / [rooms count]) forSegment:myCounter];
            [RoomSelector setTarget:self];
            [RoomSelector setAction: @selector(segControlClicked:)];
            if(myCounter == 0) [RoomSelector setSelectedSegment: YES];
            NSLog(@"index: %d, Key: %@, Value %@", myCounter, roomName, [rooms objectForKey: roomName]);
            myCounter++;
        }
        
        
        SonosController *controller = [[SonosManager sharedInstance] currentDevice];
        
        [controller getVolume:^(NSInteger volume, NSDictionary *response, NSError *error){
            [self.SliderVolume setDoubleValue:volume];
        }];
    }
}

- (IBAction)segControlClicked:(id)sender {
    NSLog(@"you clicked on: %ld", (long)[sender selectedSegment]);
}

- (void)_windowClosed:(NSNotification *)note {
    if (_eventMonitor) {
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:_window];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    SonosController *controller = [[SonosManager sharedInstance] currentDevice];
    
    [controller getVolume:^(NSInteger volume, NSDictionary *response, NSError *error){
        
    }];
    
}
- (IBAction) setVolume:(id)sender {
// I guess here I can enclose this in a loop with all the devices I want to controll.
    
    SonosController *controller = [[SonosManager sharedInstance] currentDevice];
    [controller setVolume: [SliderVolume intValue] completion:^(NSDictionary *response, NSError *error){
     //setVolume:(NSInteger)volume completion:(void (^)(NSDictionary *response, NSError *error))block;
     NSLog(@"volume slider action: %d", [SliderVolume intValue]);
     NSLog(@"response: %@", response);
    }];
}



@end
