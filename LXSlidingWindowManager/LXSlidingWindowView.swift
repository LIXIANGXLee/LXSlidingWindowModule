//
//  LXSlidingWindowView.swift
//  LXSlidingWindowModule
//
//  Created by XL on 2020/8/21.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXFitManager
import LXDarkModeManager
import AVFoundation

//MARK: - 事件声明
public typealias LXSlidingWindowViewCallBack = ((Bool) -> ())

//MARK: - LXSlidingWindowView
public class LXSlidingWindowView: UIView {
    
    /// 内容背景view
    private lazy var bgContentView: UIView = {
        let bgContentView = UIView()
        bgContentView.backgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1.0)
        /// 默认圆角设置
        bgContentView.layer.cornerRadius = 20
        bgContentView.clipsToBounds = true
        return bgContentView
    }()
    
    /// 标题label
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14).fitFont
        titleLabel.textColor = UIColor.color(lightHex: "222222", darkHex: "222222")
        titleLabel.textAlignment = .left
        titleLabel.text = "拖动下方滑块，进行拼图认证"
        return titleLabel
    }()
    
    /// 关闭按钮
    private lazy var closeBtn: UIButton = {
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage.image(light: UIImage.named("sliding_close_icon")!, dark: UIImage.named("sliding_close_icon")!), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        return closeBtn
    }()
    
    /// 背景图片
    private lazy var bgImgView: UIImageView = {
        let bgImgView = UIImageView()
        bgImgView.isUserInteractionEnabled = true
        bgImgView.contentMode = .scaleAspectFit
        bgImgView.image = UIImage.image(light: UIImage.named("bg_sliding_img")!, dark: UIImage.named("bg_sliding_img")!)

        return bgImgView
    }()
    
    /// 滑块开始view
    private lazy var startSubImgView: UIImageView = {
        let startSubImgView = UIImageView()
        startSubImgView.contentMode = .scaleAspectFit
        startSubImgView.image = UIImage.image(light: UIImage.named("start_sliding_icon")!, dark: UIImage.named("start_sliding_icon")!)
        return startSubImgView
    }()
    
    ///滑块结束view
    private lazy var endSubImgView: UIView = {
        let endSubImgView = UIView()
        endSubImgView.backgroundColor = UIColor.clear
        return endSubImgView
    }()
    
    ///滑块结束view的子view
    private lazy var endSubSubImgView: UIImageView = {
           let endSubImgView = UIImageView()
           endSubImgView.contentMode = .scaleAspectFit
           endSubImgView.image = UIImage.image(light: UIImage.named("end_sliding_icon")!, dark: UIImage.named("end_sliding_icon")!)
           return endSubImgView
       }()
    
    /// 刷新布局图片
    private lazy var updateBtn: UIButton = {
        let updateBtn = UIButton(type: .custom)
        updateBtn.addTarget(self, action: #selector(updateSlidingUI), for: .touchUpInside)
        return updateBtn
    }()
    
    private lazy var updateImgView: UIImageView = {
        let updateImgView = UIImageView()
        updateImgView.image = UIImage.image(light: UIImage.named("update_sliding_icon")!, dark: UIImage.named("update_sliding_icon")!)
        return updateImgView
    }()
    
    // slidingView
    private lazy var slidingView: LXSlidingView = {
        let slidingView = LXSlidingView()
        return slidingView
    }()
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        /// 背景色
        self.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        
        /// 初始化UI
        setContentUI()
        
        /// 事件监听
        setHandle()
        
        /// 设置尺寸
        setAllFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 滑动时 保留原始位置
   private var originSlidingViewX: CGFloat = 0
   
   /// 结束事件回调
   public var callBack: LXSlidingWindowViewCallBack?
   
   /// 背景图片修改
   public var bgImage: UIImage? {
       didSet {
           guard let bgImage = bgImage else { return }
           bgImgView.image = bgImage
       }
   }
    
    /// 背景view颜色
    public var bgBackgroundColor: UIColor? {
        didSet {
            guard let bgBackgroundColor = bgBackgroundColor else { return }
            backgroundColor = bgBackgroundColor
        }
    }
    
    ///背景view圆角
    public var bgContentCornerRadius: CGFloat? {
        didSet {
            guard let bgContentCornerRadius = bgContentCornerRadius else { return }
            bgContentView.layer.cornerRadius = bgContentCornerRadius
            bgContentView.clipsToBounds = true
        }
    }
    
    ///背景viewY坐标
    public var bgContentY: CGFloat? {
       didSet {
           guard let bgContentY = bgContentY else { return }
           bgContentView.frame.origin.y = bgContentY
       }
    }
    
    /// 验证成功 是否有振动声音
    public var isHaveCerSuccessSound: Bool = true
    ///验证成功 后的延时时间 默认两秒
    public var delayDuration: Double = 2
}

//MARK: - private
extension LXSlidingWindowView {
    
    /// 初始化UI
    private func setContentUI() {
        addSubview(bgContentView)
        bgContentView.addSubview(titleLabel)
        bgContentView.addSubview(closeBtn)
        bgContentView.addSubview(bgImgView)
        bgContentView.addSubview(slidingView)
        bgImgView.addSubview(startSubImgView)
        bgImgView.addSubview(endSubImgView)
        endSubImgView.addSubview(endSubSubImgView)
        bgImgView.addSubview(updateBtn)
        updateBtn.addSubview(updateImgView)
    }
    
    /// 时间监听
    private func setHandle() {
        /// 滑动事件结束时的回调
        slidingView.setEndHandle {  [weak self] (offSet) in
           self?.startSubImgView.frame.origin.x = min((self?.bgImgView.frame.width ?? 0) - LXFit.fitFloat(52), max(0, (self?.originSlidingViewX ?? 0) + offSet))
            guard let rect1 = self?.endSubImgView.frame , let rect2 = self?.startSubImgView.frame else { return false }
            if  rect1.contains(rect2) { /// 包含
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (self?.delayDuration ?? 2)) {
                    self?.callBack?(true)
                    self?.dismiss()
                }
                
                /// true 则播放振动声音
                if self?.isHaveCerSuccessSound ?? false {
                    self?.playSound()
                }
                return true
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self?.startSubImgView.frame.origin.x = self?.originSlidingViewX ?? 0
                }) { (finish) in
                    self?.updateSlidingUI()
                }
                return false
            }
        }
        
        /// 滑块滑动时 不断改变
        slidingView.setChangeHandle {  [weak self] (offSet) in
            self?.startSubImgView.frame.origin.x = min((self?.bgImgView.frame.width ?? 0) - LXFit.fitFloat(52), max(0, (self?.originSlidingViewX ?? 0) + offSet))
        }
    }
    
    /// 设置frame
    private func setAllFrame() {
        
         /// 设置内容尺寸
         setContentFrame()
        
         /// 刷新滑块UI
         updateSlidingUI()

         /// 滑块布局
         slidingView.setContentFrame()
        
    }
    
    /// 设置内容尺寸
    private func setContentFrame() {
        bgContentView.frame = CGRect(x: LXFit.fitFloat(25), y: (bgContentY != nil) ? bgContentY! : (LXFit.fitFloat(287 - 88) + LXSlidingApp.statusbarH), width: UIScreen.main.bounds.width - LXFit.fitFloat(50), height: LXFit.fitFloat(262))
        closeBtn.frame = CGRect(x: bgContentView.frame.width - LXFit.fitFloat(45), y: LXFit.fitFloat(9), width: LXFit.fitFloat(30), height: LXFit.fitFloat(30))
        titleLabel.frame = CGRect(x: LXFit.fitFloat(25), y: LXFit.fitFloat(14), width: closeBtn.frame.minX - LXFit.fitFloat(35), height: LXFit.fitFloat(20))
        bgImgView.frame = CGRect(x: LXFit.fitFloat(25), y: titleLabel.frame.maxY + LXFit.fitFloat(13), width: bgContentView.frame.width - LXFit.fitFloat(50), height: LXFit.fitFloat(139))
        slidingView.frame = CGRect(x: 0, y: bgImgView.frame.maxY + LXFit.fitFloat(15), width: bgContentView.frame.width, height: LXFit.fitFloat(50))
        updateBtn.frame = CGRect(x: LXFit.fitFloat(235), y: LXFit.fitFloat(103), width: LXFit.fitFloat(36), height: LXFit.fitFloat(36))
        updateImgView.frame = CGRect(x: LXFit.fitFloat(10), y: LXFit.fitFloat(10), width: LXFit.fitFloat(16), height: LXFit.fitFloat(16))

    }
    
    @objc private func updateSlidingUI() {
        let starX = max(0, arc4random_uniform(UInt32(bgImgView.frame.width * 0.5) - UInt32(LXFit.fitFloat(52))))
        let endX = max(UInt32(bgImgView.frame.width * 0.5), arc4random_uniform(UInt32(bgImgView.frame.width) - UInt32(LXFit.fitFloat(57))))
        let y = max(0, arc4random_uniform(UInt32(LXFit.fitFloat(113) - LXFit.fitFloat(52))))
        startSubImgView.frame = CGRect(x: CGFloat(starX), y:  CGFloat(y), width: LXFit.fitFloat(52), height: LXFit.fitFloat(52))
        originSlidingViewX = startSubImgView.frame.minX
        endSubImgView.frame = CGRect(x: CGFloat(endX), y:  CGFloat(y) - LXFit.fitFloat(5), width: LXFit.fitFloat(62), height: LXFit.fitFloat(62))
        endSubSubImgView.frame = CGRect(x: LXFit.fitFloat(5), y:  LXFit.fitFloat(5), width: LXFit.fitFloat(52), height: LXFit.fitFloat(52))
    }
    
     /// 关闭按钮事件监听
     @objc private func closeBtnClick() {
        self.callBack?(false)
        self.dismiss()
     }
    
    /// 播放音效
    private func playSound() {
        let ID = SystemSoundID(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(ID)
        AudioServicesPlaySystemSoundWithCompletion(ID, {
          AudioServicesDisposeSystemSoundID(ID)
       })
    }
}

//MARK: - public
extension LXSlidingWindowView {
    
    /// 显示滑动弹窗
    public func show(_ rootView: UIView?) {
        guard let rootView = rootView else { return }
        self.frame = rootView.bounds
        rootView.addSubview(self)
    }
    
    /// 关闭弹窗
    @objc public func dismiss() {
        self.removeFromSuperview()
    }
    
    /// 事件回调
    public func setHandle(_ callBack: LXSlidingWindowViewCallBack?) {
        self.callBack = callBack
    }
      
}

//MARK: - LXSlidingApp 常量 结构体
fileprivate struct LXSlidingApp {

   //根据高度来判断是否是带刘海的手机,也可以通过safaAreaInserts来判断
    fileprivate static let isIPhoneX = (UIScreen.main.bounds.height == CGFloat(812) || UIScreen.main.bounds.height == CGFloat(896)) ? true : false
    
    //状态栏高度
    fileprivate static let statusbarH = isIPhoneX ? CGFloat(44.0) : CGFloat(20.0)
    
}
