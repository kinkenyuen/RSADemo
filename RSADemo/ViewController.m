//
//  ViewController.m
//  RSADemo
//
//  Created by Kinken_Yuen on 2019/2/25.
//  Copyright © 2019年 kinkenyuen. All rights reserved.
//

#import "ViewController.h"
#import "Cipher-RSA/RSACryptor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.加载公钥
    [[RSACryptor sharedRSACryptor] loadPublicKey:[[NSBundle mainBundle] pathForResource:@"rsacert.der" ofType:nil]];
    
    //2.加载私钥
    [[RSACryptor sharedRSACryptor] loadPrivateKey:[[NSBundle mainBundle] pathForResource:@"p.p12" ofType:nil] password:@"123456"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //加密
    NSData *encryptedData = [[RSACryptor sharedRSACryptor] encryptData:[@"ken" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *base64String = [encryptedData base64EncodedStringWithOptions:0];
    NSLog(@"加密后得到的base64String:%@",base64String);
    
    //解密(一般在服务器端操作)
    NSData *decryptData = [[RSACryptor sharedRSACryptor] decryptData:encryptedData];
    NSLog(@"解密后的string:%@",[[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding]);
}

@end
