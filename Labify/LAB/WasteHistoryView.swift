//
//  WasteHistoryView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct WasteHistoryView: View {
    @StateObject private var wasteViewModel = WasteViewModel()
    @StateObject private var labViewModel = LabViewModel()
    @State private var selectedLab: Lab?
    @State private var selectedStatus: DisposalStatus?
    @State private var searchText = ""
    @State private var showingLabSelector = false
    
    private var filteredWastes: [DisposalItemData] {
        var wastes = wasteViewModel.disposalItems
        
        // 상태 필터링
        if let status = selectedStatus {
            wastes = wastes.filter { $0.statusEnum == status }
        }
        
        // 검색 필터링
        if !searchText.isEmpty {
            wastes = wastes.filter {
                $0.wasteTypeName.localizedCaseInsensitiveContains(searchText) ||
                $0.labName.localizedCaseInsensitiveContains(searchText) ||
                ($0.memo?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return wastes
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색 바
            searchBar
            
            // 필터 영역
            VStack(spacing: 12) {
                // 실험실 선택
                if labViewModel.labs.count > 1 {
                    Button(action: {
                        showingLabSelector = true
                    }) {
                        HStack {
                            Text(selectedLab?.name ?? "전체 실험실")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                
                // 상태 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        StatusFilterButton(
                            title: "전체",
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(DisposalStatus.allCases, id: \.self) { status in
                            StatusFilterButton(
                                title: status.displayName,
                                count: wasteViewModel.getCountByStatus(status),
                                isSelected: selectedStatus == status
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
            
            Divider()
            
            // 폐기물 목록
            if wasteViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredWastes.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredWastes) { waste in
                            WasteHistoryCard(waste: waste)
                        }
                    }
                    .padding(20)
                }
                .background(Color(red: 249/255, green: 250/255, blue: 252/255))
                .refreshable {
                    await loadWastes()
                }
            }
        }
        .navigationTitle("등록 이력")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingLabSelector) {
            WasteLabSelectorSheet(
                labs: labViewModel.labs,
                selectedLab: $selectedLab
            )
        }
        .task {
            await labViewModel.fetchLabs()
            await loadWastes()
        }
        .onChange(of: selectedLab?.id) { _, _ in
            Task {
                await loadWastes()
            }
        }
        .alert("오류", isPresented: $wasteViewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(wasteViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
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
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(searchText.isEmpty ? "등록된 폐기물이 없습니다" : "검색 결과가 없습니다")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Text("폐기물을 등록하고 관리를 시작해보세요")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 249/255, green: 250/255, blue: 252/255))
    }
    
    // MARK: - Helper Functions
    private func loadWastes() async {
        await wasteViewModel.fetchDisposalItems(
            labId: selectedLab?.id,
            status: nil
        )
    }
}

// MARK: - Status Filter Button
struct StatusFilterButton: View {
    let title: String
    var count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [
                        Color(red: 30/255, green: 59/255, blue: 207/255),
                        Color(red: 113/255, green: 100/255, blue: 230/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(18)
        }
    }
}

// MARK: - Waste History Card
struct WasteHistoryCard: View {
    let waste: DisposalItemData
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(waste.wasteTypeName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "building.2")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(waste.labName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 상태 뱃지
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(waste.statusEnum?.displayName ?? waste.status)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(16)
            
            Divider()
            
            // 상세 정보
            VStack(spacing: 12) {
                HStack {
                    WasteInfoItem(
                        icon: "scalemass",
                        title: "무게",
                        value: String(format: "%.1f %@", waste.weight, waste.unit)
                    )
                    
                    Spacer()
                    
                    WasteInfoItem(
                        icon: "calendar",
                        title: "등록일",
                        value: formatDate(waste.createdAt)
                    )
                }
                
                if let availableUntil = waste.availableUntil {
                    HStack {
                        WasteInfoItem(
                            icon: "clock",
                            title: "보관기한",
                            value: formatDate(availableUntil),
                            isWarning: isExpiringSoon(availableUntil)
                        )
                        Spacer()
                    }
                }
                
                if let memo = waste.memo, !memo.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "note.text")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("메모")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(memo)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var statusColor: Color {
        guard let status = waste.statusEnum else { return .gray }
        switch status {
        case .stored: return Color(red: 30/255, green: 59/255, blue: 207/255)
        case .requested: return .orange
        case .pickedUp: return .green
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
    
    private func isExpiringSoon(_ dateString: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return false }
        
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return daysUntilExpiry <= 3
    }
}

// MARK: - Waste Info Item
struct WasteInfoItem: View {
    let icon: String
    let title: String
    let value: String
    var isWarning: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(isWarning ? .red : .secondary)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isWarning ? .red : .secondary)
            }
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isWarning ? .red : .primary)
        }
    }
}

// MARK: - Lab Selector Sheet
struct WasteLabSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let labs: [Lab]
    @Binding var selectedLab: Lab?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 전체 옵션
                    Button(action: {
                        selectedLab = nil
                        dismiss()
                    }) {
                        HStack {
                            Text("전체 실험실")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedLab == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Divider()
                    
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
                    Button("닫기") {
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
    NavigationStack {
        WasteHistoryView()
    }
}
