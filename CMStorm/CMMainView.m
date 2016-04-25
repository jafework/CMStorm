//
//  CMMainView.m
//  CMStorm
//
//  Created by Joseph Afework on 5/26/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import "CMMainView.h"
#import <CoreFoundation/CoreFoundation.h>
#import <Carbon/Carbon.h>
#import <IOKit/hid/IOHIDLib.h>

NSString *const kCMBacklightStatusDidChangeNotification = @"kCMBacklightStatusDidChangeNotification";
NSString *const kCMBacklightStatusKey = @"kCMBacklightStatusKey";

@interface CMMainView ()
@property (nonatomic, strong) NSMutableArray *elements;
@property (nonatomic) IOHIDDeviceRef deviceRef;
@property (nonatomic) IOHIDManagerRef managerRef;
@end

@implementation CMMainView

-(void)registerForScrollKey
{
    //Regsiter For KeyPress: Shift + Scroll Lock
    if(!checkAccessibility())
    {
        exit(0); // If Accessibility is not enabled, exit app
    }
    
    __weak __block CMMainView *this = self;
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event)
     {
         NSString *chars = [[event characters] lowercaseString];
         unichar character = [chars characterAtIndex:0];

         //Scroll Lock Key = Unicode f711, on OSX Shift + Scroll Lock
         if (character == 0xf711)
         {
             this.managerRef = [this getManager];
             this.deviceRef = [this getDeviceForManager:this.managerRef];
             
             [self loadElements];
             BOOL currentBacklightStatus = [this currentBacklightStateForDevice:this.deviceRef];
             [this setKeyboardBacklight:!currentBacklightStatus device:this.deviceRef];
         }
     }];
}

BOOL checkAccessibility()
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

-(IOHIDDeviceRef)getDeviceForManager:(IOHIDManagerRef)manager
{
    // and copy out its devices
	CFSetRef deviceCFSetRef = IOHIDManagerCopyDevices( manager );
    
    // how many devices in the set?
	CFIndex deviceIndex, deviceCount = CFSetGetCount( deviceCFSetRef );
	
	// allocate a block of memory to extact the device ref's from the set into
	IOHIDDeviceRef *tIOHIDDeviceRefs = malloc( sizeof( IOHIDDeviceRef ) * deviceCount );
	
	// now extract the device ref's from the set
	CFSetGetValues( deviceCFSetRef, (const void **) tIOHIDDeviceRefs );
	
    CFRelease(deviceCFSetRef);
    
    IOHIDDeviceRef device = NULL;
    
    for ( deviceIndex = 0; deviceIndex < deviceCount; deviceIndex++ )
    {
        // if this is a keyboard device...
        if (IOHIDDeviceConformsTo( tIOHIDDeviceRefs[deviceIndex], kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard ) )
        {
            //If not manufacturer and model number then skip
            NSString *manufacturer = (__bridge NSString *)IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex] , CFSTR(kIOHIDManufacturerKey));
            NSString *product = (__bridge NSString *)IOHIDDeviceGetProperty(tIOHIDDeviceRefs[deviceIndex] , CFSTR(kIOHIDProductKey));
			
            if(([manufacturer isEqualToString:@"SINO WEALTH"] && [product isEqualToString:@"USB KEYBOARD"]))
            {
                device = tIOHIDDeviceRefs[deviceIndex];
                CFRetain(device);
            }
		}
        CFRelease(tIOHIDDeviceRefs[deviceIndex]);
	}
    
    free(tIOHIDDeviceRefs);
    
    return device;
}

-(IOHIDManagerRef)getManager
{
    // create a IO HID Manager reference
	IOHIDManagerRef manager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
    
    IOHIDManagerSetDeviceMatching( manager, NULL);
	
    // Now open the IO HID Manager reference
	IOHIDManagerOpen( manager, kIOHIDOptionsTypeNone );
    
    return manager;
}

-(void)awakeFromNib
{
    self.managerRef = [self getManager];
    self.deviceRef = [self getDeviceForManager:self.managerRef];
    
    [self loadElements];
    
    [self registerForScrollKey];
    
    BOOL state = [self currentBacklightStateForDevice:self.deviceRef];
    [self.status selectCellAtRow:state column:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCMBacklightStatusDidChangeNotification object:nil userInfo:@{kCMBacklightStatusKey:@(state)}];
}

-(void)loadElements
{
    self.elements = [[NSMutableArray alloc] init];
    // copy all the elements
    CFArrayRef elementCFArrayRef = IOHIDDeviceCopyMatchingElements( self.deviceRef, NULL, kIOHIDOptionsTypeNone );
    
    // for each device on the system these values are divided by the value ranges of all LED elements found
    // for example, if the first four LED element have a range of 0-1 then the four least significant bits of
    // this value will be sent to these first four LED elements, etc.
    
    // iterate over all the elements
    CFIndex elementCount = CFArrayGetCount( elementCFArrayRef );
    
    for ( CFIndex i = 0; i < elementCount; i++ )
    {
        IOHIDElementRef tIOHIDElementRef = ( IOHIDElementRef ) CFArrayGetValueAtIndex( elementCFArrayRef, i );
        
        int32_t usagePage = IOHIDElementGetUsagePage( tIOHIDElementRef );
        // if this is an LED element...
        if ( kHIDPage_LEDs == usagePage )
        {
            [self.elements addObject:[NSValue valueWithBytes:&tIOHIDElementRef objCType:@encode(IOHIDElementRef)]];
        }
        CFRelease(tIOHIDElementRef);
    }
    CFRelease( elementCFArrayRef );
}

-(BOOL)currentBacklightStateForDevice:(IOHIDDeviceRef)device
{
    BOOL state = NO;
    
    for (NSValue *ref in self.elements)
    {
        IOHIDElementRef element;
        [ref getValue:&element];
        
        uint32_t usagePage = IOHIDElementGetUsagePage( element );
        // if this is an LED element...
        if ( kHIDPage_LEDs == usagePage)
        {
            IOHIDValueRef tIOHIDValueRef;
            IOHIDDeviceGetValue(device, element, &tIOHIDValueRef);
            
            CFIndex val = IOHIDValueGetIntegerValue(tIOHIDValueRef);
            
            state = (val != 0)? YES : NO;
        }
    }
    
    return state;
}

-(void)setKeyboardBacklight:(BOOL)state device:(IOHIDDeviceRef)device
{
    for (NSValue *ref in self.elements)
    {
        IOHIDElementRef element;
        [ref getValue:&element];
        
        CFIndex tCFIndex = state;
        
        uint64_t timestamp = 0; // create the IO HID Value to be sent to this LED element
        IOHIDValueRef tIOHIDValueRef = IOHIDValueCreateWithIntegerValue( kCFAllocatorDefault, element, timestamp, tCFIndex );
        // now set it on the device
        IOHIDDeviceSetValue( device, element, tIOHIDValueRef );
        CFRelease( tIOHIDValueRef );
    }
    
    // Update Window Utillity
    [self.status selectCellAtRow:state column:0];
    
    // Update Menu Item
    [[NSNotificationCenter defaultCenter] postNotificationName:kCMBacklightStatusDidChangeNotification object:nil userInfo:@{kCMBacklightStatusKey:@(state)}];
}

-(IBAction)didPressOn:(id)sender
{
    [self setKeyboardBacklight:YES device:self.deviceRef];
}

-(IBAction)didPressOff:(id)sender
{
    [self setKeyboardBacklight:NO device:self.deviceRef];
}

@end


