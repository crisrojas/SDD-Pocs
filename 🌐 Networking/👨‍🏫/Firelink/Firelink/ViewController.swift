//
//  ViewController.swift
//  DevTemplate
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//

import UIKit
import SwiftyJSON
import SQLite

final class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Redux {

    @IBOutlet var testBtn: UIButton!
    @IBOutlet var table: UITableView!
    @IBOutlet var rsTf: TfRx!
    @IBOutlet var enter: UIButton!
    @IBOutlet var pwdMsg: UILabel!
    @IBOutlet var pwd: TfRx!
    @IBOutlet var nameMsg: UILabel!
    @IBOutlet var name: TfRx!
    var data = [JSON]() {
        didSet {
            table.reloadData()
        }
    }
    var toggle = (false, false) {
        didSet {
            enter.isEnabled = toggle == (true, true)
        }
    }
    let user = User()
    override func viewDidLoad() {
        super.viewDidLoad()
        // localization hook
        // loc()

        // Do any additional setup after loading the view, typically from a nib.

        name.rxEndEditing ~< {$0.count > 5} >~ action { (isValid, vc) in
            vc.nameMsg.text = isValid ? "" : "name > 5"
            vc.toggle.0 = isValid
        }

        pwd.rxEndEditing ~< {$0.count > 5} >~ action { (isValid, vc) in
            vc.pwdMsg.text = isValid ? "" : "pwd > 5"
            vc.toggle.1 = isValid             }
        
        pwd.rxEndEditing ~< {_ in "hello"} >~ action { (string, vc) in
            
        }

        table.delegate = self
        table.dataSource = self

        testBtn << fat(#selector(test(_:)))

        rsTf.rxEndEditing ~< action{ (s, vc) in
            guard s.notEmpty else {
                self.data = []
                return
            }
            api.search.withParam("q", s).loadIfNeeded()?.onNewData{ e in
                vc.data = e.json[P.items].arrayValue
            }
        }

        _ = User.update(\User.id == 1, [\User.tesla <- "Elon Musk"])
        dp(User.all())

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        guard let c = cell as? SearchCell else {
            return cell
        }
        let row = indexPath.row
        c.repo.text = data[row][P.full_name].stringValue
        c.url.text = data[row][P.url].stringValue
        return c
    }

    @objc func test(_ sender: Any) {
        dp("test")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

