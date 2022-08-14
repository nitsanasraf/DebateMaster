//
//  TabBarViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 14/08/2022.
//

import UIKit

class TabBarViewController: UITabBarController {
    struct Screen {
        let viewController: UIViewController
        let icon: String
        let navBarTitle: String
    }
    
    
    private let networkManager = NetworkManger()
    
    private let screens = [
        Screen(viewController: CategoriesViewController(), icon: "house", navBarTitle: "All Categories"),
        Screen(viewController: ProfileViewController(), icon: "person", navBarTitle: "Profile"),
    ]
    
    @objc private func logout() {
        guard let url = URL(string: "\(networkManager.usersURL)/\(Constants.Network.EndPoints.logout)") else {return}
        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
            if let error = error {
                print("Error fetching: \(error)")
            } else {
                KeyChain.shared.deleteAll()
                UserModel.shared.resetUser()
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CategoriesTableViewController.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        var tabVCS = [UINavigationController]()
        
        
        for (i,screen) in screens.enumerated() {
            let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .large)
            
            screen.viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape",withConfiguration: config), style: .done, target: self, action: nil)
            screen.viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(logout))
            
            screen.viewController.title = screen.navBarTitle
            let navVC = UINavigationController(rootViewController: screen.viewController)
            navVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: screen.icon), tag: i+1)
            tabVCS.append(navVC)
        }
        
        setViewControllers(tabVCS, animated: false)
        
        tabBar.tintColor = .label
    }
    
}

extension TabBarViewController: CategoriesTableVcDelegate {
    func pushRoom(viewController vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}