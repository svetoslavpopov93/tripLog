//
//  ToDoTableViewCell.h
//  TripLog
//
//  Created by plt3ch on 6/21/15.
//  Copyright (c) 2015 triOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"

@interface ToDoTableViewCell : UITableViewCell

@property (nonatomic, strong) ToDoItem* toDoItem;

@end
