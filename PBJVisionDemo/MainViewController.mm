//
//  MainViewController.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "MainViewController.h"
#import "VideoCell.h"
#import "CaptureViewController.h"
#import "DBHelper.h"
#import "VideoPlayerViewController.h"

@interface MainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, retain) UICollectionView* collectionView;

@property (nonatomic, retain) NSMutableArray* dataSource;

@end

@implementation MainViewController

- (NSMutableArray*)dataSource{
    if(!_dataSource){
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}

- (void)loadView{
    self.title = @"短视频Demo";
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-self.navigationController.navigationBar.bounds.origin.y)];
    contentView.backgroundColor = [UIColor darkGrayColor];
    self.view = contentView;
    
    //创建流水布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置竖直滚动
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // 设置各分区上、左、下、右空白的大小。
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:VideoCell.class forCellWithReuseIdentifier:VideoCellReuseIdentifier];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clearVideo)];
    [leftBarBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"录制" style:UIBarButtonItemStylePlain target:self action:@selector(showCaptureVideoVc)];
    [rightBarBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
}

- (void) clearVideo{
    [[DBHelper sharedDB] deleteAllObjectsFromTable:TBVideo.tableName];
    [self loadDataSource];
}

- (void) showCaptureVideoVc{
    CaptureViewController* captureVc = [[CaptureViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    [self presentViewController:captureVc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureVideoCompletedAction:) name:NotificationCaptureVideoCompleted object:nil];
    
    [self loadDataSource];
}

- (void) captureVideoCompletedAction:(NSNotification*)noti{
    [self loadDataSource];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) loadDataSource{
    [self.dataSource removeAllObjects];
    
    NSArray* videoArray = [[DBHelper sharedDB] getAllObjectsOfClass:TBVideo.class fromTable:TBVideo.tableName];
    if(videoArray && videoArray.count > 0){
        [self.dataSource addObjectsFromArray:videoArray];
    }
    
    [self.collectionView reloadData];
}

// 该方法返回值决定各单元格的控件。
- (UICollectionViewCell *)collectionView:(UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 从可重用单元格的队列中取出一个单元格
    VideoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:VideoCellReuseIdentifier forIndexPath:indexPath];
    if(!cell){
        cell = [[VideoCell alloc] initWithFrame:CGRectMake(0, 0, (self.view.bounds.size.width-24)/2, 140)];
    }
    
    [cell setVideo:self.dataSource[indexPath.row]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.bounds.size.width)/2, 140);
}

//设置行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置cell之间间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TBVideo* video = self.dataSource[indexPath.row];
    
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SmallVideo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    path = [path stringByAppendingPathComponent:video.videoName];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(!isExist && video.videoData){
        [[NSFileManager defaultManager] createFileAtPath:path contents:video.videoData attributes:nil];
    }
    
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    NSLog(@"isExist:%@", isExist ? @"True":@"False");
    if(isExist){
        VideoPlayerViewController* videoPlayerVc = [[VideoPlayerViewController alloc] init];
        videoPlayerVc.videoPath = path;
        [self presentViewController:videoPlayerVc animated:YES completion:nil];
    }else{
        NSLog(@"文件不存在");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
