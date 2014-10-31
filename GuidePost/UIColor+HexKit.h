//
//  UIColor+HexKit.h
//  GuestBook
//
//  Created by Vaishakh on 10/21/14.
//  Copyright (c) 2014 GuestBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexKit)

+ (UIColor *) colorFromHexCode:(NSString *)hexString;

@end
