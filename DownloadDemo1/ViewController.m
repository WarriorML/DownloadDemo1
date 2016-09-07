//
//  ViewController.m
//  DownloadDemo1
//
//  Created by MengLong Wu on 16/9/7.
//  Copyright © 2016年 MengLong Wu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
//    下载图片的连接
    NSURLConnection         *_imageDownload;
    
    NSMutableData           *_imageData;
    
//    大文件下载连接
    NSURLConnection         *_bigFileDownload;
    
    NSMutableData           *_fileData;
    
//    文件处理器
    NSFileHandle            *_handle;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",NSHomeDirectory());
}

- (IBAction)syncDownload:(id)sender {
//    同步下载，会卡主线程
    NSString *urlStr = @"http://b.hiphotos.baidu.com/image/h%3D200/sign=041abf5659da81cb51e684cd6267d0a4/2f738bd4b31c870108ffe5442f7f9e2f0608ffc3.jpg";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    
    UIImage *image = [[UIImage alloc]initWithData:data];
    
    _imageView.image = image;
}

- (IBAction)asyncDownload1:(id)sender {
//    开辟分线程进行下载
    [NSThread detachNewThreadSelector:@selector(newThread) toTarget:self withObject:nil];
    
}
- (void)newThread
{
    NSString *urlStr = @"http://b.hiphotos.baidu.com/image/h%3D200/sign=041abf5659da81cb51e684cd6267d0a4/2f738bd4b31c870108ffe5442f7f9e2f0608ffc3.jpg";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *data = [[NSData alloc]initWithContentsOfURL:url];
    
    UIImage *image = [[UIImage alloc]initWithData:data];
    
//    分线程中不允许刷新UI,回到主线程刷新
    [self performSelectorOnMainThread:@selector(mainThread:) withObject:image waitUntilDone:YES];
}
- (void)mainThread:(UIImage *)image
{
//    在主线程中刷新UI
    _imageView.image = image;
}
- (IBAction)asyncDownload2:(id)sender
{
    NSString *urlStr = @"http://b.hiphotos.baidu.com/image/h%3D200/sign=041abf5659da81cb51e684cd6267d0a4/2f738bd4b31c870108ffe5442f7f9e2f0608ffc3.jpg";
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _imageDownload = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [_imageDownload start];
}

- (IBAction)bigFileDownload:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/DownloadAndUpload/123.zip"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _bigFileDownload = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [_bigFileDownload start];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == _imageDownload) {
//        如果是图片下载的链接就初始化data
        _imageData = [[NSMutableData alloc]init];
    }
    
//    使用data下载大文件，会造成内存占用太大
    if (connection == _bigFileDownload) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self getPath]]) {
//            保存的路径不存在时需要创建
            [[NSFileManager defaultManager] createFileAtPath:[self getPath] contents:nil attributes:nil];
        }
        
//        创建文件管理器，并指定写入文件的路径
        _handle = [NSFileHandle fileHandleForWritingAtPath:[self getPath]];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _imageDownload) {
        [_imageData appendData:data];
    }
    
    if (connection == _bigFileDownload) {
//        往路径里写入数据
        [_handle writeData:data];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _imageDownload) {
        _imageView.image = [[UIImage alloc]initWithData:_imageData];
    }
    
    if (connection == _bigFileDownload) {
//        关闭文件管理器
        [_handle closeFile];
    }
}


- (NSString *)getPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/123.zip"];
}






@end
