//
//  MockData.swift
//  Labify
//
//  Created by KITS on 10/30/25.
//

import Foundation

// MARK: - Mock Pickup Items
extension TodayPickupItem {
    static let mockData: [TodayPickupItem] = [
        TodayPickupItem(
            pickupId: 1,
            labName: "분자생물학 연구실",
            labLocation: "A동 101호",
            facilityAddress: "서울특별시 강남구 테헤란로 427",
            status: "REQUESTED"
        ),
        TodayPickupItem(
            pickupId: 2,
            labName: "화학분석 연구소",
            labLocation: "B동 205호",
            facilityAddress: "서울특별시 강남구 역삼로 220",
            status: "PROCESSING"
        ),
        TodayPickupItem(
            pickupId: 3,
            labName: "생명공학 센터",
            labLocation: "C동 301호",
            facilityAddress: "서울특별시 강남구 선릉로 428",
            status: "REQUESTED"
        )
    ]
}

extension TomorrowPickupItem {
    static let mockTomorrow: [TomorrowPickupItem] = [
        TomorrowPickupItem(
            pickupId: 4,
            labName: "약학 연구실",
            labLocation: "D동 102호",
            facilityAddress: "서울특별시 서초구 반포대로 222",
            status: "REQUESTED"
        ),
        TomorrowPickupItem(
            pickupId: 5,
            labName: "환경공학 연구소",
            labLocation: "E동 303호",
            facilityAddress: "서울특별시 서초구 서초대로 411",
            status: "REQUESTED"
        )
    ]
    
    static let mockThisWeek: [TomorrowPickupItem] = [
        TomorrowPickupItem(
            pickupId: 6,
            labName: "나노기술 연구실",
            labLocation: "F동 201호",
            facilityAddress: "서울특별시 송파구 올림픽로 300",
            status: "REQUESTED"
        ),
        TomorrowPickupItem(
            pickupId: 7,
            labName: "의료기기 센터",
            labLocation: "G동 105호",
            facilityAddress: "서울특별시 송파구 중대로 135",
            status: "REQUESTED"
        ),
        TomorrowPickupItem(
            pickupId: 8,
            labName: "반도체 연구소",
            labLocation: "H동 401호",
            facilityAddress: "서울특별시 송파구 법원로 128",
            status: "REQUESTED"
        )
    ]
    
    static let mockNextWeek: [TomorrowPickupItem] = [
        TomorrowPickupItem(
            pickupId: 9,
            labName: "AI 연구센터",
            labLocation: "I동 501호",
            facilityAddress: "서울특별시 영등포구 여의대로 108",
            status: "REQUESTED"
        ),
        TomorrowPickupItem(
            pickupId: 10,
            labName: "로봇공학 연구실",
            labLocation: "J동 202호",
            facilityAddress: "서울특별시 영등포구 국제금융로 10",
            status: "REQUESTED"
        )
    ]
}

// MARK: - Mock Scan History
struct MockScanHistory: Identifiable {
    let id: Int
    let labName: String
    let scannedAt: String
    let disposalCount: Int
    
    static let mockData: [MockScanHistory] = [
        MockScanHistory(id: 1, labName: "분자생물학 연구실", scannedAt: "10분 전", disposalCount: 2),
        MockScanHistory(id: 2, labName: "화학분석 연구소", scannedAt: "1시간 전", disposalCount: 3),
        MockScanHistory(id: 3, labName: "생명공학 센터", scannedAt: "2시간 전", disposalCount: 1)
    ]
}
