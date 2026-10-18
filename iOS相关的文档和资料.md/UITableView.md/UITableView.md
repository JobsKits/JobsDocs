# <span id="前言">UITableView 的使用指南</span>

<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [1、详解UIScrollView 和UITabableView的滚动区域](#jobs-toc-heading-1)
- [2、UITableViewCell的重用](#jobs-toc-heading-2)
- [3、只刷新某一行或某一组的UITableViewCell](#jobs-toc-heading-3)
- [4、UITableView 禁止下拉 + 允许上拉](#jobs-toc-heading-4)
- [5、UITableViewCell 自适应](#jobs-toc-heading-5)
- [6、tableHeaderView 和 tableFooterView](#jobs-toc-heading-6)
- [7、viewForHeaderInSection 的使用记录](#jobs-toc-heading-7)

</details>
<!-- jobs-toc:end -->

当前总行数：0 行

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">1、详解UIScrollView 和UITabableView的滚动区域 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

![详解UIScrollView 和UITabableView的滚动区域](./assets/详解UIScrollView 和UITabableView的滚动区域.png)

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">2、UITableViewCell的重用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

![UITableViewCell的重用](./assets/UITableViewCell的重用.png)

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">3、只刷新某一行或某一组的UITableViewCell <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

*一个section刷新*

```objective-c
NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
[tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
```

*一个cell刷新*

```objective-c
NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
```

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">4、UITableView 禁止下拉 + 允许上拉 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```objective-c
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGPoint offset = self.mainTableView.contentOffset;
  if (offset.y <= 0) {
      offset.y = 0;
  }self.mainTableView.contentOffset = offset;
}
```

## <span id="jobs-toc-heading-5" data-jobs-toc="v2">5、UITableViewCell 自适应 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```objective-c
1、- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}//这个方法注销，不予实现

2、整个cell上面加与cell同样大小的label，make.edges.equalTo(self.contentView);_lab.lineBreakMode = NSLineBreakByWordWrapping;
_lab.numberOfLines = 0;

//调用系统浏览器打开 标准写法
if (@available(iOS 10.0, *)) {
    if ([UIApplication.sharedApplication respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:model.advertUrl]
																				 options:@{}
                               completionHandler:^(BOOL success) {
                   }];
               }
}else [UIApplication.sharedApplication openURL:[NSURL URLWithString:model.advertUrl]];
```

## <span id="jobs-toc-heading-6" data-jobs-toc="v2">6、tableHeaderView 和 tableFooterView <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

```objective-c
如果想在整个TableView的头部或者尾部出现一个View
注意区别于viewForHeaderInSection

需要涉及的相关属性:
_tableView.tableHeaderView;
_tableView.tableFooterView;
```

## <span id="jobs-toc-heading-7" data-jobs-toc="v2">7、viewForHeaderInSection 的使用记录 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

**UITableView的每个Section的头部出现一个view，涉及到复用机制**

*定义 BaiShaETProjMembersBoardView 文件*

*BaiShaETProjMembersBoardView.h*

```
@interface BaiShaETProjMembersBoardView : BaseTableViewHeaderView

BaiShaETProjMembersBoardView.m
#pragma mark —— BaseProtocol
/// 单例化和销毁
+(void)destroySingleton{
    static_membersBoardViewOnceToken = 0;
    static_membersBoardView = nil;
}

static BaiShaETProjMembersBoardView *static_membersBoardView = nil;
static dispatch_once_t static_membersBoardViewOnceToken;
+(instancetype)sharedInstance{
    dispatch_once(&static_membersBoardViewOnceToken, ^{
        static_membersBoardView = BaiShaETProjMembersBoardView.jobsInitWithReuseIdentifier;
    });return static_membersBoardView;
}

-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
    }return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self == [super initWithReuseIdentifier:reuseIdentifier]){

    }return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}
#pragma mark —— BaseViewProtocol
/// 具体由子类进行复写【数据定UI】【如果所传参数为基本数据类型，那么包装成对象NSNumber进行转化承接】
-(void)richElementsInViewWithModel:(UIViewModel *_Nullable)model{
    self.viewModel = model;
    MakeDataNull
}
/// 具体由子类进行复写【数据尺寸】【如果所传参数为基本数据类型，那么包装成对象NSNumber进行转化承接】
+ (CGRect)viewFrameWithModel:(UIViewModel *)model{
    return CGRectMake(0, 0, JobsMainScreen_WIDTH(), JobsWidth(39 + 64));
}
#pragma mark —— lazyLoad
...
```
在使用UITableView的主类,关联下列协议
```
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
```
在UITableView初始化部分进行注册
```
1、[_tableView registerTableViewClass];
        
2、在UITableView+RegisterClass.m添加如下
-(void)registerTableViewClass{
    [self registerHeaderFooterViewClass:BaiShaETProjMembersBoardView.class];
}
```

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
