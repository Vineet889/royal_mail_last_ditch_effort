import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'address_details_page.dart';
import '../models/address.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final TextEditingController _postcodeController = TextEditingController();
  Address? _selectedAddress;
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAddressNow();
  }

  void _initializeAddressNow() {
    // Add the Royal Mail AddressNow scripts to the head
    _addScriptToHead('https://api.addressnow.co.uk/css/addressnow-2.20.min.css?key=YOUR_API_KEY');
    _addScriptToHead('https://api.addressnow.co.uk/js/addressnow-2.20.min.js?key=YOUR_API_KEY');
    
    // Setup JavaScript callback
    js.context['handleAddressSelect'] = (dynamic addressData) {
      setState(() {
        _selectedAddress = Address.fromJson(addressData);
        _isContinueEnabled = true;
      });
    };
  }

  void _addScriptToHead(String url) {
    js.context.callMethod('eval', ['''
      var script = document.createElement('script');
      script.src = "$url";
      document.head.appendChild(script);
    ''']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Address Search')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _postcodeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Postcode',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _setupAddressNowField(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isContinueEnabled
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressDetailsPage(
                              address: _selectedAddress!,
                            ),
                          ),
                        )
                    : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupAddressNowField() {
    js.context.callMethod('eval', ['''
      AddressNow.listen('.address-search', {
        onSelect: function(address) {
          window.handleAddressSelect({
            line1: address.line1,
            line2: address.line2,
            city: address.town,
            postcode: address.postcode
          });
        }
      });
    ''']);
  }
} 