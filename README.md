# uni_connect

A new Flutter project.

For an overview of the student and lecturer signup structure, file
responsibilities, and where to make changes, see [Signup code guide](docs/signup-flow.md).

## Flask API setup

From the project root in PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r .\lib\api\requirements.txt
Copy-Item .\lib\api\.env.example .\lib\api\.env
```

Enter the JWT, RFID reader, and timetable admin keys privately in
`lib/api/.env`. Do not commit that file. Keep the RFID reader key synchronized
with the value configured in Postman and on the ESP32.

To start the API:

```powershell
Set-Location .\lib\api
..\..\.venv\Scripts\python.exe app.py
```
