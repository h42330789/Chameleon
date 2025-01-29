//
//  TestVC.m
//  BigApple
//
//  Created by Blue on 1/29/25.
//

#import "TestVC.h"

@interface TestVC() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *data;
@end

@implementation TestVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview: self.tableView];
    
    for (int i=0; i<10; i++) {
        NSMutableArray *arrayM = [NSMutableArray new];
        int idx = arc4random_uniform(20)+5;
        for (int j = 0; j<idx; j++) {
            [arrayM addObject:[NSString stringWithFormat:@"%d", j]];
        }
        [self.data addObject:arrayM];
    }
    [self.tableView reloadData];
}
// MARK: - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%ld", (long)section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *list = self.data[section];
    return list.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSString *txt = self.data[indexPath.section][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"group:%lu row:%lu---%@", (unsigned long)indexPath.section, (unsigned long)indexPath.row, txt];
    cell.backgroundColor = UIColor.blueColor;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select: %lu %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row);
//    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated: true];
    });
    
}

// MARK: - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tableView;
}
- (NSMutableArray<NSMutableArray *> *)data {
    if (_data == nil) {
        _data = [NSMutableArray new];
    }
    return _data;
}
@end
