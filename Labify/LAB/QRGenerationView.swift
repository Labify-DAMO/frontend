//
//  QRGenerationView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct QRGenerationView: View {
    @StateObject private var qrViewModel = QRViewModel()
    @StateObject private var wasteViewModel = WasteViewModel()
    @StateObject private var labViewModel = LabViewModel()
    
    @State private var selectedLab: Lab?
    @State private var showingLabSelector = false
    @State private var showingQRDetail = false
    @State private var selectedWaste: DisposalItemData?
    @State private var searchText = ""
    
    private var filteredWastes: [DisposalItemData] {
        if searchText.isEmpty {
            return wasteViewModel.disposalItems
        }
        return wasteViewModel.disposalItems.filter {
            $0.wasteTypeName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 바
                searchBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 실험실 선택
                        labSelectionSection
                        
                        // 폐기물 목록
                        wasteListSection
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("QR 생성")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingLabSelector) {
                QRLabSelectorSheet(
                    labs: labViewModel.labs,
                    selectedLab: $selectedLab
                )
            }
            .sheet(isPresented: $showingQRDetail) {
                if let waste = selectedWaste {
                    QRDetailSheet(
                        qrViewModel: qrViewModel,
                        waste: waste
                    )
                }
            }
            .task {
                await labViewModel.fetchLabs()
                if let firstLab = labViewModel.labs.first {
                    selectedLab = firstLab
                    await wasteViewModel.fetchDisposalItems(labId: firstLab.id)
                }
            }
            .alert("오류", isPresented: $qrViewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(qrViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
            .onChange(of: selectedLab?.id) { oldValue, newValue in
                if let labId = newValue {
                    Task {
                        await wasteViewModel.fetchDisposalItems(labId: labId)
                    }
                }
            }
        }
    }
    
    // MARK: - 검색 바
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField("폐기물 검색", text: $searchText)
                .font(.system(size: 16))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
    }
    
    // MARK: - 실험실 선택 섹션
    private var labSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실험실 선택")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingLabSelector = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let lab = selectedLab {
                            Text(lab.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text(lab.location)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        } else {
                            Text("실험실을 선택하세요")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - 폐기물 목록 섹션
    private var wasteListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("등록된 폐기물")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(filteredWastes.count)건")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            if wasteViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(40)
            } else if filteredWastes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(searchText.isEmpty ? "등록된 폐기물이 없습니다" : "검색 결과가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                VStack(spacing: 12) {
                    ForEach(filteredWastes) { waste in
                        QRWasteItemRow(
                            waste: waste,
                            hasQRCode: qrViewModel.hasCachedQRCode(disposalItemId: waste.id)
                        ) {
                            selectedWaste = waste
                            showingQRDetail = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 폐기물 항목 Row
struct QRWasteItemRow: View {
    let waste: DisposalItemData
    let hasQRCode: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // QR 아이콘
                ZStack {
                    Circle()
                        .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: hasQRCode ? "qrcode" : "qrcode.viewfinder")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(waste.wasteTypeName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f %@", waste.weight, waste.unit))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        if let availableUntil = waste.availableUntil {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Text(formatAvailableUntil(availableUntil))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if hasQRCode {
                        Text("QR 생성 완료")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAvailableUntil(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM/dd"
        return displayFormatter.string(from: date)
    }
}

// MARK: - QR 상세 Sheet
struct QRDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var qrViewModel: QRViewModel
    let waste: DisposalItemData
    
    @State private var isLoading = false
    @State private var showLocalError = false
    @State private var localErrorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 폐기물 정보
                    wasteInfoSection
                    
                    // QR 코드 이미지
                    qrCodeSection
                    
                    // 액션 버튼들
                    actionButtons
                }
                .padding(20)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("QR 코드")
                        .font(.system(size: 17, weight: .semibold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadQRCode()
            }
            .alert("오류", isPresented: $showLocalError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(localErrorMessage)
            }
        }
        .presentationDragIndicator(.visible)
        .onChange(of: qrViewModel.showError) { oldValue, newValue in
            if newValue {
                localErrorMessage = qrViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."
                showLocalError = true
                qrViewModel.showError = false // ViewModel의 에러 플래그 초기화
            }
        }
    }
    
    // MARK: - 폐기물 정보 섹션
    private var wasteInfoSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 244/255, green: 247/255, blue: 255/255))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "flask.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(waste.wasteTypeName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.1f %@", waste.weight, waste.unit))
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let memo = waste.memo, !memo.isEmpty {
                HStack {
                    Text(memo)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - QR 코드 섹션
    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            if isLoading || qrViewModel.isLoading || qrViewModel.isGenerating {
                ProgressView()
                    .frame(width: 280, height: 280)
                    .background(Color.white)
                    .cornerRadius(16)
            } else if let qrCode = qrViewModel.currentQRCode,
                      qrCode.id == waste.id,
                      let image = qrCode.image {
                VStack(spacing: 12) {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    
                    Text("QR 코드를 스캔하여 폐기물 정보를 확인하세요")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("QR 코드를 생성하세요")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        Task {
                            await generateQRCode()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "qrcode")
                            Text("QR 생성하기")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 30/255, green: 59/255, blue: 207/255),
                                    Color(red: 113/255, green: 100/255, blue: 230/255)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3), radius: 8, y: 4)
                    }
                }
                .frame(width: 280, height: 280)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
    
    // MARK: - 액션 버튼들
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if qrViewModel.currentQRCode?.id == waste.id {
                Button(action: {
                    if let image = qrViewModel.getShareableImage() {
                        shareQRCode(image: image)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("공유하기")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 1.5)
                    )
                }
                
                Button(action: {
                    _ = qrViewModel.saveQRCodeToPhotos()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                        Text("사진에 저장")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255), lineWidth: 1.5)
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadQRCode() async {
        print("🟣 loadQRCode 시작: \(waste.wasteTypeName), ID=\(waste.id)")
        isLoading = true
        let result = await qrViewModel.getOrCreateQRCode(
            disposalItemId: waste.id,
            wasteTypeName: waste.wasteTypeName,
            weight: waste.weight,
            unit: waste.unit
        )
        isLoading = false
        print("🟣 loadQRCode 완료: 결과=\(result)")
    }
    
    private func generateQRCode() async {
        print("🟣 generateQRCode 버튼 클릭: \(waste.wasteTypeName), ID=\(waste.id)")
        await qrViewModel.generateQRCode(
            disposalItemId: waste.id,
            wasteTypeName: waste.wasteTypeName,
            weight: waste.weight,
            unit: waste.unit
        )
    }
    
    private func shareQRCode(image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Lab Selector Sheet (QR용)
struct QRLabSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let labs: [Lab]
    @Binding var selectedLab: Lab?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(labs) { lab in
                        Button(action: {
                            selectedLab = lab
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(lab.name)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.primary)
                                    Text(lab.location)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if selectedLab?.id == lab.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        if lab.id != labs.last?.id {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            .navigationTitle("실험실 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    QRGenerationView()
}
