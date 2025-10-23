import SwiftUI

struct FacilityRegisterSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: FacViewModel
    let userInfo: UserInfo
    
    @State private var name = ""
    @State private var type = "LAB"
    @State private var address = ""
    @State private var confirmAccuracy = false
    @State private var showFinalConfirm = false
    
    private let facilityTypes = ["LAB", "HOSPITAL", "CLINIC", "UNIVERSITY"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("시설 등록 정보 입력")
                        .font(.title3.weight(.semibold))
                    
                    // ✅ 이미 시설이 있으면 경고 표시
                    if viewModel.hasFacility {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("이미 등록된 시설이 있습니다")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.orange)
                                Text("한 사용자는 하나의 시설에만 소속될 수 있습니다.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("시설명")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("예) 서울 바이오센터", text: $name)
                            .textInputAutocapitalization(.none)
                            .padding(12)
                            .background(Color(white: 0.96))
                            .cornerRadius(10)
                            .disabled(viewModel.hasFacility) // ✅ 시설 있으면 비활성화
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("시설 유형")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("시설 유형", selection: $type) {
                            ForEach(facilityTypes, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)
                        .disabled(viewModel.hasFacility) // ✅ 시설 있으면 비활성화
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("주소")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("예) Seoul, Korea", text: $address)
                            .padding(12)
                            .background(Color(white: 0.96))
                            .cornerRadius(10)
                            .disabled(viewModel.hasFacility) // ✅ 시설 있으면 비활성화
                    }
                    
                    Toggle(isOn: $confirmAccuracy) {
                        Text("입력한 정보가 정확하며, 등록 후 수정/삭제가 불가함을 이해했습니다.")
                            .font(.footnote)
                    }
                    .tint(.blue)
                    .disabled(viewModel.hasFacility) // ✅ 시설 있으면 비활성화
                }
                
                Spacer()
                
                Button {
                    // ✅ 버튼 클릭 시 최종 체크
                    if viewModel.hasFacility {
                        viewModel.errorMessage = "이미 등록된 시설이 있습니다. 한 사용자는 하나의 시설에만 소속될 수 있습니다."
                        viewModel.showError = true
                        return
                    }
                    showFinalConfirm = true
                } label: {
                    Text(viewModel.hasFacility ? "이미 시설이 등록됨" : "시설 등록하기")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            viewModel.hasFacility ? Color.gray.opacity(0.5) :
                            (confirmAccuracy && formValid ? Color.blue : Color.gray.opacity(0.5))
                        )
                        .cornerRadius(12)
                }
                .disabled(viewModel.hasFacility || !confirmAccuracy || !formValid || viewModel.isLoading) // ✅ 조건 추가
                .alert("등록 최종 확인", isPresented: $showFinalConfirm) {
                    Button("취소", role: .cancel) { }
                    Button("등록", role: .destructive) {
                        Task {
                            // ✅ 등록 직전 한 번 더 체크
                            if viewModel.hasFacility {
                                viewModel.errorMessage = "이미 등록된 시설이 있습니다."
                                viewModel.showError = true
                                return
                            }
                            
                            let ok = await viewModel.registerFacility(
                                name: name,
                                type: type,
                                address: address,
                                managerId: userInfo.userId
                            )
                            if ok {
                                await viewModel.fetchFacilityInfo()
                                isPresented = false
                            }
                        }
                    }
                } message: {
                    Text("""
                        아래 정보로 시설을 등록합니다. 등록 후 수정/삭제는 현재 불가합니다.
                        
                        • 시설명: \(name)
                        • 유형: \(type)
                        • 주소: \(address)
                        • 관리자 ID: \(userInfo.userId)
                        """)
                }
            }
            .padding()
            .navigationTitle("시설 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { isPresented = false }
                }
            }
        }
    }
    
    private var formValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
