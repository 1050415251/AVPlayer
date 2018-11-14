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

    @IBOutlet weak var pauseBtn: UIButton!
    private var playV: UIView!

    fileprivate var manager = DataDownloadManager.newinstance(dataType: .Download)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    private func initView() {
//        let view = AVFoundationView.init(url: url!)
//        view.frame = self.view.bounds
//        view.backgroundColor = UIColor.red
//        self.view.addSubview(view)
//        playV = view
        



    }


    @IBAction func download(_ sender: Any) {
        manager.taskstart(url: url!)
    }

    @IBAction func pause(_ sender: Any) {
        if pauseBtn.title(for: UIControl.State.normal) == "暂停" {
            manager.taskpause(url: url!)
            pauseBtn.setTitle("继续", for: .normal)
        }else {
            download(pauseBtn)
            pauseBtn.setTitle("暂停", for: .normal)
        }

    }


}

