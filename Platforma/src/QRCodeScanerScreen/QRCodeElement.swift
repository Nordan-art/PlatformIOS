//
//  QRCodeElement.swift
//  Platforma
//
//  Created by Daniil Razbitski on 18/12/2024.
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - QRScannerView
struct QRScannerView: UIViewControllerRepresentable {
    var completion: (Result<String, Error>) -> Void
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        var completion: (Result<String, Error>) -> Void
        
        init(completion: @escaping (Result<String, Error>) -> Void) {
            self.completion = completion
        }
        
        func didFindCode(_ code: String) {
            completion(.success(code))
        }
        
        func didFailWithError(_ error: Error) {
            completion(.failure(error))
        }
    }
}

// MARK: - QRScannerViewController
protocol QRScannerViewControllerDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: Error)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError(NSError(domain: "No camera available", code: -1, userInfo: nil))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(error)
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            delegate?.didFailWithError(NSError(domain: "Failed to add camera input", code: -1, userInfo: nil))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.microQR, .qr]
            
            // Set scan area if needed
            //            metadataOutput.rectOfInterest = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6) // Example scan area
            
            // Set the scan area to the center of the screen
            let cutoutWidth: CGFloat = min(view.bounds.width, view.bounds.height) / 1.7
            let scanAreaSize: CGFloat = 200
            let scanAreaOriginX = (view.bounds.width - scanAreaSize) / 2
            let scanAreaOriginY = (view.bounds.height - scanAreaSize) / 2
            let scanAreaFrame = CGRect(x: scanAreaOriginX, y: scanAreaOriginY, width: scanAreaSize, height: scanAreaSize)
            
            // Draw a visual overlay for the scan area
            let overlayView = UIHostingController(rootView: ScanOverlayView(cutoutWidth: cutoutWidth).ignoresSafeArea(.all))
            overlayView.view.backgroundColor = .clear
            overlayView.view.frame = view.bounds
            addChild(overlayView)
            view.addSubview(overlayView.view)
            overlayView.didMove(toParent: self)
            //        let overlay = UIView(frame: scanAreaFrame)
            //        overlay.layer.borderColor = UIColor.green.cgColor
            //        overlay.layer.borderWidth = 2
            //        overlay.backgroundColor = .clear
            //        view.addSubview(overlay)
            
            // Set rectOfInterest using normalized coordinates
            metadataOutput.rectOfInterest = CGRect(
                x: scanAreaOriginY / view.bounds.height,
                y: scanAreaOriginX / view.bounds.width,
                width: scanAreaSize / view.bounds.height,
                height: scanAreaSize / view.bounds.width
            )
            
        } else {
            delegate?.didFailWithError(NSError(domain: "Failed to add metadata output", code: -1, userInfo: nil))
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add SwiftUI overlay
        //                addSwiftUIOverlay()
        
        // Bring the scan overlay to the front
        view.bringSubviewToFront(view.subviews.last!)
        
        // Start the capture session on a background thread
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.didFindCode(stringValue)
            
            
            // Add a simple animation
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            view.addSubview(overlay)
            
            UIView.animate(withDuration: 0.5, animations: {
                overlay.alpha = 0
            }, completion: { _ in
                overlay.removeFromSuperview()
            })
            
            
            stopScanning()
            
            //            DispatchQueue.global(qos: .background).async { [weak self] in
            //                self?.captureSession?.startRunning()
            //            }
        }
    }
    
    
    func startScanning() {
        guard let captureSession = captureSession else { return }
        
        withAnimation() {
            if !captureSession.isRunning {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
            } else {
                // Restart if captureSession is already running but not processing
                stopScanning()
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.captureSession?.startRunning()
                }
            }
        }
    }
    
    func stopScanning() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            withAnimation() {
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        captureSession?.stopRunning()
        stopScanning()
    }
    
}

//struct QRCodeDataModel: Decodable {
//    var id: Int
//}

struct GlowEffect: ViewModifier {
    @State private var glow: Double = 0.3

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.green.opacity(glow), radius: 10)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    glow = 0.8
                }
            }
    }
}
