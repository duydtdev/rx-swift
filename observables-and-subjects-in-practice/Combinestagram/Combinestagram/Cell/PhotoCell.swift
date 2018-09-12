//
//  PhotoCell.swift
//  Combinestagram
//
//  Created by Duy Doan on 11/16/17.
//  Copyright © 2017 Agility. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  var representedAssetIdentifier: String!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }
  
  func flash() {
    imageView.alpha = 0
    setNeedsDisplay()
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
      self?.imageView.alpha = 1
    })
  }
}
