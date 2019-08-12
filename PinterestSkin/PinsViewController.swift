//
//  ViewController.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit
import DataCaching

class PinsViewController: UIViewController {
    
    @IBOutlet weak var pinsCollectionView: UICollectionView!
    
    private var imageCachingLibrary: DataCachingLibrary!
    private var networkLayer: NetworkLayer!
    private var pinsCollectionViewDataSource: PinsCollectionViewDataSource!
    private var refreshControl: UIRefreshControl!
    private var refreshView: RefreshControlView?
    private var lastContentOffset: CGFloat = 0
    private var currentPage  = 1
    private var totalPages = 3
    private var pinsArray: [ImageModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkLayer = NetworkLayer.init()
        imageCachingLibrary = DataCachingLibrary.init(networkLayer: networkLayer)
        pinsCollectionViewDataSource = PinsCollectionViewDataSource.init(collectionView: pinsCollectionView, imageCachingLibrary: imageCachingLibrary)
        pinsCollectionViewDataSource.scrollViewDelegate = self
        pinsCollectionViewDataSource.paginationDelegate = self
        
        currentPage = 1
        addRefreshControlToCollectionView()
        getDataFromServer(isRefresh: false)
    }
    
    //MARK:- Refresh control methods
    
    /// Add custom refresh control to collection view
    func addRefreshControlToCollectionView() {
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        pinsCollectionView.refreshControl = refreshControl
        createCustomRefreshControlView()
    }
    
    /// Creates refresh view and set its frame
    func createCustomRefreshControlView() {
        refreshView = RefreshControlView.instanceFromNib()
        refreshView?.frame = refreshControl.bounds
        guard let view = refreshView else {
            return
        }
        refreshControl.addSubview(view)
    }
    
    //MARK:- Server methods
    
    /// Function to get data from server
    ///
    /// Parameters:
    ///     isRefresh: Check whether method called from pull to refresh or not
    private func getDataFromServer(isRefresh: Bool) {
        guard let url = URL(string: "http://pastebin.com/raw/wgkJgazE") else {return}
        let urlRequest = URLRequest(url: url)
        networkLayer.requestWithCompletionBlock(request: urlRequest, completion: { [weak self] (result) in
            guard let weakSelf = self else {return}
            weakSelf.stopRefreshControl()
            switch(result)
            {
            case .Failure(let error):
                print(error.errorDescription)
            case .Success(let data):
                weakSelf.processResponseData(data: data, isRefresh: isRefresh)
            }
        })
    }
    
    /// Process the data recieved from server
    ///
    /// Parameters:
    ///     data: Data from sever
    ///     isRefresh: Either to append aur replace pins array data
    func processResponseData(data: Data, isRefresh: Bool) {
        do
        {
            let decoder = JSONDecoder()
            let modelArr = try decoder.decode([ImageModel].self, from: data)
            if isRefresh || pinsArray == nil{
                pinsArray = modelArr
            }else{
                pinsArray?.append(contentsOf: modelArr)
            }
            pinsCollectionViewDataSource.updateCollectionViewData(pinsArray: pinsArray)
        }
        catch let error{
            #if DEBUG
            print("Could not parse the data \(error.localizedDescription)")
            #endif
        }
    }
    
    //MARK:- Adjust Refresh control
    
    /// Function to stop refresh control
    ///
    private func stopRefreshControl() {
        if refreshControl.isRefreshing{
            refreshView?.stopRefreshViewRotation()
            refreshControl.endRefreshing()
        }
    }
    
    /// Function to start refresh control
    ///
    private func startRefreshControl() {
        refreshView?.startRefreshViewRotation()
        currentPage = 1
        getDataFromServer(isRefresh: true)
    }
}

extension PinsViewController: ScrollViewStartScrollingProtocol{
    func scrollViewBeginDecelerating(scrollView: UIScrollView) {
        
    }
    
    func scrollViewStartScoll(scrollView: UIScrollView) {
        if !refreshControl.isRefreshing{
            refreshView?.updateRefreshViewSize(offsetDifference: lastContentOffset-scrollView.contentOffset.y)
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewEndDecelerating(scrollView: UIScrollView) {
        if refreshControl.isRefreshing{
            startRefreshControl()
        }
    }
}

extension PinsViewController: CollectionViewPaginationProtocol{
    func getDataForNextPage() {
        currentPage += 1
        if currentPage <= totalPages{
            getDataFromServer(isRefresh: false)
        }
    }
}
