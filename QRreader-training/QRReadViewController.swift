//
//  ViewController.swift
//  QRreader-training
//
//  Created by 城野 on 2021/02/03.
//

import UIKit
import AVFoundation

final class QRReadViewController: UIViewController {
    
    @IBOutlet private weak var captureView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFrontCamera()
    }
    
    private let captureSession = AVCaptureSession()
    
    private func showFrontCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        let devices = deviceDiscoverySession.devices
        
        if let frontCamera = devices.first {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: frontCamera)
                doInit(deviceInput: deviceInput)
            } catch {
                print(error)
            }
        }
    }
    
    private func doInit(deviceInput: AVCaptureDeviceInput) {
        
        if !captureSession.canAddInput(deviceInput) { return }
        captureSession.addInput(deviceInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if !captureSession.canAddOutput(metadataOutput) { return }
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        // カメラ起動
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = captureView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        captureView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
}

extension QRReadViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRのtype： metadata.type
            // QRの中身： metadata.stringValue
            guard let value = metadata.stringValue else { return }
            
            captureSession.stopRunning()
            // captureView.isHidden = true
            print(value)
        }
        
    }
    
}
