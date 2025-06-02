//
//  EventViewModelProtocol.swift
//  Schedoolr
//
//  Created by David Medina on 5/27/25.
//

protocol EventViewModelProtocol {
    var selectedEvent: Event { get set }
    var currentUser: User { get set }
    
    //    func updateEvent(title: String, eventDate: Double, startTime: Double, endTime: Double) async
    func fetchInvitedUsers() async
    func deleteEvent() async
}
