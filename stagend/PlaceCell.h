//
//  PlaceCell.h
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaceCellView;

@interface PlaceCell : UITableViewCell {
    
	PlaceCellView *cellView;
	
}

@property (strong, nonatomic) PlaceCellView *cellView;

@end
