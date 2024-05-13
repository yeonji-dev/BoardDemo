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
        //부모클래스의 초기화로직 보장, 추가적인 초기화 작업
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "잔망루피"
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .black
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //다음 스택에 쌓일 화면(목록)의 뒤로가기 버튼 설정
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
    }
    
    @IBAction func onTouchUpInsideBoard(_ sender:UIButton){
        print("----------------------")
        
        
    }


}

