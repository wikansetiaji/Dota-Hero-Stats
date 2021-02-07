//
//  RoleCollectionViewCell.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import UIKit

class RoleCollectionViewCell: UICollectionViewCell {
    let roleLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) : .darkGray
        }
    }
    
    var role: String?{
        didSet{
            guard let role = role else {return}
            roleLabel.text = role
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .darkGray
        contentView.layer.cornerRadius = 10
        
        roleLabel.textColor = UIColor.white
        contentView.addSubview(roleLabel)

        
        setupConstraints()
    }
    
    func setupConstraints(){
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        roleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        roleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
                
        contentView.widthAnchor.constraint(equalTo: roleLabel.widthAnchor, constant: 25).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
