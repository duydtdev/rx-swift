//
//  MainViewController.swift
//  Combinestagram
//
//  Created by Duy Doan on 11/16/17.
//  Copyright © 2017 Agility. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {
  
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  
  private let bag = DisposeBag()
  private let images = Variable<[UIImage]>([])
  private var imageCache = [Int]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
      images.asObservable()
      .throttle(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] photos in
        guard let preview = self?.imagePreview else { return }
        preview.image = UIImage.collage(images: photos,
                                        size: preview.frame.size)
      })
      .disposed(by: bag)
    
    /// Subscribe an Variable subjects type to add image to UIImage
    images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        guard let preview = self?.imagePreview else { return }
        preview.image = UIImage.collage(images: photos,
                                        size: preview.frame.size)
      })
      .disposed(by: bag)
    
    /// Subscribe an Variable subjects type to update UI
    images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        self?.updateUI(photos: photos)
      })
      .disposed(by: bag)
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  private func updateNavigationIcon() {
    let icon = imagePreview.image?
      .scaled(CGSize(width: 22, height: 22))
      .withRenderingMode(.alwaysOriginal)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                       style: .done, target: nil, action: nil)
  }
  
  @IBAction func actionAdd(_ sender: Any) {
    let photosViewController = storyboard!.instantiateViewController(
      withIdentifier: "PhotosViewController") as! PhotosViewController
    
     let newPhotos = photosViewController.selectedPhotos.share()
    
     /// This is to listen add photo from photo view controller
      newPhotos.takeWhile { [weak self] image in
        return (self?.images.value.count ?? 0) < 6
      }.filter { newImage in
        return newImage.size.width > newImage.size.height
      }.filter { [weak self] newImage in
        let len = UIImagePNGRepresentation(newImage)?.count ?? 0
        guard self?.imageCache.contains(len) == false else {
          return false
        }
        self?.imageCache.append(len)
        return true
      }.subscribe(onNext: { [weak self] newImage in
        guard let images = self?.images else { return }
        images.value.append(newImage)
        }, onDisposed: {
          print("Completed photo selection")
      })
      .disposed(by: photosViewController.bag)
    
     newPhotos
      .ignoreElements()
      .subscribe(onCompleted: { [weak self] in
        self?.updateNavigationIcon()
      }).disposed(by: photosViewController.bag)
    
    navigationController!.pushViewController(photosViewController, animated:
      true)
   
  }
  
  @IBAction func actionSave(_ sender: Any) {
    /// When click on save button
    guard let image = imagePreview.image else { return }
    PhotoWriter.save(image)
      .subscribe(onError: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      }, onCompleted: { [weak self] in
        self?.showMessage("Saved")
        self?.actionClear("")
      })
      .disposed(by: bag)
  }
  @IBAction func actionClear(_ sender: Any) {
    images.value = []
    imageCache = []
  }
  
  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
}
