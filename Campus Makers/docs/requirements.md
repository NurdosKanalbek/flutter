# Requirement map

| Requirement | Implementation |
| --- | --- |
| R1 | `models/workshop.dart`: final fields, private const constructor, defensive-copy factory and `copyWith`; `models/profile.dart`: const constructors and `copyWith`. |
| R2 | `WorkshopCategory.color`: exhaustive switch over five enum values, using ColorScheme roles. |
| R3 | `Workshop.empty()` and `Profile.empty()`; new form initialisation uses these defaults. |
| R4 | `Workshop.count`, `freePlaces`, `isFull`, `isPast`, `contains`. |
| R5 | Record getter `Workshop.places`, destructured in the card and detail. |
| R6 | Nullable description displayed with a collection-if pattern in detail; the sole null assertion has an adjacent explanation in form Save. |
| R7 | `where`, `map`, `fold`, `any`, collection for/if; catalogue sorting acts on a fresh list. |
| R8 | `utils/format.dart`; own month names and `padLeft` minutes. |
| R9 | Sealed `Countdown`, `Upcoming`, `Started`, `Ended`; exhaustive `label` switch. |
| R10 | Shell State owns workshop list and profile; tabs receive values and callbacks. |
| R11 | MyApp State owns ThemeMode; callback and value pass through shell to profile. |
| R12 | setState closures only change state, without navigation or asynchronous work. |
| R13 | Detail creates Timer.periodic in initState and cancels it in dispose; no timer logging. |
| R14 | Async route, dialog, picker and save continuations check mounted before UI updates or navigation. |
| R15 | Membership asks via showDialog<bool>; missing name shows SnackBar with Profile action. |
| R16 | Full/past join disabled via null callback; members can still leave. |
| R17 | Form Save locks immediately, shows progress, waits one second, checks mounted, then returns one item. |
| R18 | Reusable WorkshopCard: Stack avatar, Expanded two-line title/date/place, favourite IconButton. |
| R19 | Positioned capacity badge: FULL, N left up to five, otherwise omitted. |
| R20 | Catalogue LayoutBuilder switches at 600 px between ListView.separated and GridView.builder, maximum cell width 360. |
| R21 | One Column with search, horizontal category chips, Include past chip, Expanded scrolling results. |
| R22 | Both themes use ColorScheme.fromSeed; profile offers System/Light/Dark chips; no literal colors or font sizes in lib. |
| R23 | Shared EmptyState used by catalogue, favourites and empty makers list; FAB opens the form. |
| R24 | Detail Stack header with bundled PNG, category icon, category chip and countdown chip. |
| R25 | Routes constants, routes shell entry, typed arguments in onGenerateRoute and Not found fallback. |
| R26 | DetailArguments carries workshop and callbacks; FormArguments carries Workshop?; form returns Workshop. |
| R27 | Shell and detail await pushNamed<Workshop>, check mounted/null, then update state. |
| R28 | One Navigator; pushed routes cover the bottom bar; profile and browse requests use shell callback. |
| R29 | Detail DefaultTabController, TabBar/TabBarView, live makers count, highlighted You. |
| R30 | Form PopScope compares an opening snapshot with current values; clean exit is immediate; dirty exit asks; save bypasses discard. |
| R31 | Implicit AppBar back control; PopupMenuButton offers Edit and confirmed Delete; no leading or BackButton. |
| R32 | Drawer About dialog and confirmed Reset; tiles first close the drawer with Navigator.pop. |
| R33 | Every text input is TextFormField; validators, Form keys, onUserInteraction; one validate in workshop Save. |
| R34 | Title 3–60/counter; conditional room/link rule; integer limit 1–500 and current count; category/date/time required; new date/time must be future. |
| R35 | Controllers and focus nodes are State fields and disposed; keyboard types, next/done and tap-outside handlers. |
| R36 | Read-only date/time fields; picker cancellation leaves values untouched; Save combines both. |
| R37 | Form SingleChildScrollView, SizedBox gaps, reachable Save; no Spacer. |
| R38 | Profile controllers start from model, submit saves, RegExp group rule; list membership count is derived on build. |
| R39 | SDK + flutter_lints only; analyze/format verification documented in manual checks. |
| R40 | At least twelve incremental Git commits with descriptive messages. |
| R41 | README domain, three screenshots and seven-sentence Decisions section. |
