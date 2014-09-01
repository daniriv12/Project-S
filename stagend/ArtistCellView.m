//
//  ArtistCellView.m
//  stagend
//
//  Created by  on 12/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArtistCellView.h"

@implementation ArtistCellView

@synthesize logo, name, genre;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
		
        logo = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 70.0, 70.0)];
		[self addSubview:logo];
        
		name = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 4.0, 205.0, 42.0)];
		name.font = [UIFont boldSystemFontOfSize:17];
		name.backgroundColor = [UIColor clearColor];
		name.numberOfLines = 0;
		name.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:name];
        
        genre = [[UILabel alloc] initWithFrame:CGRectMake(85.0, 50.0, 205.0, 20.0)];
		genre.font = [UIFont systemFontOfSize:13];
		genre.backgroundColor = [UIColor clearColor];
		genre.numberOfLines = 1;
		genre.lineBreakMode = UILineBreakModeWordWrap;
		
		[self addSubview:genre];
    }
    return self;
}

- (void)clearContents {
    
    self.name.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
	
}

- (void)resizeLabelToFitText {
    
    [self.name sizeToFit];
    
    if (self.name.frame.size.height > 42.0) {
        self.name.frame = CGRectMake(85.0, 4.0, 205.0, 42.0);
        [self.name setNeedsDisplay];
    }    
    
}

@end
