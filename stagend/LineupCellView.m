//
//  LineupCellView.m
//  stagend
//
//  Created by  on 12/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LineupCellView.h"

@implementation LineupCellView

@synthesize logo, artistName, genre, date;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
        
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, 2.0, 50.0, 50.0)];
		[self addSubview:logo];
        
		artistName = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 2.0, 250.0, 20.0)];
		artistName.font = [UIFont boldSystemFontOfSize:17];
		artistName.backgroundColor = [UIColor clearColor];
		artistName.lineBreakMode = UILineBreakModeWordWrap;
		[self addSubview:artistName];
        
        genre = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 25.0, 150.0, 12.0)];
		genre.font = [UIFont systemFontOfSize:12];
		genre.backgroundColor = [UIColor clearColor];
		genre.lineBreakMode = UILineBreakModeWordWrap;
		[self addSubview:genre];
        
        date = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 40.0, 50.0, 12.0)];
		date.font = [UIFont systemFontOfSize:12];
		date.backgroundColor = [UIColor clearColor];
		[self addSubview:date];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
