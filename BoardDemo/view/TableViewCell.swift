//
//  TableViewCell.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/08.
//

import UIKit

class TableViewCell: UITableViewCell {

    static let identifier = "TableViewCell"
    
    var boardView = UIView()
    var title = UILabel()
    var regdate = UILabel()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContentView() {
            
        // view.addSubview() 가 아닌
        // contentView !!!
        contentView.addSubview(boardView)
        boardView.translatesAutoresizingMaskIntoConstraints = false
        // boardView 레이아웃 설정
        boardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        boardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        boardView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        boardView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false

        // label 레이아웃 설정
        title.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -4).isActive = true
        title.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        
        title.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        

        contentView.addSubview(regdate)
        regdate.translatesAutoresizingMaskIntoConstraints = false

        // regdate 레이아웃 설정
        regdate.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 4).isActive = true
        regdate.leadingAnchor.constraint(equalTo: boardView.leadingAnchor).isActive = true
        regdate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

        regdate.textColor = .gray
        regdate.font = UIFont.systemFont(ofSize: 12)
    }
    
    func configure(with trend: Trend){
        title.text = trend.title
        regdate.text = trend.regdate
    }
    

}
