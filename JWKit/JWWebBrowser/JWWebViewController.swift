//
//  JWWebViewController.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/12.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//
import WebKit
import UIKit

let bottomBarHeight:CGFloat = 0

class JWWebViewController: JWBaseViewController,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler {
    
    
    var navigationActionClosure:((String)->Bool)?
    
     
    private let estimatedProgressKey = "estimatedProgress"
    private let loadingKey = "loading"
    private let titleKey = "title"
    
    //进度
    lazy var progressView:JWWebViewProgressView = {
        let progressView:JWWebViewProgressView = JWWebViewProgressView(frame: CGRect(x: 0, y: 64, width: ScreenW, height: 3))
        progressView.isHidden = true
        return progressView
    }()
    
    
    
    lazy var webView:WKWebView =  {
        
        //配置
        let config:WKWebViewConfiguration = WKWebViewConfiguration()
        
        //偏好设置
        let preference =  WKPreferences()
        preference.javaScriptEnabled = true//启用javascript
        preference.javaScriptCanOpenWindowsAutomatically = false//javascript 是否可以打开新窗口
        preference.minimumFontSize  = 12 //最小文字大小
        config.preferences = preference
        
        //内容处理池
        let  processPool =  WKProcessPool()
        config.processPool = processPool
        
        //js与webView交互
        let userContent : WKUserContentController = WKUserContentController()
        config.userContentController = userContent
        
       
        let webView:WKWebView =  WKWebView(frame:CGRect(x: 0, y: 0, width: ScreenW, height: ScreenH - bottomBarHeight), configuration: config)
        webView.allowsBackForwardNavigationGestures  = true
        
        return webView
    }()
    
    
    private var backFlag:Bool = false
    override func leftNavButtonClick(item: UIBarButtonItem) {
        if webView.canGoBack{
            webView.goBack()
        }else{
            self.backFlag = true
            super.leftNavButtonClick(item: item)
        }
    }
    
    
    private var addObserverFlag:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        view.addSubview(webView)
        
        let refreshItem:UIBarButtonItem = UIBarButtonItem(title: "刷新", style: UIBarButtonItemStyle.done, target: self, action: #selector(JWWebViewController.refresh(item:)))
        let closeItem:UIBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.done, target: self, action: #selector(JWWebViewController.close(item:)))
        
        navigationItem.rightBarButtonItems = [closeItem,refreshItem]
        
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        
        addObserverFlag = true
        
        //通过监听estimatedProgress可以获取它的加载进度 还可以监听它的title ,URL, loading
        webView.addObserver(self, forKeyPath: estimatedProgressKey, options: NSKeyValueObservingOptions.new, context: nil)
        
        //加载
         webView.addObserver(self, forKeyPath: loadingKey, options: NSKeyValueObservingOptions.new, context: nil)
        
        //标题
        webView.addObserver(self, forKeyPath: titleKey, options: NSKeyValueObservingOptions.new, context: nil)
        
        
        webView.configuration.userContentController.add(self, name: "defaultHandler")
        
        
    }
    
    func close(item:UIBarButtonItem) {
        if let nav = navigationController{
           nav.popViewController(animated: true)
        }
    }
    
    func refresh(item:UIBarButtonItem) {
        webView.reload()
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.addSubview(progressView)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        //进度
        if (keyPath?.compare(estimatedProgressKey) == ComparisonResult.orderedSame) {
             progressView.progress = CGFloat(webView.estimatedProgress)
        }else if(keyPath?.compare(loadingKey) == ComparisonResult.orderedSame)
        {
            progressView.isHidden = !webView.isLoading
            if webView.isLoading
            {
                progressView.startAnimation()
            }else
            {
                progressView.progress = 0.0//改回0
            }
            
        }else if(keyPath?.compare(titleKey) == ComparisonResult.orderedSame)
        {
            navigationItem.title = webView.title
        }
    }
    
    
    //MARK:UI代理
    
    //网页中在新窗口弹出的交互功能  target = __bank
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let frameInfo = navigationAction.targetFrame {
            if frameInfo.isMainFrame {
                webView .load(navigationAction.request)
            }
        }else{
            
        }
        
        return nil
    }
    
    //弹出 alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        if self.backFlag{
            //点击确定
            completionHandler()
            return
        }
        
        let alertController:JWAlertController = JWAlertController(title: "提示", message: message, preferredStyle: JWAlertControllerStyle.alert)
        
        let confirmAction:JWAlertAction = JWAlertAction(title: "知道了", style:JWAlertActionStyle.default) { (action) in
            //点击确定
            completionHandler()
        }
        
        alertController.addAction(action: confirmAction)
        
        present(alertController, animated: true) { 
            //完成了
          
        }
    }
    
    //弹出  取消 确定 面板
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        
        if self.backFlag{
            //点击确定
            completionHandler(false)
            return
        }
        
        let alertController:JWAlertController = JWAlertController(title: "提示", message: message, preferredStyle: JWAlertControllerStyle.alert)
        
        let confirmAction:JWAlertAction = JWAlertAction(title: "确定", style:JWAlertActionStyle.default) { (action) in
            //点击确定
            completionHandler(true)
        }
        
        let cancelAction:JWAlertAction = JWAlertAction(title: "取消", style:JWAlertActionStyle.default) { (action) in
            //点击确定
            completionHandler(false)
        }
        
        alertController.addAction(action:confirmAction)
        alertController.addAction(action:cancelAction)
        
        present(alertController, animated: true) {
            //完成了
        }
    }
    
    //js 弹出输入框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        if self.backFlag{
            //点击确定
            completionHandler("")
            return
        }
        
         let alertController:UIAlertController = UIAlertController(title: "", message:prompt , preferredStyle: UIAlertControllerStyle.alert)
        
        
        //弹出输入框
        alertController.addTextField { (textField) in
             textField.placeholder = prompt
        }
        
        let confirmAction:UIAlertAction = UIAlertAction(title: "确定", style:UIAlertActionStyle.default) { (action) in
            //点击确定
            completionHandler(alertController.textFields?.last?.text)
        }
        
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "取消", style:UIAlertActionStyle.default) { (action) in
            //点击确定
            completionHandler(defaultText)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {
            //完成了
        }
    }
    
    
    //MARK:navigation代理
    
    
    // 内容处理中断
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        
    }
    
    
    //请求准备发起  决定是否发起
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction")
        
        if AppConfigure.shared().hanlderShareUrl(shareUrl: navigationAction.request.url?.absoluteString, completion: { (resp) in
            
            if resp.isKind(of:BaseResp.classForCoder()){
                let res:BaseResp = resp
                if res.errCode == WXSuccess.rawValue{
                    self.showMessage(msg: "分享成功")
                }else{
                    self.showMessage(msg: "分享失败")
                }
            }
        }){
            //取消
            decisionHandler(WKNavigationActionPolicy.cancel)
        }else{
            if let closure =  self.navigationActionClosure{
                if let url  =  navigationAction.request.url{
                    if closure(url.absoluteString){
                        decisionHandler(WKNavigationActionPolicy.allow)
                    }else{
                        decisionHandler(WKNavigationActionPolicy.cancel)
                    }
                }
            }
            decisionHandler(WKNavigationActionPolicy.allow)
            
        }
    }
    
    
    //请求发起收到响应 决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyFor")
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    
    
    //导航失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //刷新状态
        print("导航失败")
    }
    
    //请求完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title =  webView.title
         //刷新状态
        print("didFinish")
    }
    
    //开始返回内容
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    
    //页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }
    
    //收到重定向
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("重定向")
    }
    
    
    //页面加载失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print("didFailProvisionalNavigation")
    }
  
    
    //https 授权
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //按默认处理
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
    
    
    //销毁
    deinit {
        if addObserverFlag{
            webView.removeObserver(self, forKeyPath: estimatedProgressKey)
            webView.removeObserver(self, forKeyPath: loadingKey)
            webView.removeObserver(self, forKeyPath: titleKey)
        }
    }
}
