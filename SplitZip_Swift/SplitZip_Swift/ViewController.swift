//
//  ViewController.swift
//  SplitZip_Swift
//
//  Created by Luis Genaro Arvizu Vega on 16/01/18.
//  Copyright © 2018 Luis Genaro Arvizu Vega. All rights reserved.
//

import UIKit
import SSZipArchive
class ViewController: UIViewController {
    var btnZIP: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGSize = UIScreen.main.bounds.size
        btnZIP = UIButton(frame: CGRect(x: (screenSize.width/2)-25, y: screenSize.height/2, width: 50, height: 35))
        btnZIP.setTitle("ZIP", for: UIControlState.normal)
        btnZIP.addTarget(self, action: #selector(createZIP), for: UIControlEvents.touchUpInside)
        btnZIP.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.view.addSubview(btnZIP)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func createZIP(){
        print("Beginning to create ZIPs")
        let sampleDataPath = Bundle.main.resourcePath
        let urlZip = tempZipPath()
        print(urlZip)
        let isZip:Bool = SSZipArchive.createZipFile(atPath: urlZip, withContentsOfDirectory: sampleDataPath!)
        if isZip{
            print("\nAll good\n")
        }else{
            print("\nSomething wrong\n")
        }
        if splitZip(zip: urlZip){
            print("SplitZip method OK")
        }
        //MARK: - If you want to check the zip files you have to copy the path of the log and then open with terminal or use the Finder
    }
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "Image.zip"
        return path
    }
    /// This method split a Zip
    func splitZip(zip superZipPath: String) -> Bool{
        let path = URL.init(fileURLWithPath: superZipPath)
        var numberZips: Int = 0
        //Here, I set the size of the Zips that we create in order to split the original zip
        let zipSize = 4000 * 1024
        var superPath: String = ""
        do{
            print(path)
            let fileData: NSData = try NSData(contentsOf: path)
            //We ask if the length of the zip is bigger than the split's zips
            if fileData.length > zipSize{
                    //While the size of the split's zips are less than the original zip do...
                    while ((numberZips*zipSize)<fileData.length){
                        let ZipPath = superZipPath.replacingOccurrences(of: "Image.zip", with: "/")
                        let newPath: String = ZipPath.appendingFormat("part%d", numberZips)
                        print(newPath)
                        print("")
                        print(fileData.length)
                        if (numberZips*zipSize) >= fileData.length{
                            if !FileManager.default.fileExists(atPath: newPath){
                                try FileManager.default.createDirectory(atPath: newPath, withIntermediateDirectories: false, attributes: nil)
                                    print("New Directory Created")
                                superPath = newPath.appending("/part")
                            }
                        }else{
                            if !FileManager.default.fileExists(atPath: newPath){
                                try FileManager.default.createDirectory(atPath: newPath, withIntermediateDirectories: false, attributes: nil)
                                print("Else New Directory Created")
                                superPath = newPath.appending("/part")
                            }
                        }
                        //Here is where the magic happens, we assign a range for the size of the zips
                        let dataRange = NSMakeRange(numberZips*zipSize, min(zipSize, fileData.length-(numberZips*zipSize)))
                        if var urlPath = URL.init(string: superPath){
                            urlPath.appendPathExtension("zip")
                            //And here is where the zips are created, we use "fileData.subdata(:)" to indicate that we will use just a range of bytes of the original zip
                            if !FileManager.default.createFile(atPath: urlPath.absoluteString, contents: fileData.subdata(with: dataRange), attributes: nil){
                                print("Error")
                                break
                            }
                            numberZips += 1
                        }else{
                            break
                        }
                    }
            }
            return true
        }catch let e{
            print(e.localizedDescription)
        }
        return false
    }
}

