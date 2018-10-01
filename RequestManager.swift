

import UIKit

import Alamofire
import MBProgressHUD

typealias SuccessHandler = (_ result:Any) -> Void
typealias FailureHandler = (_ error:Error) -> Void

class RequestManager: NSObject {
    
    class func getAPIWithURLString (urlPart : String,progress:Bool,successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        let finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        if progress == true
        {
            MBProgressHUD.showAdded(to:((appDelegate?.window)!)!, animated: progress)
        }
        
        print("\n\nfinal URL For Get is \(finalUrl) \n\n")
        Alamofire.request(finalUrl).responseJSON { (response) in
            MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: progress)
            print("\n\n RESPONSE IS \n \(response)")
            if response.result.isSuccess{
                successResult(response.result.value!)
            }else{
                failureResult(response.result.error!)
            }
        }
    }
    
    class func postAPIDATA (urlPart:String,progress:Bool,parameters:Dictionary<String,Any>,successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        let finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        if progress == true
        {
            MBProgressHUD.showAdded(to:((appDelegate?.window)!)!, animated: true)
        }
        print("\n\nfinal URL For POST is \(finalUrl) \n AND Parameters are \n\(parameters)\n\n")
        Alamofire.request(finalUrl,method:.post,parameters:parameters).responseData { (response) in
            MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: true)
            print("\n\n RESPONSE IS \n \(response)")
            if response.result.isSuccess{
                successResult(response.result.value!)
            }else{
                failureResult(response.result.error!)
            }
        }
    }
    
    class func postAPI (urlPart:String,progress:Bool,parameters:Dictionary<String,Any>,successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        let finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        if progress == true{
            MBProgressHUD.showAdded(to:((appDelegate?.window)!)!, animated: true)
        }
        print("\n\nfinal URL For POST is \(finalUrl) \n AND Parameters are \n\(parameters)\n\n")
        Alamofire.request(finalUrl,method:.post,parameters:parameters).responseJSON { (response) in
            MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: false)
            print("\n\n RESPONSE IS \n \(response)")
            if response.result.isSuccess{
                successResult(response.result.value!)
            }else{
                failureResult(response.result.error!)
            }
        }
    }
    
    class func postAPIAttachment(view:UIView,progress:Bool,urlPart:String,arrImages:NSArray,arrayAttachmentType:NSArray,parameters:Dictionary<String,Any>,successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        
        var finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        
        finalUrl = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("\n\nfinal URL For POST is \(finalUrl) \n AND Parameters are \n\(parameters)\n\n")
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: progress)
        progressHUD.mode = .annularDeterminate
        progressHUD.label.text = "Uploading"
        let headers: HTTPHeaders = [
            "Content-type": ""
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key,value) in parameters {
                if let data = String(describing: value).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                    multipartFormData.append(data, withName: key)
                }
            }
            
            for i in 0  ..< (arrImages.count){
                if arrayAttachmentType[i] as! String == "images" {
                    if let imgData = ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentImage") as! UIImage).jpeg(.medium) {
                        multipartFormData.append(imgData, withName: "attachment[]", fileName: (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String, mimeType: "image/png")
                        
                    }
                    print(multipartFormData)
                }else if arrayAttachmentType[i] as! String == "video" {
                    let videoUrl = (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentVideoUrl") as! URL
                    do{
                        let videoData = try Data(contentsOf: videoUrl)
                        multipartFormData.append(videoData, withName: "attachment[]", fileName: ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String), mimeType: NSString(format: "video/%@",videoUrl.pathExtension) as String)
                    }catch{
                        
                    }
                }
            }
            
            //            for i in 0..<arrImages.count {
            //                let dict = arrImages[i] as! NSDictionary
            //
            //                let imageData = UIImagePNGRepresentation(dict["Image"] as! UIImage)
            //                if imageData != nil {
            //                    print(dict)
            //                    print(imageData!)
            //                    multipartFormData.append(imageData!, withName: dict["Name"] as! String, fileName: "\(dict["Name"] as! String).png", mimeType: "image/png")
            //                }
            //            }
        }, usingThreshold: UInt64.init(), to: finalUrl, method: .post, headers:headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    progressHUD.progress = Float(progress.fractionCompleted)
                    print(progress)
                })
                upload.responseJSON { response in
                    //print response.result
                    print(response.result.value!)
                    progressHUD.hide(animated: progress)
                    successResult(response.result.value!)
                    //                     MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: true)
                }
            case .failure(let encodingError):
                //print encodingError.description
                print(encodingError)
                failureResult(encodingError)
                MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: progress)
            }
        }
    }
    
    class func postAPIGallaryAttachment(view:UIView,progress:Bool,urlPart:String,arrImages:NSArray,arrayAttachmentType:NSArray,parameters:Dictionary<String,Any>,successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        
        var finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        
        finalUrl = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("\n\nfinal URL For POST is \(finalUrl) \n AND Parameters are \n\(parameters)\n\n")
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: progress)
        progressHUD.mode = .annularDeterminate
        progressHUD.label.text = "Uploading"
        let headers: HTTPHeaders = [
            "Content-type": ""
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key,value) in parameters {
                if let data = String(describing: value).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                    multipartFormData.append(data, withName: key)
                }
            }
            for i in 0  ..< (arrImages.count){
                if arrayAttachmentType[i] as! String == "images" {
                    if let imgData = ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentImage") as! UIImage).jpeg(.medium) {
                        multipartFormData.append(imgData, withName: "image[]", fileName: (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String, mimeType: "image/png")
                    }
                   
                }else if arrayAttachmentType[i] as! String == "video" {
                    let videoUrl = (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentVideoUrl") as! URL
                    do{
                        let videoData = try Data(contentsOf: videoUrl)
                        multipartFormData.append(videoData, withName: "image[]", fileName: ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String), mimeType: NSString(format: "video/%@",videoUrl.pathExtension) as String)
                    }catch{
                        
                    }
                }
            }
            
        }, usingThreshold: UInt64.init(), to: finalUrl, method: .post, headers:headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    progressHUD.progress = Float(progress.fractionCompleted)
                    print(progress)
                })
                
                upload.responseJSON { response in
                    //print response.result
                    print(response.result.value!)
                    progressHUD.hide(animated: progress)
                    successResult(response.result.value!)
                    //                     MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: true)
                }
                
            case .failure(let encodingError):
                //print encodingError.description
                print(encodingError)
                failureResult(encodingError)
                MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: progress)
            }
        }
    }
    
    class func postAPIFileAttachment(view:UIView,progress:Bool,urlPart:String,arrImages:NSArray,arrayAttachmentType:NSArray,parameters:Dictionary<String,Any>,serverKeyName:String = "attachment[]",successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        
        var finalUrl = baseURL + urlPart
        let appDelegate = UIApplication.shared.delegate
        
        finalUrl = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("\n\nfinal URL For POST is \(finalUrl) \n AND Parameters are \n\(parameters)\n\n")
        let progressHUD = MBProgressHUD.showAdded(to: view, animated: progress)
        progressHUD.mode = .annularDeterminate
        progressHUD.label.text = "Uploading"
        let headers: HTTPHeaders = [
            "Content-type": ""
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key,value) in parameters {
                if let data = String(describing: value).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                    multipartFormData.append(data, withName: key)
                }
            }
            
            for i in 0  ..< (arrImages.count){
                if arrayAttachmentType[i] as! String == "images" {
                    if let imgData = ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentImage") as! UIImage).jpeg(.medium) {
                        multipartFormData.append(imgData, withName: serverKeyName, fileName: (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String, mimeType: "image/png")
                    }
                    print(multipartFormData)
                }else if arrayAttachmentType[i] as! String == "video" {
                    let videoUrl = (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentVideoUrl") as! URL
                    do{
                        let videoData = try Data(contentsOf: videoUrl)
                        multipartFormData.append(videoData, withName: serverKeyName, fileName: ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String), mimeType: NSString(format: "video/%@",videoUrl.pathExtension) as String)
                    }catch{
                    }
                }else if arrayAttachmentType[i] as! String == "file"{
                    let fileUrl = (arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentFileUrl") as! URL
                    do{
                        let fileData = try Data(contentsOf: fileUrl)
                        multipartFormData.append(fileData, withName: serverKeyName, fileName: ((arrImages.object(at: i) as? NSDictionary ?? [:]).value(forKey:"attachmentName") as! String), mimeType: NSString(format: "file/%@",fileUrl.pathExtension) as String)
                    }catch{
                    }
                }
            }
        }, usingThreshold: UInt64.init(), to: finalUrl, method: .post, headers:headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                    progressHUD.progress = Float(progress.fractionCompleted)
                    print(progress)
                })
                upload.responseJSON { response in
                    //print response.result
                    print(response.result.value)
                    progressHUD.hide(animated: progress)
                    successResult(response.result.value)
                    //                     MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: true)
                }
            case .failure(let encodingError):
                //print encodingError.description
                print(encodingError)
                failureResult(encodingError)
                MBProgressHUD.hide(for: ((appDelegate?.window)!)!, animated: progress)
            }
        }
    }
}
