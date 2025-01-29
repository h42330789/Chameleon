/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIViewLayoutManager.h"
#import <QuartzCore/CALayer.h>
#import "UIView+UIPrivate.h"

static UIViewLayoutManager *theLayoutManager = nil;

@implementation UIViewLayoutManager

+ (void)initialize
{
    if (self == [UIViewLayoutManager class]) {
        theLayoutManager = [[self alloc] init];
    }
}

+ (UIViewLayoutManager *)layoutManager
{
    return theLayoutManager;
}

- (void)layoutSublayersOfLayer:(CALayer *)theLayer
{
//    [[theLayer delegate] _layoutSubviews];
    if ([theLayer.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
        [[theLayer delegate] layoutSublayersOfLayer:theLayer];
    }
    /**
    在 CALayerDelegate 中，_layoutSubviews 方法已经被弃用，并且替换为 layoutSublayersOfLayer: 方法。这个变化是为了让 CALayerDelegate 变得更加灵活，遵循现代的层次化布局和渲染机制。

    1. 旧方法 (已弃用)
    在 iOS 13 之前，CALayerDelegate 可能使用了 _layoutSubviews 方法，来手动更新和布局子视图。然而，随着 iOS 13 及更高版本的更新，Apple 强烈推荐使用新的方法来替代。

    2. 新方法：layoutSublayersOfLayer:
    从 iOS 13 开始，CALayerDelegate 提供了 layoutSublayersOfLayer: 方法来替代 _layoutSubviews。这个方法在 CALayer 需要布局其子层（sub-layers）时被调用。
     */
}

@end
