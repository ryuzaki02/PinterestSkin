//
//  PinCollectionViewFlowLayout.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/6/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

protocol PinCollectionViewHeightDelegate: NSObject {
    func getHeightForIndexPath(indexPath: IndexPath, collectionView: UICollectionView) -> CGFloat
}

class PinCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate: PinCollectionViewHeightDelegate!
    
    private var cellPadding: CGFloat = 6
    private var numberOfColumns = 2
    private var contentWidth: CGFloat{
        guard let collectionView = collectionView else {
            return 0
        }
        let contentInsets = collectionView.contentInset
        return collectionView.bounds.size.width - (contentInsets.left + contentInsets.right)
    }
    private var contentHeight: CGFloat = 0
    var cache = [UICollectionViewLayoutAttributes]()
    
    //MARK:- Collection View size
    override var collectionViewContentSize: CGSize{
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
    }
    
    override func prepare() {
        if let collectionView = collectionView{
            let columnWidth = contentWidth/CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for i in 0..<numberOfColumns{
                xOffset.append(columnWidth * CGFloat(i))
            }
            var column = 0
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            
            for item in 0..<collectionView.numberOfItems(inSection: 0){
                
                let height = delegate.getHeightForIndexPath(indexPath: IndexPath(item: item, section: 0), collectionView: collectionView)
                let finalHeight = height - (cellPadding * 2)
                
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: finalHeight)
                let finalFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                let itemAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
                itemAttribute.frame = finalFrame
                cache.append(itemAttribute)
                
                contentHeight = max(frame.maxY, contentHeight)
                yOffset[column] = yOffset[column] + height
                
                column = column < (numberOfColumns-1) ? (column + 1) : 0
            }
        }
        else{
            return
        }
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes = [UICollectionViewLayoutAttributes]()
        for item in cache{
            if item.frame.intersects(rect){
                visibleAttributes.append(item)
            }
        }
        return visibleAttributes
    }
    
    func removeCache(pinsArray: [ImageModel]?) {
        if let count = pinsArray?.count{
            for (index, attribute) in cache.enumerated(){
                if attribute.indexPath.item >= count && index < cache.count{
                    cache.remove(at: index)
                }
            }
        }
    }
}
