import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'package:flutter/services.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'address_details_page.dart';
import '../models/address.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  final String _inputId = 'searchBox';
  Address? _selectedAddress;
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAddressNow();
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      // Basic AddressNow initialization
      var searchBox = document.getElementById('$_inputId');
      
      var options = {
        key: "YOUR_API_KEY",
        onSelect: function(address) {
          // Simple address formatting
          var result = {
            line1: address.Line1,
            line2: address.Line2,
            city: address.City,
            postcode: address.PostalCode
          };
          
          console.log('Address selected:', result);
          window.handleAddressSelect(result);
        }
      };

      var control = new pca.Address(searchBox, options);
      console.log('AddressNow initialized');
    ''']);

    // Simple callback handler
    js.context['handleAddressSelect'] = js.allowInterop((dynamic result) {
      print('Address received: $result');
      
      setState(() {
        _selectedAddress = Address.fromJson(Map<String, dynamic>.from(result));
        _isContinueEnabled = true;
        print('Address set: $_selectedAddress');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search box
            SizedBox(
              height: 50,
              child: HtmlElementView(viewType: _inputId),
            ),
            const SizedBox(height: 20),
            
            // Selected address display
            if (_selectedAddress != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedAddress!.line1),
                      if (_selectedAddress!.line2.isNotEmpty)
                        Text(_selectedAddress!.line2),
                      Text(_selectedAddress!.city),
                      Text(_selectedAddress!.postcode),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Continue button
            ElevatedButton(
              onPressed: _isContinueEnabled
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressDetailsPage(
                            address: _selectedAddress!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    js.context.callMethod('eval', ['window.addressNowControl = null;']);
    super.dispose();
  }
} 