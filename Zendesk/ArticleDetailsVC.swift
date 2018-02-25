//
//  ArticleDetailsVC.swift
//  Zendesk
//
//  Created by Tomislav Luketic on 25/02/2018.
//  Copyright © 2018 Tomislav Luketic. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailsVC: UIViewController {

   
    var body : String = ""
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        webView.loadHTMLString(body, baseURL: nil)
       
    }

   

}
