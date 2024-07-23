//
//  ViewController.swift
//  asakusa
//
//  Created by 黃翊唐 on 2024/7/22.
//
import UIKit

struct Result: Codable {
    let wish: String
    let illness: String
    let hopePerson: String
    let lostItem: String
    let newHouse: String
    let moving: String
    let marriage: String
    let travel: String
    let relationship: String
    
    enum CodingKeys: String, CodingKey {
        case wish = "願望"
        case illness = "疾病"
        case hopePerson = "盼望的人"
        case lostItem = "遺失物"
        case newHouse = "蓋新居"
        case moving = "搬家"
        case marriage = "嫁娶"
        case travel = "旅行"
        case relationship = "交往"
    }
}
class Poem: Codable {
    let id: String
    let type: String
    let poem: String
    let explain: String
    let result: [String: String]
    let note: String

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case poem
        case explain
        case result
        case note
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var circularButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var poemLabel: UILabel!
    let originalImage = UIImage(named: "page")
    let newImage = UIImage(named: "door")
    var poem: Poem?
    var resultEntries: [String: String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        makeButtonCircular()
        customizeButton()
        tableView.isHidden = true
        tableView.dataSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(resetState))
    }
    @objc func resetState() {
        imageView.image = originalImage
        circularButton.isHidden = false
        tableView.isHidden = true
        imageView.alpha = 1.0
        idLabel.text = ""
        typeLabel.text = ""
        poemLabel.text = ""
        tableView.reloadData()
    }
    func makeButtonCircular() {
        let minDimension = min(circularButton.frame.width, circularButton.frame.height)
        circularButton.layer.cornerRadius = minDimension / 2
        circularButton.layer.masksToBounds = true
    }
    func customizeButton() {
        circularButton.setTitleColor(.white, for: .normal)
        circularButton.setTitleColor(.gray, for: .highlighted)
        circularButton.backgroundColor = .black
        circularButton.alpha = 0.6
    }
    
    func fetchPoems(randomNumber: Int) {
        
        guard let url = URL(string: "https://script.google.com/macros/s/AKfycbz_7GMhrxE0fzbiKDgkTtFPh0KiniMTZUz-Iepp0VeoMBTvp6EpmSmB-SYywLJPWfvbjQ/exec?number=\(randomNumber)") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(Poem.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.poem = decodedData
                    self.resultEntries = decodedData.result
                    self.tableView.reloadData()
                    self.idLabel.text = decodedData.id
                    self.typeLabel.text = decodedData.type
                    self.poemLabel.text = decodedData.poem.replacingOccurrences(of: "，", with: "")
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultEntries.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 16
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        let key = Array(resultEntries.keys)[indexPath.row]
        let value = resultEntries[key]
        
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        
        cell.textLabel?.textAlignment = .left
        cell.detailTextLabel?.textAlignment = .right
        
        return cell
    }
    
    @IBAction func drawButtonTapped(_ sender: UIButton) {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        
        UIView.transition(with: self.view, duration: 3, options: [.transitionCrossDissolve], animations: {
            self.imageView.image = self.newImage
            self.circularButton.isHidden = true
            self.imageView.alpha = 0.6
            self.tableView.isHidden = false
            print(Int.random(in: 1...100))
            self.fetchPoems(randomNumber: Int.random(in: 1...100))
            
        }, completion: { _ in
            UIView.animate(withDuration: 1, animations: {
                blurEffectView.alpha = 0
            }) { _ in
                blurEffectView.removeFromSuperview()
            }
        })
    }
}
