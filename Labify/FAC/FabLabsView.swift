import SwiftUI

// MARK: - 시설 관리자 메인 화면
struct FacView: View {
    let userInfo: UserInfo
    @ObservedObject var authVM: AuthViewModel
    @State private var selectedBottomTab = 0 // 하단 탭 (0: 관리, 1: KPI, 2: 예측, 3: MY)
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var selectedFilter = 0 // 0: 새 실험실 등록, 1: 담당자 초대
    
    var body: some View {
        ZStack {
            // 선택된 하단 탭에 따라 화면 표시
            switch selectedBottomTab {
            case 0:
                ManagementTabContent(
                    userInfo: userInfo,
                    selectedTab: $selectedTab,
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
            case 1:
                KPIView()
            case 2:
                PredictionView()
            case 3:
                MyView()
            default:
                ManagementTabContent(
                    userInfo: userInfo,
                    selectedTab: $selectedTab,
                    searchText: $searchText,
                    selectedFilter: $selectedFilter
                )
            }
            
            // 하단 탭바
            VStack {
                Spacer()
                BottomTabBar(selectedTab: $selectedBottomTab)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

// MARK: - 관리 탭 컨텐츠
struct ManagementTabContent: View {
    let userInfo: UserInfo
    @Binding var selectedTab: Int
    @Binding var searchText: String
    @Binding var selectedFilter: Int
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 탭
                HStack(spacing: 0) {
                    FacilityTabButton(title: "시설", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    FacilityTabButton(title: "권한", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 필터 버튼
                HStack(spacing: 12) {
                    FilterButton(title: "새 실험실 등록", isSelected: selectedFilter == 0) {
                        selectedFilter = 0
                    }
                    FilterButton(title: "담당자 초대", isSelected: selectedFilter == 1, isOutlined: true) {
                        selectedFilter = 1
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // 통계 카드
                HStack(spacing: 12) {
                    StatCard(title: "실험실", value: "12")
                    StatCard(title: "담당자", value: "34")
                    StatCard(title: "이번 달 비용", value: "1.2 M", unit: "(₩)")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // 검색바 + 추가 버튼
                HStack(spacing: 12) {
                    HStack {
                        TextField("실험실/부서 검색", text: $searchText)
                            .padding(.leading, 12)
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                    .frame(height: 48)
                    .background(Color(white: 0.96))
                    .cornerRadius(24)
                    
                    Button(action: { /* 추가 기능 */ }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 30/255, green: 59/255, blue: 207/255),
                                             Color(red: 113/255, green: 100/255, blue: 230/255)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(24)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // 실험실 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        FacilityCard(building: "A동", floor: "3층", name: "세포배양실", manager: "담당 3명", status: "활성", statusColor: .blue)
                        FacilityCard(building: "A동", floor: "2층", name: "분자실", manager: "담당 2명", status: "활성", statusColor: .blue)
                        FacilityCard(building: "C동", floor: "2층", name: "분자실", manager: "담당 1명", status: "비활성", statusColor: .gray)
                        FacilityCard(building: "B동", floor: "1층", name: "공용실", manager: "담당 4명", status: "활성", statusColor: .blue)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("관리")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
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
    let building: String
    let floor: String
    let name: String
    let manager: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(building) \(floor) \(name)")
                .font(.system(size: 16, weight: .semibold))
            HStack(spacing: 8) {
                Text(manager).font(.system(size: 14)).foregroundColor(.gray)
                Text("·").foregroundColor(.gray)
                Text(status).font(.system(size: 14)).foregroundColor(statusColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - 하단 탭바
struct BottomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            BottomTabItem(icon: "list.bullet", title: "관리", isSelected: selectedTab == 0) { selectedTab = 0 }
            BottomTabItem(icon: "chart.bar.fill", title: "KPI", isSelected: selectedTab == 1) { selectedTab = 1 }
            BottomTabItem(icon: "calendar", title: "예측", isSelected: selectedTab == 2) { selectedTab = 2 }
            BottomTabItem(icon: "person.fill", title: "MY", isSelected: selectedTab == 3) { selectedTab = 3 }
        }
        .frame(height: 80)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

struct BottomTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .primary : .gray)
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .primary : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    FacView(
        userInfo: UserInfo(
            userId: 3,
            name: "이시설",
            email: "facility@test.com",
            role: "FACILITY_MANAGER",
            affiliation: "종합관리센터"
        ),
        authVM: AuthViewModel()
    )
}
