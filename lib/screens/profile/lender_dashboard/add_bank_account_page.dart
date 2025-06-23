import 'package:flutter/material.dart';

class AddBankAccountPage extends StatefulWidget {
  const AddBankAccountPage({super.key});

  @override
  State<AddBankAccountPage> createState() => _AddBankAccountPageState();
}

class _AddBankAccountPageState extends State<AddBankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCountry = 'Thailand'; // Prepopulate with Thailand
  String? _selectedBankCode;
  String? _selectedBank;
  final _sortNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();

  final List<String> _countries = ['Thailand'];
  final List<Map<String, String>> _banks = [
    {'name': 'Bangkok Bank', 'code': 'BBL', 'num': '002'},
    {'name': 'Bank of Ayudhya (Krungsri)', 'code': 'BAY', 'num': '025'},
    {'name': 'CIMB Thai Bank', 'code': 'CIMB', 'num': '022'},
    {'name': 'ICBC Thai', 'code': 'ICBC', 'num': '070'},
    {'name': 'Kasikornbank (KBank)', 'code': 'KBANK', 'num': '004'},
    {'name': 'Kiatnakin Phatra Bank', 'code': 'KKP', 'num': '069'},
    {'name': 'Krungthai Bank', 'code': 'KTB', 'num': '006'},
    {'name': 'Land & Houses Bank', 'code': 'LHBANK', 'num': '073'},
    {'name': 'Siam Commercial Bank', 'code': 'SCB', 'num': '014'},
    {'name': 'Standard Chartered Bank', 'code': 'SCBT', 'num': '020'},
    {'name': 'Tisco Bank', 'code': 'TISCO', 'num': '067'},
    {'name': 'TMBThanachart Bank', 'code': 'TTB', 'num': '011'},
    {'name': 'United Overseas Bank (Thai)', 'code': 'UOB', 'num': '024'},
    {'name': 'Thai Credit Bank', 'code': 'TCB', 'num': '071'},
  ];

  bool get _isFormValid =>
      _selectedCountry != null &&
      _selectedBank != null &&
      _selectedBank!.isNotEmpty &&
      _accountNumberController.text.isNotEmpty;

  @override
  void dispose() {
    _sortNumberController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "ADD ACCOUNT",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Country',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                items: _countries
                    .map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) =>
                    value == null ? 'Please select a country' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Bank Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBank,
                items: _banks
                    .map((bank) => DropdownMenuItem(
                          value: bank['name'],
                          child: Text('${bank['name']} (${bank['code']}, ${bank['num']})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBank = value;
                    final selected = _banks.firstWhere((bank) => bank['name'] == value);
                    _selectedBankCode = selected['code'];
                    // You can also access selected['num'] if needed
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a bank' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Account Number',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  hintText: 'Enter account number',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter account number' : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            // Add bank account logic here
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}