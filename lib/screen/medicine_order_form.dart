import 'package:flutter/material.dart';
import 'medicine_order_form.dart'; // Make sure to import the correct class

class MedicalDetailsForm extends StatefulWidget {
  final String shopName;

  MedicalDetailsForm({required this.shopName});

  @override
  _MedicalDetailsFormState createState() => _MedicalDetailsFormState();
}

class _MedicalDetailsFormState extends State<MedicalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _medicineController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _medicineController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order from ${widget.shopName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _medicineController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) { // Check for null or empty
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) { // Check for null or empty
                    return 'Please enter quantity';
                  }
                  // You can add additional validation for numeric values here
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _submitOrder(context);
                },
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _orderMedicine(context);
        },
        child: Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _orderMedicine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineOrderForm(shopName: widget.shopName),
      ),
    );
  }

  void _submitOrder(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Perform order submission logic here
      String medicineName = _medicineController.text;
      String quantity = _quantityController.text;
      // You can pass these values to the next screen or perform any other action here
    }
  }
}

class MedicineOrderForm extends StatefulWidget {
  final String shopName;

  MedicineOrderForm({required this.shopName});

  @override
  _MedicineOrderFormState createState() => _MedicineOrderFormState();
}

class _MedicineOrderFormState extends State<MedicineOrderForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _medicineNameController = TextEditingController();

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Medicine from ${widget.shopName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _medicineNameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _submitOrder(context);
                },
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitOrder(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Perform order submission logic here
      String medicineName = _medicineNameController.text;
      // You can pass this value to the next screen or perform any other action here
    }
  }
}
