//
//  Signal.h
//  iOS-APM
//
//  Created by 荣恒 on 2020/9/7.
//

//#include <signal.h>
 
typedef void (*SA_SIGACTION)(int, struct __siginfo *, void *);

/// 判断 sigaction 是否有 sa_sigaction
BOOL has_sa_sigaction(struct sigaction action) {
    if (action.sa_sigaction) {
        return YES;
    }
    else {
        return NO;
    }
}

SA_SIGACTION _sa_sigaction(struct sigaction action) {
    if (!action.sa_sigaction) {
        return NULL;
    }
    
    return action.sa_sigaction;
}
