//
//  RefreshControl.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/6/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

class RefreshControlView: UIView {
    
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet var innerViews: [UIView]!
    
    private var previousScale: CGFloat = 0
    private var scrollPropertyAnimator: UIViewPropertyAnimator!
    private var rotationPropertyAnimator: UIViewPropertyAnimator!
    
    class func instanceFromNib() -> RefreshControlView {
        return UINib(nibName: "RefreshControlView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RefreshControlView
    }
    
    deinit {
        #if DEBUG
        print("Refresh control view deinit")
        #endif
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        setupUI()
    }
    
    //MARK:-  Notification methods
    
    /// Start scroll property animator when app enters foreground
    @objc
    func enterForeground() {
        setupScrollPropertyAnimator()
    }
    
    /// End scroll property animator when app enters background
    @objc
    func enterBackground() {
        endScrollPropertyAnimator()
    }
    
    //MARK:- UI setup
    private func setupUI() {
        refreshView.setCornerRadius()
        for view in innerViews{
            view.setCornerRadius()
        }
        setupScrollPropertyAnimator()
    }
    
    /// Setup scroll property animator for refresh view
    ///
    private func setupScrollPropertyAnimator(){
        refreshView.transform = CGAffineTransform(scaleX: 0.005, y: 0.005)
        refreshView.alpha = 0
        
        scrollPropertyAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.refreshView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.refreshView.transform = CGAffineTransform(rotationAngle: -.pi)
            self.refreshView.alpha = 1
        }
        scrollPropertyAnimator.startAnimation()
        scrollPropertyAnimator.pauseAnimation()
    }
    
    /// End scroll property animator for refresh view
    ///
    private func endScrollPropertyAnimator() {
        scrollPropertyAnimator.stopAnimation(false)
        scrollPropertyAnimator.finishAnimation(at: .end)
    }
    
    
    //MARK:- Refresh view animation methods
    
    /// Rotate of refresh view while user start dragging collection view downwards
    ///
    ///
    /// - Parameters:
    ///   - offsetDifference: Difference of current and previous offset values of collection scroll view
    func updateRefreshViewSize(offsetDifference: CGFloat) {
        bringSubviewToFront(refreshView)
        previousScale += offsetDifference * 0.013
        scrollPropertyAnimator.fractionComplete = min(previousScale, 0.99)
    }
    
    /// Start infinte rotation after collection view starts refreshing
    func startRefreshViewRotation() {
        rotationPropertyAnimator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
            UIView.setAnimationRepeatCount(Float.infinity)
            self.refreshView.transform = CGAffineTransform(rotationAngle: .pi/2)
        }, completion: nil)
    }
    
    /// Stop infinte rotation after collection view end refreshing
    func stopRefreshViewRotation() {
        rotationPropertyAnimator.stopAnimation(false)
        rotationPropertyAnimator.finishAnimation(at: .end)
    }
}
