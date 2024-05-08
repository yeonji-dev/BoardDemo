//
//  BoardViewController.swift
//  BoardDemo
//
//  Created by YeonJi Noh on 2024/05/07.
//

import UIKit

class BoardViewController: UIViewController {
    
    var tableView = UITableView()
    var list: [Trend] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        post()
    }
    
    func setUpTableView(){
        setTableViewDelegate()
        tableView.rowHeight = 70
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.topAnchor),
           tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    func setTableViewDelegate(){
        tableView.delegate = self
        tableView.dataSource = self
    }

    func post() {
            var components = URLComponents(string: "https://krem.nremc.re.kr")
            //아까 복사해둔 서버 주소
            components?.path = "/REST/ADMIN0012"
            
            guard let url = components?.url else { return }
            
            var request: URLRequest = URLRequest(url: url)
            
            request.httpMethod = "POST"
            //헤더 지정
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //타임아웃 시간 지정. (5초 이상 걸리면 중지)
            request.timeoutInterval = 5
//            //Codable 모델 생성
//            let bodyModel = User(name: "Gons", job: "iOS")
//            //Codable 모델을 JSON 인코딩하여 데이터로 만든 후 http 바디에 추가
//            request.httpBody = try? JSONEncoder().encode(bodyModel)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else{ return }
                let decoder = JSONDecoder()
                // JSON 응답을 Trend 배열로 디코딩
                do {
                    let responseContainer = try decoder.decode(ResponseContainer.self, from: data)
                    DispatchQueue.main.async {
                        // 메인 스레드에서 UI 업데이트 또는 데이터 처리
                        self.list = responseContainer.body
                        self.tableView.reloadData()
                        responseContainer.body.forEach { trend in
                            print("\(trend.bno): \(trend.title) - \(trend.regdate)")
                        }
                    }
                } catch {
                    print("Failed to decode Trend from JSON: \(error)")
                }
            }
            
            task.resume()
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// extension 처리 및 delegate, dataSource 채택
extension BoardViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count  // <- Cell을 보여줄 갯수
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier,
                                                               for: indexPath) as? TableViewCell else {
            return UITableViewCell() // 안전한 셀 생성 실패 시 기본 셀 반환
        }
        let trend = list[indexPath.row]
        cell.configure(with: trend)  // 셀 구성을 위한 메소드 호출
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = BoardDetailViewController()
        // 선택된 트렌드 데이터를 상세 뷰 컨트롤러에 전달
        detailVC.trend = list[indexPath.row]
        
        // 뒤로 가기 버튼 타이틀 없애기
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem

        // 상세 뷰 컨트롤러로 이동
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
