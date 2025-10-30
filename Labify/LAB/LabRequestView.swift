//
//  LabRequestView.swift
//  Labify
//
//  Created by F_S on 10/30/25.
//

import SwiftUI

struct LabRequestView: View {
    @StateObject private var requestViewModel = RequestViewModel()
    @StateObject private var wasteViewModel = WasteViewModel()
    @StateObject private var labViewModel = LabViewModel()
    
    @State private var selectedLab: Lab?
    @State private var selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var showingLabSelector = false
    @State private var showingDatePicker = false
    @State private var showingSuccessAlert = false
    @State private var searchText = ""
    
    private var filteredWastes: [DisposalItemData] {
        if searchText.isEmpty {
            return wasteViewModel.disposalItems
        }
        return wasteViewModel.disposalItems.filter {
            $0.wasteTypeName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var selectedWastes: [DisposalItemData] {
        wasteViewModel.disposalItems.filter { waste in
            requestViewModel.selectedDisposalIds.contains(waste.id)
        }
    }
    
    private var totalWeight: Double {
        selectedWastes.reduce(0) { $0 + $1.weight }
    }
    
    private var canSubmit: Bool {
        selectedLab != nil && !requestViewModel.selectedDisposalIds.isEmpty
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
                        
                        // 수거 요청 날짜
                        dateSelectionSection
                        
                        // 선택 요약
                        if !requestViewModel.selectedDisposalIds.isEmpty {
                            selectionSummarySection
                        }
                        
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
                    Text("수거 요청")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .safeAreaInset(edge: .bottom) {
                submitButton
            }
            .sheet(isPresented: $showingLabSelector) {
                RequestLabSelectorSheet(
                    labs: labViewModel.labs,
                    selectedLab: $selectedLab
                )
            }
            .sheet(isPresented: $showingDatePicker) {
                RequestDatePickerSheet(selectedDate: $selectedDate)
            }
            .task {
                await labViewModel.fetchLabs()
                if let firstLab = labViewModel.labs.first {
                    selectedLab = firstLab
                    await wasteViewModel.fetchDisposalItems(labId: firstLab.id)
                }
            }
            .alert("수거 요청 완료", isPresented: $showingSuccessAlert) {
                Button("확인") {
                    requestViewModel.clearSelection()
                }
            } message: {
                Text(requestViewModel.successMessage ?? "수거 요청이 성공적으로 생성되었습니다.")
            }
            .alert("오류", isPresented: $requestViewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(requestViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
            .onChange(of: selectedLab?.id) { oldValue, newValue in
                if let labId = newValue {
                    requestViewModel.clearSelection()
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
    
    // MARK: - 날짜 선택 섹션
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수거 요청 날짜")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Button(action: {
                showingDatePicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    
                    Text(formatDate(selectedDate))
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
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
    
    // MARK: - 선택 요약 섹션
    private var selectionSummarySection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("선택한 폐기물")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("\(requestViewModel.selectedCount)건")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("총 무게")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f kg", totalWeight))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 244/255, green: 247/255, blue: 255/255),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.1), radius: 8, x: 0, y: 2)
            
            Button(action: {
                requestViewModel.clearSelection()
            }) {
                Text("전체 선택 해제")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                    .padding(.vertical, 8)
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
                    Image(systemName: "tray")
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
                        RequestWasteItemRow(
                            waste: waste,
                            isSelected: requestViewModel.isSelected(waste.id)
                        ) {
                            requestViewModel.toggleDisposalSelection(waste.id)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 제출 버튼
    private var submitButton: some View {
        Button(action: {
            Task {
                await submitRequest()
            }
        }) {
            HStack(spacing: 12) {
                if requestViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("수거 요청하기")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: canSubmit ? [
                        Color(red: 30/255, green: 59/255, blue: 207/255),
                        Color(red: 113/255, green: 100/255, blue: 230/255)
                    ] : [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: canSubmit ? Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
        .disabled(!canSubmit || requestViewModel.isLoading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func submitRequest() async {
        guard let lab = selectedLab else { return }
        
        let disposalIds = Array(requestViewModel.selectedDisposalIds)
        
        let success = await requestViewModel.createRequest(
            labId: lab.id,
            requestDate: selectedDate,
            disposalItemIds: disposalIds
        )
        
        if success {
            showingSuccessAlert = true
            // 폐기물 목록 새로고침
            await wasteViewModel.fetchDisposalItems(labId: lab.id)
        }
    }
}

// MARK: - 폐기물 항목 Row
struct RequestWasteItemRow: View {
    let waste: DisposalItemData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 선택 체크박스
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(red: 30/255, green: 59/255, blue: 207/255) : .gray.opacity(0.3))
                
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
                    
                    if let memo = waste.memo, !memo.isEmpty {
                        Text(memo)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                isSelected ?
                Color(red: 244/255, green: 247/255, blue: 255/255) :
                Color.white
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ?
                        Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.3) :
                        Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: 8, x: 0, y: 2)
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

// MARK: - Lab Selector Sheet (Request용)
struct RequestLabSelectorSheet: View {
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

// MARK: - Date Picker Sheet (Request용)
struct RequestDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            DatePicker(
                "수거 요청 날짜",
                selection: $tempDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Color(red: 30/255, green: 59/255, blue: 207/255))
            .padding(20)
            .navigationTitle("수거 요청 날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        selectedDate = tempDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    LabRequestView()
}
