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

// 本库是以iOS3为模板写的，粘性表头是iOS6才支持的，所以要想支持粘性表头要自定义管理
@property (nonatomic, strong) UIView *stickyHeaderView;  // 用来作为固定的表头视图
@property (nonatomic, assign) NSInteger stickySection;   // 当前固定的 section
@property (nonatomic, strong) NSMutableDictionary *cacheHeaders;

@end

@implementation TestVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview: self.tableView];
   
   [self.view addSubview:self.stickyHeaderView];
   self.stickySection = -1;  // 初始没有固定的 header
    
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
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 40;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [NSString stringWithFormat:@"%ld", (long)section];
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 50)];
//    return header;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *list = self.data[section];
    return list.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellClass:UITableViewCell.class forIndexPath:indexPath];
    NSString *txt = self.data[indexPath.section][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"group:%lu row:%lu---%@", (unsigned long)indexPath.section, (unsigned long)indexPath.row, txt];
    cell.backgroundColor = UIColor.blueColor;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"select: %lu %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row);
//    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated: true];
    });
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat top = scrollView.contentOffset.y; // 当前滚动的偏移量
//    
//    // 固定粘性表头的高度
//    CGFloat stickyHeaderHeight = 40.0;
//
//    // 遍历所有组，查看当前滚动位置是否需要固定某个表头
//    BOOL foundStickyHeader = NO;
//    
//    for (NSInteger section = 0; section < [self data].count; section++) {
//        CGRect headerRect = [self.tableView rectForHeaderInSection:section];
//        
//        // 如果当前组的表头没有完全滚出屏幕，保持粘性
//        if (top >= headerRect.origin.y && top < headerRect.origin.y + headerRect.size.height) {
//            // 如果当前组的表头需要固定到顶部
//            if (self.stickySection != section) {
//                self.stickySection = section;
//                UILabel *label = self.stickyHeaderView.subviews.firstObject;
//                label.text = [NSString stringWithFormat:@"Sticky Header for Section %ld", section + 1];
//            }
//            
//            // 计算粘性表头的位置，直到当前组的表头完全消失
//            CGFloat stickyHeaderY = headerRect.origin.y - top;
//            if (stickyHeaderY < 0) {
//                stickyHeaderY = 0;  // 确保粘性表头不会位于负值位置
//            }
//
//            // 设置 stickyHeaderView 可见并更新位置
//            self.stickyHeaderView.frame = CGRectMake(0, stickyHeaderY, self.view.bounds.size.width, stickyHeaderHeight);
//            self.stickyHeaderView.hidden = NO;
//            
//            foundStickyHeader = YES;
//            break;
//        }
//        // 当前组表头完全消失，切换为下一个组
//        else if (top >= headerRect.origin.y + headerRect.size.height) {
//            if (self.stickySection == section) {
//                self.stickySection = -1;  // 当前组表头已消失
//            }
//        }
//    }
//    
//    // 如果没有找到需要固定的表头，隐藏粘性表头
//    if (!foundStickyHeader) {
//        self.stickyHeaderView.hidden = YES;
//    }
//}
#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, tableView.frame.size.width, 40)];
    label.text = [NSString stringWithFormat:@"Section %ld", (long)section + 1];
    [headerView addSubview:label];
    NSString *key = [NSString stringWithFormat:@"%ld", (long)section];
    self.cacheHeaders[key] = headerView;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    for (NSInteger section = 0; section < [self.tableView numberOfSections]; section++) {
//        CGRect headerRect = [self.tableView rectForHeaderInSection:section];
//        headerRect = CGRectOffset(headerRect, 0, -self.tableView.contentOffset.y);
//        NSString *key = [NSString stringWithFormat:@"%ld", (long)section];
//        UIView *headerView = self.cacheHeaders[key];
//        
//        if (headerView) {
//            if (headerRect.origin.y < 0) {
//                headerRect.origin.y = 0;
//            }
//            
//            if (headerRect.origin.y + headerRect.size.height > self.tableView.contentOffset.y + self.tableView.frame.size.height) {
//                headerRect.origin.y = self.tableView.contentOffset.y + self.tableView.frame.size.height - headerRect.size.height;
//            }
//            
//            headerView.frame = headerRect;
//        }
//    }
//}

// MARK: - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass: UITableViewCell.class];
    }
    return _tableView;
}

- (UIView *)stickyHeaderView {
    if (_stickyHeaderView == nil) {
        // 初始化 sticky header view
        _stickyHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
        _stickyHeaderView.backgroundColor = [UIColor greenColor];
        UILabel *label = [[UILabel alloc] initWithFrame: _stickyHeaderView.bounds];
        label.text = @"Sticky Header";
        label.textColor = [UIColor blackColor];
        [_stickyHeaderView addSubview:label];
    }
    return _stickyHeaderView;
}

- (NSMutableArray<NSMutableArray *> *)data {
    if (_data == nil) {
        _data = [NSMutableArray new];
    }
    return _data;
}
- (NSMutableDictionary *)cacheHeaders {
    if (_cacheHeaders == nil) {
        _cacheHeaders = [NSMutableDictionary dictionary];
    }
    return _cacheHeaders;
}
@end
