//
//  CMAppDelegate.m
//  CMStorm
//
//  Created by Joseph Afework on 5/26/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import "CMAppDelegate.h"
#import "CMMainView.h"

@interface CMAppDelegate ()
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation CMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backlightStatusDidChange:) name:kCMBacklightStatusDidChangeNotification object:nil];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.highlightMode = YES;
    self.statusItem.title = @"CM: Off";
    self.statusItem.enabled = YES;
    self.statusItem.toolTip = @"CMStorm Uitility";
    [self.statusItem setTarget:self];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Backlight Uitility"];
    
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(didPressQuit:) keyEquivalent:@""];
    quit.target = self;
    [menu addItem:quit];
    
    [self.statusItem setMenu:menu];
}

-(IBAction)didPressQuit:(id)sender
{
    exit(0);
}

-(void)backlightStatusDidChange:(NSNotification*)notification
{
    NSNumber *status = notification.userInfo[kCMBacklightStatusKey];
    self.statusItem.title = [NSString stringWithFormat:@"CM: %@",status.boolValue ? @"On" : @"Off"];
}

@end
