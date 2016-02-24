//
//  ViewController.m
//  CameraInHtml
//
//  Created by alan on 15-9-18.
//  Copyright (c) 2015年 n22. All rights reserved.
//

#import "ViewController.h"
#import "GTMBase64.h"

#define TAKEPHOTOTAG @"takePhotoTag"

#define HTMLNAME @"takePhoto"

#define HTML @"html"

@interface ViewController ()<WebViewJavascriptBridgeDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) WebViewJavascriptBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bridge = [WebViewJavascriptBridge javascriptBridgeWithDelegate:self];
    NSError *error = nil;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有摄像头
    if(![UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    _imagePicker.sourceType = sourceType;
    _imagePicker.allowsEditing = YES;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:HTMLNAME ofType:HTML];
    NSString *htmlPath = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    [self.webView loadHTMLString:htmlPath baseURL:nil];
    self.webView.delegate = self.bridge;
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_webView];
    }
    return _webView;
}

#pragma mark -- WebViewJavascriptBridgeDelegate
- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)webView {
    if ([message isEqualToString:TAKEPHOTOTAG]) {
           [self presentViewController:_imagePicker animated:YES completion:nil];
    }
}

#pragma mark -- UIImagePickerControllerDelegate
//完成拍照
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeImg(\"%@\")",[GTMBase64 stringByEncodingData:UIImagePNGRepresentation(image)]]];
}
//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
