//
//  ImageViewController.swift
//  Mensajeria
//
//  Created by Developer on 16/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    //Public
    var galleryImage: UIImage!
    
    //Private
    @IBOutlet weak var scrollView: UIScrollView!
    var galleryImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("entre acaaaa")
        scrollView.contentSize = galleryImage.size
        print("cntent size: \(scrollView.contentSize)")
        galleryImageView.frame = CGRect(x: 0.0, y: 0.0, width: galleryImageView.image!.size.width, height: galleryImageView.image!.size.height)
        galleryImageView.center = CGPoint(x: scrollView.frame.size.width/2.0, y: scrollView.frame.size.height/2.0)
    }
    
    func setupUI() {
        galleryImageView = UIImageView(image: galleryImage)
        galleryImageView.clipsToBounds = true
        galleryImageView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(galleryImageView)
    }
}

//MARK: UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(scrollView: UIScrollView) {
        print("entreeeeeeeeee")
        let subView = self.scrollView.subviews[0] as! UIImageView
        
        let offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width) ? (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
        
        let offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height) ? (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
        
        subView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
        self.scrollView.contentSize.height * 0.5 + offsetY);
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        print("seteeeeeee")
        return galleryImageView
    }
}
