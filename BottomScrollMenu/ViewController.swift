//
//  ViewController.swift
//  BottomScrollMenu
//
//  Created by Vy Nguyen on 5/10/20.
//  Copyright © 2020 VVLab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var subViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var subViewHeader: UIView! {
        didSet {
            subViewHeader.clipsToBounds = true
            subViewHeader.layer.cornerRadius = 20
            subViewHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var subViewScrollView: UIScrollView! {
        didSet {
            self.subViewScrollView.delegate = self
        }
    }
    @IBOutlet weak var subViewContainer: UIView! {
        didSet {
            self.subViewContainer.layer.shadowColor = UIColor.black.cgColor
            self.subViewContainer.layer.shadowOpacity = 0.4
            self.subViewContainer.layer.shadowOffset = .zero
            self.subViewContainer.layer.shadowRadius = 5
        }
    }

    var subViewState: SubViewState = .closed {
        didSet { // Handle state here
            if subViewState == .fullOpen {
                subViewHeader.layer.cornerRadius = 0
            } else {
                subViewHeader.layer.cornerRadius = 20
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }
    @IBAction func showSubView(_ sender: Any) {
        openSubView()
    }
}

/// Mark: SubView
extension ViewController {
    func openSubView() {
        if subViewConstraint.constant == -self.view.frame.height
            || subViewState == .opening
            || subViewState == .fullOpen{
            return
        }
        subViewState = .opening
        subViewConstraint.constant = -self.view.frame.height

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.subViewState = .fullOpen
        }
    }
    func closeSubView() {
        if subViewConstraint.constant == 0
            || subViewState == .closed{
            return
        }
        subViewState = .closing
        subViewConstraint.constant = 0

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.subViewState = .closed
        }
    }

    func setupGestures() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(self.movePanel(_:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.subViewHeader.addGestureRecognizer(panRecognizer);
    }
    
    @objc func movePanel(_ sender:UIPanGestureRecognizer) {
        sender.view?.layer.removeAllAnimations()
        if(sender.state == UIGestureRecognizer.State.began){

        }
        if(sender.state == UIGestureRecognizer.State.changed){
            let location = sender.location(in: view)
            print("sender.location(in: view) \(sender.location(in: view))")
            subViewConstraint.constant = location.y - view.frame.height
            view.layoutIfNeeded()
            self.subViewState = .closing

        }
        if (sender.state == UIGestureRecognizer.State.ended){
            print(" UIGestureRecognizer.State.ended \( sender.velocity(in: view) )")
            if sender.velocity(in: view).y < 0 {
                self.openSubView()
            } else {
                self.closeSubView()
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        if scrollView.contentOffset.y < 0 {
            subViewConstraint.constant = subViewConstraint.constant - scrollView.contentOffset.y
            scrollView.setContentOffset(CGPoint.zero, animated: false)
            view.layoutIfNeeded()
            self.subViewState = .closing
        } else if scrollView.contentOffset.y > 0 {
            openSubView()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.subViewState == .closing {
            closeSubView()
        }
    }
}

enum SubViewState {
    case closed
    case opening
    case closing
    case fullOpen
}
