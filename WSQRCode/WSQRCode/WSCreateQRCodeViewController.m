//
//  WSCreateQRCodeViewController.m
//  WSQRCode
//
//  Created by WangS on 16/9/28.
//  Copyright © 2016年 WangS. All rights reserved.
//

#import "WSCreateQRCodeViewController.h"
#import "Masonry.h"
#define ScreenW  [UIScreen mainScreen].bounds.size.width
#define ScreenH  [UIScreen mainScreen].bounds.size.height
#define SLColor(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0  blue:(b) / 255.0  alpha:1]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WSCreateQRCodeViewController ()<UIAlertViewDelegate>
@property (nonatomic,strong) UIImageView *customImageView;
@property (nonatomic,strong) UIImageView *bigIconImgView;
@property (nonatomic,strong) UIImageView *littleIconImgView;
@property (nonatomic,strong) UIImageView *backgroundImgView;
@property (nonatomic,strong) NSDictionary *userDatas;
@end

@implementation WSCreateQRCodeViewController
-(NSDictionary *)userDatas{
    if (!_userDatas) {
        _userDatas=[NSDictionary new];
    }
    return _userDatas;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=SLColor(244, 244, 244);
    self.userDatas = @{@"avatar":@"img",@"nickname":@"WS",@"work_position":@"程序猿"};
    [self setNav];
    [self setUI];
    [self setQRCodeImg];
}

-(void)setNav{
    UIView *navView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
    navView.backgroundColor=[UIColor whiteColor];
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame=CGRectMake(0, 20, 60, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backBtn setImage:[UIImage imageNamed:@"blackBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *nameLab=[[UILabel alloc] initWithFrame:CGRectMake(60, 27, ScreenW-120, 30)];
    nameLab.textAlignment=NSTextAlignmentCenter;
    nameLab.text=@"我的二维码";
    nameLab.font=[UIFont systemFontOfSize:18];
    nameLab.textColor=[UIColor blackColor];
    [navView addSubview:nameLab];
    
    UIButton *shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame=CGRectMake(ScreenW-60, 27, 60, 30);
    [shareBtn setTitle:@"保存" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:shareBtn];
    
    UIImageView *cutImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 63.5, ScreenW, 0.5)];
    cutImgView.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:navView];
}
-(void)shareBtn{
    UIImage *img =[self convertViewToImage:self.backgroundImgView];
    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString * title;
    if (error) {
       // kShowToast(@"保存失败");
        title = @"保存失败";
    }   else {
       // kShowToast(@"已保存到您的相册");
        title = @"已保存到您的相册";

    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setUI{
    float proportion;
    if (ScreenW == 375) {
        proportion = 1.17;
    } else if(ScreenW == 414){
        proportion = 1.29;
    } else {
        proportion = 1.0;
    }
    UIImageView *backgroundImgView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 68*proportion+64, ScreenW-40, 367*proportion)];
    backgroundImgView.image=[UIImage imageNamed:@"qrRectangle"];
    self.backgroundImgView=backgroundImgView;
    [self.view addSubview:backgroundImgView];
    backgroundImgView.layer.cornerRadius = 3;
    backgroundImgView.clipsToBounds = YES;
    UIImageView *logoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(4 ,4, 5, 63*proportion)];
    
    logoImageView.image = [UIImage imageNamed:@"recetangle"];
    logoImageView.layer.masksToBounds = YES;
    
    [backgroundImgView addSubview:logoImageView];
    
    UIImageView *bigIconImgView=[[UIImageView alloc] initWithFrame:CGRectMake(18, 11, 46*proportion, 46*proportion)];
    bigIconImgView.layer.cornerRadius = 46*proportion/2.0;
    bigIconImgView.layer.masksToBounds = YES;
    bigIconImgView.image = [UIImage imageNamed:@"img"];
    [backgroundImgView addSubview:bigIconImgView];
    
    
    UILabel *nameLab=[[UILabel alloc] init];
    nameLab.font=[UIFont boldSystemFontOfSize:17];
    nameLab.text=self.userDatas[@"nickname"];
    nameLab.textColor=[UIColor blackColor];
    [backgroundImgView addSubview:nameLab];
    CGFloat nickNameWidth= [self.userDatas[@"nickname"] boundingRectWithSize:CGSizeMake(backgroundImgView.frame.size.width-75-51*proportion, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} context:nil].size.width;
    if (nickNameWidth>backgroundImgView.frame.size.width-75-51*proportion) {
        nickNameWidth=backgroundImgView.frame.size.width-75-51*proportion;
    }
    nameLab.frame=CGRectMake(CGRectGetMaxX(bigIconImgView.frame)+15, 17*proportion, nickNameWidth+5, 17);
    
    UILabel *locationLab=[[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bigIconImgView.frame)+15, CGRectGetMaxY(nameLab.frame)+7, ScreenW-145, 14)];
    locationLab.textColor=SLColor(67, 67, 67);
    locationLab.text=self.userDatas[@"work_position"];
    locationLab.font=[UIFont systemFontOfSize:14];
    [backgroundImgView addSubview:locationLab];
    
    NSString *titleContentextString = @"高度，高度";
    CGFloat titleFontSize = [titleContentextString boundingRectWithSize:CGSizeMake(ScreenW-40-36, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
    CGFloat titleHeight = 0;
    
    NSInteger titleLineNum = titleHeight / titleFontSize;
    if (titleLineNum > 3) {
        titleLineNum = 3;
    }
    
    CGFloat bioLabelHeight = titleLineNum*titleFontSize;
    bioLabelHeight = 0;
    UILabel *bioLabel=[[UILabel alloc] initWithFrame:CGRectMake(18, 11+46*proportion+15, ScreenW-40-36, bioLabelHeight)];
    bioLabel.textColor=SLColor(132, 132, 132);
    bioLabel.text=self.userDatas[@"bio"];
    bioLabel.numberOfLines = 0;
    bioLabel.font=[UIFont systemFontOfSize:14];
    [backgroundImgView addSubview:bioLabel];
    self.customImageView=[[UIImageView alloc] init];
    [backgroundImgView addSubview:self.customImageView];
    [self.customImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bioLabel.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.height.width.mas_equalTo(@(196*proportion));
    }];
    UIImageView *littleIconImgView=[[UIImageView alloc] init];
    littleIconImgView.layer.borderWidth=1;
    littleIconImgView.layer.borderColor=[UIColor whiteColor].CGColor;
    littleIconImgView.layer.cornerRadius = 2.5;
    littleIconImgView.layer.masksToBounds = YES;
    littleIconImgView.image = [UIImage imageNamed:@"img"];
    [backgroundImgView addSubview:littleIconImgView];
    [littleIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.customImageView.mas_centerX);
        make.centerY.mas_equalTo(self.customImageView.mas_centerY);
        make.height.mas_equalTo(43*proportion);
        make.width.mas_equalTo(43*proportion);
    }];
    
    UILabel *titleLab=[[UILabel alloc] init];
    titleLab.text=@"简易版，更多功能按需求设计";
    titleLab.textAlignment=NSTextAlignmentCenter;
    titleLab.font=[UIFont systemFontOfSize:13];
    titleLab.textColor=SLColor(132, 132, 132);
    [backgroundImgView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customImageView.mas_bottom).offset(9);
        make.left.mas_equalTo(self.customImageView.mas_left);
        make.right.mas_equalTo(self.customImageView.mas_right);
        make.height.mas_equalTo(12);
    }];
}
-(void)setQRCodeImg{
    // 1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.还原滤镜默认属性
    [filter setDefaults];
    // 3.设置需要生成二维码的数据到滤镜中
    // OC中要求设置的是一个二进制数据

    NSData *data = [self.userDatas[@"nickname"] dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"InputMessage"];
    
    // 4.从滤镜从取出生成好的二维码图片
    CIImage *ciImage = [filter outputImage];
    
    self.customImageView.layer.shadowOffset = CGSizeMake(0, 0.5);  // 设置阴影的偏移量
    self.customImageView.layer.shadowRadius = 1;  // 设置阴影的半径
    self.customImageView.layer.shadowColor = [UIColor blackColor].CGColor; // 设置阴影的颜色为黑色
    self.customImageView.layer.shadowOpacity = 0.3; // 设置阴影的不透明度
    
    self.customImageView.image = [self createNonInterpolatedUIImageFormCIImage:ciImage size: 500];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)ciImage size:(CGFloat)widthAndHeight{
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(widthAndHeight / CGRectGetWidth(extentRect), widthAndHeight / CGRectGetHeight(extentRect));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extentRect) * scale;
    size_t height = CGRectGetHeight(extentRect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    //return [UIImage imageWithCGImage:scaledImage]; // 黑白图片
    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    return [self imageBlackToTransparent:newImage withRed:200.0f andGreen:70.0f andBlue:189.0f];
}
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            //改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            //            ptr[3] = red; //0~255
            //            ptr[2] = green;
            //            ptr[1] = blue;
            ptr[3] = 16; //0~255
            ptr[2] = 128;
            ptr[1] = 112;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}





@end
