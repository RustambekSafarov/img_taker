# 🚗 Veemly – Vehicle Entry/Exit Capture App

GateGuard is a mobile application designed to automate the work of gate guards in factories.  
The app allows capturing required vehicle photos and sending the data directly to a backend system.

---

## 📌 Features

- 📷 **Capture Vehicle Images**
  - Front view
  - Rear view
  - Trunk / cargo area
  - Invoice/document image

- 🔄 **Event Types**
  - **Enter** – when a vehicle enters the factory
  - **Exit** – when a vehicle leaves the factory

- 📤 **Automatic Data Upload**
  - Sends all images and form data to the backend API.
  - Prevents missing required photos.

- 👮 **Built for Gate Guards**
  - Fast workflow
  - Simple UI
  - Minimizes manual work

---

## 🏗️ How It Works

1. Select **Enter** or **Exit**.
2. Capture the photos.
3. Confirm, save and send the form.
4. App uploads everything to the backend.

Payload example:

```json
{
  "event_type": "enter",
  "license_plate": "XX-1234",
  "timestamp": "2025-01-01T12:00:00Z",
  "images": {
    "front": "file_data",
    "rear": "file_data",
    "trunk": "file_data",
    "invoice": "file_data"
  }
}
