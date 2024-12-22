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
    Future.delayed(const Duration(milliseconds: 500), _initializeAddressNow);
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
            countries: ["GBR"]
          },
          bar: {
            visible: true,
            showCountry: false
          },
          onPopulate: function(address) {
            console.log('onPopulate event:', address);
            handleAddressSelection(address);
          },
          onSelect: function(address) {
            console.log('onSelect event:', address);
            handleAddressSelection(address);
          }
        });

        window.handleAddressSelection = function(address) {
          if (!address) {
            console.error('No address data received');
            return;
          }

          var formattedAddress = {
            line1: address.Line1 || '',
            line2: address.Line2 || '',
            city: address.City || '',
            postcode: address.PostalCode || ''
          };

          console.log('Formatted address:', formattedAddress);
          window.handleAddressSelect(formattedAddress);
        };

        window.addressNowControl = control;
        window.addressNowInitialized = true;
        console.log('AddressNow initialized successfully');
      }
    ''']);

    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('Dart received address: $addressData');
      
      if (addressData == null) {
        print('Error: Null address data received');
        return;
      }

      try {
        final Map<String, dynamic> address = Map<String, dynamic>.from(addressData);
        print('Processing address: $address');

        if (mounted) {
          setState(() {
            _selectedAddress = Address.fromJson(address);
            _isContinueEnabled = _selectedAddress != null && 
                               _selectedAddress!.line1.isNotEmpty;
            print('Address set: $_selectedAddress');
            print('Continue enabled: $_isContinueEnabled');
          });
        }
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
              if (_selectedAddress != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Selected: ${_selectedAddress!.line1}, ${_selectedAddress!.postcode}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ElevatedButton(
                onPressed: (_selectedAddress != null && _isContinueEnabled)
                    ? () {
                        print('Navigating with address: $_selectedAddress');
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
      if (window.addressNowControl) {
        window.addressNowControl.destroy();
      }
      window.addressNowInitialized = false;
    ''']);
    super.dispose();
  }
} 