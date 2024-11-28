//
//  DefaultCameraView.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

public struct DefaultCameraView: MCameraView {
    @ObservedObject public var cameraManager: CameraManager
    public let namespace: Namespace.ID
    public let closeControllerAction: () -> ()
    var config: Config = .init()

    @State var orientation = UIDevice.current.orientation

    public var body: some View {
        GeometryReader { geo in
            if geo.size.width < geo.size.height {
                VStack(spacing: 0) {
                    createTopView(isPortrait: true)
                    createContentView()
                    createBottomView(isPortrait: true)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background.ignoresSafeArea())
                .animation(.defaultSpring, value: isRecording)
                .animation(.defaultSpring, value: outputType)
                .animation(.defaultSpring, value: hasTorch)
                .animation(.defaultSpring, value: iconAngle)
            } else if geo.size.width > geo.size.height {
                if orientation == .landscapeLeft {
                    HStack(spacing: 0) {
                        createTopView(isPortrait: false)
                        createContentView()
                        createBottomView(isPortrait: false)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background.ignoresSafeArea())
                    .animation(.defaultSpring, value: isRecording)
                    .animation(.defaultSpring, value: outputType)
                    .animation(.defaultSpring, value: hasTorch)
                    .animation(.defaultSpring, value: iconAngle)
                } else if orientation == .landscapeRight {
                     HStack(spacing: 0) {
                        createBottomView(isPortrait: false)
                        createContentView()
                        createTopView(isPortrait: false)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background.ignoresSafeArea())
                    .animation(.defaultSpring, value: isRecording)
                    .animation(.defaultSpring, value: outputType)
                    .animation(.defaultSpring, value: hasTorch)
                    .animation(.defaultSpring, value: iconAngle)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            if UIDevice.current.orientation != .faceUp && UIDevice.current.orientation != .faceDown && UIDevice.current.orientation != .portraitUpsideDown {
                self.orientation = UIDevice.current.orientation
            }
        }
    }
}
private extension DefaultCameraView {
    func createTopView(isPortrait: Bool) -> some View {
        if isPortrait {
            ZStack {
                createCloseButton(isPortrait: true)
                createTopCentreView(isPortrait: true)
                createTopRightView(isPortrait: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            .padding(.bottom, 12)
            .padding(.horizontal, 20)
        } else {
            ZStack {
                createCloseButton(isPortrait: false)
                createTopCentreView(isPortrait: false)
                createTopRightView(isPortrait: false)
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 4)
            .padding(.trailing, 12)
            .padding(.vertical, 20)
        }
    }
    func createContentView() -> some View {
        ZStack {
            createCameraView()
        }
    }
    func createBottomView(isPortrait: Bool) -> some View {
        if isPortrait {
            ZStack {
                createTorchButton(isPortrait: true)
                createCaptureButton(isPortrait: true)
                createChangeCameraButton(isPortrait: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 32)
        } else {
            ZStack {
                createTorchButton(isPortrait: false)
                createCaptureButton(isPortrait: false)
                createChangeCameraButton(isPortrait: false)
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 16)
            .padding(.trailing, 12)
            .padding(.vertical, 32)
        }
    }
}
private extension DefaultCameraView {
    func createOutputTypeButtons() -> some View {
        HStack(spacing: 8) {
            createOutputTypeButton(.video)
            createOutputTypeButton(.photo)
        }
        .padding(8)
        .background(Color.background.opacity(0.64))
        .mask(Capsule())
        .transition(.asymmetric(insertion: .opacity.animation(.defaultSpring.delay(1)), removal: .scale.combined(with: .opacity)))
        .isActive(!isRecording)
        .isActive(config.outputTypePickerVisible)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 8)
    }
}
private extension DefaultCameraView {
    @ViewBuilder
    func createCloseButton(isPortrait: Bool) -> some View {
        if isPortrait {
            CloseButton(action: closeControllerAction)
                .rotationEffect(iconAngle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .isActive(!isRecording)
        }
        else {
            let alignment: Alignment = UIDevice.current.orientation == .landscapeRight ? .top : .bottom
            CloseButton(action: closeControllerAction)
                .rotationEffect(iconAngle)
                .frame(maxHeight: .infinity, alignment: alignment)
                .isActive(!isRecording)
        }
    }
    func createTopCentreView(isPortrait: Bool) -> some View {
        Text(recordingTime.toString())
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .foregroundColor(.white)
            .isActive(isRecording)
    }
    @ViewBuilder
    func createTopRightView(isPortrait: Bool) -> some View {
        if isPortrait {
            Group {
                HStack(spacing: 12) {
                    createGridButton()
                    createFlashButton()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .isActive(!isRecording)
                }
        } else {
            let alignment: Alignment = UIDevice.current.orientation == .landscapeRight ? .bottom : .top
            Group {
                VStack(spacing: 12) {
                    createGridButton()
                    createFlashButton()
                }
                .frame(maxHeight: .infinity, alignment: alignment)
                .isActive(!isRecording)
            }
        }
    }
}
private extension DefaultCameraView {
    func createGridButton() -> some View {
        TopButton(icon: gridButtonIcon, action: changeGridVisibility)
            .rotationEffect(iconAngle)
            .isActiveStackElement(config.gridButtonVisible)
    }
    func createFlipOutputButton() -> some View {
        TopButton(icon: flipButtonIcon, action: changeMirrorOutput)
            .rotationEffect(iconAngle)
            .isActiveStackElement(cameraPosition == .front)
            .isActiveStackElement(config.flipButtonVisible)
    }
    func createFlashButton() -> some View {
        TopButton(icon: flashButtonIcon, action: changeFlashMode)
            .rotationEffect(iconAngle)
            .isActiveStackElement(hasFlash)
            .isActiveStackElement(outputType == .photo)
            .isActiveStackElement(config.flashButtonVisible)
    }
}
private extension DefaultCameraView {
    @ViewBuilder
    func createTorchButton(isPortrait: Bool) -> some View {
        if isPortrait {
            BottomButton(icon: "icon-torch", active: torchMode == .on, action: changeTorchMode)
                .matchedGeometryEffect(id: "button-bottom-left", in: namespace)
                .rotationEffect(iconAngle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .isActive(hasTorch)
                .isActive(config.torchButtonVisible)
        } else {
            let alignment: Alignment = UIDevice.current.orientation == .landscapeRight ? .top : .bottom
            BottomButton(icon: "icon-torch", active: torchMode == .on, action: changeTorchMode)
                .matchedGeometryEffect(id: "button-bottom-left", in: namespace)
                .rotationEffect(iconAngle)
                .frame(maxHeight: .infinity, alignment: alignment)
                .isActive(hasTorch)
                .isActive(config.torchButtonVisible)
        }
    }
    func createCaptureButton(isPortrait: Bool) -> some View {
        CaptureButton(action: captureOutput, mode: outputType, isRecording: isRecording).isActive(config.captureButtonVisible)
    }
    @ViewBuilder
    func createChangeCameraButton(isPortrait: Bool) -> some View {
        if isPortrait {
            BottomButton(icon: "icon-change-camera", active: false, action: changeCameraPosition)
                .matchedGeometryEffect(id: "button-bottom-right", in: namespace)
                .rotationEffect(iconAngle)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .isActive(!isRecording)
                .isActive(config.changeCameraButtonVisible)
        } else {
            let alignment: Alignment = UIDevice.current.orientation == .landscapeRight ? .bottom : .top
            BottomButton(icon: "icon-change-camera", active: false, action: changeCameraPosition)
                .matchedGeometryEffect(id: "button-bottom-right", in: namespace)
                .rotationEffect(iconAngle)
                .frame(maxHeight: .infinity, alignment: alignment)
                .isActive(!isRecording)
                .isActive(config.changeCameraButtonVisible)
        }
    }
    func createOutputTypeButton(_ cameraOutputType: CameraOutputType) -> some View {
        OutputTypeButton(type: cameraOutputType, active: cameraOutputType == outputType, action: { changeCameraOutputType(cameraOutputType) })
            .rotationEffect(iconAngle)
    }
}
private extension DefaultCameraView {
    var iconAngle: Angle { switch isOrientationLocked {
        case true: deviceOrientation.getAngle()
        case false: .zero
    }}
    var gridButtonIcon: String { switch showGrid {
        case true: "icon-grid-on"
        case false: "icon-grid-off"
    }}
    var flipButtonIcon: String { switch mirrorOutput {
        case true: "icon-flip-on"
        case false: "icon-flip-off"
    }}
    var flashButtonIcon: String { switch flashMode {
        case .off: "icon-flash-off"
        case .on: "icon-flash-on"
        case .auto: "icon-flash-auto"
    }}
}

private extension DefaultCameraView {
    func changeGridVisibility() {
        changeGridVisibility(!showGrid)
    }
    func changeMirrorOutput() {
        changeMirrorOutputMode(!mirrorOutput)
    }
    func changeFlashMode() {
        do { try changeFlashMode(flashMode.next()) }
        catch {}
    }
    func changeTorchMode() {
        do { try changeTorchMode(torchMode.next()) }
        catch {}
    }
    func changeCameraPosition() {
        do { try changeCamera(cameraPosition.next()) }
        catch {}
    }
    func changeCameraOutputType(_ type: CameraOutputType) {
        do { try changeOutputType(type) }
        catch {}
    }
}

// MARK: - Configurables
extension DefaultCameraView { struct Config {
    var outputTypePickerVisible: Bool = true
    var torchButtonVisible: Bool = true
    var captureButtonVisible: Bool = true
    var changeCameraButtonVisible: Bool = true
    var gridButtonVisible: Bool = true
    var flipButtonVisible: Bool = true
    var flashButtonVisible: Bool = true
}}


// MARK: - CloseButton
fileprivate struct CloseButton: View {
    let action: () -> ()


    var body: some View {
        Button(action: action) {
            Image("icon-cancel", bundle: .mijick)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color.white)
        }
    }
}

// MARK: - TopButton
fileprivate struct TopButton: View {
    let icon: String
    let action: () -> ()


    var body: some View {
        Button(action: action, label: createButtonLabel)
    }
}
private extension TopButton {
    func createButtonLabel() -> some View {
        ZStack {
            createBackground()
            createIcon()
        }
    }
}
private extension TopButton {
    func createBackground() -> some View {
        Circle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 32, height: 32)
    }
    func createIcon() -> some View {
        Image(icon, bundle: .mijick)
            .resizable()
            .frame(width: 16, height: 16)
            .foregroundColor(Color.white)
    }
}

// MARK: - CaptureButton
fileprivate struct CaptureButton: View {
    let action: () -> ()
    let mode: CameraOutputType
    let isRecording: Bool


    var body: some View {
        Button(action: action, label: createButtonLabel).buttonStyle(ButtonScaleStyle())
    }
}
private extension CaptureButton {
    func createButtonLabel() -> some View {
        ZStack {
            createBackground()
            createBorders()
        }.frame(width: 72, height: 72)
    }
}
private extension CaptureButton {
    func createBackground() -> some View {
        RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
            .fill(backgroundColor)
            .padding(backgroundPadding)
    }
    func createBorders() -> some View {
        Circle().stroke(Color.white, lineWidth: 2.5)
    }
}
private extension CaptureButton {
    var backgroundColor: Color { switch mode {
        case .photo: .white
        case .video: .red
    }}
    var backgroundCornerRadius: CGFloat { switch isRecording {
        case true: 5
        case false: 34
    }}
    var backgroundPadding: CGFloat { switch isRecording {
        case true: 20
        case false: 4
    }}
}

// MARK: - BottomButton
fileprivate struct BottomButton: View {
    let icon: String
    let active: Bool
    let action: () -> ()


    var body: some View {
        Button(action: action, label: createButtonLabel)
            .buttonStyle(ButtonScaleStyle())
            .transition(.scale.combined(with: .opacity))
    }
}
private extension BottomButton {
    func createButtonLabel() -> some View {
        ZStack {
            createBackground()
            createIcon()
        }.frame(width: 52, height: 52)
    }
}
private extension BottomButton {
    func createBackground() -> some View {
        Circle().fill(Color.white.opacity(0.12))
    }
    func createIcon() -> some View {
        Image(icon, bundle: .mijick)
            .resizable()
            .frame(width: 26, height: 26)
            .foregroundColor(iconColor)
    }
}
private extension BottomButton {
    var iconColor: Color { switch active {
        case true: .yellow
        case false: .white
    }}
}

// MARK: - OutputTypeButton
fileprivate struct OutputTypeButton: View {
    let type: CameraOutputType
    let active: Bool
    let action: () -> ()


    var body: some View {
        Button(action: action, label: createButtonLabel).buttonStyle(ButtonScaleStyle())
    }
}
private extension OutputTypeButton {
    func createButtonLabel() -> some View {
        Image(icon, bundle: .mijick)
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(iconColor)
            .frame(width: backgroundSize, height: backgroundSize)
            .background(Color.white.opacity(0.12))
            .mask(Circle())
    }
}
private extension OutputTypeButton {
    var icon: String { "icon-" + .init(describing: type) }
    var iconSize: CGFloat { switch active {
        case true: 28
        case false: 22
    }}
    var backgroundSize: CGFloat { switch active {
        case true: 44
        case false: 32
    }}
    var iconColor: Color { switch active {
        case true: .yellow
        case false: .white.opacity(0.6)
    }}
}
