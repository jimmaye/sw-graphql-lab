//
//  DataProvider.h
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "SWFilm.h"
#import "SWPerson.h"

@interface DataProvider : NSObject

+(DataProvider*) sharedInstance;

-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion;

-(void)fetchCharactersForFilm:(SWFilm *)film withCompletionBlock:(void (^)(NSArray<SWPerson*> *characters))completion;

@end
