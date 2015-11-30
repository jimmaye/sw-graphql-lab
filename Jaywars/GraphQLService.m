//
//  GraphQLService.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "GraphQLService.h"

static NSString * const root = @"http://localhost:60688";
static NSString * const queryFormat = @"%@?query=%@";
static NSString * const filmsAndCharacters = @"{allFilms{films{episodeID,title,director,producers,openingCrawl,characterConnection{characters{name}}}}}";

static NSString * const contentType = @"application/graphql";
static NSString * const acceptType = @"application/json";

@interface GraphQLService()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation GraphQLService

+(instancetype)sharedInstance {
    static GraphQLService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GraphQLService alloc] init];
        service.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    
    return service;
}

-(NSURLRequest *)urlRequestForURL:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPShouldUsePipelining = YES;
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:acceptType forHTTPHeaderField:@"Accept"];
    return [request copy];
}

-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion {
    NSString *url = [NSString stringWithFormat:queryFormat, root, [filmsAndCharacters stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [self urlRequestForURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if ((statusCode / 100) != 2) {
            NSDictionary *userInfo =
                @{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Request failed with status code %ld: %@",
                                               (long)statusCode,
                                               [NSHTTPURLResponse localizedStringForStatusCode:statusCode]],
                   NSURLErrorFailingURLErrorKey: [response URL]
            };
            error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            NSLog(@"Error %@", error);
        } else {
            NSError *jsonError;
            NSDictionary *jsonDictionary = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError] valueForKey:@"data"];
            if(jsonError) {
                // check the error description
                NSLog(@"json error : %@", [jsonError localizedDescription]);
            } else {
                NSArray *films = jsonDictionary[@"allFilms"][@"films"];
                __block NSMutableArray<SWFilm *>*result = [[NSMutableArray alloc] init];
                [films enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull filmDict, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSError *error;
                    SWFilm *film = [MTLJSONAdapter modelOfClass:[SWFilm class] fromJSONDictionary:filmDict  error:&error];
                    film.episodeID = filmDict[@"episodeID"];
                    film.openingCrawl = filmDict[@"openingCrawl"];
                    if (error) {
                    } else {
                        NSArray *personDicts = filmDict[@"characterConnection"][@"characters"];
                        NSMutableArray<SWPerson *>*persons = [[NSMutableArray alloc] init];
                        [personDicts enumerateObjectsUsingBlock:^(NSDictionary  * _Nonnull personDict, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSError *error;
                            [persons addObject:[MTLJSONAdapter modelOfClass:[SWPerson class] fromJSONDictionary:personDict  error:&error]];
                        }];
                        film.characters = persons;
                        film.producer = [filmDict[@"producers"] componentsJoinedByString:@", "];
                        [result addObject:film];
                    }
                }];
                if (completion) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        completion(result);
                    }];
                }
            }
        }
    }];
    
    [task resume];
}

@end
