//
//  HeroDetailViewController.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 05/02/21.
//

import UIKit

class HeroDetailViewController: UIViewController {
    
    var hero: HeroModel?
    var role:[String] = ["Carry", "Tank", "Jungler"]
    var heroes: [HeroModel] = []
    var viewModel: HeroViewModel?
    
    let scrollView = UIScrollView()
    
    let imageView = UIImageView()
    
    let statContainerView = UIView()
    let agiLabel = UILabel()
    let strLabel = UILabel()
    let intLabel = UILabel()
    
    let attrContainerView = UIView()
    let healthLabel = UILabel()
    let attackLabel = UILabel()
    let speedLabel = UILabel()
    
    let roleLabel = UILabel()
    var roleCollectionView: UICollectionView?
    
    let similarHeroesLabel = UILabel()
    var heroCollectionView: UICollectionView?
    
    let typeLabel = UILabel()
    let typeContainerView =  UIView()
    
    var loader = ImageLoader.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        view.backgroundColor = UIColor.secondarySystemBackground
        navigationItem.backButtonTitle = "Back"
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.image = UIImage(named: "placeholder")
        
        statContainerView.backgroundColor = .darkGray
        statContainerView.layer.cornerRadius = 10
        agiLabel.textColor = .white
        strLabel.textColor = .white
        intLabel.textColor = .white
        
        attrContainerView.backgroundColor = .darkGray
        attrContainerView.layer.cornerRadius = 10
        healthLabel.textColor = .white
        attackLabel.textColor = .white
        speedLabel.textColor = .white
        
        roleLabel.text = "Roles:"
        roleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        let roleCollectionViewLayout = UICollectionViewFlowLayout()
        roleCollectionViewLayout.estimatedItemSize = CGSize(width: 50, height: 32)
        roleCollectionViewLayout.scrollDirection = .horizontal
        
        roleCollectionView = UICollectionView(frame: .null, collectionViewLayout: roleCollectionViewLayout)
        roleCollectionView?.backgroundColor = UIColor.secondarySystemBackground
        roleCollectionView?.delegate = self
        roleCollectionView?.dataSource = self
        roleCollectionView?.register(RoleCollectionViewCell.self, forCellWithReuseIdentifier: "role-cell")
        roleCollectionView?.showsHorizontalScrollIndicator = false
        roleCollectionView?.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
        roleCollectionView?.allowsSelection = false
        
        similarHeroesLabel.text = "Similiar Heroes:"
        similarHeroesLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        let heroCollectionViewLayout = UICollectionViewFlowLayout()
        heroCollectionViewLayout.itemSize = CGSize(width: 140, height: 140)
        heroCollectionViewLayout.scrollDirection = .horizontal
        
        heroCollectionView = UICollectionView(frame: .null, collectionViewLayout: heroCollectionViewLayout)
        heroCollectionView?.backgroundColor = UIColor.secondarySystemBackground
        heroCollectionView?.delegate = self
        heroCollectionView?.dataSource = self
        heroCollectionView?.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: "hero-cell")
        
        typeContainerView.backgroundColor = .darkGray
        typeContainerView.layer.cornerRadius = 10
        typeLabel.textColor = UIColor.white
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        
        scrollView.addSubview(statContainerView)
        statContainerView.addSubview(agiLabel)
        statContainerView.addSubview(strLabel)
        statContainerView.addSubview(intLabel)
        
        scrollView.addSubview(attrContainerView)
        attrContainerView.addSubview(healthLabel)
        attrContainerView.addSubview(attackLabel)
        attrContainerView.addSubview(speedLabel)
        
        scrollView.addSubview(roleLabel)
        scrollView.addSubview(roleCollectionView!)
        
        scrollView.addSubview(similarHeroesLabel)
        scrollView.addSubview(heroCollectionView!)
        
        scrollView.addSubview(typeContainerView)
        typeContainerView.addSubview(typeLabel)
        
        setupConstraints()
    }
    
    func setupData(){
        guard let hero = hero else {return}
        
        if let viewModel = viewModel{
            heroes = viewModel.getSimiliarHeroes(hero: hero)
        }
        
        title = hero.name
        
        agiLabel.text = "AGI: \(hero.agi)"
        strLabel.text = "STR: \(hero.str)"
        intLabel.text = "INT: \(hero.int)"
        
        let _ = loader.loadImage(URL(string: "https://api.opendota.com\(hero.imageUrl)")!) { result in
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } catch {
                print(error)
            }
        }
        
        healthLabel.text = "Health: \(hero.health)"
        attackLabel.text = "Attack: \(hero.maxAttack)"
        speedLabel.text = "Speed: \(hero.speed)"
        
        typeLabel.text = hero.type.capitalized
    }
    
    func setupConstraints(){
        //scrollView constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        //scrollView content constraints
        scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.contentLayoutGuide.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.contentLayoutGuide.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: heroCollectionView!.bottomAnchor).isActive = true
        
        //imageView constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        //stat constraints
        statContainerView.translatesAutoresizingMaskIntoConstraints = false
        statContainerView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20).isActive = true
        statContainerView.rightAnchor.constraint(lessThanOrEqualTo: attrContainerView.leftAnchor, constant: -20).isActive = true
        statContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        statContainerView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 0).isActive = true
        statContainerView.bottomAnchor.constraint(equalTo: typeContainerView.bottomAnchor).isActive = true
        
        //agi, str, int constraints
        agiLabel.translatesAutoresizingMaskIntoConstraints = false
        agiLabel.topAnchor.constraint(equalTo: statContainerView.topAnchor, constant: 20).isActive = true
        agiLabel.leftAnchor.constraint(equalTo: statContainerView.leftAnchor, constant: 10).isActive = true
        agiLabel.rightAnchor.constraint(equalTo: statContainerView.rightAnchor, constant: -10).isActive = true
        strLabel.translatesAutoresizingMaskIntoConstraints = false
        strLabel.leftAnchor.constraint(equalTo: agiLabel.leftAnchor).isActive = true
        strLabel.rightAnchor.constraint(equalTo: agiLabel.rightAnchor).isActive = true
        strLabel.centerYAnchor.constraint(equalTo: statContainerView.centerYAnchor).isActive = true
        intLabel.translatesAutoresizingMaskIntoConstraints = false
        intLabel.leftAnchor.constraint(equalTo: agiLabel.leftAnchor).isActive = true
        intLabel.rightAnchor.constraint(equalTo: agiLabel.rightAnchor).isActive = true
        intLabel.bottomAnchor.constraint(equalTo: statContainerView.bottomAnchor, constant: -20).isActive = true
        
        //attr constraints
        attrContainerView.translatesAutoresizingMaskIntoConstraints = false
        attrContainerView.leftAnchor.constraint(equalTo: statContainerView.rightAnchor, constant: 20).isActive = true
        attrContainerView.rightAnchor.constraint(lessThanOrEqualTo: scrollView.contentLayoutGuide.rightAnchor, constant: -20).isActive = true
        attrContainerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20).isActive = true
        attrContainerView.bottomAnchor.constraint(equalTo: typeContainerView.bottomAnchor).isActive = true
        
        //health, attack, speed constraints
        healthLabel.translatesAutoresizingMaskIntoConstraints = false
        healthLabel.topAnchor.constraint(equalTo: attrContainerView.topAnchor, constant: 20).isActive = true
        healthLabel.leftAnchor.constraint(equalTo: attrContainerView.leftAnchor, constant: 10).isActive = true
        healthLabel.rightAnchor.constraint(equalTo: attrContainerView.rightAnchor, constant: -10).isActive = true
        attackLabel.translatesAutoresizingMaskIntoConstraints = false
        attackLabel.leftAnchor.constraint(equalTo: healthLabel.leftAnchor).isActive = true
        attackLabel.rightAnchor.constraint(equalTo: healthLabel.rightAnchor).isActive = true
        attackLabel.centerYAnchor.constraint(equalTo: attrContainerView.centerYAnchor).isActive = true
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.leftAnchor.constraint(equalTo: healthLabel.leftAnchor).isActive = true
        speedLabel.rightAnchor.constraint(equalTo: healthLabel.rightAnchor).isActive = true
        speedLabel.bottomAnchor.constraint(equalTo: attrContainerView.bottomAnchor, constant: -20).isActive = true
        
        //role label constraints
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 20).isActive = true
        roleLabel.topAnchor.constraint(equalTo: typeContainerView.bottomAnchor, constant: 20).isActive = true
        
        //role collection constraints
        roleCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        roleCollectionView?.leftAnchor.constraint(equalTo: roleLabel.leftAnchor).isActive = true
        roleCollectionView?.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -20).isActive = true
        roleCollectionView?.topAnchor.constraint(equalTo: roleLabel.bottomAnchor).isActive = true
        roleCollectionView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //hero label constraints
        similarHeroesLabel.translatesAutoresizingMaskIntoConstraints = false
        similarHeroesLabel.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 20).isActive = true
        similarHeroesLabel.topAnchor.constraint(equalTo: roleCollectionView!.bottomAnchor, constant: 20).isActive = true
        
        //hero collection constraints
        heroCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        heroCollectionView?.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor, constant: 20).isActive = true
        heroCollectionView?.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor, constant: -20).isActive = true
        heroCollectionView?.topAnchor.constraint(equalTo: similarHeroesLabel.bottomAnchor, constant: 0).isActive = true
        heroCollectionView?.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        //type label constraints
        typeContainerView.translatesAutoresizingMaskIntoConstraints = false
        typeContainerView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        typeContainerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        typeContainerView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        typeContainerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.centerYAnchor.constraint(equalTo: typeContainerView.centerYAnchor).isActive = true
        typeLabel.centerXAnchor.constraint(equalTo: typeContainerView.centerXAnchor).isActive = true
    }
}

extension HeroDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == roleCollectionView{
            return role.count
        }
        else{
            return heroes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == roleCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "role-cell", for: indexPath)
            
            if let cell = cell as? RoleCollectionViewCell{
                cell.role = role[indexPath.row]
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
        if let _ = collectionView.cellForItem(at: indexPath) as? HeroCollectionViewCell{
            let heroDetail = HeroDetailViewController()
            heroDetail.hero = heroes[indexPath.row]
            heroDetail.viewModel = viewModel
            navigationController?.pushViewController(heroDetail, animated: true)
        }
    }
    
}
