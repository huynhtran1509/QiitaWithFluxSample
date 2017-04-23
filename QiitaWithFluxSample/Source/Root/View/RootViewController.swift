//
//  RootViewController.swift
//  QiitaWithFluxSample
//
//  Created by marty-suzuki on 2017/04/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import SafariServices

class RootViewController: UIViewController {
    private (set) var currentViewController: UIViewController? {
        didSet {
            guard let currentViewController = currentViewController else { return }
            addChildViewController(currentViewController)
            currentViewController.view.frame = view.bounds
            view.addSubview(currentViewController.view)
            currentViewController.didMove(toParentViewController: self)
            
            guard let oldViewController = oldValue else { return }
            view.sendSubview(toBack: currentViewController.view)
            UIView.transition(from: oldViewController.view,
                              to: currentViewController.view,
                              duration: 0.3,
                              options: .transitionCrossDissolve) { [weak oldViewController] _ in
                guard let oldViewController = oldViewController else { return }
                oldViewController.willMove(toParentViewController: nil)
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
            }
        }
    }
    
    private let viewModel = RootViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func observeViewModel() {
        viewModel.login
            .observeOn(ConcurrentMainScheduler.instance)
            .filterNil()
            .subscribe(onNext: { [weak self] displayType in
                guard let me = self else { return }
                let loginNC: LoginNavigationController
                if let nc = me.currentViewController as? LoginNavigationController {
                    loginNC = nc
                } else {
                    loginNC = LoginNavigationController()
                    me.currentViewController = loginNC
                }
                switch displayType {
                case .root:
                    if loginNC.topViewController is LoginTopViewController {
                        return
                    }
                    loginNC.popToRootViewController(animated: true)
                case .webView:
                    if loginNC.topViewController is LoginViewController {
                        return
                    }
                    loginNC.pushViewController(LoginViewController.instantiate(), animated: true)
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.search
            .observeOn(ConcurrentMainScheduler.instance)
            .filterNil()
            .subscribe(onNext: { [weak self] displayType in
                guard let me = self else { return }
                let searchNC: SearchNavigationController
                if let nc = me.currentViewController as? SearchNavigationController {
                    searchNC = nc
                } else {
                    searchNC = SearchNavigationController()
                    me.currentViewController = searchNC
                }
                switch displayType {
                case .root:
                    if searchNC.topViewController is SearchTopViewController {
                        return
                    }
                    searchNC.popToRootViewController(animated: true)
                case .webView(let url):
                    if searchNC.topViewController is SFSafariViewController {
                        return
                    }
                    searchNC.pushViewController(SFSafariViewController(url: url), animated:  true)
                }
            })
            .addDisposableTo(disposeBag)
    }
}

