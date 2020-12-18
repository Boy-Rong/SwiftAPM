//
//  signal.c
//  SwiftAPM
//
//  Created by 荣恒 on 2020/9/18.
//

#include "signal.h"

/// 判断 sigaction 是否有 sa_sigaction
bool has_sa_sigaction(struct sigaction action) {
    if (action.sa_sigaction) {
        return true;
    }
    else {
        return false;
    }
}
