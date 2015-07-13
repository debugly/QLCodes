//
//  ViewController.m
//  QLStudyDemo
//
//  Created by xuqianlong on 14/11/8.
//  Copyright (c) 2014年 前沿科技. All rights reserved.
//

#import "ViewController.h"
#import "EZCarouseImageView.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight  [UIScreen mainScreen].bounds.size.height
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*
     
    NSLog( @"屏幕尺寸：%g x %g",KScreenWidth,KScreenHeight);//375,667
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat Height = 20;
    UITextView *tx = [[UITextView alloc]initWithFrame:CGRectZero];
    tx.editable = NO;
    tx.contentInset = UIEdgeInsetsZero;
   
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor redColor],
                                 NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
                                 NSTextEffectAttributeName:NSTextEffectLetterpressStyle};
    NSString *indicatorStr = @"ios 7 TextKit：\n   凸版印刷体效果（Letterpress effects）  给文字加上了奇妙阴影和高光，让文字看起来有凹凸感，像被压在屏幕上的：\n";
    NSString *codeStr = @"NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],NSTextEffectAttributeName:NSTextEffectLetterpressStyle};";
    NSString *str = [NSString stringWithFormat:@"%@%@",indicatorStr,codeStr];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:str attributes:attributes];

    [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:[str rangeOfString:codeStr]];
    NSRange range = [str rangeOfString:@"NSTextEffectAttributeName:NSTextEffectLetterpressStyle"];
    [attributeString addAttributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),NSUnderlineColorAttributeName:[UIColor blackColor]} range:range];
    
    NSString *str2 = @"\n路径排除：（Exclusion Paths）\n图文混排是非常常见的需求，但有时候我们的图片并一定都是正常的矩形，这个时候我们如果需要将文本环绕在图片周围，就可以用路径排除（exclusion paths）了。）";
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wujiaoxing"]];
    imgView.frame = CGRectMake(120, 160, 40, 40);
    ;
    CGRect rect = [tx convertRect:imgView.bounds fromView:imgView];
//    rect.origin.x -= label.textContainerInset.left;
//    rect.origin.y -= label.textContainerInset.top;
    
    UIBezierPath *floatingPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    tx.textContainer.exclusionPaths = @[floatingPath];
    [tx addSubview:imgView];
    NSAttributedString *attributeString2 = [[NSAttributedString alloc]initWithString:str2 attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    [attributeString appendAttributedString:attributeString2];
    tx.attributedText = attributeString;
    
    CGSize txSize = [tx sizeThatFits:CGSizeMake(KScreenWidth, 2000)];
    tx.frame = CGRectMake(0,Height, txSize.width, txSize.height);
    [self.view addSubview:tx];
    
    Height += txSize.height;
    
     
    /************************Label sizeToFit**************************************/
    
    /*
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = @"测试Label的sizeToFit\n换行了，哈哈O(∩_∩)O~~";
    label.backgroundColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 2;
    [label sizeToFit];
    CGSize labelSize = label.frame.size;
    label.frame = CGRectMake((KScreenWidth-labelSize.width)/2, Height, labelSize.width, labelSize.height);
    [self.view addSubview:label];
    
    Height += labelSize.height;
    
    /************************UITextView sizeToFit**************************************/
    
    /*
    UITextView *tx2 = [[UITextView alloc]initWithFrame:CGRectZero];
    tx2.text = @"1、经过半年多的iphone开发，我发现在开发过程中最难的就是一些嘈杂的细节，而了解一些小技巧就会达到事半功倍的效果，下面我就总结一下在iphone开发中的一些小技巧。\n"
    @"2、如果在程序中想对某张图片进行处理的话（得到某张图片的一部分）可一用以下代码：\n"
    @"3、如果在程序中想对某张图片进行处理的话（得到某张图片的一部分）可一用以下代码：";
    tx2.font = [UIFont systemFontOfSize:14];
    CGSize tx2Size = [tx2 sizeThatFits:CGSizeMake(KScreenWidth-10, 2000)];
    tx2.frame = CGRectMake(5, Height, tx2Size.width, tx2Size.height);
    tx2.editable = NO;
    [self.view addSubview:tx2];
    
    Height += tx2Size.height;

    UILabel *linkLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    linkLabel.attributedText = [[NSAttributedString alloc]initWithString:@"官方链接：Text Programming Guide for iOS " attributes:@{NSLinkAttributeName:[NSURL URLWithString: @"https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/Introduction/Introduction.html"]}];
    linkLabel.font = [UIFont systemFontOfSize:14];
    [linkLabel sizeToFit];
//    http://www.raywenderlich.com/50151/text-kit-tutorial
    CGSize linkLabelSize = linkLabel.frame.size;
    linkLabel.frame = CGRectMake(0, Height, linkLabelSize.width, linkLabelSize.height);
    [self.view addSubview:linkLabel];
    
    
    /***************************************分组数据****************************************/
   
    /*
     
    NSString *path = [[NSBundle mainBundle]pathForResource:@"JSON" ofType:@"txt"];
    NSData *JSONData = [NSData dataWithContentsOfFile:path];
//    NSLog(@"------%@",JSONData);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"----dic : %@",dic);
    NSArray *whispersArr = [[dic objectForKey:@"body"]objectForKey:@"whispers"];
//    NSLog(@"----arr :%@",arr);
    
    NSArray *uidArr = [whispersArr valueForKeyPath:@"@distinctUnionOfObjects.uid"];
//    NSLog(@"----arr :%@",uidArr);
    
    NSMutableDictionary *groupDic = [[NSMutableDictionary alloc]initWithCapacity:3];
    NSMutableArray *whisperGroupArr = [[NSMutableArray alloc]initWithCapacity:3];
    
    for (NSString *uid in uidArr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %@",uid];
        NSArray *arr = [whispersArr filteredArrayUsingPredicate:predicate];
//        NSLog(@"----uid :%@",uid);
//        NSLog(@"----arr :%@",arr);
        if (uid.length == 0) {
            [whisperGroupArr addObjectsFromArray:arr];
        }else{
            [groupDic setObject:[NSMutableArray arrayWithArray:arr] forKey:uid];
        }
    }
    
    NSLog(@"-----%@",groupDic);
    
    for (NSDictionary *dic in whisperGroupArr) {
        NSString *whisperId = [dic objectForKey:@"whisperId"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@",whisperId];
        NSArray *arr = [whispersArr filteredArrayUsingPredicate:predicate];
        if ([arr count]>0) {
            NSArray *uidArr = [arr valueForKeyPath:@"@distinctUnionOfObjects.uid"];
            NSString *uid = [uidArr firstObject];
            if (uid && uid.length > 0) {
                NSMutableArray *arr = [groupDic objectForKey:uid];
                if ([arr isKindOfClass:[NSMutableArray class]]) {
                    [arr addObject:dic];
                }
            }
        }
    }
    
    NSLog(@"-----%@",groupDic);
    
    */
    
    EZCarouseImageView *carouseImageView = [[EZCarouseImageView alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, 200)];
    
    [self.view addSubview:carouseImageView];
    
    [carouseImageView resetEasyURLArr:@[@"http://h.hiphotos.baidu.com/baike/w%3D268/sign=cc1fa1384d4a20a4311e3bc1a8529847/342ac65c1038534374fb7e0b9113b07ecb8065380cd790d8.jpg",
                                        @"http://img3.3lian.com/2013/c4/14/d/4.jpg",
                                        @"http://file.fwjia.com:88/d/file/2013-08-05/2412fbe21dc666a2e33ccd15158e9fbc.jpg",
                                        @"http://www.jianbihua.cc/uploads/allimg/140216/2-1402161R046112.jpg"]];
    
    carouseImageView.backgroundColor = [UIColor whiteColor];

}

@end
