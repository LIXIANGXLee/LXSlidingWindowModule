//
//  LXSlidingView.swift
//  LXSlidingWindowModule
//
//  Created by XL on 2020/8/21.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager

/// 声明回调
typealias LXSlidingViewChangeCallBack = ((_ offSetX: CGFloat) -> ())
typealias LXSlidingViewEndCallBack = ((_ offSetX: CGFloat) -> (Bool))

class LXSlidingView: UIView {
    // 滑块图片
    private lazy var slidingImgView: UIImageView = {
       let slidingImgView = UIImageView()
        slidingImgView.image = UIImage.image(light: UIImage.named("sliding_icon")!, dark: UIImage.named("sliding_icon")!)
        slidingImgView.contentMode = .scaleAspectFit
        slidingImgView.isUserInteractionEnabled = true
       return slidingImgView
    }()
    
    // 默认滑动条背景色
    private lazy var normalSlidingView: UIView = {
        let normalSlidingView = UIView()
        normalSlidingView.backgroundColor = UIColor.color(lightHex: "E6E6E6", darkHex: "E6E6E6")
        normalSlidingView.layer.cornerRadius = LXFit.fitFloat(17)
        normalSlidingView.clipsToBounds = true
        return normalSlidingView
    }()
    
    // 默认滑动条背景色
    private lazy var currentSlidingView: UIView = {
        let currentSlidingView = UIView()
        currentSlidingView.backgroundColor = UIColor.white
        currentSlidingView.layer.borderWidth = LXFit.fitFloat(1)
        currentSlidingView.layer.borderColor = UIColor.color(lightHex: "E31937", darkHex: "E31937").cgColor
        currentSlidingView.layer.cornerRadius = LXFit.fitFloat(17)
        currentSlidingView.clipsToBounds = true
        return currentSlidingView
    }()
    
    // 标题label
    private lazy var slidingTitleLabel: UILabel = {
        let slidingTitleLabel = UILabel()
        slidingTitleLabel.font = UIFont.systemFont(ofSize: 14).fitFont
        slidingTitleLabel.textColor = UIColor.color(lightHex: "666666", darkHex: "666666")
        slidingTitleLabel.textAlignment = .right
        slidingTitleLabel.text = "请拖动滑块，完成上方拼图"
        return slidingTitleLabel
    }()
    
    /// 手势滑动
     private lazy var panGesture: UIPanGestureRecognizer = {
         let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
         return panGesture
     }()
    
    /// 事件回调
    public var changeCallBack: LXSlidingViewChangeCallBack?
    public var endCallBack: LXSlidingViewEndCallBack?
   
    /// 滑动时 保留原始位置
    private var originSlidingViewX: CGFloat = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        /// 初始化内容UI
        setContentUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - private
extension LXSlidingView {
    
    /// 初始化UI
    private func setContentUI() {
        addSubview(normalSlidingView)
        addSubview(slidingTitleLabel)
        addSubview(currentSlidingView)
        addSubview(slidingImgView)
        slidingImgView.addGestureRecognizer(panGesture)
        
    }
    
    /// 设置内容的frame
    internal func setContentFrame() {
        normalSlidingView.frame = CGRect(x: LXFit.fitFloat(39), y: LXFit.fitFloat(8), width: self.frame.width - LXFit.fitFloat(79), height: LXFit.fitFloat(34))
        
        slidingTitleLabel.frame = CGRect(x: LXFit.fitFloat(39), y: normalSlidingView.frame.origin.y, width: self.frame.width - LXFit.fitFloat(79) - LXFit.fitFloat(22) , height: LXFit.fitFloat(34))
        currentSlidingView.frame = CGRect(x: LXFit.fitFloat(39), y: normalSlidingView.frame.origin.y, width: LXFit.fitFloat(30), height: LXFit.fitFloat(34))
        slidingImgView.frame = CGRect(x: LXFit.fitFloat(30), y: 0, width: LXFit.fitFloat(50) , height: LXFit.fitFloat(50))
        
    }
    
    /// 滑动事件处理
   @objc private func panGesture(_ gesture: UIPanGestureRecognizer) {
       
       let point = gesture.translation(in: gesture.view)

       if gesture.state == .began{
          originSlidingViewX = self.slidingImgView.frame.origin.x
       }else if gesture.state == .changed {/// 开始滑动
         
           self.slidingImgView.frame.origin.x = min(max(LXFit.fitFloat(30), originSlidingViewX + point.x), self.frame.width - LXFit.fitFloat(87))
           self.currentSlidingView.frame.size.width = self.slidingImgView.frame.midX - LXFit.fitFloat(39)
        
           /// 事件回调
           self.changeCallBack?(point.x)
        
       }else { /// 结束 或者 取消滑动
            let result = self.endCallBack?(point.x)
            if let _ = result, result! { ///两张图片完全吻合时处理
                gesture.view?.isUserInteractionEnabled = false
                
                slidingImgView.image =                     UIImage.image(light: UIImage.named("sliding_icon_select")!, dark: UIImage.named("sliding_icon_select")!)
            }else{
                UIView.animate(withDuration: 0.2) {
                    self.slidingImgView.frame.origin.x = LXFit.fitFloat(39)
                    self.currentSlidingView.frame.size.width = LXFit.fitFloat(30)
                }
           }
       }
   }
}

//MARK: - public
extension LXSlidingView {
    
    /// 设置回调
    public func setChangeHandle(_ changeCallBack: LXSlidingViewChangeCallBack?) {
        self.changeCallBack = changeCallBack
    }
    
    /// 设置回调
    public func setEndHandle(_ endCallBack: LXSlidingViewEndCallBack?) {
        self.endCallBack = endCallBack
    }
}
