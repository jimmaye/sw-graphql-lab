//
//  HomeViewController.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "HomeViewController.h"
#import "DataProvider.h"


static NSString * const reuseIdentifier = @"homeViewControllerCellIdentifier";
static int const sections = 1;

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<SWFilm*> *movies;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchIfNeeded];
}

-(void) fetchIfNeeded {
    [[DataProvider sharedInstance] fetchMoviesWithCompletionBlock:^(NSArray<SWFilm *> *movies) {
        self.movies = movies;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    SWFilm *film = self.movies[indexPath.row];
    
    cell.textLabel.text = film.title;
    cell.detailTextLabel.text = film.openingCrawl;
    return cell;
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
