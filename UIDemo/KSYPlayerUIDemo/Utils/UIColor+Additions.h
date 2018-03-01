//
//  UIColor+Additions.h
//  Mobile Buy SDK
//
//  Created by Shopify.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@import UIKit;

#define BUY_RGB(r, g, b) BUY_RGBA(r, g, b, 1)
#define BUY_RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface UIColor (Additions)

/**
 *  Check if the color is light (brightness of colors combined less than .5)
 *  Supports RGB and grey space colors
 *
 *  @return Returns true if the color is light
 */
- (BOOL)isLightColor;

/**
 *  Creates a UIColor from a hex value
 *
 *  @param hex the hex value to convert to a UIColor
 *
 *  @return A UIColor object
 */
+ (UIColor*)colorWithHex:(NSInteger)hex;
+ (UIColor*)colorWithHexString:(NSString *)hexString;

/**
 *  Creates a string representing the hex value for the color
 *
 *  @return String representing the hex value
 */
- (NSString *)hexString;

@end
