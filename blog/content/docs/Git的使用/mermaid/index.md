---
title: "mermaid"
date: 2026-06-01T05:08:26+08:00
draft: false
weight: 660
summary: ""
bookCollapseSection: false
---


<iframe
  src="https://dragonir.github.io/3d/#/earth"
  title="Jobs出品，必属精品"
  width="100%"
  height="400"
  style="border:0; display:block;"
  allowfullscreen>
</iframe>

```mermaid
classDiagram
class UIViewModelProtocol {
    +@property(nonatomic,strong,nullable)UITextModel *textModel;
    +@property(nonatomic,strong,nullable)UITextModel *subTextModel;
    +@property(nonatomic,strong,nullable)UITextModel *backBtnTitleModel;
    +@property(nonatomic,strong,nullable)UIButtonModel *buttonModel;
    +@property(nonatomic,strong,nullable)UIButtonModel *subButtonModel;
    +@property(nonatomic,strong,nullable)JobsReturnIDByIDBlock jobsBlock;
    +@property(nonatomic,strong,nullable)NSMutableArray <JobsReturnIDByIDBlock>*jobsBlockMutArr;
}
UIPictureAndBackGroundCorProtocol <|-- UIViewModelProtocol
UILocationProtocol <|-- UIViewModelProtocol
UIMarkProtocol <|-- UIViewModelProtocol
UIViewModelOthersProtocol <|-- UIViewModelProtocol
BaseButtonProtocol <|-- UIViewModelProtocol
UITextModelProtocol <|-- UIViewModelProtocol

class UICollectionViewCellProtocol {
    +-(UICollectionView *)jobsGetCurrentCollectionView;
    +-(NSIndexPath *)jobsGetCurrentIndexPath;
    +-(NSInteger)jobsGetCurrentNumberOfSections;
    +-(NSInteger)jobsGetCurrentNumberOfItemsInSection;
    +-(UITextView *)getTextView;
    +-(UIButton *)getBgBtn;
}
BaseCellProtocol <|-- UICollectionViewCellProtocol

class UIMarkProtocol {
    +@property(nonatomic,strong,nullable)NSIndexPath __block *indexPath;
    +@property(nonatomic,assign)NSInteger __block section;
    +@property(nonatomic,assign)NSInteger __block row;
    +@property(nonatomic,assign)NSInteger __block item;
    +@property(nonatomic,assign)CGPoint __block lastPoint;
    +@property(nonatomic,assign)NSInteger __block index;
    +@property(nonatomic,assign)NSInteger __block currentPage;
    +@property(nonatomic,assign)NSInteger __block pageSize;
    +@property(nonatomic,assign)BOOL __block isMark;
    +@property(nonatomic,assign)CGFloat presentUpHeight;
}
NSObject <|-- UIMarkProtocol

class UIPictureAndBackGroundCorProtocol {
    +@property(nonatomic,strong,nullable)UIImage __block *image;
    +@property(nonatomic,strong,nullable)UIImage __block *bgImage;
    +@property(nonatomic,strong,nullable)NSString __block *imageURLString;
    +@property(nonatomic,strong,nullable)NSString __block *bgImageURLString;
    +@property(nonatomic,strong,nullable)UIColor __block *bgCor;
    +@property(nonatomic,strong,nullable)UIImage __block *backBtnIMG;
    +@property(nonatomic,strong,nullable)UIBackgroundConfiguration *bgConfig API_AVAILABLE(ios(14.0), tvos(14.0), watchos(7.0));
    +@property(nonatomic,strong,nullable)UIImage __block *selectedImage;
    +@property(nonatomic,strong,nullable)UIImage __block *bgSelectedImage;
    +@property(nonatomic,strong,nullable)NSString __block *selectedImageURLString;
    +@property(nonatomic,strong,nullable)NSString __block *bgSelectedImageURLString;
    +@property(nonatomic,strong,nullable)UIColor __block *bgSelectedCor;
    +@property(nonatomic,strong,nullable)UIImage __block *backBtnSelectedIMG;
    +@property(nonatomic,strong,nullable)UIBackgroundConfiguration *bgSelectedConfig API_AVAILABLE(ios(14.0), tvos(14.0), watchos(7.0));
    +@property(nonatomic,strong,nullable)UIImageView __block *bgImageView;
}
NSObject <|-- UIPictureAndBackGroundCorProtocol

class BaseViewControllerProtocol {
    +- (void)updateStatusBarCor:(UIColor *_Nullable)cor;
    +-(void)restoreStatusBarCor:(UIColor *_Nullable)cor;
    +-(void)showUserInfo;
    +-(void)setGKNav;
    +-(void)setGKNavBackBtn;
    +@property(nonatomic,weak)UIViewController *fromVC;
    +@property(nonatomic,strong,nullable)SPAlertController *alertController;
    +@property(nonatomic,assign)ComingStyle pushOrPresent;
    +@property(nonatomic,assign)BOOL setupNavigationBarHidden;
    +@property(nonatomic,strong)UIView *statusBar;
}
BaseViewProtocol <|-- BaseViewControllerProtocol

class AppToolsProtocol {
    +-(void)toLoginOrRegister:(CurrentPage)appDoorContentType;
    +-(void)toLogin;
    +-(void)forcedLogin;
    +-(void)popUpViewToLogout;
    +-(UITabBar *)getTabBar;
    +-(void)tabBarClosePan;
    +-(void)tabBarOpenPan;
    +-(void)jumpToHome;
    +-(NSMutableArray <UIViewController *>*)appRootVC;
    +-(BOOL)isRootVC;
    +-(NSString *)encodePicStr:(NSString *)picStr;
    +-(NSString *)decodePicStr:(NSString *)encodePicStr;
    +-(void)openGameWithUrl:(NSString *)url;
    +-(UIImage *)defaultHeaderImage;
    +-(NSString *)currentLanguage;
    +-(HTTPRequestHeaderLanguageType)currentLanguageType;
    +-(void)actionForHotLabel:(JobsHotLabelWithSingleLine *)hl;
}
BaseProtocol <|-- AppToolsProtocol

class UIViewModelOthersProtocol {
    +-(BOOL)jobsVisible;
    +-(void)setJobsVisible:(BOOL)jobsVisible;
    +@property(nonatomic,strong,nullable)Class __block cls;
    +@property(nonatomic,strong,nullable)UIViewModel __block *viewModel;
    +@property(nonatomic,strong,nullable)NSMutableArray <UIViewModel *> __block *viewModelMutArr;
    +@property(nonatomic,strong,nullable)RACSignal __block *reqSignal;
    +@property(nonatomic,strong,nullable)NSString __block *internationalizationKEY;
    +@property(nonatomic,assign)NSUInteger __block jobsTag;
    +@property(nonatomic,assign)BOOL __block jobsSelected;
    +@property(nonatomic,assign)BOOL __block isMultiLineShows;
    +@property(nonatomic,assign)BOOL __block isTranslucent;
    +@property(nonatomic,assign)BOOL __block isVisible;
    +@property(nonatomic,assign)UILabelShowingType labelShowingType;
    +@property(nonatomic,strong,nullable)id __block data;
    +@property(nonatomic,strong,nullable)id __block requestParams;
    +@property(nonatomic,strong,nullable)NSMutableSet __block *jobsDataMutSet;
    +@property(nonatomic,strong,nullable)NSMutableArray __block *jobsDataMutArr;
    +@property(nonatomic,strong,nullable)NSMutableDictionary __block *jobsDataMutDic;
    +@property(nonatomic,strong,nullable)UIColor __block *layerBorderCor;
    +@property(nonatomic,assign)CGFloat __block layerBorderWidth;
    +@property(nonatomic,assign)CGFloat __block layerCornerRadius;
}
NSObject <|-- UIViewModelOthersProtocol

class UITextModelProtocol {
    +@property(nonatomic,assign)NSTextAlignment __block textAlignment;
    +@property(nonatomic,assign)NSLineBreakMode __block lineBreakMode;
    +@property(nonatomic,assign)CGFloat __block textLineSpacing;
    +@property(nonatomic,copy)NSString __block *placeholder;
    +@property(nonatomic,strong)UIColor __block *placeholderColor;
    +@property(nonatomic,assign)NSInteger __block curWordCount;
    +@property(nonatomic,assign)NSInteger __block maxWordCount;
    +@property(nonatomic,strong,nullable)NSString __block *text;
    +@property(nonatomic,strong,nullable)UIFont __block *font;
    +@property(nonatomic,strong,nullable)UIColor __block *textCor;
    +@property(nonatomic,strong,nullable)NSAttributedString __block *attributedText API_AVAILABLE(ios(6.0));
    +@property(nonatomic,strong)NSMutableArray <RichTextConfig *>__block *titleAttributedDataMutArr;
    +@property(nonatomic,strong,nullable)NSString __block *selectedText;
    +@property(nonatomic,strong,nullable)UIFont __block *selectedFont;
    +@property(nonatomic,strong,nullable)UIColor __block *selectedTextCor;
    +@property(nonatomic,strong,nullable)NSAttributedString __block *selectedAttributedText API_AVAILABLE(ios(6.0));
    +@property(nonatomic,strong)NSMutableArray <RichTextConfig *>__block *selectedTitleAttributedDataMutArr;
}
NSObject <|-- UITextModelProtocol

class BaseButtonProtocol {
    +-(void)richElementsInButtonWithModel:(id _Nullable)model;
    ++(CGFloat)buttonWidthWithModel:(id _Nullable)model;
    ++(CGFloat)buttonHeightWithModel:(id _Nullable)model;
    ++(CGSize)buttonSizeWithModel:(id _Nullable)model;
    ++(CGRect)buttonFrameWithModel:(id _Nullable)model;
    +-(CGFloat)buttonWidthWithModel:(id _Nullable)model;
    +-(CGFloat)buttonHeightWithModel:(id _Nullable)model;
    +-(CGSize)buttonSizeWithModel:(id _Nullable)model;
    +-(CGRect)buttonFrameWithModel:(id _Nullable)model;
    +@property(nonatomic,strong)UIFont *titleFont;
    +@property(nonatomic,assign)NSTextAlignment titleAlignment;
    +@property(nonatomic,assign)BOOL jobsSelected;
    +@property(nonatomic,strong)UIImage *normalImage;
    +@property(nonatomic,strong)UIImage *normalBackgroundImage;
    +@property(nonatomic,strong)NSString *normalTitle;
    +@property(nonatomic,strong)NSString *normalSubTitle;
    +@property(nonatomic,strong)UIColor *normalTitleColor;
    +@property(nonatomic,strong)UIColor *normalSubTitleColor;
    +@property(nonatomic,strong)NSAttributedString *normalAttributedTitle;
    +@property(nonatomic,strong)NSAttributedString *normalAttributedSubTitle;
    +@property(nonatomic,strong)UIImage *selectedImage;
    +@property(nonatomic,strong)UIImage *selectedBackgroundImage;
    +@property(nonatomic,strong)NSString *selectedTitle;
    +@property(nonatomic,strong)NSString *selectedSubTitle;
    +@property(nonatomic,strong)UIColor *selectedTitleColor;
    +@property(nonatomic,strong)UIColor *selectedSubTitleColor;
    +@property(nonatomic,strong)NSAttributedString *selectedAttributedTitle;
    +@property(nonatomic,strong)NSAttributedString *selectedAttributedSubTitle;
    +@property(nonatomic,strong)UIColor *btnBackgroundColor;
    +@property(nonatomic,assign)CGSize imageSize;
    +@property(nonatomic,assign)UIControlContentHorizontalAlignment contentHorizontalAlignment;
    +@property(nonatomic,assign)UIControlContentVerticalAlignment contentVerticalAlignment;
    +@property(nonatomic,assign)UIEdgeInsets contentEdgeInsets;
    +@property(nonatomic,readwrite,assign)NSDirectionalEdgeInsets contentInsets;
    +@property(nonatomic,assign)CGFloat contentSpacing;
    +@property(nonatomic,assign)NSLineBreakMode lineBreakMode;
    +@property(nonatomic,assign)CGFloat btnWidth;
    +@property(nonatomic,assign)CGRect textLabelFrame;
    +@property(nonatomic,assign)CGRect subTextLabelFrame;
    +@property(nonatomic,assign)CGRect imageViewFrame;
    +@property(nonatomic,assign)CGSize textLabelSize;
    +@property(nonatomic,assign)CGSize subTextLabelSize;
    +@property(nonatomic,assign)CGSize imageViewSize;
    +@property(nonatomic,assign)CGFloat textLabelWidth;
    +@property(nonatomic,assign)CGFloat subTextLabelWidth;
    +@property(nonatomic,assign)CGFloat imageViewWidth;
    +@property(nonatomic,assign)CGFloat textLabelHeight;
    +@property(nonatomic,assign)CGFloat subTextLabelHeight;
    +@property(nonatomic,assign)CGFloat imageViewHeight;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetX;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetY;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetWidth;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetHeight;
    +@property(nonatomic,assign)CGFloat subTextLabelFrameOffsetX;
    +@property(nonatomic,assign)CGFloat subTextLabelFrameOffsetY;
    +@property(nonatomic,assign)CGFloat subTextLabelFrameOffsetWidth;
    +@property(nonatomic,assign)CGFloat subTextLabelFrameOffsetHeight;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetX;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetY;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetWidth;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetHeight;
}
BaseViewProtocol <|-- BaseButtonProtocol

class UITableViewCellProtocol {
    ++(instancetype)initTableViewCellWithStyle:(UITableViewCellStyle)style;
    ++(instancetype)cellStyleDefaultWithTableView:(UITableView *)tableView;
    ++(instancetype)cellStyleValue1WithTableView:(UITableView *)tableView;
    ++(instancetype)cellStyleValue2WithTableView:(UITableView *)tableView;
    ++(instancetype)cellStyleSubtitleWithTableView:(UITableView *)tableView;
    ++(void)settingForTableViewCell:(UITableViewCell *)tableViewCell;
    +-(UITableView *)jobsGetCurrentTableView;
    +-(NSIndexPath *)jobsGetCurrentIndexPath;
    +-(NSInteger)jobsGetCurrentNumberOfSections;
    +-(NSInteger)jobsGetCurrentNumberOfRowsInSection;
    +@property(nonatomic,assign)CGRect textLabelFrame;
    +@property(nonatomic,assign)CGRect detailTextLabelFrame;
    +@property(nonatomic,assign)CGRect imageViewFrame;
    +@property(nonatomic,assign)CGSize textLabelSize;
    +@property(nonatomic,assign)CGSize detailTextLabelSize;
    +@property(nonatomic,assign)CGSize imageViewSize;
    +@property(nonatomic,assign)CGFloat textLabelWidth;
    +@property(nonatomic,assign)CGFloat textLabelHeight;
    +@property(nonatomic,assign)CGFloat detailTextLabelWidth;
    +@property(nonatomic,assign)CGFloat detailTextLabelHeight;
    +@property(nonatomic,assign)CGFloat imageViewWidth;
    +@property(nonatomic,assign)CGFloat imageViewHeight;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetX;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetY;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetWidth;
    +@property(nonatomic,assign)CGFloat textLabelFrameOffsetHeight;
    +@property(nonatomic,assign)CGFloat detailTextLabelOffsetX;
    +@property(nonatomic,assign)CGFloat detailTextLabelOffsetY;
    +@property(nonatomic,assign)CGFloat detailTextLabelOffsetWidth;
    +@property(nonatomic,assign)CGFloat detailTextLabelOffsetHeight;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetX;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetY;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetWidth;
    +@property(nonatomic,assign)CGFloat imageViewFrameOffsetHeight;
}
BaseCellProtocol <|-- UITableViewCellProtocol

class BaseCellProtocol {
    +-(void)richElementsInCellWithModel:(id _Nullable)model;
    ++(CGFloat)cellHeightWithModel:(id _Nullable)model;
    ++(CGSize)cellSizeWithModel:(id _Nullable)model;
    +-(void)setCellBgImage:(UIImage *)bgImage;
    +-(UIButton *)getLeftBtn;
    +-(UIButton *)getRightBtn;
}
BaseViewProtocol <|-- BaseCellProtocol

class BaseViewProtocol {
    +-(void)richElementsInViewWithModel:(id _Nullable)model;
    ++(CGFloat)viewWidthWithModel:(id _Nullable)model;
    ++(CGFloat)viewHeightWithModel:(id _Nullable)model;
    ++(CGFloat)heightForFooterInSection:(id _Nullable)model;
    ++(CGFloat)heightForHeaderInSection:(id _Nullable)model;
    ++(CGSize)viewSizeWithModel:(id _Nullable)model;
    ++(CGRect)viewFrameWithModel:(id _Nullable)model;
    ++(CGFloat)viewChangeXWithModel:(id _Nullable)model;
    ++(CGFloat)viewChangeYWithModel:(id _Nullable)model;
    ++(CGFloat)viewChangeWidthWithModel:(id _Nullable)model;
    ++(CGFloat)viewChangeHeightWithModel:(id _Nullable)model;
    ++(CGSize)collectionReusableViewSizeWithModel:(id _Nullable)model;
    ++(CGFloat)widthByData:(UIViewModel *_Nonnull)data;
    ++(CGFloat)heightByData:(UIViewModel *_Nonnull)data;
    +-(CGFloat)viewWidthWithModel:(id _Nullable)model;
    +-(CGFloat)viewHeightWithModel:(id _Nullable)model;
    +-(CGFloat)heightForFooterInSection:(id _Nullable)model;
    +-(CGFloat)heightForHeaderInSection:(id _Nullable)model;
    +-(CGSize)viewSizeWithModel:(id _Nullable)model;
    +-(CGRect)viewFrameWithModel:(id _Nullable)model;
    +-(CGFloat)viewChangeXWithModel:(id _Nullable)model;
    +-(CGFloat)viewChangeYWithModel:(id _Nullable)model;
    +-(CGFloat)viewChangeWidthWithModel:(id _Nullable)model;
    +-(CGFloat)viewChangeHeightWithModel:(id _Nullable)model;
    +-(CGSize)collectionReusableViewSizeWithModel:(id _Nullable)model;
    +-(CGFloat)widthByData:(UIViewModel *_Nonnull)data;
    +-(CGFloat)heightByData:(UIViewModel *_Nonnull)data;
    +-(instancetype)initWithSize:(CGSize)thisViewSize;
    +-(void)pullToRefresh;
    +-(void)loadMoreRefresh;
    +-(UIViewModel *_Nullable)getViewModel;
    +@property(nonatomic,strong,nullable)JobsReturnIDByIDBlock jobsBackBlock;
    +@property(nonatomic,assign)UIRectCorner layoutSubviewsRectCorner;
    +@property(nonatomic,assign)CGSize layoutSubviewsRectCornerSize;
    +@property(nonatomic,strong)NSMutableArray <MASConstraint *>*constraintMutArr;
    +@property(nonatomic,assign)CGSize thisViewSize;
    +@property(nonatomic,assign)JobsHeaderFooterViewStyle headerFooterViewStyle;
}
BaseProtocol <|-- BaseViewProtocol

class UILocationProtocol {
    +@property(nonatomic,assign)UIInterfaceOrientationMask currentInterfaceOrientationMask;
    +@property(nonatomic,assign)CGFloat __block cornerRadius;
    +@property(nonatomic,assign)UIRectCorner __block rectCorner;
    +@property(nonatomic,assign)CGSize __block cornerRadii;
    +@property(nonatomic,assign)CGFloat __block jobsWidth;
    +@property(nonatomic,assign)CGFloat __block jobsHeight;
    +@property(nonatomic,assign)CGFloat __block jobsTop;
    +@property(nonatomic,assign)CGFloat __block jobsLeft;
    +@property(nonatomic,assign)CGFloat __block jobsRight;
    +@property(nonatomic,assign)CGFloat __block jobsBottom;
    +@property(nonatomic,assign)CGFloat __block jobsOffsetX;
    +@property(nonatomic,assign)CGFloat __block jobsOffsetY;
    +@property(nonatomic,assign)CGSize __block jobsSize;
    +@property(nonatomic,assign)CGRect __block jobsRect;
    +@property(nonatomic,assign)CGPoint __block jobsPoint;
    +@property(nonatomic,assign)UILayoutConstraintAxis __block axis;
    +@property(nonatomic,assign)UIStackViewDistribution __block distribution;
    +@property(nonatomic,assign)UIStackViewAlignment __block alignment;
    +@property(nonatomic,assign)NSDirectionalRectEdge __block buttonEdgeInsetsStyle;
    +@property(nonatomic,assign)CGFloat __block imageTitleSpace;
    +@property(nonatomic,assign)CGFloat __block titleSpace;
    +@property(nonatomic,assign)CGFloat __block cellHeight;
    +@property(nonatomic,assign)CGFloat __block heightForHeaderInSection;
    +@property(nonatomic,assign)CGSize __block cellSize;
    +@property(nonatomic,assign)CGSize __block tableHeaderViewSize;
    +@property(nonatomic,assign)CGSize __block tableFooterViewSize;
    +@property(nonatomic,assign)BOOL __block usesTableViewHeaderView;
    +@property(nonatomic,assign)BOOL __block usesTableViewFooterView;
    +@property(nonatomic,assign)CGFloat __block offsetXForEach;
    +@property(nonatomic,assign)CGFloat __block offsetYForEach;
    +@property(nonatomic,assign)CGFloat __block offsetHeight;
    +@property(nonatomic,assign)CGFloat __block offsetWidth;
}
NSObject <|-- UILocationProtocol

class BaseProtocol {
    +-(void)languageSwitchNotificationWithSelector:(SEL)aSelector;
    +-(void)changeTabBarItemTitle:(NSIndexPath *)indexPath;
    +-(JobsReturnIDByIDBlock _Nonnull)valueForKeyBlock;
    +-(JobsReturnBOOLByIDBlock _Nonnull)isKindOfClassBlock;
    +-(JobsReturnBOOLByIDBlock _Nonnull)isMemberOfClassBlock;
    ++(void)target:(id)target languageSwitchNotificationWithSelector:(SEL)aSelector;
    +-(void)monitorAppLanguage;
    +-(void)languageSwitchNotification:(nonnull NSNotification *)notification;
    ++(void)destroySingleton;
    ++(instancetype)sharedInstance;
    +@property(nonatomic,assign)BOOL isLock;
    +@property(nonatomic,strong)RACDisposable *racDisposable;
    +@property(nonatomic,copy)JobsReturnIDByIDBlock keyboardUpNotificationBlock;
    +@property(nonatomic,copy)JobsReturnIDByIDBlock keyboardDownNotificationBlock;
}
NSObject <|-- BaseProtocol
```
