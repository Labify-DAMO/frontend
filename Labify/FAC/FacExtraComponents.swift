//
//  FacExtraComponents.swift
//  Labify
//
//  Created by F_S on 10/22/25.
//

import SwiftUI

// MARK: - 수거업체 연결 시트
struct AddPickupRelationSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FacViewModel
    
    @State private var selectedPickupFacilityId: Int? = nil
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("연결할 수거업체를 선택하세요")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.isLoading && viewModel.pickupFacilities.isEmpty {
                    ProgressView("목록 불러오는 중…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 수거업체 목록 (type == "PICKUP")
                List(viewModel.pickupFacilities, id: \.id, selection: $selectedPickupFacilityId) { f in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(f.name)
                                .font(.body.weight(.semibold))
                            Text(f.address)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if selectedPickupFacilityId == f.id {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedPickupFacilityId = f.id }
                }
                .listStyle(.insetGrouped)
                
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
                    
                    Button("연결하기") {
                        Task {
                            guard
                                let pickupId = selectedPickupFacilityId,
                                let labFacilityId = viewModel.facilityId,
                                !isSubmitting
                            else { return }
                            
                            isSubmitting = true
                            let ok = await viewModel.createFacilityRelation(
                                labFacilityId: labFacilityId,
                                pickupFacilityId: pickupId
                            )
                            isSubmitting = false
                            if ok { isPresented = false }
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
                    .disabled(selectedPickupFacilityId == nil || viewModel.facilityId == nil || isSubmitting)
                    .opacity((selectedPickupFacilityId == nil || viewModel.facilityId == nil) ? 0.5 : 1)
                }
            }
            .padding()
            .navigationTitle("수거업체 연결")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { isPresented = false }
                }
            }
            .task {
                // 필요 시 수거업체 목록 갱신
                if viewModel.pickupFacilities.isEmpty {
                    await viewModel.fetchPickupFacilities()
                }
            }
        }
    }
}


// MARK: - 수거업체 관계 카드
struct PickupRelationCard: View {
    let relation: FacilityRelation
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("관계 #\(relation.id)")
                    .font(.system(size: 16, weight: .semibold))
                // 모델에 이름 필드가 있다면 주석 해제해서 사용
                // Text("\(relation.labFacilityName) ↔︎ \(relation.pickupFacilityName)")
                //     .font(.system(size: 14)).foregroundColor(.gray)
            }
            Spacer()
            Button(role: .destructive) {
                onDelete()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("삭제")
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}


// MARK: - 시설 가입 요청 카드
/// 서버 모델 `FacilityJoinRequestItem`을 그대로 받아 표시.
/// 모델 필드가 프로젝트마다 다를 수 있어 **필수 id만 사용**하고,
/// 나머지는 있으면 표시, 없으면 자동으로 생략되도록 옵셔널 접근을 사용.
struct FacilityJoinRequestCard: View {
    let request: FacilityJoinRequestItem
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단 타이틀
            HStack {
                Text("가입 요청 #\(request.id)")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                // createdAt이 있다면 보여주기
                if let createdAt = (request as? HasCreatedAt)?.createdAt {
                    Text(formatDate(createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            // 본문 정보 (존재하는 필드만 안전하게 출력)
            VStack(alignment: .leading, spacing: 4) {
                if let requesterName = (request as? HasRequesterName)?.requesterName, !requesterName.isEmpty {
                    HStack(spacing: 8) {
                        Text("요청자").font(.caption).foregroundColor(.gray)
                        Text(requesterName).font(.callout)
                    }
                }
                if let requesterEmail = (request as? HasRequesterEmail)?.requesterEmail, !requesterEmail.isEmpty {
                    HStack(spacing: 8) {
                        Text("이메일").font(.caption).foregroundColor(.gray)
                        Text(requesterEmail).font(.callout).foregroundColor(.gray)
                    }
                }
                if let facilityCode = (request as? HasFacilityCode)?.facilityCode, !facilityCode.isEmpty {
                    HStack(spacing: 8) {
                        Text("시설 코드").font(.caption).foregroundColor(.gray)
                        Text(facilityCode).font(.callout).foregroundColor(.gray)
                    }
                }
                if let status = (request as? HasStatus)?.status, !status.isEmpty {
                    HStack(spacing: 8) {
                        Text("상태").font(.caption).foregroundColor(.gray)
                        Text(status).font(.callout).foregroundColor(.gray)
                    }
                }
            }
            
            HStack(spacing: 8) {
                Button("거절") {
                    onReject()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(white: 0.95))
                .foregroundColor(.red)
                .cornerRadius(8)
                
                Button("승인") {
                    onConfirm()
                }
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
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        // 서버 포맷이 다를 수 있어 실패 시 원문 그대로 표시
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - FacilityJoinRequestItem의 선택적 필드를 안전하게 읽기 위한 프로토콜들
/// 실제 모델 구조가 달라도, 존재할 때만 그 값을 읽어 UI에 표시할 수 있도록 얇은 프로토콜로 감쌌습니다.
/// (모델에 해당 프로퍼티가 없다면 그냥 표시 안 됩니다.)
protocol HasCreatedAt { var createdAt: String { get } }
protocol HasRequesterName { var requesterName: String { get } }
protocol HasRequesterEmail { var requesterEmail: String { get } }
protocol HasFacilityCode { var facilityCode: String { get } }
protocol HasStatus { var status: String { get } }
