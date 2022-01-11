//
//  GMAppleLoginTool.swift
//  wristband
//
//  Created by suhengxian on 2021/11/2.
//

import UIKit
import Foundation
import AuthenticationServices

typealias GMAppleLoginToolSuccessClosures = (_ user:String,_ token:String) -> Void
typealias GMAppleLoginToolFailureClosures = (_ error:BaseError) -> Void

@available(iOS 13,*)
class GMAppleLoginTool: NSObject {
    static let instance = GMAppleLoginTool()
    
    private override init(){
        
    }
    
    override func copy() -> Any {
        return GMAppleLoginTool.instance
    }
    
    override func mutableCopy() -> Any {
        return GMAppleLoginTool.instance
    }
    
    public func reset(){
        
    }
    
    private weak var parentController:UIViewController?
    
    private var successComplete:GMAppleLoginToolSuccessClosures?
    private var failuerComplete:GMAppleLoginToolFailureClosures?
    
    public func isPast() -> Void {
        let provider = ASAuthorizationAppleIDProvider.init()
        provider.getCredentialState(forUserID: "") { status, error in
            
            switch status{
            case .revoked:do{ //已撤销
                
            }
            case.authorized:do{ //已授权
                
            }
            case .notFound:do{//未发现
                
            }
            case .transferred:do{//已转移
                
            }
            @unknown default:
                break
            }
        }
    }
    
    public func show(success:GMAppleLoginToolSuccessClosures? = nil,failure:GMAppleLoginToolFailureClosures? = nil){
        
        self.successComplete = success
        self.failuerComplete = failure
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        let controller = ASAuthorizationController.init(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
    }
}

@available(iOS 13,*)
extension GMAppleLoginTool:ASAuthorizationControllerPresentationContextProviding{
 
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return UIApplication.shared.keyWindow!
        
    }
}

@available(iOS 13,*)
extension GMAppleLoginTool:ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        var baseError = BaseError.init()
        baseError.code = Int.init(error._code)
        
        switch baseError.code{
        case ASAuthorizationError.Code.canceled.rawValue:
            baseError.msg = "取消授权"
        case ASAuthorizationError.Code.failed.rawValue:
            baseError.msg = "授权请求失败"
        case ASAuthorizationError.Code.invalidResponse.rawValue:
            baseError.msg = "授权请求响应无效"
        case ASAuthorizationError.Code.notHandled.rawValue:
            baseError.msg = "未能处理授权请求"
        default:
            baseError.msg = "授权失败"
        }
        self.failuerComplete?(baseError)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if authorization.credential is ASAuthorizationAppleIDCredential{
            let credential = authorization.credential as! ASAuthorizationAppleIDCredential
            let user = credential.user
            guard let identityToken = credential.identityToken else{
                self.failuerComplete?(BaseError.init(code: 0, msg: "identityToken为空"))
                return
            }
            guard let token = String.init(data: identityToken, encoding: .utf8) else{
                self.failuerComplete?(BaseError.init(code: 0, msg: "identityToken为空"))
                return
            }
            self.successComplete?(user,token)
            
        }else if authorization.credential is ASPasswordCredential{ // 使用现有的iCloud密钥链凭证登录。
            let baseError = BaseError.init(code: 0, msg: "授权失败")
            self.failuerComplete?(baseError)
            
        }else{
            let baserError = BaseError.init(code: 0, msg: "授权失败")
            self.failuerComplete?(baserError)
            
        }
        
    }
    
}

struct BaseError{
    var code:Int?
    var msg:String?
    
    init(code:Int,msg:String){
        self.code = code
        self.msg = msg
    }
    
    init(){}
}

