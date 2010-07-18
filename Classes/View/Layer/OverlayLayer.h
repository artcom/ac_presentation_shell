//
//  OverlayLayer.h
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface OverlayLayer : CALayer {
	CATextLayer *textLayer;
}

@property (copy) NSString *text;

@end
