//
//  BVPlaygroundRow.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BVPlaygroundRow : SKSpriteNode

@property (nonatomic, assign) int pos;
@property (nonatomic, assign) BOOL isEven;
@property (nonatomic, assign) CGSize groundSize; // used while create new cells
@property (nonatomic, weak) BVPlaygroundRow *prevObjRow;
@property (nonatomic, strong) NSMutableArray *cells;

- (void)createObjectCells;
- (void)fillCells;
- (void)refillCells;

@end
