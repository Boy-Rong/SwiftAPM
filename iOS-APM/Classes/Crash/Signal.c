//
//  Signal.c
//  iOS-APM
//
//  Created by 荣恒 on 2020/9/18.
//

#include "Signal.h"

/// 判断 sigaction 是否有 sa_sigaction
BOOL has_sa_sigaction(struct sigaction action) {
    if (action.sa_sigaction) {
        return YES;
    }
    else {
        return NO;
    }
}
