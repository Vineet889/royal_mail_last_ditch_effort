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
            codesList: "GBR",
            defaultCode: "GBR"
          },
          search: {
            countries: ["GBR"],
            setCountry: "GBR"
          },
          onSelect: function(address, variations) {
            console.log('onSelect triggered with address:', address);
            
            if (!address) {
              console.error('No address data in onSelect');
              return;
            }
            
            // Format the address for our callback
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            console.log('Formatted address in onSelect:', formattedAddress);
            window.handleAddressSelect(formattedAddress);
          },
          onPopulate: function(address, variations) {
            console.log('onPopulate triggered with address:', address);
            
            if (!address) {
              console.error('No address data in onPopulate');
              return;
            }
            
            // Format the address for our callback
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            console.log('Formatted address in onPopulate:', formattedAddress);
            window.handleAddressSelect(formattedAddress);
          }
        });

        window.addressNowControl = control;
        window.addressNowInitialized = true;
        console.log('AddressNow initialized successfully');
      }
    ''']);

    // Setup the callback handler with verbose logging
    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('handleAddressSelect called with data: $addressData');
      
      if (addressData == null) {
        print('Error: Received null address data');
        return;
      }

      try {
        final Map<String, dynamic> address = Map<String, dynamic>.from(addressData);
        print('Successfully converted to Dart Map: $address');
        
        if (address.isEmpty) {
          print('Error: Empty address data');
          return;
        }

        // Create the Address object first to validate it
        final newAddress = Address.fromJson(address);
        print('Successfully created Address object: $newAddress');

        // Only update state if we have a valid address
        if (newAddress.line1.isNotEmpty) {
          setState(() {
            _selectedAddress = newAddress;
            _isContinueEnabled = true;
            print('State updated - Selected address: $_selectedAddress');
            print('Continue button enabled: $_isContinueEnabled');
          });
        } else {
          print('Error: Invalid address - line1 is empty');
        }
      } catch (e, stackTrace) {
        print('Error processing address: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add debug print to track rebuilds
    print('Building AddressSearchPage with selectedAddress: $_selectedAddress');
    print('Continue button enabled: $_isContinueEnabled');

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
              if (_selectedAddress != null) 
                Text('Selected Address: ${_selectedAddress.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_selectedAddress != null && _isContinueEnabled)
                    ? () {
                        print('Continue button pressed with address: $_selectedAddress');
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