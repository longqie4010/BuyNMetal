//
//  ViewController.m
//  BuyNMetal
//
//  Created by 李红伟 on 19/7/2.
//  Copyright © 2019年 李红伟. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSDictionary *productInfoDictionary;
@property (nonatomic,strong) NSArray *productInfoArray;

@property (nonatomic,strong) NSDictionary *buyInfoDictionary;
@property (nonatomic,strong) NSArray *buyInfoArray;

@property (nonatomic,strong) NSArray *userListArray;


@property (nonatomic,assign) NSInteger manjianMoney;
@property (nonatomic,assign) CGFloat youhuiMoney;
@property (nonatomic,assign) CGFloat zhekouMoney;
@property (nonatomic,assign) NSInteger discountMoney;

@property (nonatomic,assign) CGFloat allTotalProductMoney;
@property (nonatomic,assign) CGFloat saleProductMoney;

@property(nonatomic,strong) NSArray *discountCardArray;
@property(nonatomic,strong) NSString *integral;
@property(nonatomic,strong) NSString *cardLevel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allTotalProductMoney = 0;
    [self getProductInfo];
    [self getBuyInfo];
    [self totalPrefentCount];
}

-(void)totalPrefentCount
{
    for (NSDictionary *buyDic in _buyInfoArray) {
        for (NSDictionary *productDic in _productInfoArray) {
            if ([[buyDic objectForKey:@"product"] isEqualToString:[productDic objectForKey:@"product"]]) {
                if ([[buyDic objectForKey:@"amount"] integerValue] !=0)
                {
                    NSInteger totalPrice = [[productDic objectForKey:@"price"] integerValue] * [[buyDic objectForKey:@"amount"] integerValue];
                    [self getFullDelagte:totalPrice info:productDic];
                    [self getYouhuiDelagte:[[buyDic objectForKey:@"amount"] integerValue] price:[[productDic objectForKey:@"price"] integerValue] info:productDic];
                    [self getZhekouDelagte:totalPrice discountCards:_discountCardArray info:productDic];
                    [self findMaxYouhui:totalPrice];
                }
            }
        }
    }
    NSLog(@"_allTotalProductMoney~~~~%.2f",_allTotalProductMoney);
    [self getUserIntegral];
}

-(void)getUserIntegral
{
    for (NSDictionary *userDic in _userListArray) {
        if ([[userDic objectForKey:@"cardLevel"] isEqualToString:_cardLevel]) {
            [self getUserLevel:_cardLevel];
        }
    }
}

-(void)getUserLevel:(NSString *)cardName
{
    NSInteger times = 1;
    if ([cardName isEqualToString:@"普卡"])
    {
        
    }
}

-(void)findMaxYouhui:(NSInteger)totalPrice
{
    NSNumber *san = [NSNumber numberWithFloat:_zhekouMoney];
    NSNumber *er = [NSNumber numberWithFloat:_youhuiMoney];
    NSNumber *yi = [NSNumber numberWithInteger:_manjianMoney];
    NSArray *array = @[san,er,yi];
    CGFloat lastDelate = [self findMax:array];
    NSString *last = [NSString stringWithFormat:@"%.2f",lastDelate];
    _saleProductMoney = totalPrice - [last floatValue];
    
    NSLog(@"_saleProductMoney~~~~%.2f",_saleProductMoney);
    _allTotalProductMoney = _allTotalProductMoney + _saleProductMoney;
}


-(void)getZhekouDelagte:(long)count discountCards:(NSArray *)cardArray info:(NSDictionary *)detailInfoDictionary
{
    if ([[detailInfoDictionary objectForKey:@"zhekouValue"] floatValue]==1) {
        _zhekouMoney = 0;
        return;
    }
    if (cardArray.count==0){
        _zhekouMoney = 0;
        return ;
    }
    for (NSString *cardString in cardArray) {
        if (([cardString isEqualToString:@"9折券"] &&[[detailInfoDictionary objectForKey:@"zhekouValue"] doubleValue]== 0.9) || ([cardString isEqualToString:@"95折券"] &&[[detailInfoDictionary objectForKey:@"zhekouValue"] doubleValue]== 0.95)) {
            _zhekouMoney = count *(1-[[detailInfoDictionary objectForKey:@"zhekouValue"] floatValue]);
        }
    }
}

-(void)getYouhuiDelagte:(long)count price:(NSInteger)price info:(NSDictionary *)detailInfoDictionary
{
    if (count<3) {
        _youhuiMoney = 0;
        return;
    }
    if (count >3) {
        if ([[detailInfoDictionary objectForKey:@"jianyiValue"] boolValue]==1) {
            _youhuiMoney = price;
            return;
        }
    }
    if ([[detailInfoDictionary objectForKey:@"banjiaValue"] boolValue]==1) {
        _youhuiMoney = price/2;
    }
}

-(void)getFullDelagte:(long)count info:(NSDictionary *)detailInfoDictionary
{
    
    [self configFullDelagte:count info:detailInfoDictionary delagteMoney:^(NSInteger delagteMoneyCount) {
        _manjianMoney =  delagteMoneyCount;
    }];
}

-(void)configFullDelagte:(NSInteger)count info:(NSDictionary *)detailInfoDictionary delagteMoney:(void (^)(NSInteger delagteMoneyCount))completedBlock
{
    NSNumber *san = [NSNumber numberWithInteger:[self threeThousandDelate:count info:detailInfoDictionary]];
    NSNumber *er = [NSNumber numberWithInteger:[self twoThousandDelate:count info:detailInfoDictionary]];
    NSNumber *yi = [NSNumber numberWithInteger:[self oneThousandDelate:count info:detailInfoDictionary]];
    NSArray *array = @[san,er,yi];
    CGFloat lastDelete = [self findMax:array];
    completedBlock(lastDelete);
    
}

-(NSInteger)threeThousandDelate:(NSInteger)count info:(NSDictionary *)detailInfoDictionary
{
    if ([[detailInfoDictionary objectForKey:@"threeThousandValue"] integerValue]==0) {
        return 0;
    }
    NSInteger times = count/[[detailInfoDictionary objectForKey:@"threeThousandValue"] integerValue];
    return times * [[detailInfoDictionary objectForKey:@"threeThousandValueDelate"] integerValue];
}

-(NSInteger)twoThousandDelate:(NSInteger)count info:(NSDictionary *)detailInfoDictionary
{
    if ([[detailInfoDictionary objectForKey:@"twoThousandValue"] integerValue]==0) {
        return 0;
    }
    NSInteger times = count/[[detailInfoDictionary objectForKey:@"twoThousandValue"] integerValue];
    return times * [[detailInfoDictionary objectForKey:@"twoThousandValueDelate"] integerValue];
}

-(NSInteger)oneThousandDelate:(NSInteger)count info:(NSDictionary *)detailInfoDictionary
{
    if ([[detailInfoDictionary objectForKey:@"oneThousandValue"] integerValue]==0) {
        return 0;
    }
    NSInteger times = count/[[detailInfoDictionary objectForKey:@"oneThousandValue"] integerValue];
    return times * [[detailInfoDictionary objectForKey:@"oneThousandValueDelate"] integerValue];
}

-(CGFloat)findMax:(NSArray *)array
{
    CGFloat max = [array[0] floatValue];
    if ([array[1] floatValue] >= max) {
        max = [array[1] floatValue];
    }
    if ([array[2] floatValue] >= max) {
        max = [array[2] floatValue];
    }
    return max;
}


-(void)getBuyInfo
{
    NSString * jsonPath = [[NSBundle mainBundle]pathForResource:@"buyInfo" ofType:@"json"];
    NSData * jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];
    _buyInfoDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    _buyInfoArray = [_buyInfoDictionary objectForKey:@"items"];
    if ([[_buyInfoDictionary objectForKey:@"discountCards"] count]>0) {
        _discountCardArray = [_buyInfoDictionary objectForKey:@"discountCards"];
    }
    _cardLevel = [_buyInfoDictionary objectForKey:@"cardLevel"];
    NSLog(@"_buyInfoDictionary~~%@",_buyInfoDictionary);

}

-(void)getProductInfo
{
    NSString * jsonPath = [[NSBundle mainBundle]pathForResource:@"product" ofType:@"json"];
    NSData * jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];
    _productInfoDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    _productInfoArray = [_productInfoDictionary objectForKey:@"items"];
    NSLog(@"_productInfoArray~~%@",_productInfoArray);

}

-(void)getUserList
{
    NSString * jsonPath = [[NSBundle mainBundle]pathForResource:@"userInfo" ofType:@"json"];
    NSData * jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    _userListArray = [jsonDictionary objectForKey:@"items"];
    NSLog(@"_userListArray~~%@",_userListArray);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
