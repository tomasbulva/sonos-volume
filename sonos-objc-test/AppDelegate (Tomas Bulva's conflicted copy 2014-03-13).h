//
//  AppDelegate.h
//  sonos-objc-test
//
//  Created by Tomas Bulva on 3/5/14.
//  Copyright (c) 2014 Tomas Bulva. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *_statusItem;
    NSSlider *_SliderVolume;
    NSWindow *_window;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSSlider *SliderVolume;

@end
