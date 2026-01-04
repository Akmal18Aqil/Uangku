# 💰 Uangku - Personal Finance Tracker

**Uangku** is a simple yet powerful personal finance application built with **Flutter**. It allows you to track your income and expenses easily, using **Google Sheets** as a free and accessible backend database.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Google Sheets](https://img.shields.io/badge/Google%20Sheets-34A853?style=for-the-badge&logo=google-sheets&logoColor=white)

---

## ✨ Features

*   📝 **Record Transactions**: Log your daily income and expenses.
*   📊 **Google Sheets Backend**: all data is stored securely in your own Google Sheet.
*   📅 **Real-time Sync**: Data is updated instantly via Google Apps Script.
*   🏷️ **Categories**: Organize transactions by categories (Food, Transport, Salary, etc.).
*   📱 **Clean UI**: Built with modern Flutter practices and Material Design.

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK installed ([Guide](https://docs.flutter.dev/get-started/install))
*   A Google Account (for Google Sheets)

### 1. Clone the Repository

```bash
git clone https://github.com/Akmal18Aqil/Uangku.git
cd Uangku
flutter pub get
```

### 2. Backend Setup (Google Sheets)

This app uses a Google Sheet as its database. Follow these steps to set it up:

1.  Create a new **Google Sheet**.
2.  Rename the first sheet (tab) to **`Transactions`**.
3.  In the first row, create the following headers:
    *   **A1**: `Date`
    *   **B1**: `Description`
    *   **C1**: `Category`
    *   **D1**: `Type`
    *   **E1**: `Amount`
4.  Go to **Extensions** > **Apps Script**.
5.  Delete any existing code and paste the [Script Code provided below](#-google-apps-script-code).
6.  Click **Deploy** > **New deployment**.
7.  Click the **Select type** icon (gear) > **Web app**.
8.  Configure as follows:
    *   **Description**: `Uangku API`
    *   **Execute as**: `Me (your email)`
    *   **Who has access**: `Anyone` (Crucial for the app to access the sheet).
9.  Click **Deploy**.
10. Copy the **Web app URL** (starts with `https://script.google.com/macros/s/...`).

### 3. Connect App to Backend

1.  Open `lib/features/transactions/data/datasources/sheets_service.dart`.
2.  Replace the `apiUrl` variable with your Deployment URL:

```dart
static const String apiUrl = 'YOUR_DEPLOYMENT_URL_HERE';
```

### 4. Run the App

```bash
flutter run
```

---

## 📜 Google Apps Script Code

Copy this code into your Google Apps Script project.

```javascript
/**
 * KONFIGURASI
 * Sesuaikan nama sheet jika nanti berubah.
 */
const SHEET_NAME = 'Transactions';

/**
 * MENGANDEL REQUEST GET (READ DATA)
 * Mengambil semua baris dari sheet dan mengembalikannya sebagai JSON Array.
 */
function doGet(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(SHEET_NAME);
    
    // Cek jika sheet tidak ditemukan
    if (!sheet) {
      return responseJSON({ status: 'error', message: 'Sheet not found' });
    }

    // Ambil semua data (termasuk header)
    const data = sheet.getDataRange().getValues();
    
    // Jika data kosong atau hanya header
    if (data.length <= 1) {
      return responseJSON({ status: 'success', data: [] });
    }

    // Pisahkan header dan baris data
    const rows = data.slice(1); // Mengabaikan baris 1 (Header)
    
    // Mapping data array ke object JSON
    const formattedData = rows.map(row => {
      return {
        date: formatDate(row[0]),       // Col A
        description: row[1],            // Col B
        category: row[2],               // Col C
        type: row[3],                   // Col D
        amount: Number(row[4]) || 0     // Col E (Force number)
      };
    });

    return responseJSON({ status: 'success', data: formattedData });

  } catch (error) {
    return responseJSON({ status: 'error', message: error.toString() });
  }
}

/**
 * MENGANDEL REQUEST POST (CREATE DATA)
 * Menerima JSON dari Flutter dan menambahkannya ke baris baru (Append Row).
 */
function doPost(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(SHEET_NAME);

    if (!sheet) {
      return responseJSON({ status: 'error', message: 'Sheet not found' });
    }

    // Parsing data body dari request
    // e.postData.contents berisi string JSON mentah
    const requestData = JSON.parse(e.postData.contents);

    // Validasi sederhana
    if (!requestData.description || !requestData.amount) {
      return responseJSON({ status: 'error', message: 'Description and Amount are required' });
    }

    // Persiapkan baris baru sesuai urutan kolom: 
    // Date (A), Description (B), Category (C), Type (D), Amount (E)
    const newRow = [
      new Date(),                // Otomatis isi waktu server saat ini
      requestData.description,
      requestData.category || 'Uncategorized',
      requestData.type || 'Expense',
      requestData.amount
    ];

    // Tambahkan ke sheet
    sheet.appendRow(newRow);

    return responseJSON({ status: 'success', message: 'Data saved successfully' });

  } catch (error) {
    return responseJSON({ status: 'error', message: error.toString() });
  }
}

/**
 * HELPER: Format Output JSON
 * Memastikan output selalu dalam format JSON yang valid untuk API
 */
function responseJSON(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * HELPER: Format Tanggal
 * Mengubah object Date Javascript/GAS menjadi string ISO (YYYY-MM-DD)
 * agar mudah diparsing di Flutter.
 */
function formatDate(dateObj) {
  if (Object.prototype.toString.call(dateObj) === '[object Date]') {
    // Menggunakan Utilities.formatDate untuk zona waktu Jakarta (WIB)
    return Utilities.formatDate(dateObj, Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  }
  return dateObj; // Jika bukan tanggal, kembalikan aslinya
}
```

## 🛠 Dependencies

*   [flutter](https://flutter.dev)
*   [provider](https://pub.dev/packages/provider) - State Management
*   [http](https://pub.dev/packages/http) - API Requests
*   [intl](https://pub.dev/packages/intl) - Date Formatting
*   [google_fonts](https://pub.dev/packages/google_fonts) - Typography

---
Created with ❤️ by [Akmal18Aqil](https://github.com/Akmal18Aqil)
