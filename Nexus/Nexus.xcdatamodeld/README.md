Este directorio es un placeholder para `Planificador.xcdatamodeld`.

He creado el modelo Core Data programáticamente en `PersistenceController.swift` para que la app funcione sin abrir Xcode. Si deseas editar visualmente el modelo en Xcode, crea el modelo `.xcdatamodeld` con entidades:

- CDEvent
  - id: UUID (no optional)
  - symbol: String
  - title: String
  - date: Date
  - calendarID: UUID (optional)
  - subtype: String
  - repeatFrequency: String
  - repeatEndDate: Date (optional)
  - tasksData: Binary Data (optional) — codifica `[EventTask]` en JSON
  - colorData: Binary Data (optional) — codifica `RGBAColor` en JSON

- CDSubcalendar
  - id: UUID (no optional)
  - title: String
  - isVisible: Boolean
  - colorData: Binary Data (optional) — codifica `RGBAColor` en JSON


Sugerencia: después de añadir el `.xcdatamodeld` en Xcode, elimina la inicialización programática si prefieres usar el modelo de Xcode directamente.
