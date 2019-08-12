//
//  PinsCollectionViewCell.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit
import DataCaching

class PinsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pinImageView: ImageViewWithURL!
    @IBOutlet weak var reloadContainerView: UIView!
    @IBOutlet weak var reloadImageView: UIImageView!
    
    private weak var imageCachingLibrary: DataCachingLibrary!
    private var imageModel: ImageModel!
    private var reloadImageViewIsAnimating = false
    private weak var sessionTask: CustomURLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reloadContainerView.isHidden = true
    }
    
    //MARK:- Call before cell start reusing itself
    override func prepareForReuse() {
        super.prepareForReuse()
        pinImageView.image = nil
        reloadContainerView.isHidden = true
        cancelRequest()
    }
    
    //MARK:- Setup cell
    
    /// Setup inital data for cell
    ///
    /// - Parameters:
    ///   - imageModel: Model consists of all information related to image.
    ///   - imageCachingLibrary: Object of image caching library to perform fetching, caching data and other operations.
    func setupCell(imageModel: ImageModel, imageCachingLibrary: DataCachingLibrary) {
        pinImageView.imageViewURL = imageModel.imageUrls?.imageUrlRegular
        self.imageModel = imageModel
        self.imageCachingLibrary = imageCachingLibrary
        loadDataForImageModel(imageModel: imageModel)
    }
    
    // Load image from url with caching
    ///
    /// - Parameters:
    ///   - imageModel: Model consists of all information related to image.
    private func loadDataForImageModel(imageModel: ImageModel){
        guard let imageUrl = imageModel.imageUrls?.imageUrlRegular else {
            return
        }
        
        ///To check cancel functionality
        /*imageUrl = "https://images.unsplash.com/photo-1464550883968-cec281c19761?ixlib=rb-0.3.5\u{0026}q=80\u{0026}fm=jpg\u{0026}crop=entropy\u{0026}s=4b142941bfd18159e2e4d166abcd0705"*/
        
        sessionTask = imageCachingLibrary.getDataFromServerForURL(urlString: imageUrl) { [weak self] (result) in
            guard let weakSelf = self else {return}
            switch(result){
            case .success(let data, let urlString) where urlString == imageModel.imageUrls?.imageUrlRegular:
                weakSelf.pinImageView.image = UIImage(data: data)
            default:
                weakSelf.reloadContainerView.isHidden = false
            }
        }
    }
    
    //MARK:- Button Actions
    @IBAction func reloadButtonAction(_ sender: UIButton){
        reloadContainerView.isHidden = true
        loadDataForImageModel(imageModel: imageModel)
    }
    
    //MARK:- Cancel request method
    private func cancelRequest() {
        /// To cancel completion handler for current cell
        sessionTask?.cancelRequest()
    }
}
