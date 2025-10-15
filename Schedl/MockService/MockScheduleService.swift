//
//  MockScheduleService.swift
//  Schedl
//
//  Created by David Medina on 10/9/25.
//

import Foundation

class MockScheduleService: ScheduleServiceProtocol {
    
    private var schedules: [Schedule]
    private var blends: [Blend]
    
    init(userId: String, name: String) {
        self.schedules = MockScheduleFactory.createSchedules(5, for: userId, with: name)
        self.blends = MockBlendFactory.createBlends(5, for: userId, with: name)
    }
    
    func fetchAllSchedules(userId: String) async throws -> [Schedule] {
        return schedules.filter { $0.ownerId == userId }
    }
    
    func fetchScheduleId(userId: String) async throws -> String {
        guard let schedule = schedules.first(where: { $0.ownerId == userId }) else {
            throw ScheduleServiceError.failedToFetchSchedule
        }
        
        return schedule.id
    }
    
    func fetchSchedule(scheduleId: String) async throws -> Schedule {
        guard let schedule = schedules.first(where: { $0.id == scheduleId }) else {
            throw ScheduleServiceError.failedToFetchSchedule
        }
        
        return schedule
    }
    
    func createSchedule(userId: String, title: String) async throws -> Schedule {
        let newSchedule = Schedule(id: UUID().uuidString, ownerId: userId, title: title, createdAt: Date.now)
        schedules.append(newSchedule)
        
        return newSchedule
    }
    
    func updateSchedule(scheduleId: String, title: String) async throws {
        guard let index = schedules.firstIndex(where: { $0.id == scheduleId }) else { throw ScheduleServiceError.failedToUpdateSchedule }
        
        schedules[index].title = title
    }
    
    func deleteSchedule(scheduleId: String, userId: String) async throws {
        guard let index = schedules.firstIndex(where: { $0.id == scheduleId && $0.ownerId == userId }) else { throw ScheduleServiceError.failedToUpdateSchedule }
        
        schedules.remove(at: index)
    }
    func createBlendSchedule(ownerId: String, scheduleId: String, title: String, invitedUsers: [InvitedUser], colors: [UserMappedBlendColor]) async throws {
        let newBlend = Blend(id: UUID().uuidString, ownerId: ownerId, title: title, invitedUsers: invitedUsers, scheduleIds: [scheduleId], colors: colors)
        
        blends.append(newBlend)
    }
    
    func fetchAllBlendSchedules(userId: String) async throws -> [Blend] {
        return blends.filter { $0.ownerId == userId }
    }
    
    func fetchBlendSchedule(blendId: String) async throws -> Blend? {
        return blends.first { $0.id == blendId }
    }
}
