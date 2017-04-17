//
//  RoundButton.swift
//  instagramFirebase
//
//  Created by Vuk on 4/16/17.
//  Copyright © 2017 Vuk. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        imageView?.contentMode = .scaleAspectFit
//        layer.cornerRadius = self.frame.width / 2 //ovo ne moze jer kad se koristi awakeFromNib velicina ekrana jos nije proracunata, tj frame, tako da ne zna koju sirinu da deli na pola, pa ce biti kvadrat i dalje, moze da se postavi layer.cornerRadius = 10
    }
    
    //zato koristim ovu metodu
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
    }

}
