# 一、RSA公私钥生成

1. 生成私钥

 `openssl genrsa -out private.pem 1024`

2. 从私钥中提取（生成）公钥

 `openssl rsa -in private.pem -pubout -out public.pem`
 
3. 查看公私钥信息,得到的内容为base64编码内容

 `cat ***.pem`
 
4. 以文本形式查看私钥

 `openssl rsa -in private.pem -text -out private.txt`

# 二、RSA终端演示

#### 2.1、公钥加密&私钥解密

1. 用公钥对文件`file.txt`加密

 `openssl rsautl -encrypt -in file.txt -inkey public.pem -pubin -out enc.txt`
 
2. 查看加密后的文件

 `cat enc.txt`
 
 ![1](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/1.png)
 
3. 用私钥解密

 `openssl rsautl -decrypt -in enc.txt -inkey private.pem -out dec.txt`
 
4. 查看解密后的文件

 `cat dec.txt`

 ![2](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/2.png)
 
#### 2.2、公钥签名&公钥解签
 
1. 用私钥对文件`file.txt`签名

 `openssl rsautl -sign -in file.txt -inkey private.pem -out enc.bin`
 
2. 查看签名后的文件

 `xxd enc.bin`
 
 ![3](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/3.png)
 
3. 用公钥解签文件

 `openssl rsautl -verify -in enc.bin -inkey public.pem -pubin -out dec2.txt`
 
4. 查看解签后的文件
 
 `cat dec2.txt`
 
 ![4](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/4.png)
 
# 三、iOS上准备RSA

iOS上一般不直接使用.pem格式的公私钥加解密

1. 通过私钥,向证书颁发结构申请请求证书

 `openssl req -new -key private.pem -out rsacert.csr`
 
 填写请求证书相关信息
 
 ![5](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/5.png)
 
2. 对证书进行签名，生成crt文件

 这里用自己的私钥签名，若通过认证机构签名，需要交纳一定费用
 
 `openssl x509 -req -days 3650 -in rsacert.csr -signkey private.pem -out rsacert.crt`

 认证机构签名过后的证书，可以用于放在服务器让用户接收认证，https是一个例子
 
3. 通过crt文件导出der文件

 `openssl x509 -outform der -in rsacert.crt -out rsacert.der`
 
 该文件主要包含RSA的公钥以及一些个人或组织信息
 
4. 通过der文件导出对应的p12文件
 
 `openssl pkcs12 -export -out p.p12 -inkey private.pem -in rsacert.crt`
 
 ![6](https://raw.githubusercontent.com/kinkenyuen/kinkenyuen.github.io/master/img/2019-02-25/6.png)

 p12文件实际上是与der文件内公钥对应的RSA**私钥**
 
---

在iOS上，可以用der文件做RSA加密，下面用der文件与p12文件在iOS上演示**客户端加密**、**服务端解密**

# 四、iOS使用RSA加密

以下使用封装好的RSA加密库展开
 
```
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
```

输出如下

```
2019-02-25 14:56:01.883482+0800 RSADemo[2928:120935] 加密后得到的base64String:XNOWwdX+WfmXD57V6XK5hQFqX2/u6F5lDfP1AWtzPC1tiePfpfDywAfwPPj+pD1hOm8+uRTdMWO0J2GjuD3405jgJXCABAmqHTxXCz+AnxGChQNSevoGTZnylu7ZmAzHPFtO879Yq1lWZS+F5b3ltcqRjRDdap0y8LJRR3U7oLc=
2019-02-25 14:56:01.884475+0800 RSADemo[2928:120935] 解密后的string:ken
2019-02-25 14:57:48.954304+0800 RSADemo[2928:120935] 加密后得到的base64String:ll7XlQYcb/N+9ZuUfyWF2QDJn+tfDdgtzksm8rqD1ejRzKU/1qRPwFw8HnGd3M4Y1izra6eg3fyFVJ/rvLlZhLHmUVQ5zJL6th1z871oNUMZECncRXIHZp/3SvgVaayS+wPAI8YnPigZHsuhVgmfRXW0IjZBBHlP1TXthrcRmfw=
2019-02-25 14:57:48.955285+0800 RSADemo[2928:120935] 解密后的string:ken
```

从两次加密结果看出，每次加密的结果是不一样的，这与**填充模式**相关，是可选的

---

RSA特点：效率低，适合加密小数据

运用：加密key、hash，数字签名