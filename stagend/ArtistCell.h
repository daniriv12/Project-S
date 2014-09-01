//
//  ArtistCell.h
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArtistCellView;

@interface ArtistCell : UITableViewCell {
    
	ArtistCellView *cellView;
	
}

@property (strong, nonatomic) ArtistCellView *cellView;

@end
