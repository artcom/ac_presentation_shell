//
//  CategoryCell.h
//  ACShell
//
//  Created by Julian Krumow on 04.03.16.
//  Copyright © 2016 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CategoryCellDelegate;
@interface CategoryCell : NSTableCellView

@property (nonatomic, weak) IBOutlet NSButton *checkbox;
@property (nonatomic, weak) id <CategoryCellDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end

@protocol CategoryCellDelegate <NSObject>

- (void)categoryCellDidCheck:(CategoryCell *)cell withIndex:(NSInteger)index;
- (void)categoryCellDidUncheck:(CategoryCell *)cell withIndex:(NSInteger)index;
@end