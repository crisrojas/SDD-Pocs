//
//  RxTableView.swift
//  DevTemplate
//
//  Created by jimlai on 2018/5/7.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import UIKit
import SwiftyJSON

extension UITableViewCell {
    static var cellId: String {
        return String(describing: self)
    }
}

protocol TDS: class {
    var rows: Int {get}
}

protocol Table: TDS, UITableViewDelegate {
    associatedtype CellType: UITableViewCell
    var table: SCTableView! {get set}
    func configCell(_ ip: IndexPath, _ cell: CellType)
    func setupTableView(_ cls: () -> ())
}

extension Table {
    func setupTableView(_ cls: () -> ()) {
        table.prepare(self)
        cls()
    }
}

class SCTableView: UITableView, UITableViewDataSource {
    weak var tds: TDS? {
        return self.delegate as? TDS
    }
    var cellId = ""
    var updateCell: ((IndexPath, UITableViewCell) -> ())?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tds?.rows ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        updateCell?(indexPath, cell)
        return cell
    }

    func prepare<T>(_ delegate: T) where T: Table {
        self.delegate = delegate
        self.dataSource = self
        dp(T.CellType.cellId)
        self.register(T.CellType.self, forCellReuseIdentifier: T.CellType.cellId)
        cellId = T.CellType.cellId
        self.updateCell = { [weak delegate] (ip, cell) in
            if let c = cell as? T.CellType {
                delegate?.configCell(ip, c)
            }
        }
    }
}
