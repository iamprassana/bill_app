import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Services {
  final auth = FirebaseAuth.instance;
  static String? userId;

  static void getUsers() {
    userId = FirebaseAuth.instance.currentUser!.uid;
  }
}

class Database {
  final users = Supabase.instance.client.from('users');
  final bills = Supabase.instance.client.from('bills');

  Future insertUser() async {
    try {
      await users.insert({'uid': Services.userId});
      print("User Successfully Inserted");
    } catch (e) {
      print("Error::: ${e.toString()}");
    }
  }

  Future insertBill(String fName, String mName, String quantity, String vName,
      String unit, String imageUrl) async {
    try {
      await bills.insert({
        'fName': fName,
        'mName': mName,
        'quantity': quantity,
        'vName': vName,
        'unit': unit,
        'image': imageUrl,
        'userId': Services.userId
      });
      print("Bill Successfully Inserted");
    } catch (e) {
      print("Not inserted successfully $e");
    }
  }

  Future<List<dynamic>> getBills() async {
  Services.getUsers();
    final userID = Services.userId;

    return await bills.select().eq('userId', userID!);
  }

  Future<void> deleteBill(int billId) async{
    final response = await bills.delete().eq('id', billId);
    if(response!= null) {
      print("Error deleting");
    }else {
      print("Successfully deleted");
    }
  }
}
