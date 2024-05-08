//
//  ViewController.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/07.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var boardPageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "잔망루피"
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .black
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func onTouchUpInsideBoard(_ sender:UIButton){
        print("----------------------")
        
        
    }


}

