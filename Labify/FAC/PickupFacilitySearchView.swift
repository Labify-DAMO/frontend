//
//  PickupFacilitySearchView.swift
//  Labify
//
//  Created by F_S on 10/29/25.
//

import SwiftUI

struct PickupFacilitySearchView: View {
    @ObservedObject var viewModel: FacViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var facilityCode = ""
    @State private var showSuccessAlert = false
    @State private var searchCompleted = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("수거업체 연결")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                // 균형을 위한 투명 버튼
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 32) {
                    // 헤더 아이콘 및 타이틀
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("수거업체 시설 코드를 입력하세요")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("수거업체로부터 받은 시설 코드를 입력하면\n해당 업체와 연결됩니다.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, 40)
                    
                    // 입력 필드
                    VStack(alignment: .leading, spacing: 12) {
                        Text("시설 코드")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("예) AB12CD", text: $facilityCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // 조회 버튼
                    if !searchCompleted {
                        Button {
                            Task {
                                await searchPickupFacility()
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else {
                                Text("조회하기")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        .background(
                            formValid && !viewModel.isLoading ?
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(14)
                        .disabled(!formValid || viewModel.isLoading)
                    }
                    
                    // 조회 결과 표시
                    if searchCompleted, let facility = viewModel.searchedPickupFacility {
                        VStack(spacing: 20) {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("수거업체 정보")
                                    .font(.system(size: 18, weight: .bold))
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    InfoRow(title: "업체명", value: facility.name)
                                    InfoRow(title: "주소", value: facility.address)
                                    InfoRow(title: "시설 코드", value: facility.facilityCode)
                                    InfoRow(title: "유형", value: facility.type == "PICKUP" ? "수거업체" : facility.type)
                                }
                                .padding(16)
                                .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                                .cornerRadius(12)
                            }
                            
                            // 연결하기 버튼
                            Button {
                                Task {
                                    await connectToPickupFacility(pickupFacilityId: facility.id)
                                }
                            } label: {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                } else {
                                    Text("연결하기")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                }
                            }
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(14)
                            .disabled(viewModel.isLoading)
                        }
                    }
                    
                    // 안내 박스
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 30/255, green: 59/255, blue: 207/255))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("연결 후")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("해당 수거업체에 폐기물 수거 요청을 할 수 있습니다.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(red: 244/255, green: 247/255, blue: 255/255))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 30/255, green: 59/255, blue: 207/255).opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(20)
                .padding(.bottom, 100)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .alert("연결 완료", isPresented: $showSuccessAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("수거업체와의 연결이 완료되었습니다.")
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private var formValid: Bool {
        !facilityCode.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func searchPickupFacility() async {
        let success = await viewModel.searchFacilityByCode(
            facilityCode: facilityCode.trimmingCharacters(in: .whitespaces)
        )
        
        if success {
            searchCompleted = true
        }
    }
    
    private func connectToPickupFacility(pickupFacilityId: Int) async {
        guard let labFacilityId = viewModel.facilityId else {
            viewModel.errorMessage = "연구소 시설 정보를 찾을 수 없습니다."
            viewModel.showError = true
            return
        }
        
        let success = await viewModel.createFacilityRelation(
            labFacilityId: labFacilityId,
            pickupFacilityId: pickupFacilityId
        )
        
        if success {
            showSuccessAlert = true
        }
    }
}

// MARK: - 정보 표시 Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        PickupFacilitySearchView(viewModel: FacViewModel())
    }
}
