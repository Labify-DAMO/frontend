//
//  FacilityRegisterSheet.swift
//  Labify
//
//  Created by KITS on 10/22/25.
//

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
            VStack(spacing: 16) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("시설 정보 입력")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("시설명")
                                .font(.subheadline).foregroundColor(.gray)
                            TextField("예) Seoul Biotech Facility", text: $name)
                                .textInputAutocapitalization(.none)
                                .padding(12)
                                .background(Color(white: 0.96))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("시설 유형")
                                .font(.subheadline).foregroundColor(.gray)
                            Picker("시설 유형", selection: $type) {
                                ForEach(facilityTypes, id: \.self) { Text($0) }
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("주소")
                                .font(.subheadline).foregroundColor(.gray)
                            TextField("예) Seoul, Korea", text: $address)
                                .padding(12)
                                .background(Color(white: 0.96))
                                .cornerRadius(10)
                        }

                        Toggle(isOn: $confirmAccuracy) {
                            Text("입력한 정보가 정확하며, 등록 후 수정/삭제가 불가함을 이해했습니다.")
                                .font(.footnote)
                        }
                        .tint(.blue)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 6)
                }

                Spacer()

                Button {
                    showFinalConfirm = true
                } label: {
                    Text("시설 등록하기")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(confirmAccuracy && formValid ? Color.blue : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                }
                .disabled(!confirmAccuracy || !formValid || viewModel.isLoading)
                .alert("등록 최종 확인", isPresented: $showFinalConfirm) {
                    Button("취소", role: .cancel) { }
                    Button("등록", role: .destructive) {
                        Task {
                            let ok = await viewModel.registerFacility(
                                name: name,
                                type: type,
                                address: address,
                                managerId: userInfo.userId
                            )
                            if ok {
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
                        • 관리자(ID): \(userInfo.userId)
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
