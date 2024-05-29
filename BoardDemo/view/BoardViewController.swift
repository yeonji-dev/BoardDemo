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
        //tableView의 두가지 주요 프로토콜: UITableViewDelegate, UITableViewDatasource 구현 및 설정 -> 현재 클래스에서 구현
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 70
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        view.addSubview(tableView)
        //Auto layout 관련 -> 직접 지정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           tableView.topAnchor.constraint(equalTo: view.topAnchor),
           tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
           tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }

    func post() {
        guard let apiUrl = Bundle.main.object(forInfoDictionaryKey: "REST_API_URL") as? String else { return }
            var components = URLComponents(string: "https://" + apiUrl)
            components?.path = "/REST/ADMIN0012"
            
            guard let url = components?.url else { return }
            
            var request: URLRequest = URLRequest(url: url)
            
            request.httpMethod = "POST"
            //헤더 지정
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            //타임아웃 시간 지정. (5초 이상 걸리면 중지)
            request.timeoutInterval = 5
//            //Codable 모델 생성 -> 일단 지금은 parameter 없음
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

    //UITableViewDataSource 프로토콜의 필수 메서드: 행의 수 리턴
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    // UITableViewDataSource 프로토콜 필수 메서드: 각 행의 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier,
                                                               for: indexPath) as? TableViewCell else {
            return UITableViewCell() // 안전한 셀 생성 실패 시 기본 셀 반환
        }
        let trend = list[indexPath.row]
        cell.configure(with: trend)  // 셀 구성을 위한 메소드 호출
        return cell
    }
    
    // UITableViewDelegate 프로토콜 선택적 메서드: 셀 선택 시 동작
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = BoardDetailViewController()
        // 선택된 데이터를 상세 뷰 컨트롤러에 전달 (글번호 등)
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
