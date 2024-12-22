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
    _initializeAddressNow();
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      var input = document.getElementById('$_inputId');
      if (input && !window.addressNowInitialized) {
        var control = new pca.Address(input, {
          key: "YOUR_API_KEY",
          countries: {
            codesList: ["GBR"],
            defaultCode: "GBR"
          },
          search: {
            countries: ["GBR"]
          },
          bar: {
            visible: true,
            showCountry: false
          },
          capture: "line1,line2,city,postcode",
          onPopulate: function(address) {
            console.log('onPopulate triggered with:', address);
            
            // Format the address for our callback
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            console.log('Formatted address:', formattedAddress);
            
            // Call our callback
            if (typeof window.handleAddressSelect === 'function') {
              window.handleAddressSelect(formattedAddress);
            } else {
              console.error('handleAddressSelect is not defined');
            }
          },
          onSearchComplete: function(items) {
            console.log('Search complete with items:', items);
          }
        });

        // Store control reference globally
        window.addressNowControl = control;
        window.addressNowInitialized = true;
        console.log('AddressNow initialized with direct configuration');
      }
    ''']);

    // Setup the callback handler
    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('handleAddressSelect called with: $addressData');
      
      if (addressData == null) {
        print('Error: Received null address data');
        return;
      }

      try {
        final Map<String, dynamic> address = Map<String, dynamic>.from(addressData);
        print('Processing address data: $address');

        if (mounted) {
          setState(() {
            _selectedAddress = Address.fromJson(address);
            _isContinueEnabled = _selectedAddress != null && 
                               _selectedAddress!.line1.isNotEmpty;
            print('State updated:');
            print('Selected address: $_selectedAddress');
            print('Continue enabled: $_isContinueEnabled');
          });
        }
      } catch (e, stackTrace) {
        print('Error processing address:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }
    });
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
              SizedBox(
                height: 50,
                child: HtmlElementView(viewType: _inputId),
              ),
              const SizedBox(height: 16),
              // Debug text to show current state
              Text('Selected Address: ${_selectedAddress?.toString() ?? "None"}'),
              Text('Continue Enabled: $_isContinueEnabled'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_selectedAddress != null && _isContinueEnabled)
                    ? () {
                        print('Continue button pressed');
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
      ),
    );
  }

  @override
  void dispose() {
    js.context.callMethod('eval', ['''
      var input = document.getElementById('$_inputId');
      if (input) {
        input.remove();
      }
      window.addressNowInitialized = false;
    ''']);
    super.dispose();
  }
} 