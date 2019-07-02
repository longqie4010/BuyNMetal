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
@property (nonatomic,assign) CGFloat oldAllTotalProductMoney;
@property (nonatomic,assign) CGFloat saleProductMoney;

@property(nonatomic,strong) NSArray *discountCardArray;
@property(nonatomic,strong) NSString *cardNumber;
@property(nonatomic,strong) NSDictionary *userDetailInfo;
@property (nonatomic,strong) NSMutableArray *delegateInfoMarray;
@property (nonatomic,strong) NSMutableArray *delegateMoneyMarray;
@property(nonatomic,strong) NSString *oldLevel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allTotalProductMoney = 0;
    _oldAllTotalProductMoney = 0;
    _delegateInfoMarray = [[NSMutableArray alloc]init];
    _delegateMoneyMarray = [[NSMutableArray alloc]init];
    [self getUserList];
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
                    [self findMaxYouhui:totalPrice buyInfo:buyDic];
                }
            }
        }
    }
//    NSLog(@"_allTotalProductMoney~~~~%.2f",_allTotalProductMoney);
    [self getUserIntegral];
}

-(void)getUserIntegral
{
    BOOL yesOrNo = NO;
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:[NSString stringWithFormat:@"%@",_cardNumber]];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:_cardNumber] == nil || [[[NSUserDefaults standardUserDefaults] objectForKey:_cardNumber] isEqualToString:@""]) {
        yesOrNo = YES;
    }
    for (NSDictionary *userDic in _userListArray) {
        if (!yesOrNo) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"cardNumber"] isEqualToString:[userDic objectForKey:@"cardNumber"]]) {
                _userDetailInfo = userDic;
                _oldLevel = [_userDetailInfo objectForKey:@"cardLevel"];
                [self getUserLevel:[[[NSUserDefaults standardUserDefaults] objectForKey:@"totalIntegral"] integerValue]];
            }
        }else
        {
            if ([[userDic objectForKey:@"cardNumber"] isEqualToString:_cardNumber]) {
                _userDetailInfo = userDic;
                _oldLevel = [_userDetailInfo objectForKey:@"cardLevel"];
                [self getUserLevel:[[userDic objectForKey:@"jinfen"] integerValue]];
                break;
            }
        }
    }
}

-(void)getUserLevel:(NSInteger)integral
{
    NSInteger times = 1;
    if (integral <=50000 && integral >10000){
        times = 1.5;
    }else if(integral <= 100000 && integral >50000){
        times = 1.8;
    }else if(integral >100000){
        times = 2;
    }
    NSInteger totalIntegral =  integral + _allTotalProductMoney * times;
    [[NSUserDefaults standardUserDefaults] setValue:[_userDetailInfo objectForKey:@"cardNumber"] forKey:[NSString stringWithFormat:@"%@",[_userDetailInfo objectForKey:@"cardNumber"]]];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",totalIntegral] forKey:@"totalIntegral"];
//    NSLog(@"totalIntegral~~~~~%ld~%ld\n",(long)times,[[[NSUserDefaults standardUserDefaults] objectForKey:@"totalIntegral"] integerValue]);
    NSLog(@"%@\n",@"方鼎银行贵金属购买凭证");
    NSLog(@"销售单号：%@   日期：%@\n",[_buyInfoDictionary objectForKey:@"orderId"],[_buyInfoDictionary objectForKey:@"createTime"]);
    NSLog(@"客户卡号：%@   姓名：%@    客户等级：%@    积分：%@\n",[_userDetailInfo objectForKey:@"cardNumber"],[_userDetailInfo objectForKey:@"name"],[_userDetailInfo objectForKey:@"cardLevel"],[[NSUserDefaults standardUserDefaults] objectForKey:@"totalIntegral"]);
    NSLog(@"%@    %@    %@",@"商品及数量",@"单价",@"金额\n");
    for (NSDictionary *proInfo  in _buyInfoArray) {
        NSLog(@"(%@)%@%ld,%ld,%ld",[proInfo objectForKey:@"product"],[proInfo objectForKey:@"productName"],[[proInfo objectForKey:@"amount"] integerValue],[[proInfo objectForKey:@"price"] integerValue],[[proInfo objectForKey:@"amount"] integerValue]*[[proInfo objectForKey:@"product"] integerValue]);
    }
    NSLog(@"合计%.2f\n",_oldAllTotalProductMoney);
    NSLog(@"优惠清单\n");
    for (int i= 0; i<_delegateInfoMarray.count; i++) {
        NSLog(@"%@%@:%@",[_delegateInfoMarray[i] objectForKey:@"product"],[_delegateInfoMarray[i] objectForKey:@"productName"],[NSString stringWithFormat:@"%@",_delegateMoneyMarray[i]]);
    }
    NSLog(@"优惠合计:%.2f\n",_oldAllTotalProductMoney - _allTotalProductMoney);
    NSLog(@"应收合计:%.2f\n",_allTotalProductMoney);
    for (NSString *string in _discountCardArray) {
        NSLog(@"优惠券%@",string);
    }
    NSInteger integralk = [[[NSUserDefaults standardUserDefaults] objectForKey:@"totalIntegral"] integerValue];
    NSString *newLevel = @"";
    if(integralk <10000)
    {
        newLevel = @"普卡";
        NSLog(@"%@",@"普卡");
    }else if (integralk <=50000 && integralk >10000){
        newLevel = @"金卡";
        NSLog(@"%@",@"金卡");
    }else if(integralk <= 100000 && integralk >50000){
        newLevel = @"白金卡";
        NSLog(@"%@",@"白金卡");
    }else if(integralk >100000){
        newLevel = @"钻石卡";
        NSLog(@"%@",@"钻石卡");
    }
    if ([_oldLevel isEqualToString:newLevel]) {
        NSLog(@"恭喜您升级为%@客户",newLevel);
    
    }

}

-(void)findMaxYouhui:(NSInteger)totalPrice buyInfo:(NSDictionary *)buyInfo
{
    NSNumber *san = [NSNumber numberWithFloat:_zhekouMoney];
    NSNumber *er = [NSNumber numberWithFloat:_youhuiMoney];
    NSNumber *yi = [NSNumber numberWithInteger:_manjianMoney];
    NSArray *array = @[san,er,yi];
    CGFloat lastDelate = [self findMax:array];
    NSString *last = [NSString stringWithFormat:@"%.2f",lastDelate];
    _saleProductMoney = totalPrice - [last floatValue];
    [_delegateInfoMarray addObject:buyInfo];
    [_delegateMoneyMarray addObject:last];
    _oldAllTotalProductMoney = _oldAllTotalProductMoney + totalPrice;
//    NSLog(@"_saleProductMoney~~~~%.2f",_saleProductMoney);
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
    _cardNumber = [_buyInfoDictionary objectForKey:@"cardNumber"];
//    NSLog(@"_buyInfoDictionary~~%@",_buyInfoDictionary);

}

-(void)getProductInfo
{
    NSString * jsonPath = [[NSBundle mainBundle]pathForResource:@"product" ofType:@"json"];
    NSData * jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];
    _productInfoDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    _productInfoArray = [_productInfoDictionary objectForKey:@"items"];
//    NSLog(@"_productInfoArray~~%@",_productInfoArray);

}

-(void)getUserList
{
    NSString * jsonPath = [[NSBundle mainBundle]pathForResource:@"userInfo" ofType:@"json"];
    NSData * jsonData = [[NSData alloc]initWithContentsOfFile:jsonPath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    _userListArray = [jsonDictionary objectForKey:@"items"];
//    NSLog(@"_userListArray~~%@",_userListArray);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
