//
//  JDMNode.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/6/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMUtility.h"



@import SceneKit;
@import SpriteKit;
@import GLKit;




@interface JDMNode : SCNNode

+(instancetype)makeCharacter;

-(void)doAnimation;

@end
