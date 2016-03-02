//
//  HeaderLayer.h
//  ACShell
//
//  Created by Julian Krumow on 02.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface HeaderLayer : CALayer

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;
@end
