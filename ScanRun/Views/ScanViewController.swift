//
//  ScanViewController.swift
//  ScanRun
//
//  Created by Thomas Pain-Surget on 05/09/2018.
//  Copyright © 2018 Alexandre Ménielle. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    @IBOutlet weak var geolocBtn: UIButton!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var globalView: UIView!
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var imageProduct: UIImageView!
    
    var captureSession = AVCaptureSession()
    var idProduct = ""
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var productFound : Product?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageProduct.contentMode = UIViewContentMode.scaleAspectFit
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.view.layer.bounds
        globalView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
    }
    
    func getProduct(ean : String){
        NiceActivityIndicatorBuilder()
            .setSize(100)
            .setType(.pacman)
            .setColor(.white)
            .build()
            .startAnimating(self.globalView)
        
        APIManager.shared.getProduct(ean: ean) { (json) in
            NiceActivityIndicator().stopAnimating(self.globalView)
            if json.count > 0 {
                self.productView.isHidden = false
                self.imageProduct.image = nil
                
                NiceActivityIndicatorBuilder()
                    .setSize(100)
                    .setType(.ballPulse)
                    .setColor(.white)
                    .build()
                    .startAnimating(self.imageProduct)
                
                self.productFound = Product(json: json)
                
                self.showGeoloc((self.productFound?.geoPoints.count ?? 0) > 0)
                
                if let nav = self.presentingViewController as? UINavigationController,
                    let presenter = nav.topViewController as? CheckDuelViewController{
                    
                    presenter.productScanned = self.productFound
                    self.dismiss(animated: true)
                }
                
                if let title = json["name"] as? String{
                    if title != "" {
                        self.titleLabel.text = title.uppercased()
                    } else {
                        self.titleLabel.text = ""
                    }
                } else {
                    self.titleLabel.text = ""
                }
                if let brand = json["brand"] as? String{
                    if brand != "" {
                        self.brandLabel.text = "Marque : " + brand
                    } else {
                        self.brandLabel.text = ""
                    }
                } else {
                    self.brandLabel.text = ""
                }
                if let quantity = json["quantity"] as? String{
                    if quantity != "" {
                        self.quantityLabel.text = "Quantité : " + quantity
                    } else {
                        self.quantityLabel.text = ""
                    }
                } else {
                    self.quantityLabel.text = ""
                }
                if let image = json["image"] as? String, image != "" {
                    self.imageProduct.downloaded(from: image, callback: {
                        NiceActivityIndicator().stopAnimating(self.imageProduct)
                        if self.imageProduct.image == nil{
                            self.imageProduct.image = UIImage(named: "placeholder")
                        }
                    })
                } else {
                    self.imageProduct.image = UIImage(named: "placeholder")
                    NiceActivityIndicator().stopAnimating(self.imageProduct)
                }
            }else{
                let addProductAction = UIAlertAction(title: "Ajouter le produit", style: .default, handler: { (action) in
                    self.presentNewProduct()
                })
                let rescanAction = UIAlertAction(title: "Scanner un autre produit", style: .cancel, handler: { (action) in
                    self.messageLabel.text = "Scannez le produit"
                    self.messageLabel.backgroundColor = UIColor.lightGray
                    self.captureSession.startRunning()
                })
                
                self.showAlert(title: "Produit introuvable", message: "Donnez nous les informations de ce produit !", actions: [addProductAction,rescanAction])
            }
        }
    }
    
    func presentNewProduct(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let newProductVC = storyBoard.instantiateViewController(withIdentifier: "NewProductViewController") as! NewProductViewController
        newProductVC.passedEAN = self.idProduct
        self.present(newProductVC, animated: true)
    }
    
    func reScan() {
        self.messageLabel.text = "Scannez le produit"
        self.messageLabel.backgroundColor = UIColor.lightGray
        self.productView.isHidden = true
        self.captureSession.startRunning()
    }
    
    func showGeoloc(_ show : Bool){
        geolocBtn.alpha = show ? 1 : 0
        geolocBtn.isEnabled = show
    }
    
    @IBAction func onGeoloc(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ProductLocationViewController") as! ProductLocationViewController
        controller.product = productFound
        self.present(controller, animated: true)
    }
    
    @IBAction func reScanProduct(_ sender: Any) {
        reScan()
    }
    
    @IBAction func onValidate(_ sender: Any) {
        if let presenter = presentingViewController as? CreateDuelViewController {
            presenter.chooseProduct = self.productFound
            self.dismiss(animated: true)
        }
        captureSession.startRunning()
        productView.isHidden = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let duelVC = storyBoard.instantiateViewController(withIdentifier: "CreateDuelViewController") as! CreateDuelViewController
        duelVC.chooseProduct = self.productFound
        self.present(duelVC, animated: true)
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Scannez le produit"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil, let ean = metadataObj.stringValue  {
                self.idProduct = ean
                getProduct(ean: ean)
                messageLabel.text = "Produit detécté !"
                messageLabel.backgroundColor = UIColor(red:0.16, green:0.69, blue:0.10, alpha:0.9)
                captureSession.stopRunning()
            }
        }
    }
    
}
