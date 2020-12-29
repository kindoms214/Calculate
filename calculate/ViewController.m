//
//  ViewController.m
//  calculate
//
//  Created by bytedance on 2020/12/29.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
@interface ViewController ()
@property (nonatomic, strong) NSArray * panel;
@end

@implementation ViewController

-(NSArray *)panel{
    if(_panel == nil){
        NSString * path = [[NSBundle mainBundle] pathForResource:@"btnData" ofType:@"plist"];
        _panel = [NSArray arrayWithContentsOfFile:path];
    }
    return _panel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view = [UIView new];
    [self.view addSubview:view];
        
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view);
    }];
        
    
    NSMutableArray * labelArray = [NSMutableArray new];//图片数组
    for (int i = 0; i < 7; i++) {
        
        UIView *subview = [UIView new];
        [view addSubview:subview];
        [labelArray addObject:subview];
        
        if (i > 1) {
            NSMutableArray * btnArray = [NSMutableArray new];
            
            for (int j = 0; j < 4; j++) {
                NSDictionary *btnPanel = self.panel[(i - 2) * 4 + j];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                
                [subview addSubview:btn];
                [btnArray addObject:btn];
                
                btn.backgroundColor = [UIColor orangeColor];
                [btn setTitle:[NSString stringWithFormat:@"%d",j+90] forState:UIControlStateNormal];
                
                //设置tag字段
                btn.tag = [btnPanel[@"value"] intValue];
                
                //设置显示的信息
                [btn setTitle:btnPanel[@"title"] forState:UIControlStateNormal];
                [btn setTitle:btnPanel[@"title"] forState:UIControlStateHighlighted];
                
                //为按钮注册单击事件
                [btn addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [btnArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
            
            [btnArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.bottom.mas_equalTo(0);
            }];
        } else if (i == 0) {
            UILabel *expression = [UILabel new];
            [subview addSubview:expression];
            
            //设置字体和居右显示
            expression.font = [UIFont systemFontOfSize:48];
            expression.textAlignment = NSTextAlignmentRight;
            
            //长数据的处理
            expression.lineBreakMode = NSLineBreakByTruncatingHead;
            
            //设置tag
            expression.tag = 100;
            
            [expression mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.and.right.mas_equalTo(0);
                make.height.mas_equalTo(subview);
            }];
            
        } else if (i == 1) {
            UILabel * result = [UILabel new];
            [subview addSubview:result];
            
            //设置字体和居右显示
            result.font = [UIFont systemFontOfSize:32];
            result.textAlignment = NSTextAlignmentRight;
            
            //设置tag
            result.tag = 200;
            
            [result mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.left.and.right.mas_equalTo(0);
                make.height.mas_equalTo(subview);
            }];
        }
        
    }
    [labelArray mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    
    [labelArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
    }];
}

//为每个按键设置不同的tag值,用switch-case执行对应操作
-(void) optionButtonClick:(UIButton *)sender{
//    NSLog(@"被点击按钮的tag的数值：%ld", sender.tag);
    
    UILabel * expr = [self.view viewWithTag:100];
    UILabel * result = [self.view viewWithTag:200];
    
    NSMutableString * temp;
    if(expr.text == nil){
        
    } else {
        temp = [[NSMutableString alloc] initWithString:expr.text];
    }
    
    switch (sender.tag) {
        case 0: case 1: case 2: case 3: case 4: case 5: case 6:
        case 7: case 8: case 9:
            if(expr.text == nil) {
                expr.text = [NSString stringWithFormat:@"%ld", sender.tag];
            } else {
                [temp appendString:[NSString stringWithFormat:@"%ld", sender.tag]];
                expr.text = temp;
            }
            break;
        case 65535:             //AC清屏
            expr.text = [NSString stringWithFormat:@""];
            result.text = [NSString stringWithFormat:@""];
            return;
        case -1:                //DEL退格
            //判断是否有字符串
            if ([temp length]){
                expr.text = [temp substringToIndex:([temp length] - 1)];
            } else {
                expr.text = [NSString stringWithFormat:@""];
                result.text = [NSString stringWithFormat:@""];
                return;
            }
            break;
        case 11:                //"+"
            if(expr.text == nil) {
                expr.text = [NSString stringWithFormat:@"%ld", sender.tag];
            } else {
                [temp appendString:[NSString stringWithFormat:@"%s", "+"]];
                expr.text = temp;
            }
            break;
        case 12:                //"-"
            if(expr.text == nil) {
                expr.text = [NSString stringWithFormat:@"%ld", sender.tag];
            } else {
                [temp appendString:[NSString stringWithFormat:@"%s", "-"]];
                expr.text = temp;
            }
            break;
        case 13:                //"*"
            if(expr.text == nil) {
                expr.text = [NSString stringWithFormat:@"%ld", sender.tag];
            } else {
                [temp appendString:[NSString stringWithFormat:@"%s", "*"]];
                expr.text = temp;
            }
            break;
        case 14:                //"/"
            if(expr.text == nil) {
                expr.text = [NSString stringWithFormat:@"%ld", sender.tag];
            } else {
                [temp appendString:[NSString stringWithFormat:@"%s", "/"]];
                expr.text = temp;
            }
            break;
        default:                //“=”（和没实现的“.”、"%"）
            break;
    }
    
    //最后一位为数字的时候，调用计算函数
    NSString * last = [expr.text substringWithRange:NSMakeRange([expr.text length] - 1, 1)];
    if([last isEqualToString:@"0"] ||
       [last isEqualToString:@"1"] ||
       [last isEqualToString:@"2"] ||
       [last isEqualToString:@"3"] ||
       [last isEqualToString:@"4"] ||
       [last isEqualToString:@"5"] ||
       [last isEqualToString:@"6"] ||
       [last isEqualToString:@"7"] ||
       [last isEqualToString:@"8"] ||
       [last isEqualToString:@"9"] ){
        [self CAComplexExpression];
    }
}

-(void) CAComplexExpression{
    
    UILabel * expr = [self.view viewWithTag:100];
    UILabel * result = [self.view viewWithTag:200];
    
    int exprLen = (int)[expr.text length];
    if (exprLen == 0){
        return ;
    }
    
    NSMutableArray * op = [[NSMutableArray alloc] init];
    NSMutableArray * num = [[NSMutableArray alloc] init];

    int startIndex = 0, endIndex = 0;
    
    //根据运算符进行判断，将运算符之前的 数 和 运算符 分别加入num和op中
    for (int i = 0; i < exprLen; i++) {
        NSString * singleJudge = [expr.text substringWithRange:NSMakeRange(i, 1)];
        if ([singleJudge isEqualToString:@"+"] ||
            [singleJudge isEqualToString:@"-"] ||
            [singleJudge isEqualToString:@"*"] ||
            [singleJudge isEqualToString:@"/"] ||
            [singleJudge isEqualToString:@"%"]){
            
            [num addObject:[expr.text substringWithRange:NSMakeRange(startIndex, i - startIndex)]];
            [op addObject:singleJudge];
            
            startIndex = i + 1;
            endIndex = i;
        }
    }
    
    //没有出现运算符，则startIndex == 0
    if (startIndex == 0) {
        [num addObject:expr.text];
        result.text = [NSString stringWithFormat:@"%@", expr.text];
        return ;
    }
    
    //最后一个运算符后面还有数字和没有数字的处理
    if (endIndex != exprLen - 1){
        [num addObject: [expr.text substringFromIndex:endIndex+1]];
    } else {
        return ;
    }
    
    int opCount = (int)op.count;
    int flag = 1;
    
    //先遍历一遍op，把乘除运算先计算完
    while(flag){
        int tag = 0;
        for (int i = 0; i < opCount; i++) {
            if ([op[i] isEqualToString:@"*"]) {
                num[i] = [NSString stringWithFormat:@"%.2f", [num[i] floatValue] * [num[i+1] floatValue]];
                tag = 1;
            } else if ([op[i] isEqualToString:@"/"]) {
                num[i] = [NSString stringWithFormat:@"%.2f", [num[i] floatValue] / [num[i+1] floatValue]];
                tag = 1;
            }
   
            if (tag) {
                [num removeObjectAtIndex: i + 1];
                [op removeObjectAtIndex: i];
                opCount--;
                
                //没有操作符，while中止
                flag = (opCount == 0) ? 0 : 1;
                break;
            }
            
            //访问到最后一个运算符，没有乘号、除号，while中止
            flag = (i == opCount - 1) ? 0 : 1;
        }
    }

    //再遍历一遍op，把加减运算计算完
    //计算过程中的中间结果
    float midAns = [num[0] floatValue];
    for (int i = 0; i < opCount; i++) {
        if ([op[i] isEqualToString:@"+"]) {
            midAns += [num[i+1] floatValue];
        } else if ([op[i] isEqualToString:@"-"]) {
            if (i + 1 < opCount && [op[i+1] isEqualToString:@"+"] && ([num[i+1] intValue] == 0)) {
                op[i+1] = [NSString stringWithFormat:@"-"];
            } else {
                midAns -= [num[i+1] floatValue];
            }
        }
    }
    
    //去除多余的0以及小数点
    NSString * resultWithZeros = [NSString stringWithFormat:@"%f", midAns];
    int resLen = (int)[resultWithZeros length];
    for (int i = resLen - 1; i >= 0; i--) {
        result.text = [NSString stringWithString:resultWithZeros];
        if ([[resultWithZeros substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"0"]){
            result.text = [NSString stringWithFormat:@"%@", [resultWithZeros substringWithRange:NSMakeRange(0, i)]];
        } else if ([[resultWithZeros substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"."]){
            result.text = [NSString stringWithFormat:@"%@", [resultWithZeros substringWithRange:NSMakeRange(0, i)]];
            break;
        } else {
            break;
        }
    }
}

@end
