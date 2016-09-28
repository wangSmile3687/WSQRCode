//
//  WSQRCodeViewController.m
//  WSQRCode
//
//  Created by WangS on 16/9/28.
//  Copyright © 2016年 WangS. All rights reserved.
//

#import "WSQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WSCreateQRCodeViewController.h"

#define ScreenW  [UIScreen mainScreen].bounds.size.width
#define ScreenH  [UIScreen mainScreen].bounds.size.height
#define SLColor(r, g, b) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0  blue:(b) / 255.0  alpha:1]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface WSQRCodeViewController ()
<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>{
    NSTimer *timer;
    BOOL upToDown;
    int num;
    BOOL isShow;
    UIImageView *lineImageView;
}
@property (nonatomic, strong) AVCaptureSession *mySession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *myPreviewLayer;
@property (nonatomic, copy) NSString *QRCodeInfo;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIImageView *avatarImageVw;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) UIView *backView;
@end

@implementation WSQRCodeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    UIView *backView=[[UIView alloc] initWithFrame:self.view.bounds];
    backView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    self.backView=backView;
    [self.view addSubview:backView];
    [self setNav];
    [self setUI];
    [self readQRcode];

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
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, ScreenW, ScreenH)];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake((ScreenW-221*proportion)/2, 68*proportion+64, 221*proportion, 221*proportion) cornerRadius:1] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.backView.layer.mask = maskLayer;
    
    self.scanView=[[UIView alloc] init];
    self.scanView.frame=CGRectMake((ScreenW-221*proportion)/2, 68*proportion+64, 221*proportion, 221*proportion);
    self.scanView.layer.borderWidth=0.5;
    self.scanView.layer.borderColor=[UIColor whiteColor].CGColor;
    [self.view addSubview:self.scanView];
    
    lineImageView = [[UIImageView alloc]init];
    lineImageView.frame = CGRectMake(self.scanView.frame.origin.x, self.scanView.frame.origin.y, self.scanView.frame.size.width, 4);
    lineImageView.image=[UIImage imageNamed:@"lineImage"];
    [self.view addSubview:lineImageView];
    //边角
    UIImageView *imgView1=[[UIImageView alloc] initWithFrame:CGRectMake((ScreenW-221*proportion)/2, 68*proportion+64, 15, 15)];
    imgView1.image=[UIImage imageNamed:@"corner1"];
    [self.view addSubview:imgView1];
    UIImageView *imgView2=[[UIImageView alloc] initWithFrame:CGRectMake((ScreenW+221*proportion)/2-15, 68*proportion+64, 15, 15)];
    imgView2.image=[UIImage imageNamed:@"corner2"];
    [self.view addSubview:imgView2];
    UIImageView *imgView3=[[UIImageView alloc] initWithFrame:CGRectMake((ScreenW-221*proportion)/2, 221*proportion+68*proportion+64-15, 15, 15)];
    imgView3.image=[UIImage imageNamed:@"corner3"];
    [self.view addSubview:imgView3];
    UIImageView *imgView4=[[UIImageView alloc] initWithFrame:CGRectMake((ScreenW+221*proportion)/2-15, 221*proportion+68*proportion+64-15, 15, 15)];
    imgView4.image=[UIImage imageNamed:@"corner4"];
    [self.view addSubview:imgView4];
    
    UILabel *describetionLab=[[UILabel alloc] initWithFrame:CGRectMake((ScreenW-221*proportion)/2, 221*proportion+68*proportion+64+50, 221*proportion, 20)];
    describetionLab.text=@"将二维码放入框内，即可自动扫码";
    describetionLab.textColor=[UIColor whiteColor];
    describetionLab.font=[UIFont systemFontOfSize:14];
    describetionLab.numberOfLines=0;
    describetionLab.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:describetionLab];
    
    UIButton *QRCodeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    QRCodeBtn.frame=CGRectMake(40, 221*proportion+68*proportion+64+20+50, ScreenW-80, 30);
    [QRCodeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    QRCodeBtn.titleLabel.shadowColor = [UIColor blackColor];
    [QRCodeBtn setTitleColor:SLColor(16, 128, 112) forState:UIControlStateNormal];
    QRCodeBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [QRCodeBtn addTarget:self action:@selector(QRCodeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:QRCodeBtn];
    
}
-(void)QRCodeBtnClick{
    //生成二维码
    WSCreateQRCodeViewController *vc=[[WSCreateQRCodeViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)setNav{
    UIView *navView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame=CGRectMake(0, 20, 60, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [backBtn setImage:[UIImage imageNamed:@"whileBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *nameLab=[[UILabel alloc] initWithFrame:CGRectMake(60, 27, ScreenW-120, 30)];
    nameLab.textAlignment=NSTextAlignmentCenter;
    nameLab.text=@"二维码";
    nameLab.font=[UIFont systemFontOfSize:18];
    nameLab.textColor=[UIColor whiteColor];
    [navView addSubview:nameLab];
    
    UIButton *picktureBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    picktureBtn.frame=CGRectMake(ScreenW-60, 27, 60, 30);
    picktureBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [picktureBtn setTitle:@"相册" forState:UIControlStateNormal];
    [picktureBtn addTarget:self action:@selector(picktureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:picktureBtn];
    
    [self.view addSubview:navView];
}
-(void)picktureBtnClick{//识别相册中的二维码
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self stopTimer];
    [self.mySession stopRunning];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //返回的UIImage
    CIImage *ciImage = [CIImage imageWithCGImage:[image CGImage]];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    NSArray *arr = [detector featuresInImage:ciImage];
    if (arr.count>0){
        CIQRCodeFeature *feature = arr[0];
        self.QRCodeInfo=feature.messageString;
        [self dismissViewControllerAnimated:YES completion:nil];
        //[HUDManager showLoadingHUDView:[UIApplication sharedApplication].keyWindow withText:@""];
        [self captureResultManage];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"未发现二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag=100;
        [alert show];
    }
}
- (void)backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)readQRcode {
    float proportion;
    if (ScreenW == 375) {
        proportion = 1.17;
    } else if(ScreenW == 414){
        proportion = 1.29;
    } else {
        proportion = 1.0;
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"没有摄像头：%@", error.localizedDescription);
        return;
    }
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    CGSize size = self.view.bounds.size;
    CGRect cropRect = CGRectMake((ScreenW-221*proportion)/2, 68*proportion+64, 221*proportion, 221*proportion);
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = ScreenW * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = ScreenH * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
    
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session addInput:input];
    [session addOutput:output];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [preview setFrame:self.view.bounds];
    [self.view.layer insertSublayer:preview atIndex:0];
    self.myPreviewLayer = preview;
    self.mySession = session;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startTimer];
        [session startRunning];
    });
}
-(void)startTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    upToDown = YES;
    num = 0;
    lineImageView.frame = CGRectMake(self.scanView.frame.origin.x, self.scanView.frame.origin.y, self.scanView.frame.size.width, 4);
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
}
- (void)stopTimer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
- (void)lineAnimation{
    if (!([self isViewLoaded] && [self.view superview])) {
        return;
    }
    if (upToDown) {
        num++;
        float temp = 0.0;
        if (4*num > self.scanView.frame.size.height-4) {
            temp = self.scanView.frame.size.height+self.scanView.frame.origin.y;
            upToDown = NO;
        }else{
            temp = self.scanView.frame.origin.y + 4*num;
        }
        lineImageView.frame = CGRectMake(self.scanView.frame.origin.x, temp, self.scanView.frame.size.width, 4);
    }else{
        num--;
        float temp = 0.0;
        if (num <= 0) {
            temp = self.scanView.frame.origin.y;
            upToDown = YES;
        }else{
            temp = self.scanView.frame.origin.y + 4*num;
        }
        lineImageView.frame = CGRectMake(self.scanView.frame.origin.x, temp, self.scanView.frame.size.width, 4);
    }
}
#pragma  mark - 输出代理方法
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.mySession stopRunning];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        [self stopTimer];
        self.QRCodeInfo=obj.stringValue;
        [self captureResultManage];
    }
}

- (void)captureResultManage{
 //扫描结果处理
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"可能存在风险，是否打开此链接？" message:self.QRCodeInfo delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打开链接", nil];
        alertView.tag=101;
        [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        if (buttonIndex==0) {
            [self startTimer];
            [self.mySession startRunning];
        }
    }else if (alertView.tag==101){
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.QRCodeInfo]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.mySession startRunning];
                [self startTimer];
            });
            
        }else{
            [self.mySession startRunning];
            [self startTimer];
        }
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.mySession) {
        [self.mySession stopRunning];
        self.mySession = nil;
    }
}



@end
