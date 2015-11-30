//
//  MovieDetailsViewController.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "DataProvider.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.textColor = [UIColor yellowColor];
    self.textView.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [NSString stringWithFormat:@"Details for %@", self.currentFilm.title];

    BOOL includeCharacters = YES; // Determines if we fetch character names or not
    
    [self loadUIIfNeededWithCharacters:includeCharacters];
}

-(void)loadUIIfNeededWithCharacters:(BOOL)includeCharacters {
    [self fillTextViewWithDefaultFilmInformation];
    
    if (includeCharacters) {
        [[DataProvider sharedInstance] fetchCharactersForFilm:self.currentFilm withCompletionBlock:^(NSArray<SWPerson *> *characters) {
            self.textView.text = [NSString stringWithFormat:@"%@ \n\nCharacters \n %@", self.textView.text, [characters valueForKey:@"name"]];
        }];
    }
}


- (void) fillTextViewWithDefaultFilmInformation {
    self.textView.text = [NSString stringWithFormat:@"Episode \n%@ \n\nOpening text \n%@ \n\nDirector \n%@ \n\nProducer(s) \n%@",
                          self.currentFilm.episodeID,
                          [[self.currentFilm.openingCrawl componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "],
                          self.currentFilm.director,
                          self.currentFilm.producer];
}

@end
