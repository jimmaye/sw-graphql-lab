//
//  GraphQLService.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "GraphQLService.h"

static NSString * const root = @"http://localhost:59103";

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
    [request setValue:@"application/graphql" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return [request copy];
}


-(void)fetchMoviesWithCompletionBlock:(void (^)(NSArray<SWFilm*> *movies))completion {
    NSString *query = @"{allFilms{films{episodeID,title,director,producers,openingCrawl}}}";
    
    NSString *url = [NSString stringWithFormat:@"%@?query=%@", root, [query stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    NSLog(@"URL %@", url);
    NSURLRequest *request = [self urlRequestForURL:[NSURL URLWithString:url]];
    
    /*[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"stuff");
    }];
    */
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        id responseObject = nil;
        if (!error && data) {
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        }
        
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if ((statusCode / 100) != 2) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Request failed with status code %ld: %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]],
                                       NSURLErrorFailingURLErrorKey: [response URL]
                                       };
            
            error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            NSLog(@"Error %@", error);
        } else if (completion) {
            NSLog(@"Completion success");
            
            
        }
    }];
    
    [task resume];
    
}

-(void)fetchCharactersForFilm:(SWFilm *)film withCompletionBlock:(void (^)(NSArray<SWPerson*> *characters))completion {
    
}

@end
