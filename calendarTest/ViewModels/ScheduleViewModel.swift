//
//  ScheduleViewModel.swift
//  calendarTest
//
//  Created by David Medina on 10/16/24.
//

import SwiftUI
import Firebase

class ScheduleViewModel: ObservableObject {
    
    @Published var showPopUp = false
    @Published var isLoading = false
    @Published var errorMsg: String = ""
    @Published var selectedSchedule: Schedule? = nil
    
    private var scheduleRef: DatabaseReference?
    private var scheduleListenerHandle: DatabaseHandle?
    
//    init(isLoading: Bool = false, errormsg: String) {
//        self.isLoading = isLoading
//        self.errorMsg = errormsg
//    }
    
    func togglePopUp() {
        showPopUp.toggle()
    }
    
    // will listen for any changes made to currently selected/viewed schedule
//    func startListeningToSchedule(withId scheduleId: String) {
//        // Detach any existing listener before attaching a new one
//        stopListeningToSchedule()
//
//        // set the reference to the selected schedule in Firebase
//        scheduleRef = FirebaseManager.shared.ref.child("schedules").child(scheduleId)
//
//        // attach a listener to the selected schedule
//        scheduleListenerHandle = scheduleRef?.observe(.value, with: { snapshot in
//            if let scheduleData = snapshot.value as? [String: Any] {
//                // Update the published selectedSchedule with the new data
//                // self.selectedSchedule = Schedule(scheduleId: scheduleId)
//            }
//        })
//    }
    
    // when user selects another schedule or changes to another screen, use this function to stop listening
//    func stopListeningToSchedule() {
//        if let handle = scheduleListenerHandle {
//            scheduleRef?.removeObserver(withHandle: handle)
//        }
//        scheduleListenerHandle = nil
//        scheduleRef = nil
//    }
    
//    func loadSchedule() {
//        self.isLoading = true
//        FirebaseManager.shared.fetchSchedule(scheduleId: <#T##String#>) { _, error in
//            if let error = error {
//                self.errorMsg = error.localizedDescription
//                return
//            }
//            self.isLoading = false
//            return
//        }
//        
//    }
}

