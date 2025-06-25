//
//  ScheduleViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/5/25.
//

protocol ScheduleViewModelProtocol {
    var userSchedule: Schedule? { get set }
    
    func fetchSchedule() async
    func createSchedule(title: String) async
    func updateSchedule() async
//    func deleteSchedule() async
    func fetchEvents() async
    func fetchFriends() async
    func createEvent(title: String, startDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, color: String, notes: String, endDate: Double?, repeatedDays: [String]?) async
}
