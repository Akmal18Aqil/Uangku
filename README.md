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

1.  Create a file named `.env` in the root directory.
2.  Add your Google Apps Script Web App URL to the file:

```env
SHEETS_API_URL=https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec
```

> **Note**: The `.env` file is included in `.gitignore` to keep your API URL private.

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

function doGet(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(SHEET_NAME);
    
    if (!sheet) {
      return responseJSON({ status: 'error', message: 'Sheet not found' });
    }

    const data = sheet.getDataRange().getValues();
    
    if (data.length <= 1) {
      return responseJSON({ status: 'success', data: [] });
    }

    const rows = data.slice(1);
    
    // Mapping data array ke object JSON
    // Asumsi kolom: A=Date, B=Description, C=Category, D=Type, E=Amount, F=ID
    const formattedData = rows.map(row => {
      return {
        date: formatDate(row[0]),
        description: row[1],
        category: row[2],
        type: row[3],
        amount: Number(row[4]) || 0,
        id: row[5] || '' // Tambahan ID
      };
    });

    return responseJSON({ status: 'success', data: formattedData });

  } catch (error) {
    return responseJSON({ status: 'error', message: error.toString() });
  }
}

function doPost(e) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(SHEET_NAME);

    if (!sheet) {
      return responseJSON({ status: 'error', message: 'Sheet not found' });
    }

    const requestData = JSON.parse(e.postData.contents);
    const action = requestData.action || 'create';

    if (action === 'create') {
      if (!requestData.description || !requestData.amount) {
        return responseJSON({ status: 'error', message: 'Description and Amount are required' });
      }

      // Generate UID
      const newId = Utilities.getUuid();

      const newRow = [
        new Date(),
        requestData.description,
        requestData.category || 'Uncategorized',
        requestData.type || 'Expense',
        requestData.amount,
        newId
      ];

      sheet.appendRow(newRow);
      return responseJSON({ status: 'success', message: 'Data saved successfully', id: newId });

    } else if (action === 'update') {
      if (!requestData.id) return responseJSON({ status: 'error', message: 'ID is required for update' });
      
      const data = sheet.getDataRange().getValues();
      // Find row by ID (Column F is index 5)
      for (let i = 1; i < data.length; i++) {
        if (data[i][5] === requestData.id) {
          const rowNumber = i + 1;
          // Update values
          if (requestData.date) sheet.getRange(rowNumber, 1).setValue(new Date(requestData.date));
          if (requestData.description) sheet.getRange(rowNumber, 2).setValue(requestData.description);
          if (requestData.category) sheet.getRange(rowNumber, 3).setValue(requestData.category);
          if (requestData.type) sheet.getRange(rowNumber, 4).setValue(requestData.type);
          if (requestData.amount) sheet.getRange(rowNumber, 5).setValue(requestData.amount);
          
          return responseJSON({ status: 'success', message: 'Data updated successfully' });
        }
      }
      return responseJSON({ status: 'error', message: 'ID not found' });

    } else if (action === 'delete') {
      if (!requestData.id) return responseJSON({ status: 'error', message: 'ID is required for delete' });
      
      const data = sheet.getDataRange().getValues();
      for (let i = 1; i < data.length; i++) {
        if (data[i][5] === requestData.id) {
          const rowNumber = i + 1;
          sheet.deleteRow(rowNumber);
          return responseJSON({ status: 'success', message: 'Data deleted successfully' });
        }
      }
      return responseJSON({ status: 'error', message: 'ID not found' });
    }

    return responseJSON({ status: 'error', message: 'Invalid action' });

  } catch (error) {
    return responseJSON({ status: 'error', message: error.toString() });
  }
}

function responseJSON(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

function formatDate(dateObj) {
  if (Object.prototype.toString.call(dateObj) === '[object Date]') {
    return Utilities.formatDate(dateObj, Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  }
  return dateObj;
}
```

## 🛠 Dependencies

*   [flutter](https://flutter.dev)
*   [provider](https://pub.dev/packages/provider) - State Management
*   [http](https://pub.dev/packages/http) - API Requests
*   [intl](https://pub.dev/packages/intl) - Date Formatting
*   [google_fonts](https://pub.dev/packages/google_fonts) - Typography
*   [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) - Environment Variables

---
Created with ❤️ by [Akmal18Aqil](https://github.com/Akmal18Aqil)
