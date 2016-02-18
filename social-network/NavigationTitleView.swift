//
//  NavigationTitleView.swift
//  social-network
//
//  Created by Killian Jackson on 2/18/16.
//  Copyright © 2016 Killian Jackson. All rights reserved.
//

import UIKit

class NavigationTitleView: UIView {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        
        
    }

}
