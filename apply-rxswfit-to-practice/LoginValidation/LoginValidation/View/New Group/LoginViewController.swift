//
//  LoginViewController.swift
//  LoginValidation
//
//  Created by Duy Doan on 12/5/17.
//  Copyright © 2017 Agility. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class LoginViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var messageLabel: UILabel!
  
  let bag = DisposeBag()
  
  var loginViewModel = LoginViewModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    emailTextField.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.emailText).disposed(by: bag)
    passwordTextField.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.passwordText).disposed(by: bag)
    
    loginViewModel.isValid.bind(to: loginButton.rx.isEnabled).disposed(by: bag)
    
    loginViewModel.isValid.subscribe(onNext: { [unowned self] isValid in
      self.messageLabel.text = isValid ? "Enable" : "Disable"
      self.messageLabel.textColor = isValid ? .green : .red
    }).disposed(by: bag)
    
    }
}
