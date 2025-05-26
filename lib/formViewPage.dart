import 'package:bill_app/ImageView.dart';
import 'package:flutter/material.dart';

class Formviewpage extends StatelessWidget {
  final List<dynamic> data;

  Formviewpage(this.data, {super.key});

  Color color = Color(0xff5f615f);

  Widget textView(String category, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category,
          style: TextStyle(color: Colors.white, fontSize: 26),),
        SizedBox(width: 15,),
        Text(data[0][name],
          style: TextStyle(color: Colors.white, fontSize: 26),),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color,
        title: Text(data[0]['fName'].toString().trim(),
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Imageview( data[0]['image']),
                    ),
                  );
                },
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      data[0]['image'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              textView("Material:", 'mName'),
              SizedBox(height: 24),
              textView("Quantity:", 'quantity'),
              SizedBox(height: 24),
              textView("Vendor  :", 'vName'),
              SizedBox(height: 24),
              textView("Unit    :", 'unit'),
            ],
          ),
        ),
      ),
    );
  }
}