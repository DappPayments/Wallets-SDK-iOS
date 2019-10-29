//
//  DappScannerViewController.swift
//  dapp-sdk-wallets-ios
//
//  Created by Rodrigo Rivas on 9/10/19.
//  Copyright © 2019 Dapp. All rights reserved.
//

import UIKit

public protocol DappScannerViewControllerDelegate {
    
    func dappScannerViewControllerSuccess(_ viewController: DappScannerViewController, code: DappCode)
    
    func dappScannerViewControllerFailure(_ viewController: DappScannerViewController, error: DappError)
}

public class DappScannerViewController: UIViewController, DappScannerViewDelegate {
    
    internal var scannerView: DappScannerView!
    internal var loadingView: DappLoadingView!
    internal var btnCancel: UIButton!
    internal var delegate: DappScannerViewControllerDelegate?
    
    public init(delegate: DappScannerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scannerView = DappScannerView()
        scannerView.delegate = self
        scannerView.frame = view.frame
        scannerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scannerView)
    }
    
    override public func viewDidLayoutSubviews() {
        if !scannerView.isScanning() {
            scannerView.startScanning()
        }
        if btnCancel == nil {
            btnCancel = UIButton(type: .system)
            btnCancel.frame.origin = CGPoint(x: 8, y: view.layoutMargins.top + 8)
            btnCancel.setTitle("Cancelar", for: .normal)
            btnCancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            btnCancel.setTitleColor(.white, for: .normal)
            btnCancel.sizeToFit()
            btnCancel.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
            view.addSubview(btnCancel)
        }
    }
    
    internal func showLoader() {
        if loadingView == nil {
            loadingView = DappLoadingView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100))
            view.addSubview(loadingView)
        }
        loadingView.show()
    }
    
    internal func hideLoader() {
        if let lv = loadingView {
            lv.hide()
        }
    }
    
    @objc internal func didTapCancelButton() {
        scannerView.stopScanning()
        dismiss(animated: true)
    }
    
    //MARK: - DappScannerViewControllerDelegate
    public func dappScannerView(_ dappScannerView: DappScannerView, didChangeStatus status: DappScannerViewStatus) {
        switch status {
        case .isValidatingQR:
            dappScannerView.stopScanning()
            showLoader()
        case .success(let code):
            hideLoader()
            delegate?.dappScannerViewControllerSuccess(self, code: code)
        case .failed(let e):
            hideLoader()
            switch e {
            case .invalidDappCode:
                dappScannerView.stopScanning()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dappScannerView.startScanning()
                }
                delegate?.dappScannerViewControllerFailure(self, error: e)
            case .responseError(_):
                dappScannerView.overlayLayer?.strokeColor = UIColor.red.cgColor
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dappScannerView.startScanning()
                }
                delegate?.dappScannerViewControllerFailure(self, error: e)
            default:
                delegate?.dappScannerViewControllerFailure(self, error: e)
            }
        }
    }
}
