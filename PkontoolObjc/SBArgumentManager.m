//
//  SBArgumentManager.m
//  PkontoolObjc
//
//  Created by Eskil Sviggum on 17/10/2020.
//

#import "SBArgumentManager.h"

@implementation SBArgumentManager

NSMutableDictionary * handlers;

- (instancetype)init
{
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerHandlerForArgument:(NSString*)argument handler:(SEL)handler {
    if ([argument isEqualToString:@"-h"]) { printf("Cannot register handler for “-h”. Instead, use the method: “registerHelpHandler:”."); return; }
    [handlers setValue:NSStringFromSelector(handler) forKey:argument];
}

- (void)registerHelpHandler:(SEL)handler {
    [handlers setValue:NSStringFromSelector(handler) forKey:@"-h"];
}

- (void)runHandlerForArguments:(int)argc argv:(const char *_Nullable*_Nullable)argv target:(NSObject*)target {
    //Seriliser argument
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    NSString * nxtkey;
    for (int i = 1; i < argc; i++) {
        const char * arg = argv[i];
        NSString * strarg = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
        
        if (nxtkey != NULL) {
            args[nxtkey] = strarg;
            nxtkey = NULL;
            continue;
        }
        
        if ([strarg containsString:@"-"]) {
            nxtkey = strarg;
        }
    }
    
    if (args.count == 0) { [self runHandlerForArgument:@"-h" value:NULL target:target]; return; }
    
    for (id object in [args keyEnumerator]) {
        [self runHandlerForArgument:object value:args[object] target:target];
    }
}

-(void)runHandlerForArgument:(NSString*)arg value:(_Nullable id)val target:(NSObject*)target {
    if (handlers[arg]) {
        [target performSelector:NSSelectorFromString(handlers[arg]) withObject:val];
    }
}

@end
