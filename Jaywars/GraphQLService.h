//
//  GraphQLService.h
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWFilm.h"
#import "SWPerson.h"

@interface GraphQLService : NSObject

+(instancetype)sharedInstance;

-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion;
-(void)fetchCharactersForFilm:(SWFilm *)film withCompletionBlock:(void (^)(NSArray<SWPerson*> *characters))completion;

@end
