# Svasthya - Flutter App with Supabase Integration

A Flutter health application integrated with Supabase backend.

## 🚀 Setup Complete

### ✅ What's Been Configured:

1. **Package Name Changed**: `com.example.svasthya` → `com.sirius.svasthya`
2. **Supabase Integration**: Connected to your Supabase project
3. **Database Service**: Ready-to-use CRUD operations
4. **Authentication**: User sign up/in/out functionality
5. **Connection Test**: Built-in widget to verify Supabase connection

### 📁 Project Structure:

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase credentials
├── services/
│   └── database_service.dart         # Database operations
├── widgets/
│   └── supabase_test_widget.dart     # Connection test widget
└── main.dart                         # App initialization
```

## 🔧 How to Use Database Service

### Basic CRUD Operations:

```dart
import 'package:svasthya/services/database_service.dart';

// Test connection
bool isConnected = await DatabaseService.testConnection();

// Insert data
Map<String, dynamic> newRecord = await DatabaseService.insertData(
  'your_table_name',
  {'column1': 'value1', 'column2': 'value2'}
);

// Get all data
List<Map<String, dynamic>> allData = await DatabaseService.getAllData('your_table_name');

// Get data by ID
Map<String, dynamic> record = await DatabaseService.getDataById('your_table_name', 'id', 123);

// Update data
Map<String, dynamic> updated = await DatabaseService.updateData(
  'your_table_name',
  'id',
  123,
  {'column1': 'new_value'}
);

// Delete data
bool deleted = await DatabaseService.deleteData('your_table_name', 'id', 123);
```

### Authentication:

```dart
// Sign up new user
AuthResponse response = await DatabaseService.signUp('email@example.com', 'password');

// Sign in existing user
AuthResponse response = await DatabaseService.signIn('email@example.com', 'password');

// Check if user is authenticated
bool isLoggedIn = DatabaseService.isAuthenticated();

// Get current user
User currentUser = DatabaseService.getCurrentUser();

// Sign out
bool signedOut = await DatabaseService.signOut();
```

## 🗃️ Next Steps:

1. **Create your database tables** in Supabase dashboard
2. **Update the database service** with your specific table operations
3. **Add your table schemas** to the project
4. **Implement your specific business logic**

## 🧪 Testing the Connection:

1. Run the app: `flutter run`
2. Tap the "Test Connection" button
3. You should see "✅ Connected to Supabase!" if everything is working

## 📊 Your Supabase Details:

- **Project URL**: https://ctjrnsxzamiktbguxkar.supabase.co
- **Status**: Connected and ready to use
- **Authentication**: Enabled
- **Database**: Ready for your tables

## 🔒 Security Notes:

- The anon key is safe to use in client applications
- Never commit service role keys to version control
- Use Row Level Security (RLS) in Supabase for data protection

---

Ready to start building your health app! 🏥💙