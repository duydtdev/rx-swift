//
//  LoginViewModel.swift
//  LoginValidation
//
//  Created by Duy Doan on 12/6/17.
//  Copyright © 2017 Agility. All rights reserved.
//

import Foundation
import RxSwift

struct LoginViewModel {
  var emailText = Variable<String>("")
  var passwordText = Variable<String>("")
  
  var isValid: Observable<Bool> {
    return Observable.combineLatest(emailText.asObservable(), passwordText.asObservable()) { email, password in
      email.count >= 3 && password.count > 3
    }
  }
}
