//
//  DataProvider.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "DataProvider.h"
#import "SWAPI.h"

@interface DataProvider()

@property (nonatomic, strong) NSOperationQueue *dataQueue;

@end


@implementation DataProvider

+(DataProvider*) sharedInstance {
    
    static DataProvider *dataProvider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataProvider = [[DataProvider alloc] init];
        dataProvider.dataQueue = [[NSOperationQueue alloc] init];
        dataProvider.dataQueue.maxConcurrentOperationCount = 5;
        dataProvider.dataQueue.name = @"Jaywars.DataQueue";
    });
    
    return dataProvider;
}

-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion {
    [self.dataQueue addOperationWithBlock:^{
        [SWAPI getFilmsWithCompletion:^(SWResultSet *result, NSError *error) {
            if (error) {
                NSLog(@"An error occured, %@", [error debugDescription]);
            } else {
                if (completion) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSArray *sorted = [result.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"episodeID" ascending:YES]]];
                        completion(sorted);
                    }];

                }
            }
        }];
    }];
}

- (void)fetchCharactersForFilm:(SWFilm *)film withCompletionBlock:(void (^)(NSArray<SWPerson*> *characters))completion {
    [self.dataQueue addOperationWithBlock:^{
        [film getCharactersWithCompletion:^(SWResultSet *result, NSError *error) {
            if (completion) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSArray *sorted = [result.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                    completion(sorted);
                }];
                
            }
        }];
        
    }];
}

@end
