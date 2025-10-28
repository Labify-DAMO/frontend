//
//  WasteSummarySheets.swift
//  Labify
//
//  바텀 시트 모음
//

import SwiftUI

// MARK: - Weight Editor Sheet
struct WeightEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var weight: Double
    @Binding var unit: String
    @State private var tempWeight: String
    
    init(weight: Binding<Double>, unit: Binding<String>) {
        self._weight = weight
        self._unit = unit
        self._tempWeight = State(initialValue: String(format: "%.1f", weight.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("무게 입력")
                        .font(.system(size: 20, weight: .bold))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        TextField("0.0", text: $tempWeight)
                            .font(.system(size: 48, weight: .medium))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                        
                        Text(unit)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                
                // 빠른 선택
                VStack(alignment: .leading, spacing: 12) {
                    Text("빠른 입력")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        QuickAddButton(value: 0.5, tempWeight: $tempWeight)
                        QuickAddButton(value: 1.0, tempWeight: $tempWeight)
                        QuickAddButton(value: 2.0, tempWeight: $tempWeight)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    if let newWeight = Double(tempWeight), newWeight > 0 {
                        weight = newWeight
                        dismiss()
                    }
                }) {
                    Text("확인")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
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

// MARK: - Lab Selector Bottom Sheet
struct LabSelectorBottomSheet: View {
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

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "보관 기한",
                    selection: $tempDate,
                    in: Date().addingTimeInterval(-86400)...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color(red: 30/255, green: 59/255, blue: 207/255))
                .padding(20)
                
                Spacer()
                
                Button(action: {
                    selectedDate = tempDate
                    dismiss()
                }) {
                    Text("확인")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                         Color(red: 113/255, green: 100/255, blue: 230/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(20)
            }
            .navigationTitle("보관 기한 선택")
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

// MARK: - Preview
#Preview("Weight Editor") {
    WeightEditorSheet(
        weight: .constant(2.5),
        unit: .constant("kg")
    )
}

#Preview("Lab Selector") {
    LabSelectorBottomSheet(
        labs: [
            Lab(id: 1, name: "생화학 실험실", location: "과학관 301호", facilityId: 1),
            Lab(id: 2, name: "유기화학 실험실", location: "과학관 302호", facilityId: 2)
        ],
        selectedLab: .constant(nil)
    )
}

#Preview("Date Picker") {
    DatePickerSheet(selectedDate: .constant(Date()))
}
