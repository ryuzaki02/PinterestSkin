//
//  PinsCollectionViewDataSource.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit
import DataCaching

protocol CollectionViewPaginationProtocol: NSObject {
    
    func getDataForNextPage()
}

protocol ScrollViewStartScrollingProtocol: NSObject {
    /// Collection view scroll protocols to manage custom pull to refresh view
    ///
    /// Parameter:
    ///     scollView: Collection view scoll view to get data related to it
    
    func scrollViewStartScoll(scrollView: UIScrollView)
    
    func scrollViewEndDecelerating(scrollView: UIScrollView)
    
    func scrollViewBeginDecelerating(scrollView: UIScrollView)
}

class PinsCollectionViewDataSource: NSObject {
    
    let defaultCellHeight: CGFloat = 300
    let extraPaddingForCellHeight: CGFloat = 100
    private let cellIdentifier = "PinCollectionViewCell"
    private var collectionView: UICollectionView!
    private var pinsArray: [ImageModel]?
    private weak var imageCachingLibrary: DataCachingLibrary!
    weak var scrollViewDelegate: ScrollViewStartScrollingProtocol?
    weak var paginationDelegate: CollectionViewPaginationProtocol?
    private var collectionViewLayout: PinCollectionViewFlowLayout?
    
    //MARK:- Init Method
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
    ///
    /// - Parameters:
    ///   - request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
    ///   - progressBlock: Asynchronous block for progress update.(Optional)
    ///   - completion: The completion handler to call when the load request is complete with Result enum.
    /// - Returns: The new session data task.(Optional)
    init(collectionView: UICollectionView, imageCachingLibrary: DataCachingLibrary) {
        super.init()
        self.collectionView = collectionView
        self.imageCachingLibrary = imageCachingLibrary
        if let layout = collectionView.collectionViewLayout as? PinCollectionViewFlowLayout{
            collectionViewLayout = layout
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        collectionView.delegate = self
        collectionView.dataSource = self
        //updateCollectionViewData(pinsArray: pinsArray, isRefresh: false)
    }
    
    //MARK:- Update collection view data
    
    /// Update collection view with new data from controller
    ///
    /// - Parameters:
    ///   - pinsArray: Consist of all the image models to be shown.(Optional)
    func updateCollectionViewData(pinsArray: [ImageModel]?) {
        self.pinsArray = pinsArray
        collectionView.reloadData()
    }
    
}

extension PinsCollectionViewDataSource: UICollectionViewDelegate{
    /// Can add cell tap or other delegates in future
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let count = pinsArray?.count else {
            return
        }
        if indexPath.row == count-2{
            paginationDelegate?.getDataForNextPage()
        }
    }
}

extension PinsCollectionViewDataSource: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinsArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PinsCollectionViewCell
        if let imageModel = pinsArray?[indexPath.row]{
            cell.setupCell(imageModel: imageModel, imageCachingLibrary: imageCachingLibrary)
        }
        return cell
    }
}

/// It provides height of each cell to custom layout at runtime
extension PinsCollectionViewDataSource: PinCollectionViewHeightDelegate{
    func getHeightForIndexPath(indexPath: IndexPath, collectionView: UICollectionView) -> CGFloat {
        let staticWidth = Double((UIScreen.main.bounds.size.width-15)/2)
        if let height = pinsArray?[indexPath.row].height,
            let width = pinsArray?[indexPath.row].width{
            let value = (height * staticWidth)/width
            return CGFloat(value) + extraPaddingForCellHeight //added padding to make it like pinterest
        }
        return defaultCellHeight //Random height to return when height was not mentioned in web service
    }
}

extension PinsCollectionViewDataSource: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewStartScoll(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewEndDecelerating(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewBeginDecelerating(scrollView: scrollView)
    }
}
