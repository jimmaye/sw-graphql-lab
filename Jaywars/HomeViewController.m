//
//  HomeViewController.m
//  Jaywars
//
//  Created by Jimmie Jensen on 30/11/15.
//  Copyright © 2015 Jayway. All rights reserved.
//

#import "HomeViewController.h"
#import "DataProvider.h"
#import "BasicCell.h"

static NSString * const reuseIdentifier = @"BasicCell";
static int const sections = 1;

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<SWFilm*> *movies;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.hidden = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80.0;
    [self.spinner startAnimating];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleLabel.text = @"Jaywars - your SW index";
    self.titleLabel.backgroundColor = [UIColor blackColor];
    self.titleLabel.textColor = [UIColor yellowColor];
    [self fetchIfNeeded];
}

-(void) fetchIfNeeded {
    [[DataProvider sharedInstance] fetchMoviesWithCompletionBlock:^(NSArray<SWFilm *> *movies) {
        [self.spinner stopAnimating];
        self.movies = movies;
        if (self.movies.count > 0) {
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table View

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    SWFilm *film = self.movies[indexPath.row];
    
    cell.titleLabel.text = film.title;
    cell.subtitleLabel.text = [NSString stringWithFormat:@"Episode: %@ \nDirector: %@ \nProducer: %@", film.episodeID, film.director, film.director];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Storyboard navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
