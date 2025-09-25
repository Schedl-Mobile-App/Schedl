//
//  MockScheduleService.swift
//  Schedl
//
//  Created by David Medina on 8/31/25.
//

final class MockScheduleService: ScheduleServiceProtocol {
    func fetchAllSchedules(userId: String) async throws -> [Schedule] {
        
    }
    
    func fetchSchedule(scheduleId: String) async throws -> Schedule {
        <#code#>
    }
    
    func fetchScheduleId(userId: String) async throws -> String {
        <#code#>
    }
    
    func fetchScheduleIds(userIds: [String]) async throws -> [String] {
        <#code#>
    }
    
    func createSchedule(userId: String, title: String) async throws -> Schedule {
        <#code#>
    }
    
    func updateSchedule(scheduleId: String, title: String) async throws {
        <#code#>
    }
    
    func deleteSchedule(scheduleId: String, userId: String) async throws {
        <#code#>
    }
    
    func observeAddedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func observeRemovedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func observeUpdatedEvents(scheduleId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func removeScheduleObserver(handle: DatabaseHandle, scheduleId: String) {
        <#code#>
    }
    
    func createBlendSchedule(ownerId: String, scheduleId: String, title: String, invitedUsers: [InvitedUser], colors: [String : String]) async throws {
        <#code#>
    }
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend] {
        <#code#>
    }
    
    func fetchBlendSchedule(blendId: String) async throws -> Blend {
        <#code#>
    }
    
    func observeCreatedBlend(userId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func observeAddedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func observeRemovedBlendSchedules(blendId: String, completion: @escaping (String) -> Void) -> DatabaseHandle {
        <#code#>
    }
    
    func removeNewBlendObserver(handle: DatabaseHandle, userId: String) {
        <#code#>
    }
    
    func removeBlendObserver(handle: DatabaseHandle, blendId: String) {
        <#code#>
    }
    
    
}
