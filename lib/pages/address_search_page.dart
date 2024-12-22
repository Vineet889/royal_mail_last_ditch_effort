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
  final String _inputId = 'addressNowInput';
  Address? _selectedAddress;
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add the scripts in initState
    _addScriptToHead('https://api.addressnow.co.uk/css/addressnow-2.20.min.css?key=YOUR_API_KEY');
    _addScriptToHead('https://api.addressnow.co.uk/js/addressnow-2.20.min.js?key=YOUR_API_KEY');
    
    // Register the element factory after a delay to ensure scripts are loaded
    Future.delayed(const Duration(milliseconds: 1000), () {
      _initializeAddressNow();
    });
  }

  void _addScriptToHead(String src) {
    js.context.callMethod('eval', ['''
      var script = document.createElement('script');
      script.src = '$src';
      document.head.appendChild(script);
    ''']);
  }

  void _initializeAddressNow() {
    // Create and register the HTML element
    js.context.callMethod('eval', ['''
      if (!window.addressNowInitialized) {
        // Create the input element
        var input = document.createElement('input');
        input.id = '$_inputId';
        input.type = 'text';
        input.style.width = '100%';
        input.style.height = '100%';
        input.style.padding = '8px';
        input.style.border = '1px solid #ccc';
        input.style.borderRadius = '4px';
        input.style.fontSize = '16px';
        input.placeholder = 'Enter your postcode';

        // Register the factory
        window.platformViewRegistry.registerViewFactory('$_inputId', function(viewId) {
          return input;
        });

        // Initialize AddressNow
        var fields = [{
          element: input,
          field: "{Line1}",
          mode: pca.fieldMode.SEARCH
        }];

        var options = {
          key: "YOUR_API_KEY",
          search: { countries: "GBR" },
          onSelect: function(address) {
            window.handleAddressSelect({
              line1: address.Line1 || '',
              line2: address.Line2 || '',
              city: address.City || '',
              postcode: address.PostalCode || ''
            });
          }
        };

        // Create the control
        var control = new pca.Address(fields, options);
        window.addressNowInitialized = true;
      }
    ''']);

    // Setup the callback handler
    js.context['handleAddressSelect'] = (dynamic addressData) {
      setState(() {
        _selectedAddress = Address.fromJson(addressData);
        _isContinueEnabled = true;
      });
    };
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