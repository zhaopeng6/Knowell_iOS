//
//  AddCardViewController.swift
//  KnoWell
//
//  Created by zhaopeng on 2/7/16.
//  Copyright © 2016 MickelStudios. All rights reserved.
//

import UIKit
import AVFoundation

class AddCardViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?

    var capturedCard:Card?

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Initialize QR code

        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var input: AnyObject!
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ {
            // If any error occurs, simply log the description of it and don't continue any more.
            performSegueWithIdentifier("ScannedCardSegue", sender: nil)
            return
        }

        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)

        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)

        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
        captureSession?.startRunning()

        // Move the message label to the top view
        view.bringSubviewToFront(messageLabel)

        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {

        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = "No QR code is detected"
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;

            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                print("SilentError: Got Text %s", messageLabel.text)
                performSegueWithIdentifier("ScannedCardSegue", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ScannedCardSegue" {
            // Get the new view controller using segue.destinationViewController.
            let controller = segue.destinationViewController as! EditCardViewController

            // Pass the selected object to the new view controller.
            controller.toEditCard = Card.getCurrentUserCard()
        }
    }
    
}
