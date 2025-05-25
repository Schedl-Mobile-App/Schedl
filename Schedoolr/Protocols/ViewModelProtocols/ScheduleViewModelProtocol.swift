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
    func deleteSchedule() async
    func createEvent(title: String, eventDate: Double, startTime: Double, endTime: Double, location: MTPlacemark, taggedUsers: [String]) async
    func fetchEvents() async
    func fetchFriends() async
//    func updateEvent(title: String, eventDate: Double, startTime: Double, endTime: Double) async
    func deleteEvent() async
}
