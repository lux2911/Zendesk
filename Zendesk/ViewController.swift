//
//  ViewController.swift
//  Zendesk
//
//  Created by Tomislav Luketic on 24/02/2018.
//  Copyright © 2018 Tomislav Luketic. All rights reserved.
//

import UIKit
import Suas




struct FetchArticles {
    
    var articlesData : ArticlesList
    
}

struct ArticlesList
{
    var articles : [ArticleItem]
    var totalArticlesCount : Int
    var nextPage : String?
}

struct ArticleItem
{
    var title : String
    var lastUpdate : String
    var body : String
}

struct FetchArticlesAsyncAction: AsyncAction
{
    
    let urlString : String
    
    init(url : String)
    {
        urlString = url
    }
    
    func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
        
        let url = URL(string: urlString)!
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let client = NetworkClient(session: URLSession(configuration: .default))
        
        client.get(url: url, callback: { (data, response, error) in
            
            var resp = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            
            var list = ArticlesList(articles: [], totalArticlesCount: (resp["count"] as? Int)!, nextPage: resp["next_page"] as? String)
            
            let articles = resp["articles"] as?  [[String: Any]]
            
            for article in articles!
            {
                let item =  ArticleItem(title: (article["title"] as? String)!, lastUpdate: (article["updated_at"] as? String)!,  body: (article["body"] as? String)!)
                
                list.articles.append(item)
            }
            
            let prevState = getState()
            
            if let prevJson = prevState.value(forKey: "FetchArticles") as? FetchArticles
            {
                if prevJson.articlesData.articles.count > 0
                {
                    let prevList = prevJson.articlesData.articles
                    list.articles = prevList + list.articles
                    
                }
            }
            
            dispatch(ArticlesFetchedAction(articlesData: list))
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
             
        })
        
       
    }
    

}

struct ArticlesFetchedAction: Action {
    let articlesData : ArticlesList
}

struct FetchArticlesReducer: Reducer {
    
    var initialState = FetchArticles(articlesData: ArticlesList(articles: [],totalArticlesCount: 0,nextPage: ""))
    
    func reduce(state: FetchArticles, action: Action) -> FetchArticles? {
        
        if let action = action as? ArticlesFetchedAction
        {
            return FetchArticles(articlesData: action.articlesData)
        }
        
        return nil
    }
    
}

let store = Suas.createStore(reducer: FetchArticlesReducer(), middleware: AsyncMiddleware())

class ViewController: UIViewController {

    var listenerSubscription: Subscription<FetchArticles>?
    var articles: ArticlesList = ArticlesList(articles: [], totalArticlesCount: 0, nextPage: "")
    {
        didSet
            {
                tableView.reloadData()
                isLoading = false
            }
        
    }
    
    var isLoading : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        
        //Since this is the initial ViewController, it will be loaded when running tests and we don't want that !!
        if NSClassFromString("XCTestCase") != nil
        {
            return
        }
        
      listenerSubscription = store.addListener(forStateType: FetchArticles.self) { [weak self] state in
        
            self?.articles = state.articlesData
        }
        
        
        listenerSubscription?.linkLifeCycleTo(object: self)
        
        store.dispatch(action: FetchArticlesAsyncAction(url: "https://support.zendesk.com/api/v2/help_center/en-us/sections/200623776/articles.json"))
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "ShowArticleDetails"
        {
            let vc = segue.destination as! ArticleDetailsVC
            let indexPath = sender as? IndexPath
           
            let article = articles.articles[(indexPath?.row)!]
            
            vc.body = article.body
        }
        
      
    }
  
}

extension ViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell") as! ArticleCell
               
        let article = articles.articles[indexPath.row]
        
        cell.lblTitle.text = article.title
        
        
        if let date = article.lastUpdate.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'")
        {
            cell.lblLastUpdated.text = date.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
        }
        
        return cell
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return articles.articles.count
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowArticleDetails", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let rows = tableView.numberOfRows(inSection: 0)
        
        if !isLoading && indexPath.row == rows-1 && articles.nextPage != nil && rows < articles.totalArticlesCount
        {
            isLoading = true
            store.dispatch(action: FetchArticlesAsyncAction(url: articles.nextPage!))
        }
    }
    
   

}


extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    
}

extension String
{
    func toDate( dateFormat format  : String) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
               
        return dateFormatter.date(from: self)
                
    }
}



