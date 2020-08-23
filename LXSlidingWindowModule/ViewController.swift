//
//  ViewController.swift
//  LXSlidingWindowModule
//
//  Created by XL on 2020/8/21.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit
import LXSlidingWindowManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white

        let button = UIButton(frame: CGRect(x: 100, y: 50, width: 100, height: 40))
        
        button.setTitle("滑动弹窗", for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.red
        self.view.addSubview(button)
    }

    
    @objc func buttonClick() {
        let sliderView = LXSlidingWindowView()
        sliderView.show(self.view)
        sliderView.isHaveCerSuccessSound = true
        sliderView.setHandle { (isFinish) in
            print("==========\(isFinish)")
        }
    }
    
}


