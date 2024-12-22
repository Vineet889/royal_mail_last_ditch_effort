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
  final String _inputId = 'addressNowInput';

  @override
  void initState() {
    super.initState();
    _initializeAddressNow();
  }

  void _initializeAddressNow() {
    js.context.callMethod('eval', ['''
      // Create input element factory
      function AddressInputFactory() {
        var container = document.createElement('div');
        container.style.width = '100%';
        container.style.height = '56px';  // Match Material Design height
        
        var input = document.createElement('input');
        input.id = '$_inputId';
        input.type = 'text';
        input.style.width = '100%';
        input.style.height = '100%';
        input.style.padding = '8px';
        input.style.border = '1px solid #ccc';
        input.style.borderRadius = '4px';
        input.style.fontSize = '16px';
        
        container.appendChild(input);
        
        // Initialize AddressNow after a short delay to ensure DOM is ready
        setTimeout(function() {
          var fields = [{
            element: input,
            field: "Line1",
            mode: pca.fieldMode.SEARCH
          }];
          
          var options = {
            key: "YOUR_API_KEY",
            search: {
              countries: "GBR"
            },
            onSelect: function(address) {
              window.handleAddressSelect({
                line1: address.Line1 || '',
                line2: address.Line2 || '',
                city: address.City || '',
                postcode: address.PostalCode || ''
              });
            }
          };
          
          var control = new pca.Address(fields, options);
        }, 1000);
        
        return container;
      }
      
      // Register the factory
      window.platformViewRegistry.registerViewFactory('$_inputId', function(viewId) {
        return new AddressInputFactory();
      });
    ''']);

    // Setup JavaScript callback
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
            TextField(
              controller: _postcodeController,
              decoration: const InputDecoration(
                labelText: 'Postcode',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56, // Fixed height for the input
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
        input.parentElement.remove();
      }
    ''']);
    super.dispose();
  }
} 