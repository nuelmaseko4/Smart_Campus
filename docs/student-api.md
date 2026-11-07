# Student API

All student self-service routes require the JWT returned by `POST /login` with
`role: "student"`. Send it as `Authorization: Bearer <token>`.

When adding or changing Flask routes, restart the API from `lib/api` so the
running server loads the updated route files:

```powershell
python -m flask --app app run --host 0.0.0.0 --port 5000
```

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/timetables` | List scheduled classes; optional `course_id`, `year_of_study`, and `semester` filters |
| `POST` | `/timetables` | Add one or more scheduled classes (requires timetable admin key) |
| `GET` | `/students/me` | Read the signed-in student's ID, email, and course |
| `PATCH` | `/students/me` | Update the signed-in student's email |
| `GET` | `/students/me/timetable` | List timetable entries for the student's course |
| `GET` | `/students/me/attendance` | Read attendance history and status totals |
| `GET` | `/rooms/availability?start_time=...&end_time=...` | List rooms without an overlapping class |
| `GET` | `/students/me/gate-entries` | View the signed-in student's gate scan history |
| `POST` | `/rfid/check-in` | Record attendance from a trusted campus RFID reader |
| `POST` | `/rfid/gate-entry` | Record a gate scan from a trusted campus RFID reader |

The room-availability route also requires a student JWT. It accepts
timezone-free local campus datetimes, for example `2026-03-20T09:00:00`. A room
is unavailable when any timetable entry overlaps the requested interval.

## Populate the timetable

The timetable stores actual date and time ranges; it does not yet support
recurring weekly rules. Add one entry for each actual class occurrence that
should block room availability. For example, a weekly class needs an entry for
each scheduled date.

Before creating entries, use `GET /courses`, `GET /lecturers`, and `GET /rooms`
to look up the numeric IDs. Timetable entries require the course, lecturer, and
room IDs, the unit name, the study year, semester number, and timezone-free
local start/end datetimes. The study year must not exceed the program duration.
The API rejects overlapping room or lecturer schedules. A bulk request is
saved atomically: if one entry is invalid or conflicts, none of the entries are
created.

Configure a private key before starting Flask. In PowerShell, from `lib/api`:

```powershell
$env:TIMETABLE_ADMIN_API_KEY = "set-a-long-random-secret"
python -m flask --app app run --host 127.0.0.1 --port 5000
```

In Postman, send `POST http://127.0.0.1:5000/timetables`, select **Body →
raw → JSON**, and add the `X-Timetable-Admin-Key` header with the same key:

```json
[
  {
    "course_id": 1,
    "lecture_id": 1,
    "room_id": 1,
    "year_of_study": 1,
    "semester": 1,
    "unit_name": "Replace with the real unit name",
    "start_time": "2026-11-03T09:00:00",
    "end_time": "2026-11-03T10:00:00"
  }
]
```

Replace the example IDs, unit, dates, and times with the actual records and
published schedule. Use `GET /timetables` to verify entries. Once populated,
students can check free rooms at a particular date and time with
`GET /rooms/availability?start_time=2026-11-03T09:00:00&end_time=2026-11-03T10:00:00`
and their student JWT.

## Campus RFID reader

Set `RFID_READER_API_KEY` before starting Flask. In PowerShell, from `lib/api`:

```powershell
$env:RFID_READER_API_KEY = "use-a-long-random-secret"
python -m flask --app app run --host 0.0.0.0 --port 5000
```

The RFID reader posts a card UID and timetable entry ID to `/rfid/check-in`,
or a card UID and gate `access_point` to `/rfid/gate-entry`. Both routes require
the key in the `X-Reader-Token` header:

```json
{
  "card_id": "CARD-100",
  "timetable_id": 12
}
```

For a gate scan, send the configured gate name instead:

```json
{
  "card_id": "CARD-100",
  "access_point": "North entrance"
}
```

The server accepts a check-in only for an active card, the student's own
course, and an active class (starting up to 15 minutes ahead). It records a
student at most once per timetable entry. The reader key must stay on the
trusted reader/server side; do not put it in the Flutter app. Use HTTPS when
the reader communicates over a network.

Gate scans are recorded for an active card and known gate access point and
return an access-granted result to the trusted reader. Configure the reader to
act on that response. Card issuance is not exposed as a public API: an
administrator must associate each card UID with a student in `rfid_cards` and
keep its status `active`.
