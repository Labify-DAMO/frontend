//
//  FacComponent.swift
//  Labify
//
//  Created by F_S on 10/17/25.
//

import SwiftUI

// MARK: - 실험실 등록 시트
struct RegisterLabSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FacViewModel
    let facilityId: Int
    
    @State private var labName = ""
    @State private var location = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("실험실 이름")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: 세포배양실", text: $labName)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: A동 3층 217호", text: $location)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("취소") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.95))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("등록하기") {
                        Task {
                            let success = await viewModel.registerLab(
                                name: labName,
                                location: location,
                                facilityId: facilityId
                            )
                            if success {
                                isPresented = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(labName.isEmpty || location.isEmpty || viewModel.isLoading)
                    .opacity(labName.isEmpty || location.isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("새 실험실 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - 담당자 초대 시트
struct InviteManagerSheet: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 초대 정보 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("초대 정보")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        TextField("이메일 주소", text: $email)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        
                        Text("입력한 이메일 주소로 초대 링크가 전송됩니다.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 252/255))
            .navigationTitle("담당자 초대")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("초대") {
                        Task {
                            await sendInvite()
                        }
                    }
                    .disabled(email.isEmpty || isSubmitting)
                }
            }
            .disabled(isSubmitting)
        }
        .presentationDragIndicator(.visible)
    }
    
    private func sendInvite() async {
        isSubmitting = true
        // TODO: 초대 로직 구현
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isSubmitting = false
        isPresented = false
    }
}

// MARK: - 실험실 수정 시트
struct EditLabSheet: View {
    @Binding var isPresented: Bool
    let lab: Lab
    @ObservedObject var viewModel: FacViewModel
    
    @State private var labName: String
    @State private var location: String
    
    init(isPresented: Binding<Bool>, lab: Lab, viewModel: FacViewModel) {
        self._isPresented = isPresented
        self.lab = lab
        self.viewModel = viewModel
        self._labName = State(initialValue: lab.name)
        self._location = State(initialValue: lab.location)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("실험실 이름")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: 세포배양실", text: $labName)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("위치")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("예: A동 3층 217호", text: $location)
                        .padding()
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("취소") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.95))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("수정하기") {
                        Task {
                            let success = await viewModel.updateLab(
                                labId: lab.id,
                                name: labName,
                                location: location
                            )
                            if success {
                                isPresented = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                     Color(red: 113/255, green: 100/255, blue: 230/255)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(labName.isEmpty || location.isEmpty || viewModel.isLoading)
                    .opacity(labName.isEmpty || location.isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("실험실 정보 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - 실험실 요청 카드
// MARK: - 실험실 개설 요청 카드
// FacComponent.swift

struct LabRequestCard: View {
    let request: LabRequestItem  // ✅ LabRequest → LabRequestItem 변경
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.labName)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text(request.location)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // ✅ status 필드 활용 가능
                Text(statusText(request.status))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(statusColor(request.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(request.status).opacity(0.1))
                    .cornerRadius(12)
            }
            
            Divider()
            
            // 요청 정보
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(title: "요청자", value: request.requesterName)
                InfoRow(title: "요청일", value: formatDate(request.createdAt))
            }
            
            // ✅ PENDING 상태일 때만 액션 버튼 표시
            if request.status == "PENDING" {
                HStack(spacing: 12) {
                    Button(action: onReject) {
                        Text("거절")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onConfirm) {
                        Text("승인")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // ✅ 헬퍼 함수들 추가
    private func statusText(_ status: String) -> String {
        switch status {
        case "PENDING": return "대기중"
        case "APPROVED": return "승인됨"
        case "REJECTED": return "거절됨"
        default: return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "PENDING": return .orange
        case "APPROVED": return .green
        case "REJECTED": return .red
        default: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = simpleFormatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
                displayFormatter.locale = Locale(identifier: "ko_KR")
                return displayFormatter.string(from: date)
            }
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
}

// MARK: - 시설 가입 요청 카드
struct FacilityJoinRequestCard: View {
    let request: FacilityJoinRequestItem
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.userName)
                        .font(.system(size: 17, weight: .semibold))
                    
                    Text("시설 가입 요청")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 상태 배지
                Text(statusText(request.status))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(statusColor(request.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(request.status).opacity(0.1))
                    .cornerRadius(12)
            }
            
            Divider()
            
            // 요청 정보
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(title: "요청일", value: formatDate(request.createdAt))
            }
            
            // 액션 버튼 (PENDING 상태일 때만 표시)
            if request.status == "PENDING" {
                HStack(spacing: 12) {
                    Button(action: onReject) {
                        Text("거절")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onConfirm) {
                        Text("승인")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func statusText(_ status: String) -> String {
        switch status {
        case "PENDING":
            return "대기중"
        case "APPROVED":
            return "승인됨"
        case "REJECTED":
            return "거절됨"
        default:
            return status
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "PENDING":
            return .orange
        case "APPROVED":
            return .green
        case "REJECTED":
            return .red
        default:
            return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        return displayFormatter.string(from: date)
    }
}

// MARK: - 상단 탭 버튼
struct FacilityTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .gray)
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 필터 버튼
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    var isOutlined: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isOutlined ? .primary : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isOutlined {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                                .background(Color.white)
                        } else {
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    }
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - 통계 카드
struct StatCard: View {
    let title: String
    let value: String
    var unit: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .padding(.bottom, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 실험실 카드
struct FacilityCard: View {
    let name: String
    let location: String
    let managerCount: Int
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.system(size: 16, weight: .semibold))
            HStack(spacing: 8) {
                Text(location)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text("담당 \(managerCount)명")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text(isActive ? "활성" : "비활성")
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .blue : .gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
