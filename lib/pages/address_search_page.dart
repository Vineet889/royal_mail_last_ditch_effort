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
  final String _inputId = 'addressInput';
  final _addressController = TextEditingController();
  bool _isContinueEnabled = false;

  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(_inputId, (int viewId) {
      final input = html.TextAreaElement()
        ..id = _inputId
        ..style.width = '100%'
        ..style.height = '100px'
        ..style.padding = '8px'
        ..style.border = '1px solid #ccc'
        ..style.borderRadius = '4px'
        ..placeholder = 'Paste your full address here';

      // Listen for input changes
      input.onInput.listen((event) {
        final address = input.value ?? '';
        _processAddress(address);
      });

      return input;
    });
  }

  void _processAddress(String fullAddress) {
    if (fullAddress.isEmpty) {
      setState(() => _isContinueEnabled = false);
      return;
    }

    // Split address into lines
    final lines = fullAddress.split('\n');
    if (lines.length < 2) return;

    // Extract postcode from the last line
    final postcode = lines.last.trim();
    
    // City is typically the line before postcode
    final city = lines[lines.length - 2].trim();
    
    // First line is address line 1
    final line1 = lines[0].trim();
    
    // Everything else goes into line 2
    final line2 = lines.length > 3 
        ? lines.sublist(1, lines.length - 2).join(', ').trim()
        : '';

    final address = Address(
      line1: line1,
      line2: line2,
      city: city,
      postcode: postcode,
    );

    setState(() {
      _isContinueEnabled = true;
      _addressController.text = fullAddress;
    });

    js.context['selectedAddress'] = js.JsObject.jsify({
      'line1': line1,
      'line2': line2,
      'city': city,
      'postcode': postcode,
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
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: HtmlElementView(viewType: _inputId),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isContinueEnabled
                  ? () {
                      final addressData = js.context['selectedAddress'];
                      if (addressData != null) {
                        final address = Address.fromJson(
                          Map<String, dynamic>.from(
                            js.JsObject.dartify(addressData) as Map
                          )
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressDetailsPage(
                              address: address,
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
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
} 