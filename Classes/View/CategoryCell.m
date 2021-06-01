//
//  CategoryCell.m
//  ACShell
//
//  Created by Julian Krumow on 04.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.checkbox.target = self;
    self.checkbox.action = @selector(buttonClicked:);
}

- (void)buttonClicked:(id)sender
{
    if (self.checkbox.state == NSControlStateValueOff) {
        [self.delegate categoryCellDidUncheck:self withIndex:self.index];
    }
    if (self.checkbox.state == NSControlStateValueOn) {
        [self.delegate categoryCellDidCheck:self withIndex:self.index];
    }
}

@end
