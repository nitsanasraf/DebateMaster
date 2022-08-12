//
//  LoadingViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 16/07/2022.
//

import UIKit

class LoadingViewController: UIViewController {
    
    private var networkManager = NetworkManger()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.alignment = .center
        return stackView
    }()
    
    private let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.color = .white
        indicator.startAnimating()
        return indicator
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Looking for an available room"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let timeAssessmentLabel: UILabel = {
        let label = UILabel()
        label.text = "(No more than 2 minutes)"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        config.title = "Cancel"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "xmark",withConfiguration: imgConfig)
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .white
        config.imagePadding = 5
        config.imagePlacement = .trailing
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        return btn
    }()
    
    @objc private func cancelSearch() {
        navigationController?.popViewController(animated: true)
    }
    
    private func findEmptyRoom() {
        guard let category = categoryLabel.text?.makeURLSafe() else {return}
        guard let userUID = UserModel.shared.uid else {return}
        
        networkManager.fetchData(type: RoomModel.self, url: "\(networkManager.roomsURL)/\(category)") { [weak self] room in
            guard let self = self else {return}
            
            let url = "\(self.networkManager.rtcURL)/\(KeyCenter.appID)/\(KeyCenter.appCertificate)/\(room.name)/\(userUID)"
            guard let url = URL(string: url) else {return}
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error fetching: \(error)")
                } else {
                    guard let data = data else {return}
                    guard let token = String(data: data, encoding: .utf8) else {return}
                    print(token)
                    UserModel.shared.agoraToken = token
                    DispatchQueue.main.async {
                        RoomModel.moveToRoom(room: room, fromViewController: self, withTitle: self.categoryLabel.text)
                    }
                }
            }
            task.resume()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSkeleton()
        addViews()
        addLayouts()
        findEmptyRoom()
    }
    
    private func configureSkeleton() {
        view.backgroundColor = Constants.Colors.primary
        self.navigationItem.hidesBackButton = true
    }
    
    private func addViews() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(loadingLabel)
        stackView.addArrangedSubview(timeAssessmentLabel)
        stackView.addArrangedSubview(cancelButton)
    }
    
    private func addLayouts() {
        let stackViewConstraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
}
