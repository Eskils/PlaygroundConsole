//
//  main.m
//  PkontoolObjc
//
//  Created by Eskil Sviggum on 06/10/2020.
//

#import <Foundation/Foundation.h>
#import "PPrintSenderObjc.h"
#import "SBArgumentManager.h"
#import <OSLog/OSLog.h>

void lagreUdverdi(NSString* key, NSString* val) {
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"group.playgroundprint"];
    [ud setValue:val forKey:key];
}

NSString* hentUdverdi(NSString* key) {
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"group.playgroundprint"];
    return [ud valueForKey:key];
}

@interface Functions : NSObject

@end

@implementation Functions

NSURL * sendloc;

- (instancetype)init
{
    self = [super init];
    if (self) {
        sendloc =  [PPrint customSendLocation:hentUdverdi(@"customSendLocation")];
    }
    return self;
}

- (void)help {
    printf("\n\n");
    printf("pkontool — Commands");
    NSArray * cmds = @[@"-l / --loc",
                       @"-v / --val",
                       @"-k / --key",
                       @"-m / --msg",
                       @"-c / --cmd",
                       @"-s / --style"];
    
    NSArray * desc = @[@"change sendlocation",
                       @"value to save for key in user defaults",
                       @"key to save for in user defaults",
                       @"send message to console",
                       @"send command to console",
                       @"change style for the console"];
    NSArray * para = @[@"String: location, specify “..” to reset.",
                       @"String: value",
                       @"String: key",
                       @"String: message",
                       @"(Enum)Int: command \n  0: empty,\n  1: enableScrolling, \n  2: disableScrolling, \n  3: refreshStyle",
                       @"(Enum)Int: style \n  0: traditional, \n  1: futuristic, \n  2: clean, \n  3: hacker"];
    
    for (NSInteger i = 0; i < cmds.count; i++) {
        printf("\n\n");
        NSString * key = cmds[i];
        NSString * des = desc[i];
        NSString * par = para[i];
        printf("%s\nDescription: %s\nParameters: %s", [key cStringUsingEncoding:NSUTF8StringEncoding], [des cStringUsingEncoding:NSUTF8StringEncoding], [par cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    printf("\n\n");
}

-(void)changeSendlocation:(id)value {
    if ([value isEqualToString:@".."]) {
        lagreUdverdi(@"customSendLocation", NULL);
    }else {
        lagreUdverdi(@"customSendLocation", value);
    }
    sendloc = [PPrint customSendLocation:value];
}

-(void)sendMelding:(id)value {
    [PPrint pprint:value sendLocation:sendloc];
}

-(void)endreStyle: (id)value {
    lagreUdverdi(@"style", value);
    [PPrint pkonsoll:RefreshStyleKommando sendLocation:sendloc];
}

-(void)sendKommando: (id)style {
    int val = [style intValue];
    [PPrint pkonsoll:val sendLocation:sendloc];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Functions * funcs = [[Functions alloc] init];
        SBArgumentManager * argman = [[SBArgumentManager alloc] init];
        
        //Argumentdefinisjinar
        
        //-h ; sjå hjelp
        [argman registerHelpHandler:NSSelectorFromString(@"help")];

        
        //-l ; endre sendlocation
        [argman registerHandlerForArgument:@"-l" handler:NSSelectorFromString(@"changeSendlocation:")];
        [argman registerHandlerForArgument:@"--loc" handler:NSSelectorFromString(@"changeSendlocation:")];

        
        //-v + -k ; lagre verdi for nøkkel i ud
        /*if (args[@"-v"] && args[@"-k"]) {
            lagreUdverdi([args valueForKey:@"-k"], [args valueForKey:@"-v"]);
        }*/
        
        //--msg ; send melding
        [argman registerHandlerForArgument:@"-m" handler:NSSelectorFromString(@"sendMelding:")];
        [argman registerHandlerForArgument:@"--msg" handler:NSSelectorFromString(@"sendMelding:")];
        
        // --style ; endre stil
        [argman registerHandlerForArgument:@"-s" handler:NSSelectorFromString(@"endreStyle:")];
        [argman registerHandlerForArgument:@"--style" handler:NSSelectorFromString(@"endreStyle:")];
        
        // --cmd ; send komando
        [argman registerHandlerForArgument:@"-c" handler:NSSelectorFromString(@"sendKommando:")];
        [argman registerHandlerForArgument:@"--cmd" handler:NSSelectorFromString(@"sendKommando:")];
        
        [argman runHandlerForArguments:argc argv:argv target:funcs];
        
    }
    return 0;
}
