import UIKit
import WebKit

fileprivate enum LocalConstants {
    static let fontSettings = "<span style=\"font-family: Lucida Grande; font-size: 30\"</span>"
}

class DetailsViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!

    var record: Record? {
        didSet { showDetails() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationItem.setHidesBackButton(true, animated: false)
        }
        showDetails()
    }

    private func showDetails() {
        guard let item = record else { return }
        guard self.isViewLoaded else { return }
        if let htmlDescription = item.result {
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            // Increase font on iOS
            let content = isIpad ? htmlDescription : LocalConstants.fontSettings + htmlDescription
            webView.loadHTMLString(content, baseURL: nil)
        }
        DispatchQueue(label: "background.queue").async { [weak self] in
            self?.loadImage(imageUrl: item.iconUrl)
        }
    }
    
    private func loadImage(imageUrl: String?) {
        guard var imageUrl = imageUrl else {
            setImageOnMainThread(nil)
            return
        }
        imageUrl = "https://duckduckgo.com/" + imageUrl
        guard let url = URL(string: imageUrl) else {
            setImageOnMainThread(nil)
            return
        }
        guard let imageData = try? Data(contentsOf: url) else  {
            setImageOnMainThread(nil)
            return
        }
        setImageOnMainThread(UIImage(data: imageData))
    }

    private func setImageOnMainThread(_ optionalImage: UIImage?) {
        let image = optionalImage ?? UIImage(named: "genericPerson")
        DispatchQueue.main.async { [weak self] in self?.imageView.image = image }
    }

    // MARK: - WKWebView functionality
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle content links in an external browser
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if navigationAction.request.url?.absoluteString == "about:blank" {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
