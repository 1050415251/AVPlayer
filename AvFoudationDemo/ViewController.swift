//
//  ViewController.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/12.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let url = URL.init(string: "http://vt1.doubanio.com/201609291737/4af83e686c0432c0dbd3c320f14eba6f/view/movie/M/302030039.mp4")

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
    }

    private func initView() {
        let view = AVFoundationView.init(url: url!)
        view.frame = CGRect.init(x: 0, y: 84, width: 414, height: 400)
        self.view.addSubview(view)
    }



}

