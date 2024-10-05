//
//  Public+MCameraErrorView.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

public protocol MCameraErrorView: View {
    var error: CameraManager.Error { get }
    var closeControllerAction: () -> () { get }
}

// MARK: - Helpers
public extension MCameraErrorView {
    func openAppSettings() { if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url)
    }}
}
public extension MCameraErrorView {
    func getDefaultTitle() -> String { switch error {
        case .cameraPermissionsNotGranted: NSLocalizedString("Enable Camera Access", comment: "")
        default: ""
    }}
    func getDefaultDescription() -> String { switch error {
        case .cameraPermissionsNotGranted: Bundle.main.infoDictionary?["NSCameraUsageDescription"] as? String ?? ""
        default: ""
    }}
}
