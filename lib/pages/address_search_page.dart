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
            console.log('Address selected:', address);
            
            if (!address) {
              console.error('No address data received');
              return;
            }
            
            // Format the address for our callback
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            console.log('Calling handleAddressSelect with:', formattedAddress);
            window.handleAddressSelect(formattedAddress);
          }
        });

        window.addressNowControl = control;
        window.addressNowInitialized = true;
        console.log('AddressNow initialized successfully');
      }
    ''']);

    // Setup the callback handler
    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('Address selected in Dart: $addressData');
      
      if (addressData == null) {
        print('Error: Received null address data');
        return;
      }

      try {
        final Map<String, dynamic> address = Map<String, dynamic>.from(addressData);
        
        if (address.isEmpty) {
          print('Error: Empty address data');
          return;
        }

        setState(() {
          _selectedAddress = Address.fromJson(address);
          _isContinueEnabled = _selectedAddress != null && 
                             _selectedAddress!.line1.isNotEmpty;
          print('State updated - Selected address: $_selectedAddress');
          print('Continue button enabled: $_isContinueEnabled');
        });
      } catch (e) {
        print('Error processing address: $e');
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
              ElevatedButton(
                onPressed: (_isContinueEnabled && _selectedAddress != null)
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