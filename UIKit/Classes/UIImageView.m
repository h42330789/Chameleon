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

#import "UIImageView+UIPrivate.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIImageAppKitIntegration.h"
#import "UIWindow.h"
#import "UIImage+UIPrivate.h"
#import "UIScreen.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageRep.h"

static NSArray *CGImagesWithUIImages(NSArray *images)
{
    NSMutableArray *CGImages = [NSMutableArray arrayWithCapacity:[images count]];
    for (UIImage *img in images) {
        [CGImages addObject:(__bridge id)[img CGImage]];
    }
    return CGImages;
}

@implementation UIImageView {
    _UIImageViewDrawMode _drawMode;
}

+ (BOOL)_instanceImplementsDrawRect
{
    return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        _drawMode = _UIImageViewDrawModeNormal;
        self.userInteractionEnabled = NO;
        self.opaque = NO;
    }
    return self;
}

- (id)initWithImage:(UIImage *)theImage
{
    CGRect frame = CGRectZero;

    if (theImage) {
        frame.size = theImage.size;
    }
        
    if ((self = [self initWithFrame:frame])) {
        self.image = theImage;
    }

    return self;
}


- (CGSize)sizeThatFits:(CGSize)size
{
    return _image? _image.size : CGSizeZero;
}

- (void)setHighlighted:(BOOL)h
{
    if (h != _highlighted) {
        _highlighted = h;
        [self setNeedsDisplay];

        if ([self isAnimating]) {
            [self startAnimating];
        }
    }
}

- (void)setImage:(UIImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        if (!_highlighted || !_highlightedImage) {
            [self setNeedsDisplay];
        }
    }
}

- (void)setHighlightedImage:(UIImage *)newImage
{
    if (_highlightedImage != newImage) {
        _highlightedImage = newImage;
        if (_highlighted) {
            [self setNeedsDisplay];
        }
    }
}

- (BOOL)_hasResizableImage
{
    return (_image.topCapHeight > 0 || _image.leftCapWidth > 0);
}

- (void)_setDrawMode:(_UIImageViewDrawMode)drawMode
{
    if (drawMode != _drawMode) {
        _drawMode = drawMode;
        [self setNeedsDisplay];
    }
}
/**
1. displayLayer: 方法的弃用
UIImageView 的 displayLayer: 方法在早期版本的 iOS 中是用于在 UIImageView 的 CALayer 上进行自定义绘制，但在 iOS 13 后，Apple 推荐使用 drawLayer:inContext: 方法，或其他绘制方法来代替 displayLayer:。

2. 新的替代方法：drawRect: 或 drawLayer:inContext:
虽然 displayLayer: 被弃用，但如果你需要在 UIImageView 上进行自定义绘制操作，可以考虑以下方法：

1. 使用 drawRect:（对于 UIView 子类）
如果你需要对 UIImageView 进行自定义绘制，可以通过继承 UIImageView 并重写其 drawRect: 方法。drawRect: 方法用于在视图的内容区域进行自定义绘制。
 */
- (void)displayLayer:(CALayer *)theLayer
{
//    [super displayLayer:theLayer];
    
    UIImage *displayImage = (_highlighted && _highlightedImage)? _highlightedImage : _image;
    const CGFloat scale = self.window.screen.scale;
    const CGRect bounds = self.bounds;
    
    if (displayImage && self._hasResizableImage && bounds.size.width > 0 && bounds.size.height > 0) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, scale);
        [displayImage drawInRect:bounds];
        displayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // adjust the image if required.
    // this will likely only ever be used UIButton, but it seemed a good place for it.
    // I wonder how the real UIKit does this...
    if (displayImage && (_drawMode != _UIImageViewDrawModeNormal)) {
        CGRect imageBounds;
        imageBounds.origin = CGPointZero;
        imageBounds.size = displayImage.size;

        UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, scale);
        
        CGBlendMode blendMode = kCGBlendModeNormal;
        CGFloat alpha = 1;
        
        if (_drawMode == _UIImageViewDrawModeDisabled) {
            alpha = 0.5;
        } else if (_drawMode == _UIImageViewDrawModeHighlighted) {
            [[[UIColor blackColor] colorWithAlphaComponent:0.4] setFill];
            UIRectFill(imageBounds);
            blendMode = kCGBlendModeDestinationAtop;
        }
        
        [displayImage drawInRect:imageBounds blendMode:blendMode alpha:alpha];
        displayImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
    }

    UIImageRep *bestRepresentation = [displayImage _bestRepresentationForProposedScale:scale];
    theLayer.contents = (__bridge id)bestRepresentation.CGImage;
    
    if ([theLayer respondsToSelector:@selector(setContentsScale:)]) {
        [theLayer setContentsScale:bestRepresentation.scale];
    }
}

- (void)_displayIfNeededChangingFromOldSize:(CGSize)oldSize toNewSize:(CGSize)newSize
{
    if (!CGSizeEqualToSize(newSize,oldSize) && self._hasResizableImage) {
        [self setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)newFrame
{
    [self _displayIfNeededChangingFromOldSize:self.frame.size toNewSize:newFrame.size];
    [super setFrame:newFrame];
}

- (void)setBounds:(CGRect)newBounds
{
    [self _displayIfNeededChangingFromOldSize:self.bounds.size toNewSize:newBounds.size];
    [super setBounds:newBounds];
}

- (void)startAnimating
{
    NSArray *images = _highlighted? _highlightedAnimationImages : _animationImages;

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.duration = self.animationDuration ?: ([images count] * (1/30.0));
    animation.repeatCount = self.animationRepeatCount ?: HUGE_VALF;
    animation.values = CGImagesWithUIImages(images);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;

    [self.layer addAnimation:animation forKey:@"contents"];
}

- (void)stopAnimating
{
    [self.layer removeAnimationForKey:@"contents"];
}

- (BOOL)isAnimating
{
    return ([self.layer animationForKey:@"contents"] != nil);
}

@end
