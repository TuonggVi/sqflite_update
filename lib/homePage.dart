import 'package:flutter/material.dart';
import 'package:test_database/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'SQLITE',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _lotIdController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _purchaseOrderController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sublotSizeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _lotIdController.text = existingJournal['lotId'];
      _itemNameController.text = existingJournal['itemName'];
      _purchaseOrderController.text = existingJournal['purchaseOrderNumber'];
      _quantityController.text = existingJournal['quantity'];
      _sublotSizeController.text = existingJournal['sublotSize'];
      _locationController.text = existingJournal['location'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _lotIdController,
                    decoration: const InputDecoration(hintText: 'Mã lô'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(hintText: 'Tên sản phẩm'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _purchaseOrderController,
                    decoration: const InputDecoration(hintText: 'Số PO'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(hintText: 'Tổng lượng'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _sublotSizeController,
                    decoration: const InputDecoration(hintText: 'Định mức'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Vị trí'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }
                      // Clear the text fields
                      _lotIdController.text = '';
                      _itemNameController.text = '';
                      _purchaseOrderController.text = '';
                      _quantityController.text = '';
                      _sublotSizeController.text = '';
                      _locationController.text = '';
                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _lotIdController.text,
        _itemNameController.text,
        _purchaseOrderController.text,
        _quantityController.text,
        _sublotSizeController.text,
        _locationController.text);
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id,
        _lotIdController.text,
        _itemNameController.text,
        _purchaseOrderController.text,
        _quantityController.text,
        _sublotSizeController.text,
        _locationController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => Container(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: Column(   
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                      child: Column(
                        children: [
                          Text('Mã lô: ' + _journals[index]['lotId']),
                          Text('Tên sản phẩm: '+_journals[index]['itemName']),
                          Text('Số PO: '+_journals[index]['purchaseOrderNumber']),
                          Text('Tổng lượng: '+_journals[index]['quantity']),
                          Text('Định mức: '+_journals[index]['sublotSize']),
                          Text('Vị trí: '+_journals[index]['location']),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(200, 5, 0, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_journals[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
