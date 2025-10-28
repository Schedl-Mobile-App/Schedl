# Schedl

A social calendar app that bridges personal scheduling with authentic social sharing. Built with SwiftUI, UIKit, and Firebase.

## Overview

Schedl reimagines how people coordinate and share their lives by making events the foundation of social interaction. Unlike traditional social media where users can post anything at any time, Schedl users can only create posts from events that existed on their calendar which creates more genuine, experience based content.

## Key Features

### Smart Calendar Management
- Create and manage events with rich details (time, location, notes, custom colors)
- Manual event categorization and color-coding
- Native iOS calendar integration

### Social Scheduling
- **Blends**: Merge calendars with friend groups to coordinate schedules and find open time slots
- View availability across your friend network without sharing private details
- Group coordination made simple

### Event-Based Social Posts
- Post only from events that existed on your calendar
- Automatic tagging of invited attendees
- Organic, authentic content tied to real experiences

### Privacy-First Design
- Profiles are discoverable but private by default
- Content only visible to mutual friends
- Granular control over event visibility in blends

### User Discovery
- Search for friends by username
- Recent searches with persistent history
- Profile browsing with friend/event/post counts

### Key Technical Features
- Custom navigation coordinator pattern for deep routing
- Debounced search for real-time user discovery
- Use of Core Data for persisting schedules and events
- Responsive UI with matched geometry transitions

### Architecture Patterns
- MVVM architecture for clear separation of concerns
- Environment-based dependency injection
- Custom shape rendering for unique UI elements

## Future Enhancements

- [ ] Push notifications for event invites and updates
- [ ] Calendar import/export (.ics support)
- [ ] Event templates for recurring occasions
