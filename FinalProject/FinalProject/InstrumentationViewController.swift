//
//  InstrumentationViewController.swift
//
//  Created by Hank Sway on 4/24/17.
//

import UIKit

class InstrumentationViewController: UIViewController, EngineDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sizeInput: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshSlider: UISlider!
    @IBOutlet weak var refreshSwitch: UISwitch!
    
    static var tableStrings:[String] = []
    static var gridState:[String: [[Int]]] = [:]
    var engine: StandardEngine!
    
    let finalProjectURL: String = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        engine = StandardEngine.engine
        engine.delegate = self
        
        refreshSwitch.setOn(false, animated: true)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTableView),
            name: NSNotification.Name(rawValue: "load"),
            object: nil
        )
        loadJSON(finalProjectURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        
        let newPatternButton = UIBarButtonItem(title: "+ New Pattern",
                                               style: .plain,
                                               target: self,
                                               action: #selector(InstrumentationViewController.addPattern))
        navigationItem.leftBarButtonItem = newPatternButton
    }
    
    func loadJSON(_ link:String) {
        let url:URL = URL(string: link)!
        let urlsession = URLSession.shared
        let urlrequest = NSMutableURLRequest(url: url)
        urlrequest.httpMethod = "GET"
        urlrequest.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let dataTask = urlsession.dataTask(with: urlrequest as URLRequest, completionHandler: { (data, urlresponse, error) in
            guard let _:Data = data, let _:URLResponse = urlresponse , error == nil else {
                return
            }
            self.readJSON(data!)
        })
        dataTask.resume()
    }
    
    
    func readJSON(_ data: Data){
        let json: Any?
        
        do { json = try JSONSerialization.jsonObject(with: data, options: []) }
        catch { return }
        
        guard let jsonArray = json as? NSArray else { return }
        
        if let patternArray = json as? NSArray{
            for i in 0 ..< jsonArray.count{
                if let patternItem = patternArray[i] as? NSDictionary{
                    if let title = patternItem["title"] as? String , let gridState = patternItem["contents"] as? [[Int]] {
                        if !InstrumentationViewController.tableStrings.contains(title) {
                            InstrumentationViewController.tableStrings.append(title)
                            InstrumentationViewController.gridState[title] = gridState
                        } else {
                            let alreadyExistsAlert = UIAlertController(
                                title: "Error",
                                message: "\"\(title)\" already exists",
                                preferredStyle: UIAlertControllerStyle.alert
                            )
                            alreadyExistsAlert.addAction(UIAlertAction(
                                title: "OK",
                                style: UIAlertActionStyle.default,handler: nil
                            ))
                            self.present(alreadyExistsAlert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: { self.reloadTableView() })
    }
    
    func reloadTableView() { self.tableView.reloadData() }

    func addPattern(){
        let ac = UIAlertController(
            title: "New Pattern",
            message: "Enter new pattern name:",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let field = ac.textFields?[0] {
                if let text = field.text {
                    if !InstrumentationViewController.tableStrings.contains(text){
                        InstrumentationViewController.tableStrings.append(text)
                        InstrumentationViewController.gridState[text] = []
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: InstrumentationViewController.tableStrings.count-1,
                                                                 section: 0)],
                                                                 with: .automatic)
                        self.tableView.endUpdates()
                    } else {
                        let alreadyExistsAlert = UIAlertController(
                            title: "Error",
                            message: "\"\(text)\" already exists",
                            preferredStyle: UIAlertControllerStyle.alert
                        )
                        alreadyExistsAlert.addAction(UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,handler: nil
                        ))
                        self.present(alreadyExistsAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        ac.addTextField { (textField) in textField.placeholder = "" }
        ac.addAction(confirmAction)
        ac.addAction(cancelAction)
        self.present(ac, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InstrumentationViewController.tableStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = InstrumentationViewController.tableStrings[indexPath.item]
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {}
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {}
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return true }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cancelButton = UIBarButtonItem()
        cancelButton.title = "Cancel"
        navigationItem.backBarButtonItem = cancelButton
        
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let title = InstrumentationViewController.tableStrings[indexPath.row]
            let gridState = InstrumentationViewController.gridState[title]
            if let vc = segue.destination as? GridEditorViewController {
                vc.name = title
                vc.gridData = gridState
            }
        }
    }
    
    @IBAction func refreshOnOff(_ sender: Any) {
        if refreshSwitch.isOn {
            if engine.timer != nil {
                engine.timer!.invalidate()
                engine.timer = nil
            }
            engine.timerInterval = TimeInterval(refreshSlider.value)
        } else { engine.timerInterval = 0.0 }
    }
    
    @IBAction func refreshRate(_ sender: Any) {
        if refreshSwitch.isOn {
            if engine.timer != nil{
                engine.timer!.invalidate()
                engine.timer = nil
            }
            engine.timerInterval = TimeInterval(refreshSlider.value)
        }
    }
    
    @IBAction func setGridSize(_ sender: UITextField) {
        if Int(sender.text!) != nil {
            sizeStepper.value = Double(sizeInput.text!)!
        }
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    @IBAction func sizeStep(_ sender: UIStepper) {
        sizeInput.text = String(Int(sender.value))
        engine.theGrid = Grid(Int(sender.value), Int(sender.value))
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    // EngineDelegate protocol
    func engineDidUpdate(withGrid: GridProtocol){}
    
    // GridViewDataSource protocol
    public subscript (pos: Position) -> CellState {
        get {  return engine.theGrid[pos] }
        set {  engine.theGrid[pos] = newValue }
    }
}
