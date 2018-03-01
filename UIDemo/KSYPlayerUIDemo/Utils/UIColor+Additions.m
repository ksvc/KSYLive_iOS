//
//  UIColor+Additions.m
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

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

-(BOOL)isLightColor
{
	CGFloat colorBrightness = 0;
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(self.CGColor);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
	if (colorSpaceModel == kCGColorSpaceModelRGB) {
		const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
		colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
	} else {
		[self getWhite:&colorBrightness alpha:0];
	}
	return (colorBrightness >= .5f);
}

+ (UIColor*)colorWithHex:(NSInteger)hex
{
	return [UIColor colorWithRed:(((hex & 0xFF0000) >> 16)) / 255.0f
						   green:(((hex & 0x00FF00) >>  8)) / 255.0f
							blue:(((hex & 0x0000FF) >>  0)) / 255.0f
						   alpha:1.0];
}

+ (UIColor*)colorWithHexString:(NSString *)hexString
{
	if ([hexString length] == 0) {
		return nil;
	}
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	unsigned hex;
	[scanner scanHexInt:&hex];
	return [UIColor colorWithHex:hex];
}

- (NSString *)hexString
{
	CGFloat r;
	CGFloat g;
	CGFloat b;
	
	[self getRed:&r green:&g blue:&b alpha:nil];
	
	return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
			lround(r * 255),
			lround(g * 255),
			lround(b * 255)];
}


@end
