//
//  BoardDetailViewController.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/08.
//

import UIKit
import Alamofire
import WebKit

class BoardDetailViewController:UIViewController, WKNavigationDelegate{

    var trend: Trend?

    private let headerView = UIView()
    private let contentView = UIView()
    private var webView: WKWebView!

    private let titleLabel = UILabel()
    private let regdateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "잔망루피"
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .black
        self.navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.white]
        view.backgroundColor = .white

        initializeUI()
        fetchDetailByBno()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let border = CALayer()
        border.backgroundColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: headerView.frame.height - 1, width: headerView.frame.width, height: 1)
        headerView.layer.addSublayer(border)
    }

    private func initializeUI(){

        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0 // 여러 줄 표시
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)

        regdateLabel.translatesAutoresizingMaskIntoConstraints = false
        regdateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        regdateLabel.textColor = .gray

        view.addSubview(headerView)
        view.addSubview(contentView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(regdateLabel)
        contentView.addSubview(webView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 54),

            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),

            regdateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            regdateLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            regdateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),

            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            webView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }


    private func fetchDetailByBno(){
        guard let bno = trend?.bno else {
            print("Board number is nil")
            return
        }

        let param: Parameters = ["bno": bno]

        let req = AF.request("https://krem.nremc.re.kr/REST/ADMIN0011", method: .post, parameters: param, encoding: JSONEncoding.default)
        req.responseDecodable(of: TrendContainer.self) { response in
            switch response.result {
            case .success(let container):
                self.handleSuccessRes(container)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }

    private func handleSuccessRes(_ container: TrendContainer){
        self.trend = container.body
        titleLabel.text = trend?.title
        regdateLabel.text = trend?.regdate
        if let htmlContent = trend?.content{
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }

    private func handleError(_ error: Error){
        print("Error:", error)
        let alert = UIAlertController(title: "Error", message: "데이터를 가져오는 도중 오류가 발생했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true) // Alert 닫힌 후 뒤로 이동
        })
        present(alert, animated: true)
    }

    // WKNavigationDelegate 메서드 구현 -> 안됨...
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if navigationAction.navigationType == .linkActivated {
                // 외부 브라우저나 앱에서 링크 열기 (Safari 등)
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                // 기본적인 웹뷰 내 탐색 허용
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
