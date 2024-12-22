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
    // Add the Royal Mail AddressNow scripts to the head
    _addScriptToHead('https://api.addressnow.co.uk/css/addressnow-2.20.min.css?key=YOUR_API_KEY');
    _addScriptToHead('https://api.addressnow.co.uk/js/addressnow-2.20.min.js?key=YOUR_API_KEY');
    
    // Setup JavaScript callback
    js.context['handleAddressSelect'] = (dynamic addressData) {
      setState(() {
        _selectedAddress = Address.fromJson(addressData);
        _isContinueEnabled = true;
      });
    };
  }

  void _addScriptToHead(String url) {
    js.context.callMethod('eval', ['''
      var script = document.createElement('script');
      script.src = "$url";
      document.head.appendChild(script);
    ''']);
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
              HtmlElementView(
                viewType: _inputId,
                key: ValueKey(_inputId),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isContinueEnabled
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressDetailsPage(
                              address: _selectedAddress!,
                            ),
                          ),
                        )
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createInputElement();
  }

  void _createInputElement() {
    // Register the platform view
    if (js.context['_addressInputRegistered'] == null) {
      js.context['_addressInputRegistered'] = true;
      
      // Create and register the platform view factory
      js.context.callMethod('eval', ['''
        function AddressInputFactory() {}
        AddressInputFactory.prototype.createElement = function() {
          var container = document.createElement('div');
          var input = document.createElement('input');
          input.type = 'text';
          input.id = '$_inputId';
          input.className = 'form-control';
          input.placeholder = 'Enter postcode';
          container.appendChild(input);
          
          // Initialize AddressNow on the input
          setTimeout(function() {
            if (window.AddressNow) {
              AddressNow.listen('#$_inputId', {
                key: 'YOUR_API_KEY',
                onSelect: function(address) {
                  window.handleAddressSelect({
                    line1: address.line1,
                    line2: address.line2,
                    city: address.town,
                    postcode: address.postcode
                  });
                }
              });
            }
          }, 1000);
          
          return container;
        };
        
        // Register the factory
        window.platformViewRegistry.registerViewFactory('$_inputId', function(viewId) {
          return new AddressInputFactory().createElement();
        });
      ''']);
    }
  }

  @override
  void dispose() {
    // Cleanup any resources
    js.context.callMethod('eval', ['''
      var input = document.getElementById('$_inputId');
      if (input) {
        input.remove();
      }
    ''']);
    super.dispose();
  }
} 