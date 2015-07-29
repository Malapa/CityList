//
//  CityListViewController.m
//  CityList
//
//  Created by bhb on 15/7/29.
//  Copyright (c) 2015年 Micky. All rights reserved.
//

#import "CityListViewController.h"
#import "City.h"
@interface CityListViewController ()
{
    NSDictionary *_cities; // 城市字典
    NSMutableArray *_keys; // 分组索引
    NSMutableArray *_indexKeys; // 侧索引
    NSMutableArray *_cityNames; // 城市名
    NSArray *_filterData; // 搜索结果
    NSArray *_hotCity; // 热门城市
    UISearchDisplayController *_searchController;
    
}

@end
@implementation CityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"citydict" ofType:@"plist"];
    _hotCity = [NSArray arrayWithObjects:@"上海",@"北京",@"广州",@"深圳",@"武汉",@"天津",@"西安",@"南京",@"杭州",@"成都",@"重庆", nil];
    _cities = [[NSDictionary alloc] initWithContentsOfFile:path];
    _keys = [NSMutableArray arrayWithArray:[[_cities allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    _indexKeys = [NSMutableArray arrayWithArray:_keys];
    [_indexKeys insertObjects:@[@"#",@"$",@"*"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    [_keys insertObjects:@[@"定位城市",@"最近访问城市",@"热门城市"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    _cityNames = [NSMutableArray array];
    // 获取所有城市名
    for (NSArray *cityArr in [_cities allValues]) {
        for (NSString *cityStr in cityArr) {
            City *city = [[City alloc] init];
            city.cityName = cityStr;
            // 转换为拼音
            NSMutableString *ms = [[NSMutableString alloc] initWithString:cityStr];
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                city.cityLetter = ms;
            }
            [_cityNames addObject:city];
        }
    }
}
- (void)configUI
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"搜索";
    self.tableView.tableHeaderView = searchBar;
    self.tableView.sectionIndexColor = [UIColor lightGrayColor];
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
}

- (void)btnClicked:(UIButton *)btn
{
    NSLog(@"%@",btn.titleLabel.text);
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        NSString *key = [_keys objectAtIndex:indexPath.section];
        NSLog(@"%@",[[_cities objectForKey:key] objectAtIndex:indexPath.row]);
    }
    else
    {
        NSLog(@"%@",[[_filterData objectAtIndex:indexPath.row] cityName]);
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return _keys[section];
    }
    return nil;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return _indexKeys;
    }
    else
        return nil;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index

{
    //点击索引，列表跳转到对应索引的行
    if (tableView == self.tableView) {
        [tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
         atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return index;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 2) {
        return 60.f;
    }
    else if (indexPath.section == 2)
        return 210.f;
    else
        return 44.f;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.tableView) {
        return _keys.count;
    }
    else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        if (section < 3) {
            return 1;
        }
        NSString *key = _keys[section];
        NSArray *cityNames = [_cities objectForKey:key];
        return cityNames.count;
    }
    else
    {
        // c忽略大小写，d忽略重音 根据中文和拼音筛选
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cityName contains [cd] %@ OR cityLetter BEGINSWITH [cd] %@", _searchController.searchBar.text,_searchController.searchBar.text];
        _filterData = [[NSArray alloc] initWithArray:[_cityNames filteredArrayUsingPredicate:predicate]];
        return _filterData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"mycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView == self.tableView) {
        [self configCell:cell IndexPath:indexPath];
    }
    else{
        cell.textLabel.text = [[_filterData objectAtIndex:indexPath.row] cityName];
    }
    return cell;
}

- (void)configCell:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    CGFloat spaceWidth = (self.view.frame.size.width - 80 * 3 - 20)/4;
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.textLabel.text = nil;
    switch (indexPath.section) {
        case 0: // 定位城市
        {
#warning testData
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(spaceWidth, 10, 80, 40);
            [btn setTitle:@"深圳市" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            btn.layer.borderWidth = 0.5;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
        }
            break;
        case 1: // 最近城市
        {
#warning testData
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(spaceWidth, 10, 80, 40);
            [btn setTitle:@"深圳市" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            btn.layer.borderWidth = 0.5;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
        }
            break;
        case 2: // 热门城市
        {
            for (NSInteger i = 0; i < _hotCity.count; i++) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(spaceWidth + (80+spaceWidth)*(i%3), 10 + (40+10)*(i/3), 80, 40);
                [btn setTitle:_hotCity[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                btn.layer.borderWidth = 0.5;
                [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
            }
        }
            break;
        default: // 城市列表
        {
            NSString *key = [_keys objectAtIndex:indexPath.section];
            cell.textLabel.text = [[_cities objectForKey:key] objectAtIndex:indexPath.row];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
