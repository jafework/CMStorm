//
//  CMMainView.h
//  CMStorm
//
//  Created by Joseph Afework on 5/26/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kCMBacklightStatusDidChangeNotification;
extern NSString *const kCMBacklightStatusKey;

@interface CMMainView : NSView
@property(nonatomic,strong) IBOutlet NSMatrix *status;
@end
