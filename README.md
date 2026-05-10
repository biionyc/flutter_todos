# flutter_todos

A robust, offline-first Todo application built with Flutter following Clean Architecture principles.

## Getting Started

To get this app running locally on your machine, you don't need any special configuration. Just ensure you have Flutter installed.

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run the app on either an iOS or Android simulator/device using `flutter run`.

### Demo Credentials
To log into the app, you can use the following dummy credentials:
* **Email:** `test@example.com`
* **Password:** `password123`

## Architecture & Design Decisions

This app is built using **Clean Architecture**. The primary design decision was to keep it simple while adhering strictly to the dependency rule (the domain layer knows nothing about the outer layers, and everything depends inward). 

While I omitted the **Use Case layer**, this is a recognized simplification that doesn't disqualify it from being Clean Architecture. The project scope didn't justify the extra layer, so the BLoC calls the repository directly. This keeps the codebase streamlined without violating any architectural rules.

## State Management: BLoC Pattern

The app uses the standard BLoC (Business Logic Component) pattern where everything is driven by events and states. 

For example, a `GetTodos` event is fired when the todos list page is rendered. The BLoC then emits states to reflect the progress: loading, success, or failure. A key implementation detail is that I used separate loading, success, and failure states *per event*. This ensures that a loading state is only associated with one specific part of the UI at a time, preventing the entire screen from being blocked or affected when only a single action is occurring.

## Challenges Faced & Solutions

**1. Architecting True Offline-First Data Handling**
* **Description:** Shifting from a traditional "fetch-and-display" model to a robust offline-first architecture was complex. I had to ensure the local database acted as the single source of truth for the UI, while managing background sync status gracefully without blocking user interactions.
* **Solution:** I decoupled the UI state from network requests. The BLoC updates the local database and immediately reflects changes in the UI (optimistic updates), then triggers a background sync. I used specific state properties (`isSyncing`, `pendingCount`) to display subtle syncing indicators instead of blocking loading screens.

**2. Dummy API Unique ID Collisions**
* **Description:** The dummy backend API had a flaw where simulating the creation of new todos always returned the exact same hardcoded ID. This caused immediate unique constraint crashes in the local database when saving the "synced" data.
* **Solution:** I discarded the ID returned by the API's create response. Instead, I generate a unique local ID (UUID) when the user creates the todo and persist that temporary ID as the permanent identifier across the database and app state.

## Offline Support Strategy

For an offline-first app, it is crucial not to rely heavily on loading indicators. Instead, the UI immediately reflects changes (optimistic updates) while the app attempts to sync with the backend in the background. 

The strategy includes the following mechanisms:
* **Background Sync & Rollback:** If the background sync fails due to a server error, the app simply reverts the optimistic change back to its original version and displays an error popup with the server's message.
* **Pending Status & UI Indicators:** When the device is offline, data is saved locally with a "sync pending" status. To keep the user informed, the UI displays a pending item count badge at the top of the screen and a small amber dot on the specific item to indicate its changes are pending.
* **Offline Banner:** A disconnected banner is shown at the top of the screen whenever the network is lost, making it clear to the user that they are operating purely on local data.
* **Action Coalescing (Last Change Sync):** When the device comes back online, the app only synchronizes the *last* state of an item. For instance, if a user toggles the completion status of a todo multiple times while offline, the app only pushes the final state to the server rather than all intermediate actions. Once the background sync completes successfully, a confirmation popup is shown to the user.
