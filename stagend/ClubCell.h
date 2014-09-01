//
//  ClubCell.h
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClubCellView;

@interface ClubCell : UITableViewCell {
    
	ClubCellView *cellView;
	
}

@property (strong, nonatomic) ClubCellView *cellView;

@end
