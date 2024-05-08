//
//  BoardDetailViewController.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/08.
//

import UIKit

class BoardDetailViewController:UIViewController{
    
    var trend: Trend?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("-----------")
        print(trend?.bno)
        self.title = "잔망루피"
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .black
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
        view.backgroundColor = .white
    }
}
