//
//  PPrintSenderObjc.m
//  PkontoolObjc
//
//  Created by Eskil Sviggum on 06/10/2020.
//

#import <Foundation/Foundation.h>
#import "PPrintSenderObjc.h"

/*typedef NS_ENUM(NSUInteger, KonsollKomando) {
    KonsollKomandoTøm,
    KonsollKomandoSkrollingPå,
    KonsollKomandoSkrollingAv,
    KonsollKomandoForfriskTema
};*/

@implementation Kommando

NSString *kommando;

- (instancetype)init:(int)cmd
{
    self = [super init];
    if (self) {
        NSArray * cmds = @[@"tøm", @"skrollingPå", @"skrollingAv", @"forfriskTema"];
        kommando = cmds[cmd];
    }
    return self;
}

- (NSData *)enkodMelding {
    return [[NSString stringWithFormat:@"\"%@\"", kommando] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
}

@end

@implementation Melding

NSString *melding;
double timestamp;
int ident;

- (instancetype)init:(NSString*)mld
{
    self = [super init];
    if (self) {
        melding = mld;
        timestamp = [[NSDate alloc] init].timeIntervalSince1970;
        ident = arc4random_uniform(10);
    }
    return self;
}

- (NSData *)enkodMelding {
    NSString* msg = [NSString stringWithFormat:@"{\"melding\":\"%@\",\"timestamp\":%f,\"id\":%d}", melding, timestamp, ident];
    return [msg dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
}

@end

@implementation PPAvsendar

NSURL *hostUrl;
int sendteMeldingar = 0;
NSMutableArray* sendeStack;
BOOL drivMedSending = NO;

- (instancetype)init:(NSURL*)url
{
    self = [super init];
    if (self) {
        hostUrl = url;
        sendeStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) sendMelding:(NSString*)melding comp:(void(^)(void))comp {
    
    Melding * data = [[Melding alloc] init:melding];
    sendteMeldingar += 1;
    [sendeStack addObject:data];
    
    //if (!drivMedSending) {
        if (sendeStack.count == 0) { return; }
        [self faktiskSend:[sendeStack firstObject] comp:comp];
        [sendeStack removeObjectAtIndex:0];
    //}
}

- (void) sendKommando:(int)kommando comp:(void(^)(void))comp {
    
    Kommando * data = [[Kommando alloc] init:kommando];
    sendteMeldingar += 1;
    [sendeStack addObject:data];
    
    //if (!drivMedSending) {
    if (sendeStack.count == 0) { return; }
    [self faktiskSend:[sendeStack firstObject] comp:comp];
    [sendeStack removeObjectAtIndex:0];
    //}
}

- (void) faktiskSend:(id)mld comp:(void(^)(void))comp {
    drivMedSending = YES;
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:hostUrl];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[mld enkodMelding]];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [[[NSURLSession sessionWithConfiguration:config] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (comp) { comp(); }
        if (sendeStack.count > 0) {
            id nyMld = [sendeStack firstObject];
            [sendeStack removeObjectAtIndex:0];
            [self faktiskSend:nyMld comp:NULL];
        } else {
            drivMedSending = NO;
        }
    }] resume];
}

@end

@implementation PPrint

+ (NSURL*) localSendLocation {
    return [[NSURL alloc] initWithString:@"http://localhost"];
}

+ (NSURL*) customSendLocation:( NSString* _Nullable )location {
    if (location == NULL) {
        return [PPrint localSendLocation];
    }
    return [[NSURL alloc] initWithString:location];
}

+ (void) pprint:(NSString*)melding sendLocation:(NSURL*)location  {
    PPAvsendar *avsendar = [[PPAvsendar alloc] init:location];
    __block bool finished = NO;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [avsendar sendMelding:melding comp:^{
            finished = YES;
        }];
    });
    
    while (!finished) {}
}

+ (void) pkonsoll:(int)kommando sendLocation:(NSURL*)location  {
    PPAvsendar *avsendar = [[PPAvsendar alloc] init:location];
    __block bool finished = NO;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [avsendar sendKommando:kommando comp:^{
            finished = YES;
        }];
    });
    
    while (!finished) {}
}

@end
