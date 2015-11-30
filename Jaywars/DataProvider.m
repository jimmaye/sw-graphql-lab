//
//  DataProvider.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "DataProvider.h"

@implementation DataProvider

+(DataProvider*) sharedInstance {
    
    static DataProvider *dataProvider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataProvider = [[DataProvider alloc] init];
    });
    
    return dataProvider;
}

@end
