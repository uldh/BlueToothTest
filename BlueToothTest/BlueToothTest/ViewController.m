//
//  ViewController.m
//  BlueToothTest
//
//  Created by Ant on 2019/12/16.
//  Copyright © 2019 Ant. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *cMgr;
@property (nonatomic, strong) CBPeripheral *peripheral;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}
- (IBAction)clickedButtonWrite:(id)sender{
    [self cMgr];
//    [self.peripheral writeValue:_batteryData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    //第一个参数是已连接的蓝牙设备 ；第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入
}
-(CBCentralManager *)cMgr
{
    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _cMgr;
}
#pragma mark - delegate
//只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case 0:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case 1:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case 2:
            NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            break;
        case 3:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case 4:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
        }
            break;
        case 5:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            // 在中心管理者成功开启后再进行一些操作
            // 搜索外设
            [self.cMgr scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
                                              options:nil]; // dict,条件
            // 搜索成功之后,会调用我们找到外设的代理方法
            // - (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI; //找到外设
        }
            break;
        default:
            break;
    }
}
// 发现外设后调用的方法
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didDiscoverPeripheral:(CBPeripheral *)peripheral // 外设
     advertisementData:(NSDictionary *)advertisementData // 外设携带的数据
                  RSSI:(NSNumber *)RSSI // 外设发出的蓝牙信号强度
{
    //NSLog(@"%s, line = %d, cetral = %@,peripheral = %@, advertisementData = %@, RSSI = %@", __FUNCTION__, __LINE__, central, peripheral, advertisementData, RSSI);
    
    /*
     peripheral = <CBPeripheral: 0x166668f0 identifier = C69010E7-EB75-E078-FFB4-421B4B951341, Name = "OBand-75", state = disconnected>, advertisementData = {
     kCBAdvDataChannel = 38;
     kCBAdvDataIsConnectable = 1;
     kCBAdvDataLocalName = OBand;
     kCBAdvDataManufacturerData = <4c69616e 0e060678 a5043853 75>;
     kCBAdvDataServiceUUIDs =     (
     FEE7
     );
     kCBAdvDataTxPowerLevel = 0;
     }, RSSI = -55
     根据打印结果,我们可以得到运动手环它的名字叫 OBand-75
     
     */
    
    // 需要对连接到的外设进行过滤
    // 1.信号强度(40以上才连接, 80以上连接)
    // 2.通过设备名(设备字符串前缀是 OBand)
    // 在此时我们的过滤规则是:有OBand前缀并且信号强度大于35
    // 通过打印,我们知道RSSI一般是带-的
    NSLog(@"peripheral.name====%@,advertisementData====%@,RSSI===%@",peripheral.name,advertisementData,RSSI);
    if ([peripheral.name hasPrefix:@"Flower care"]) {
        // 在此处对我们的 advertisementData(外设携带的广播数据) 进行一些处理
        
        // 通常通过过滤,我们会得到一些外设,然后将外设储存到我们的可变数组中,
        // 这里由于附近只有1个运动手环, 所以我们先按1个外设进行处理
        
        // 标记我们的外设,让他的生命周期 = vc
        self.peripheral = peripheral;
        // 发现完之后就是进行连接
        [self.cMgr connectPeripheral:self.peripheral options:nil];
        NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
        
    }
    if ([peripheral.name hasPrefix:@"OBand"]) {
        // 在此处对我们的 advertisementData(外设携带的广播数据) 进行一些处理
        
        // 通常通过过滤,我们会得到一些外设,然后将外设储存到我们的可变数组中,
        // 这里由于附近只有1个运动手环, 所以我们先按1个外设进行处理
        
        // 标记我们的外设,让他的生命周期 = vc
        self.peripheral = peripheral;
        // 发现完之后就是进行连接
        [self.cMgr connectPeripheral:self.peripheral options:nil];
        NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    }
}

#pragma mark - 链接外围设备
// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
  didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    NSLog(@"%s, line = %d, %@=连接成功", __FUNCTION__, __LINE__, peripheral.name);
    // 连接成功之后,可以进行服务和特征的发现
    
    //  设置外设的代理
    self.peripheral.delegate = self;
    
    // 外设发现服务,传nil代表不过滤
    // 这里会触发外设的代理方法 - (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    CBUUID * uuid = [CBUUID UUIDWithString:@"FE95"];
    [self.peripheral discoverServices:@[uuid]];
}
// 外设连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
}

// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
}
//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"%s, line = %d, %@=发现服务", __FUNCTION__, __LINE__, peripheral.name);
    NSLog(@"didDiscoverServices");
    
    if (error){
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
//        if ([self.delegate respondsToSelector:@selector(DidNotifyFailConnectService:withPeripheral:error:)])
//            [self.delegate DidNotifyFailConnectService:nil withPeripheral:nil error:nil];
        return;
    }
    for (CBService *service in peripheral.services){
        //发现服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FE95"]]){
            NSLog(@"Service found with UUID: %@", service.UUID);//查找特征
            [self.peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}
// 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
//
    for (CBCharacteristic *cha in service.characteristics) {
        NSLog(@"%s, line = %d, char = %@", __FUNCTION__, __LINE__, cha);
    }
    if (error){
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
//        [self error];
        return;
    }
    NSLog(@"服务：%@",service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics){
        //发现特征
        char *str = "123456789";
        NSData *data = [NSData dataWithBytes:str length:strlen(str)];

        [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FE95"]]) {
            NSLog(@"监听：%@",characteristic);//监听特征
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSData *d2 = [NSData new];
            [self.peripheral writeValue:d2 forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
}
// 更新特征的value的时候会调用 （凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
//    if (characteristic == @"你要的特征的UUID或者是你已经找到的特征") {
//        //characteristic.value就是你要的数据
//    }
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
//        self.error_b = BluetoothError_System;
//        [self error];
        return;
    }
    
    //    NSLog(@"收到的数据：%@",characteristic.value);
//    [self decodeData:characteristic.value];
}

// 需要注意的是特征的属性是否支持写数据
- (void)yf_peripheral:(CBPeripheral *)peripheral didWriteData:(NSData *)data forCharacteristic:(nonnull CBCharacteristic *)characteristic
{
    /*
     typedef NS_OPTIONS(NSUInteger, CBCharacteristicProperties) {
     CBCharacteristicPropertyBroadcast                                              = 0x01,
     CBCharacteristicPropertyRead                                                   = 0x02,
     CBCharacteristicPropertyWriteWithoutResponse                                   = 0x04,
     CBCharacteristicPropertyWrite                                                  = 0x08,
     CBCharacteristicPropertyNotify                                                 = 0x10,
     CBCharacteristicPropertyIndicate                                               = 0x20,
     CBCharacteristicPropertyAuthenticatedSignedWrites                              = 0x40,
     CBCharacteristicPropertyExtendedProperties                                     = 0x80,
     CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)        = 0x100,
     CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(NA, 6_0)  = 0x200
     };
     
     打印出特征的权限(characteristic.properties),可以看到有很多种,这是一个NS_OPTIONS的枚举,可以是多个值
     常见的又read,write,noitfy,indicate.知道这几个基本够用了,前俩是读写权限,后俩都是通知,俩不同的通知方式
     */
        NSLog(@"%s, line = %d, char.pro = %d", __FUNCTION__, __LINE__, characteristic.properties);
    // 此时由于枚举属性是NS_OPTIONS,所以一个枚举可能对应多个类型,所以判断不能用 = ,而应该用包含&
}
@end
