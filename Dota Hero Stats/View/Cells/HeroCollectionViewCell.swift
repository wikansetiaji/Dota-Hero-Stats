//
//  HeroCollectionViewCell.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import UIKit

class HeroCollectionViewCell: UICollectionViewCell {
    let nameLabel = UILabel()
    let imageView = UIImageView()
    var dataTask: URLSessionDataTask?
    
    weak var viewController: UIViewController?
    
    let loader = ImageLoader.shared
    var token: UUID?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let token = token {
            self.loader.cancelLoad(token)
        }
        imageView.image = UIImage(named: "placeholder")
    }
    
    
    var hero: HeroModel?{
        didSet{
            guard let hero = hero else {return}
            nameLabel.text = hero.name
            
            token = loader.loadImage(URL(string: "https://api.opendota.com\(hero.imageUrl)")!) { result in
                do {
                    let image = try result.get()
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.image = UIImage(named: "placeholder")	
        contentView.addSubview(imageView)
        
        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = 20
        contentView.addSubview(nameLabel)
        
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        setupConstraints()
        
    }
    
    func setupConstraints(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
