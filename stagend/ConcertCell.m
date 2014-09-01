//
//  ConcertCell.m
//  Stagend
//
//  Created by koa on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConcertCell.h"
#import "ConcertCellView.h"


@implementation ConcertCell

@synthesize cellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) { 
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		cellView = [[ConcertCellView alloc] initWithFrame:tzvFrame];
		cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground"]];
		[self.contentView addSubview:cellView];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)redisplay {
	[cellView setNeedsDisplay];
}



@end
