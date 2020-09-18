//
//  Signal.h
//  iOS-APM
//
//  Created by 荣恒 on 2020/9/7.
//

#include <sys/signal.h>
#include <objc/objc.h>
 
/// 判断 sigaction 是否有 sa_sigaction
BOOL has_sa_sigaction(struct sigaction action);
