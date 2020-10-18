//
//  PPrintSenderObjc.h
//  PkontoolObjc
//
//  Created by Eskil Sviggum on 06/10/2020.
//

@protocol Sendable <NSObject>

- (NSData*) enkodMelding;

@end

@interface Melding : NSObject <Sendable>
- (instancetype)init:(NSString*)mld;
- (NSData*) enkodMelding;

@end

@interface Kommando : NSObject <Sendable>
- (instancetype)init:(int)cmd;
- (NSData*) enkodMelding;

@end

@interface PPAvsendar : NSObject
- (instancetype)init:(NSURL*)url;
- (void) sendMelding:(NSString*)melding comp:(void(^)(void))comp;
- (void) sendKommando:(int)kommando comp:(void(^)(void))comp;
@property BOOL drivMedSending;
@end

typedef enum : NSUInteger {
    EmptyKommando,
    ScrollEnabledKommando,
    ScrollDisabledKommando,
    RefreshStyleKommando
} KonsollKomando;

@interface PPrint : NSObject
+ (NSURL*) localSendLocation;

+ (NSURL*) customSendLocation:(NSString*)location;

+ (void) pprint:(NSString*)melding sendLocation:(NSURL*)location;

+ (void) pkonsoll:(int)kommando sendLocation:(NSURL*)location;
@end
