//
//  URLTableViewController.m
//  KSYPlayerDemo
//
//  Created by isExist on 16/8/22.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import "URLTableViewController.h"
#import "QRViewController.h"

static NSString *kCellWithIdentifier = @"reuseIdentifier";

@interface URLTableViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *stringURLs;

@end

@implementation URLTableViewController

- (instancetype)initWithURLs:(NSArray<NSURL *> *)urls {
    if (self = [super init]) {
        _stringURLs = [NSMutableArray array];
        for (NSURL * url in urls) {
            [_stringURLs addObject:[url absoluteString]];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *scanButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(scanQR)];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem, scanButtonItem];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.leftBarButtonItems = @[cancelButtonItem, confirmButtonItem];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellWithIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm {
    NSMutableArray<NSURL *> *URLs = [NSMutableArray array];
    for (NSString *stringURL in _stringURLs) {
        [URLs addObject:[NSURL URLWithString:stringURL]];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        _getURLs(URLs);
    }];
}

- (void)scanQR {
    QRViewController *qrVC = [[QRViewController alloc] init];
    __weak typeof(qrVC) weakQRVC = qrVC;
    qrVC.getQrCode = ^(NSString *stringQR) {
        [_stringURLs addObject:stringQR];
        typeof(weakQRVC) strongQRVC = weakQRVC;
        [strongQRVC dismissViewControllerAnimated:YES completion:nil];
        [self.tableView reloadData];
    };
    [self presentViewController:qrVC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _stringURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = _stringURLs[indexPath.row];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_stringURLs removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
