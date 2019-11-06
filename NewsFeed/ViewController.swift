//  Copyright © 2019 Nico Zino. All rights reserved.

import UIKit

class MySuperCell : UITableViewCell {
    
    @IBOutlet var imageViw: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var datelabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comicsDL.count
    }
    
    let cellType = "cell"    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : MySuperCell
        
        if let c = tableView.dequeueReusableCell(withIdentifier: cellType) as? MySuperCell {
            cell = c
        } else {
            let c = MySuperCell(style: .default, reuseIdentifier: cellType)
            cell = c
        }
        
       // TODO
        let c = comicsDL.getComic(comicsDL.count - indexPath.row - 1)
        cell.label.text = c[XKCDFetcher.titleKey] as? String
        cell.datelabel.text = "\((c[XKCDFetcher.yearKey] as? String) ?? "")/\((c[XKCDFetcher.monthKey] as? String) ?? "")/\((c[XKCDFetcher.dayKey] as? String) ?? "")"
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    @IBOutlet var tableView: UITableView!
    
    private var comicsDL = XKCDFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        
        DispatchQueue.init(label: "fetch").async {
            let lock = NSLock()
            lock.lock()

            self.comicsDL.getLatest {
                lock.unlock()
            }
            
            lock.lock()
            self.comicsDL.get20more {
                lock.unlock()
            }
            
            lock.lock()
            self.comicsDL.get20more {
                lock.unlock()
                print("40p")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
