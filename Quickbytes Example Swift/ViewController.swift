//
//  ViewController.swift
//  Quickbytes Example Swift
//
//  Created by Aaron Brethorst on 9/25/17.
//  Copyright © 2017 Quickbytes. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    var feed: Feed?
    let decoder = AppStoreDecoder.init()
    let tableView = UITableView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        self.configureTableView()

        let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/25/non-explicit.json")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {
                print("Error: \(String(describing: error))")
                return
            }

            let feed = self.decoder.decodeFeed(from: data)

            DispatchQueue.main.async {
                self.feed = feed
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }

    // MARK: - Table View

    private func configureTableView() {
        self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.tableView.frame = self.view.bounds
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let feed = self.feed else {
            return 0
        }

        return feed.feedItems.count
    }

    private static let cellReuseIdentifier = "identifier"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellReuseIdentifier)

        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: ViewController.cellReuseIdentifier)
        }

        let feedItem = self.feed?.feedItems[indexPath.row]

        cell?.textLabel?.text = feedItem?.name

        if let developer = feedItem?.developer {
            cell?.detailTextLabel?.text = "By \(developer)"
        }
        else {
            cell?.detailTextLabel?.text = nil
        }

        return cell!
    }
}
