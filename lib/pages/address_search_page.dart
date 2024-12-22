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
  final String _inputId = 'addressNowInput';
  Address? _selectedAddress;
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    // Register the view factory for our custom input
    ui.platformViewRegistry.registerViewFactory(_inputId, (int viewId) {
      final input = html.InputElement()
        ..id = _inputId
        ..style.width = '100%'
        ..style.height = '40px'
        ..style.padding = '8px'
        ..style.border = '1px solid #ccc'
        ..style.borderRadius = '4px'
        ..placeholder = 'Enter your postcode';

      // Initialize AddressNow after the input is created
      _initializeAddressNow();
      
      return input;
    });
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      function initializeAddressNow() {
        var input = document.getElementById('$_inputId');
        if (!input) {
          console.log('Input element not found, retrying...');
          setTimeout(initializeAddressNow, 100);
          return;
        }

        console.log('Input element found, initializing AddressNow');
        
        var options = {
          key: "YOUR_API_KEY",
          bar: { visible: true },
          onSelect: function(address) {
            console.log('Address selected:', address);
            
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            console.log('Formatted address:', formattedAddress);
            window.handleAddressSelect(formattedAddress);
          }
        };

        try {
          window.addressNowControl = new pca.Address(input, options);
          console.log('AddressNow initialized successfully');
        } catch (error) {
          console.error('Error initializing AddressNow:', error);
        }
      }

      // Start initialization
      initializeAddressNow();
    ''']);

    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('Received address data: $addressData');
      
      if (addressData == null) {
        print('Error: Null address data');
        return;
      }

      try {
        final address = Map<String, dynamic>.from(addressData);
        print('Processing address: $address');
        
        setState(() {
          _selectedAddress = Address.fromJson(address);
          _isContinueEnabled = true;
          print('Address set successfully: $_selectedAddress');
        });
      } catch (e) {
        print('Error processing address: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Address'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search input
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: HtmlElementView(viewType: _inputId),
              ),
              
              const SizedBox(height: 20),
              
              // Selected address display
              if (_selectedAddress != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selected Address:',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_selectedAddress!.line1),
                      if (_selectedAddress!.line2.isNotEmpty)
                        Text(_selectedAddress!.line2),
                      Text(_selectedAddress!.city),
                      Text(_selectedAddress!.postcode),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Continue button
              ElevatedButton(
                onPressed: _isContinueEnabled
                    ? () {
                        print('Navigating with address: $_selectedAddress');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddressDetailsPage(address: _selectedAddress!),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    js.context.callMethod('eval', ['''
      if (window.addressNowControl) {
        window.addressNowControl.destroy();
      }
    ''']);
    super.dispose();
  }
} 