//
//  ViewController.swift
//  AppleLogin
//
//  Created by suhengxian on 2022/1/11.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect.init(x: 100, y: 100, width: 100, height: 100)
        btn.setTitle("login", for: .normal)
        btn.addTarget(self, action: #selector(AppleLogin), for: .touchUpInside)
        btn.backgroundColor = UIColor.red
        self.view.addSubview(btn)
        
    }
    
    //苹果登录
    @objc func AppleLogin(){
        if #available(iOS 13, *){
            GMAppleLoginTool.instance.show(success: { (user, token) in
                NSLog(user)
                
                let params = ["type":"APPLE","accessToken":token]
                
                //上传到服务器
                //self.thirdLogin(params: params)
                
            }) { (error) in
                print("登录失败,请稍后重试")

            }
        }
    }
    
    //谷歌登录
    func googleLogin(){
        
        let signInConfig = GIDConfiguration.init(clientID:"")
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
        
            if error != nil{
                print("登录失败，请稍后重试")
                
            }else{
                let authentication:GIDAuthentication = user!.authentication
                let accessToken = authentication.idToken;
                
                print("accessToken:\(accessToken)")
                let params = ["type":"GOOGLE","accessToken":accessToken]
//                self.thirdLogin(params: params as [String : Any])
            }
        }
    }
    
    // facebook 登录
    func facebookLogin(){
        let login = LoginManager.init()
        login.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
        
            print("result:\(result)")
            print("error:\(error)")
            
            if result?.isCancelled == true{
                return
            }
            
            if error != nil{
              print("登录失败,请稍后重试")
            }else{
                let token = result?.token
                let authToken = result?.authenticationToken
                        
                print("token == \(token)")
                print("authToken == \(authToken)")
                    
                let params = ["type":"FACEBOOK","accessToken":token?.tokenString]
//                self.thirdLogin(params: params as [String : Any])
            }
        }
    }
}

