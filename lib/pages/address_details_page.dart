import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressDetailsPage extends StatelessWidget {
  final Address address;

  const AddressDetailsPage({super.key, required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Address Details')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: TextEditingController(text: address.line1),
                decoration: const InputDecoration(
                  labelText: 'Line 1',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: address.line2),
                decoration: const InputDecoration(
                  labelText: 'Line 2',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: address.city),
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: address.postcode),
                decoration: const InputDecoration(
                  labelText: 'Postcode',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 