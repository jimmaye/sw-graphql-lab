//
//  DataProvider.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "DataProvider.h"
#import "SWAPI.h"


static NSString * const allMovies = @"allMoviesKey";

@interface DataProvider()

@property (nonatomic, strong) NSOperationQueue *dataQueue;
@property (nonatomic, strong) NSMutableDictionary *dummyCache;

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
        dataProvider.dummyCache = [[NSMutableDictionary alloc] init];
    });
    
    return dataProvider;
}

-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion {
    [self.dataQueue addOperationWithBlock:^{
        if (completion && [self.dummyCache valueForKey:allMovies]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion([self.dummyCache valueForKey:allMovies]);
            }];
        } else {
            [SWAPI getFilmsWithCompletion:^(SWResultSet *result, NSError *error) {
                if (error) {
                    NSLog(@"An error occured, %@", [error debugDescription]);
                } else {
                    if (completion) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSArray *sorted = [result.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"episodeID" ascending:YES]]];
                            [self.dummyCache setValue:sorted forKey:allMovies];
                            completion(sorted);
                        }];
                        
                    }
                }
            }];
        }
    }];
}

- (void)fetchCharactersForFilm:(SWFilm *)film withCompletionBlock:(void (^)(NSArray<SWPerson*> *characters))completion {
    [self.dataQueue addOperationWithBlock:^{
        if (completion && [self.dummyCache valueForKey:film.URLString]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion([self.dummyCache valueForKey:film.URLString]);
            }];
        } else {
            [film getCharactersWithCompletion:^(SWResultSet *result, NSError *error) {
                if (completion) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSArray *sorted = [result.items sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                        [self.dummyCache setValue:sorted forKey:film.URLString];
                        completion(sorted);
                    }];
                    
                }
            }];
        }
    }];
}

@end
