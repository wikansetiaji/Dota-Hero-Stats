//
//  ViewController.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import UIKit

class HeroesViewController: UIViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var refreshControl = UIRefreshControl()
    var roleCollectionView: UICollectionView?
    var heroCollectionView: UICollectionView?
    var loading = UIActivityIndicatorView()
    var isRefreshing = false
    
    var role = ["Carry", "Support", "Nuker", "Disabler", "Jungler", "Durable", "Escape", "Pusher", "Initiator"]
    var selectedRoles:[String] = []{
        didSet{
            viewModel.filterHeroes(role: selectedRoles, query: searchQuery)
            heroCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        }
    }
    var searchQuery: String = ""{
        didSet{
            viewModel.filterHeroes(role: selectedRoles, query: searchQuery)
        }
    }
    var heroes: [HeroModel] = []
    
    var viewModel = HeroViewModel()
    
    var loader = ImageLoader.shared
    
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dota Hero Stats"
        view.backgroundColor = UIColor.systemBackground
        
        navigationItem.backButtonTitle = "Home"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Heroes"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let roleCollectionViewLayout = UICollectionViewFlowLayout()
        roleCollectionViewLayout.estimatedItemSize = CGSize(width: 50, height: 32)
        roleCollectionViewLayout.scrollDirection = .horizontal
        
        roleCollectionView = UICollectionView(frame: .null, collectionViewLayout: roleCollectionViewLayout)
        roleCollectionView?.backgroundColor = UIColor.systemBackground
        roleCollectionView?.delegate = self
        roleCollectionView?.dataSource = self
        roleCollectionView?.register(RoleCollectionViewCell.self, forCellWithReuseIdentifier: "role-cell")
        roleCollectionView?.showsHorizontalScrollIndicator = false
        roleCollectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        roleCollectionView?.allowsMultipleSelection = true
        view.addSubview(roleCollectionView!)
        
        let heroCollectionViewLayout = UICollectionViewFlowLayout()
        heroCollectionViewLayout.itemSize = CGSize(width: 180, height: 180)
        heroCollectionViewLayout.scrollDirection = .vertical
        
        heroCollectionView = UICollectionView(frame: .null, collectionViewLayout: heroCollectionViewLayout)
        heroCollectionView?.backgroundColor = UIColor.systemBackground
        heroCollectionView?.delegate = self
        heroCollectionView?.dataSource = self
        heroCollectionView?.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: "hero-cell")
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        heroCollectionView?.addSubview(refreshControl)
        
        view.addSubview(heroCollectionView!)
        
        loading.startAnimating()
        view.addSubview(loading)
        
        setupViewModel()
        
        loadData(isRefresh: false)
        
        setupConstraints()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        isRefreshing = true
        loadData(isRefresh: true)
    }
    
    func setupViewModel(){
        viewModel.displayedHeroesChanged = { (hero) in
            self.toggleDataChange(hero: hero)
        }
        
        viewModel.loadingStateChanged = { (isLoading) in
            self.toggleLoading(isLoading: isLoading)
        }
        
        viewModel.errorChanged = { (error) in
            self.toggleError(error: error)
        }
    }
    
    func loadData(isRefresh: Bool){
        loader.clear()
        viewModel.fetchHeroes(isRefresh: isRefresh)
    }
    
    func toggleLoading(isLoading: Bool){
        DispatchQueue.main.async {
            if isLoading{
                if !self.isRefreshing{
                    self.loading.startAnimating()
                }
            }
            else{
                self.refreshControl.endRefreshing()
                self.loading.stopAnimating()
            }
        }
    }
    
    
    func toggleDataChange(hero: [HeroModel]){
        DispatchQueue.main.async {
            self.heroes = hero
            self.heroCollectionView?.reloadData()
            self.heroCollectionView?.isHidden = false
        }
    }
    
    func toggleError(error: APIDataSource.Error?){
        guard let error = error else{return}
        
        var title = ""
        var message = ""
        
        if error == .noInternet{
            title = "Oops!"
            message = "There is something wrong with the internet connection"
        }
        else{
            title = "Uh ohh"
            message = "No data was fetched from the API"
        }
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: .alert)
            
            if error == .noInternet{
                alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: {
                    action in
                    self.loadData(isRefresh: true)
                    self.navigationController?.popViewController(animated: true)
                }))
            }
            else{
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
                    action in
                    self.navigationController?.popViewController(animated: true)
                }))
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    var collectionView50HeightConstraint: NSLayoutConstraint?
    var collectionView0HeightConstraint: NSLayoutConstraint?
    
    func setupConstraints(){
        guard let roleCollectionView = roleCollectionView else {return}
        roleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        roleCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        roleCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        roleCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        collectionView50HeightConstraint = roleCollectionView.heightAnchor.constraint(equalToConstant: 50)
        collectionView50HeightConstraint?.isActive = true
        
        collectionView0HeightConstraint = roleCollectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionView0HeightConstraint?.isActive = false
        
        guard let heroCollectionView = heroCollectionView else {return}
        heroCollectionView.translatesAutoresizingMaskIntoConstraints = false
        heroCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        heroCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        heroCollectionView.topAnchor.constraint(equalTo: roleCollectionView.bottomAnchor, constant: 5).isActive = true
        heroCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: heroCollectionView.centerYAnchor).isActive = true
    }
    
}

extension HeroesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchQuery = searchController.searchBar.text!
    }
}

extension HeroesViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == roleCollectionView{
            return role.count + 1
        }
        else{
            return heroes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView ==  roleCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "role-cell", for: indexPath)
            
            if let cell = cell as? RoleCollectionViewCell{
                if indexPath.row == 0{
                    cell.role = "All"
                }
                else{
                    cell.role = role[indexPath.row - 1]
                }
            }
            
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hero-cell", for: indexPath)
            
            if let cell = cell as? HeroCollectionViewCell{
                cell.viewController = self
                cell.hero = heroes[indexPath.row]
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == roleCollectionView{
            if indexPath.row == 0{
                selectedRoles = []
                return
            }
            selectedRoles.append(role[indexPath.row-1])
        }
        else{
            if let _ = collectionView.cellForItem(at: indexPath) as? HeroCollectionViewCell{
                let heroDetail = HeroDetailViewController()
                heroDetail.hero = heroes[indexPath.row]
                heroDetail.viewModel = viewModel
                navigationController?.pushViewController(heroDetail, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == roleCollectionView{
            if indexPath.row != 0{
                collectionView.deselectItem(at: IndexPath(row: 0, section: 0), animated: true)
            }
            else{
                if let selected = collectionView.indexPathsForSelectedItems{
                    for a in selected{
                        collectionView.deselectItem(at: a, animated: true)
                    }
                }
            }
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            return
        }
        selectedRoles.removeAll { (string) -> Bool in
            return string == role[indexPath.row-1]
        }
        if selectedRoles.count == 0 {
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        }
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((self.lastContentOffset > scrollView.contentOffset.y || scrollView.contentOffset.y <= 0) && scrollView.contentOffset.y + scrollView.frame.height < scrollView.contentSize.height) {
            roleCollectionView?.isHidden = false
            collectionView0HeightConstraint?.isActive = false
            collectionView50HeightConstraint?.isActive = true
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            roleCollectionView?.isHidden = true
            collectionView50HeightConstraint?.isActive = false
            collectionView0HeightConstraint?.isActive = true
        }

        self.lastContentOffset = scrollView.contentOffset.y
    }
}

