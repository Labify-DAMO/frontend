//
//  QRScannerView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var pickupViewModel = PickupViewModel()
    @StateObject private var scannerViewModel = QRScannerViewModel()
    
    @State private var showingResult = false
    @State private var scannedCode: String?
    @State private var scanResult: QRScanResponse?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 카메라 뷰
                QRCodeScannerRepresentable(
                    onCodeScanned: { code in
                        handleScannedCode(code)
                    },
                    isScanning: scannerViewModel.isScanning
                )
                .edgesIgnoringSafeArea(.all)
                
                // 오버레이
                VStack {
                    Spacer()
                    
                    // 스캔 가이드
                    scanGuideOverlay
                    
                    Spacer()
                    
                    // 하단 컨트롤
                    bottomControls
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("QR 스캔")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingResult) {
                if let result = scanResult {
                    QRScanResultView(
                        scanResult: result,
                        onComplete: {
                            showingResult = false
                            scannerViewModel.resumeScanning()
                        }
                    )
                }
            }
            .alert("오류", isPresented: $pickupViewModel.showError) {
                Button("확인", role: .cancel) {
                    scannerViewModel.resumeScanning()
                }
            } message: {
                Text(pickupViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // MARK: - 스캔 가이드 오버레이
    private var scanGuideOverlay: some View {
        VStack(spacing: 24) {
            Text("QR 코드를 스캔하세요")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // 스캔 프레임
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 30/255, green: 59/255, blue: 207/255),
                            Color(red: 113/255, green: 100/255, blue: 230/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 280, height: 280)
                .overlay(
                    // 스캔 라인 애니메이션
                    scannerViewModel.isScanning ?
                    Rectangle()
                        .fill(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3))
                        .frame(height: 3)
                        .offset(y: scannerViewModel.scanLineOffset)
                    : nil
                )
            
            Text("폐기물 QR 코드를 프레임 안에 맞춰주세요")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - 하단 컨트롤
    private var bottomControls: some View {
        VStack(spacing: 16) {
            if pickupViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(12)
            }
            
            HStack(spacing: 20) {
                // 플래시
                Button(action: {
                    scannerViewModel.toggleFlash()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: scannerViewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 24))
                        Text("플래시")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(16)
                }
                
                // 수동 입력
                Button(action: {
                    // TODO: 수동 입력 기능
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 24))
                        Text("수동 입력")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(16)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Helper Functions
    private func handleScannedCode(_ code: String) {
        print("🔍 QR 스캔됨: \(code)")
        
        scannedCode = code
        scannerViewModel.pauseScanning()
        
        Task {
            let success = await pickupViewModel.scanQRCode(code: code)
            
            if success {
                // 스캔 결과 표시
                // TODO: API 응답에서 결과 가져오기
                scanResult = QRScanResponse(
                    disposalId: 0,
                    status: "PICKED_UP",
                    processedAt: ISO8601DateFormatter().string(from: Date())
                )
                showingResult = true
            } else {
                // 에러는 alert로 표시됨
                scannerViewModel.resumeScanning()
            }
        }
    }
}

// MARK: - QR Scanner ViewModel
@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var isScanning = true
    @Published var isFlashOn = false
    @Published var scanLineOffset: CGFloat = -140
    
    private var timer: Timer?
    
    init() {
        startScanLineAnimation()
    }
    
    func pauseScanning() {
        isScanning = false
        timer?.invalidate()
    }
    
    func resumeScanning() {
        isScanning = true
        startScanLineAnimation()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        // Flash toggle은 AVCaptureDevice에서 처리
    }
    
    private func startScanLineAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            withAnimation(.linear(duration: 0.02)) {
                if self.scanLineOffset >= 140 {
                    self.scanLineOffset = -140
                } else {
                    self.scanLineOffset += 2
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - QR Code Scanner Representable
struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    let isScanning: Bool
    
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
        Coordinator(onCodeScanned: onCodeScanned)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        let onCodeScanned: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }
        
        func didScanCode(_ code: String) {
            onCodeScanned(code)
        }
    }
}

// MARK: - QR Scanner Delegate
protocol QRScannerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

// MARK: - QR Scanner View Controller
class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ 카메라를 사용할 수 없습니다")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("❌ 카메라 입력 생성 실패: \(error)")
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            print("❌ 카메라 입력을 추가할 수 없습니다")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("❌ 메타데이터 출력을 추가할 수 없습니다")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }
    
    func startScanning() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanCode(stringValue)
        }
    }
}

#Preview {
    QRScannerView()
}
