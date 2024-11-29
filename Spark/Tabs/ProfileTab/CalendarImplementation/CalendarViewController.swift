//
//  CalendarViewController.swift
//  Spark
//
//  Created by Edison Chiu on 11/15/24.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class CalendarViewController: DayViewController, EKEventEditViewDelegate {
    private var eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        requestAccessToCalendar()
        subscribeToNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func requestAccessToCalendar() {
        let completionHandler: EKEventStoreRequestAccessCompletionHandler = { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.reloadData()
                }
            }
        }

        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents(completion: completionHandler)
        } else {
            eventStore.requestAccess(to: .event, completion: completionHandler)
        }
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }

    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        return eventKitEvents.map(EKWrapper.init)
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        presentDetailViewForEvent(ckEvent.ekEvent)
    }

    private func presentDetailViewForEvent(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController, animated: true)
    }

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        endEventEditing()
        let newEKWrapper = createNewEvent(at: date)
        create(event: newEKWrapper, animated: true)
    }

    private func createNewEvent(at date: Date) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEKEvent.startDate = date
        newEKEvent.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)
        newEKEvent.title = "New Event"
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        return newEKWrapper
    }

    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? EKWrapper else { return }
        endEventEditing()
        beginEditing(event: descriptor, animated: true)
    }

    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            if originalEvent === editingEvent {
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                try? eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
        }
        reloadData()
    }

    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true)
    }

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true)
    }
}
