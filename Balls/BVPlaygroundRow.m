//
//  BVPlaygroundRow.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVPlaygroundRow.h"
#import "BVPlaygroundObject.h"
#import "BVPlaygroundBitmasks.h"
#import "SKSpriteNode+BVPos.h"
#import "BVSize.h"

@implementation BVPlaygroundRow
{
    int _coinsAdded;
    int _obstaclesAdded;
}

@synthesize pos = _pos;

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size
{
    self = [super initWithColor:color size:size];
    
    if (self) {
        
        self.name = @"row";
        self.color = color;
        self.size = size;
        self.zPosition = 9;
        
        // add object cells
        //[self createObjectCells];
    }
    return self;
}

- (void)createObjectCells
{
    _cells = [NSMutableArray array];
    
    // Even rows can hold obstacle and coin objects. Maximum of 3 obstacles allowed and 1 coin
    // Odd rows will be blank. So they will not have any cell
    if (_isEven) {
        
        SKSpriteNode *previousCell;
        for (int i = 0; i < 4; i++) {
            float cellWidth = [BVSize resizableValueOniPhones:50 andiPads:45];
            CGSize cellSize = CGSizeMake(cellWidth, self.size.height/4); // previous value of height was = 130
            
            SKSpriteNode *cell = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:cellSize];
            
            if (!previousCell) {
                cell.position = CGPointMake(0, CGRectGetMaxY(self.frame) - (cell.size.height / 2) - (_groundSize.height / 2));
            }
            else {
                [cell setPosRelativeTo:previousCell.frame side:BVPosSideBottom margin:0];
            }
            
            [self addChild:cell];
            [_cells addObject:cell];
            
            previousCell = cell;
        }
    }
}

- (void)refillCells
{
    [self clearupCells];
    
    [self fillCells];
}

- (void)fillCells
{
    if (_isEven) {
        int cellNum = 1;
        for (SKSpriteNode *cell in _cells) {
            int r = arc4random() % 3;
            [self addObjectWithNum:r inCell:cell cellNum:cellNum decisionConfirmed:NO];
            
            cellNum++;
        }
    }
}

- (void)clearupCells
{
    _obstaclesAdded = 0;
    _coinsAdded = 0;
    
    // clear up the cells
    for (SKSpriteNode *cell in _cells) {
        // remove every single child of cell
        for (SKSpriteNode *obj in cell.children) {
            [obj removeFromParent];
        }
    }
}

- (void)addGatewaySensorInCell:(SKSpriteNode *)cell
{
    SKSpriteNode *gatewaySensor = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1, cell.size.height)];
    gatewaySensor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gatewaySensor.size];
    gatewaySensor.physicsBody.affectedByGravity = NO;
    gatewaySensor.physicsBody.dynamic = NO;
    gatewaySensor.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategoryCellGateway;
    [cell addChild:gatewaySensor];
}

- (void)addObjectWithNum:(int)num inCell:(SKSpriteNode *)cell cellNum:(int)cellNum decisionConfirmed:(BOOL)confirmed
{
   
    // this check will solve this problem:
    // |
    // |  |
    //    |
    // that distance in the game is hard to go through.
    // so if prevObjRow's last cell is a gateway, then we must make current
    // row's first cell obstacle.
    if (cellNum == 1 && !confirmed) {

        SKSpriteNode *prevRowLastCell = ((SKSpriteNode *)[_prevObjRow.cells lastObject]);
        BVPlaygroundObject *prevRowLastCellObj = [BVPlaygroundObject Blank];
        
        for (id obj in prevRowLastCell.children) {
            if ([obj isKindOfClass:[BVPlaygroundObject class]]) {
                prevRowLastCellObj = (BVPlaygroundObject *)obj;
            }
        }
        
        if (prevRowLastCellObj.type != BVPlaygroundObjectTypeObstacle) {
            // Previous row's last cell is a gateway.
            // So, current row's first cell can't be a gateway
            [self addObjectWithNum:1 inCell:cell cellNum:cellNum decisionConfirmed:YES];
            // no more need to execute rest of the code. So return.
            return;
        }
    }

    
    int obstaclesAllowed = 3;
    int coinsAllowed = 1;
    
    if (num == 1) {
        // add obstacle
        if (_obstaclesAdded < obstaclesAllowed) {
            BVPlaygroundObject *obstacle = [BVPlaygroundObject Spikes];
            obstacle.size = cell.size;
            [cell addChild:obstacle];
            _obstaclesAdded++;
        }
        else {
            // This is a blank cell
            [self addGatewaySensorInCell:cell];
        }
    }
    else if (num == 2) {
        // add star
        if (_coinsAdded < coinsAllowed) {
            BVPlaygroundObject *coin = [BVPlaygroundObject Coin];
            [cell addChild:coin];
            _coinsAdded++;
            
            // this cell have star in it
            [self addGatewaySensorInCell:cell];
        }
        else {
            [self addObjectWithNum:1 inCell:cell cellNum:cellNum decisionConfirmed:NO];
        }
    }
    else {
        [self addObjectWithNum:1 inCell:cell cellNum:cellNum decisionConfirmed:NO];
    }
    
}

#pragma mark - Getter & Setter

- (void)setPos:(int)pos
{
    _pos = pos;
    if ((pos % 2) == 0) {
        _isEven = YES;
    } else {
        _isEven = NO;
    }
}

@end
