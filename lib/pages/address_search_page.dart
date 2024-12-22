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
    // Register the view factory using the proper Flutter mechanism
    ui.platformViewRegistry.registerViewFactory(_inputId, (int viewId) {
      final input = html.InputElement()
        ..id = _inputId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.padding = '8px'
        ..style.border = '1px solid #ccc'
        ..style.borderRadius = '4px'
        ..style.fontSize = '16px'
        ..placeholder = 'Enter your postcode';
      
      // Add the scripts after creating the element
      _addScriptToHead('https://api.addressnow.co.uk/css/addressnow-2.20.min.css?key=YOUR_API_KEY');
      _addScriptToHead('https://api.addressnow.co.uk/js/addressnow-2.20.min.js?key=YOUR_API_KEY');
      
      // Initialize AddressNow after scripts are loaded
      Future.delayed(const Duration(milliseconds: 1000), () {
        _initializeAddressNow();
      });

      return input;
    });
  }

  void _addScriptToHead(String src) {
    final script = html.ScriptElement()
      ..src = src
      ..type = 'text/javascript';
    html.document.head!.children.add(script);
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      var input = document.getElementById('$_inputId');
      if (input && !window.addressNowInitialized) {
        // Initialize AddressNow for UK only
        var control = new pca.Address(input, {
          key: "YOUR_API_KEY",
          countries: {
            codesList: "GBR",
            defaultCode: "GBR"
          },
          search: {
            countries: ["GBR"]
          },
          onPopulate: function(address) {
            console.log('Address selected:', address); // Debug log
            
            // Format the address for our callback
            var formattedAddress = {
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            };
            
            // Call our Dart callback
            if (window.handleAddressSelect) {
              window.handleAddressSelect(formattedAddress);
            }
          }
        });

        window.addressNowControl = control;  // Store reference
        window.addressNowInitialized = true;
      }
    ''']);

    // Setup the callback handler
    js.context['handleAddressSelect'] = js.allowInterop((dynamic addressData) {
      print('Address selected in Dart: $addressData'); // Debug log
      
      if (addressData != null) {
        setState(() {
          _selectedAddress = Address.fromJson(Map<String, dynamic>.from(addressData));
          _isContinueEnabled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: HtmlElementView(viewType: _inputId),
            ),
            const SizedBox(height: 16),
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