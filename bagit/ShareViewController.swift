//
//  ShareViewController.swift
//  bagit
//
//  Created by maxime marinel on 30/12/2016.
//  Copyright © 2016 maxime marinel. All rights reserved.
//

import UIKit
import Social

@objc(ShareViewController)
class ShareViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let user = UserDefaults(suiteName: "group.wallabag.share_extension"),
                let item = self?.extensionContext?.inputItems.first as? NSExtensionItem,
                let itemProvider = item.attachments?.first as? NSItemProvider else {
                    self?.extensionContext?.cancelRequest(withError: NSError())
                    return
            }

            if  itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, _) -> Void in
                    guard let shareURL = url as? NSURL,
                        let host = user.value(forKey: "host") as? String,
                        let clientId = user.value(forKey: "clientId") as? String,
                        let clientSecret = user.value(forKey: "clientSecret") as? String,
                        let username = user.value(forKey: "username") as? String,
                        let password = user.value(forKey: "password") as? String
                        else {
                            return
                    }
                    let server = Server(host: host, client_secret: clientSecret, client_id: clientId, username: username, password: password)
                    WallabagApi.configureApi(from: server)
                    WallabagApi.requestToken { _ in
                        WallabagApi.addArticle(shareURL as URL, completion: { _ in
                            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        })
                    }
                })
            }
        }
    }
}
