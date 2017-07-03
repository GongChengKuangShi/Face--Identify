//
//  ViewController.m
//  FaceIdentify
//
//  Created by xiangronghua on 2017/7/3.
//  Copyright © 2017年 xiangronghua. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#define KWS(weakSelf) __weak __typeof(&*self) weakSelf=self

@interface ViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //带人脸的照片
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.imageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(id)sender {
    [self choosePhoto];
}

- (void)choosePhoto {
    [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowPickingVideo     = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.photoWidth = 1800;
    [self presentViewController:imagePickerVc animated:self completion:nil];
}

- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // DLog(@"cancel");
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    KWS(ws);
    for (PHAsset *results in assets) {
        [[TZImageManager manager]getOriginalPhotoDataWithAsset:results completion:^(NSData *data, NSDictionary *info,BOOL isDegraded) {
            UIImage*image = [UIImage imageWithData:data];
            
            CGFloat imageHeight = image.size.height/image.size.width * ws.view.frame.size.width;
            ws.imageView.image = [ws reSizeImage:image toSize:CGSizeMake(ws.view.frame.size.width, imageHeight)];
            ws.imageView.frame = CGRectMake(0, 0, ws.view.frame.size.width, imageHeight);
            
            [ws imageInfo:ws.imageView.image];
        }];
        
    }
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

- (void)imageInfo:(UIImage *)image {
    
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    //转成CIImage
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    //拿到所有的脸
    NSArray <CIFeature *> *featureArray = [faceDetector featuresInImage:ciImage];
    if (featureArray.count == 0) {
        NSLog(@"未检测到人脸");
        //初始化提示框;
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"提示" message:@"未检测到人脸" preferredStyle: UIAlertControllerStyleAlert];
        [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            //点击按钮的响应事件;
        }]];
        //弹出提示框;
        [self presentViewController:alert1 animated:true completion:nil];
    }else{
        //遍历
        for (CIFeature *feature in featureArray) {
#warning feature的Y坐标从底部开始算的
            
            CGFloat breageViewOrighY =self.imageView.frame.size.height - feature.bounds.origin.y-feature.bounds.size.height;
            
            UIView *breageView = [[UIView alloc] initWithFrame:CGRectMake(feature.bounds.origin.x, breageViewOrighY, feature.bounds.size.width, feature.bounds.size.height)];
            
            breageView.layer.borderColor = [UIColor redColor].CGColor;
            breageView.layer.borderWidth = 2;
            [self.imageView addSubview:breageView];
        }
    }
}

@end
