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
    // Wait for the DOM to be ready
    Future.delayed(const Duration(milliseconds: 1000), () {
      _initializeAddressNow();
    });
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      if (typeof pca === 'undefined') {
        console.error('AddressNow library not loaded');
        return;
      }

      var input = document.getElementById('$_inputId');
      if (!input) {
        console.error('Input element not found');
        return;
      }

      if (!window.addressNowInitialized) {
        try {
          var control = new pca.Address(input, {
            key: "YOUR_API_KEY",
            countries: {
              codesList: "GBR",
              defaultCode: "GBR"
            },
            bar: {
              visible: true,
              showCountry: false
            },
            search: {
              countries: ["GBR"]
            },
            onSelect: function(address, variations) {
              console.log('Address selected event triggered');
              console.log('Raw address:', address);
              
              var formattedAddress = {
                line1: address.Line1 || '',
                line2: address.Line2 || '',
                city: address.City || '',
                postcode: address.PostalCode || ''
              };
              
              console.log('Formatted address:', formattedAddress);
              window.handleAddressSelect(formattedAddress);
            }
          });

          window.addressNowControl = control;
          window.addressNowInitialized = true;
          console.log('AddressNow successfully initialized');
        } catch (error) {
          console.error('Error initializing AddressNow:', error);
        }
      }
    ''']);

    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('Dart callback received address: $addressData');
      
      if (addressData != null) {
        try {
          final address = Map<String, dynamic>.from(addressData);
          print('Converting to Dart map: $address');
          
          setState(() {
            _selectedAddress = Address.fromJson(address);
            _isContinueEnabled = true;
            print('Updated state - Selected address: $_selectedAddress');
            print('Continue button enabled: $_isContinueEnabled');
          });
        } catch (e) {
          print('Error processing address in Dart: $e');
        }
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
                onPressed: _isContinueEnabled
                    ? () {
                        if (_selectedAddress != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressDetailsPage(
                                address: _selectedAddress!,
                              ),
                            ),
                          );
                        }
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