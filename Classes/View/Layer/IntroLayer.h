//
//  IntroLayer.h
//  ACShell
//
//  Created by Julian Krumow on 03.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface IntroLayer : CALayer

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) CALayer *logo;
@property (nonatomic, strong) CATextLayer *titleLayer;
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;
@end
