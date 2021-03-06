import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_stock/models/item.dart';
import 'package:home_stock/models/user.dart';
import 'package:home_stock/screens/shared/loading.dart';
import 'package:home_stock/screens/shared/systemPadding.dart';
import 'package:home_stock/services/database.dart';
import 'package:provider/provider.dart';

class EditItem extends StatefulWidget {

  final Item item;

  EditItem({this.item});

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {

  final _formKey = GlobalKey<FormState>();
  final List<String> categories = ['Fresh Food', 'Dry Food', 'Grocery', 'Household', 'Other'];
  final List<String> metrics = ['Grams', 'Kilograms', 'Milliliters', 'Liters', 'Packets', 'Tins', 'Bottles', 'Other'];

  bool loading = false;

  String _name;
  String _category;
  String _metric;
  int _quantity;

  @override
  Widget build(BuildContext context) {

    final listForUser = Provider.of<UserData>(context);

    _name = _name ?? widget.item.name;
    _category = _category ?? widget.item.category;
    _metric = _metric ?? widget.item.metric;
    _quantity = _quantity ?? widget.item.quantity;

    void _showFailedPanel(){
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (context){
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Failed to add Item',
                style: TextStyle(fontSize: 15.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                color: Colors.lightGreen[700],
                child: Text(
                  'Dismiss',
                  style: TextStyle(color: Colors.white)
                ),
                onPressed: () async{
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      });
    }

    return loading ? Loading() : new SystemPadding(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Text(
              'Edit Item',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              enabled: false,
              initialValue: _name ?? 'Name',
              validator: (val) => val.isEmpty ? 'Please enter a Name' : null,
              onChanged: (val) => setState(() => _name = val),
              readOnly: true,
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField(
              decoration: InputDecoration(hintText: 'Category'),
              value: _category.isEmpty ? null : categories[categories.indexOf(_category)],
              items: categories.map((category){
                return DropdownMenuItem(
                  value: category,
                  child: Text('$category'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _category = val),
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField(
              decoration: InputDecoration(hintText: 'Metric'),
              value: _metric.isEmpty ? null : metrics[metrics.indexOf(_metric)],
              items: metrics.map((metric){
                return DropdownMenuItem(
                  value: metric,
                  child: Text('$metric'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _metric = val),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              initialValue: _quantity.toString().isEmpty ? '0' : _quantity.toString(),
              keyboardType: TextInputType.number,
              validator: (val) => val.isEmpty ? 'Please enter Quantity' : null,
              onChanged: (val) => setState(() => _quantity = int.parse(val)),
            ),
            SizedBox(height: 20.0),
            RaisedButton(
              color: Colors.lightGreen[700],
              child: Text(
                'Edit Item',
                style: TextStyle(color: Colors.white)
              ),
              onPressed: () async {
                if(_formKey.currentState.validate()){
                  setState(() {
                    loading = true;
                  });
                  dynamic result = await DatabaseService(uid: listForUser.items).updateItemData(_name, _category, _quantity, _metric, widget.item.inShoppingList);
                  if(result == null){
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context);
                  }else if(result.toString() == 'Connection failed'){
                      showDialog(context: context, barrierDismissible: true, builder: (context){
                        return AlertDialog(
                            content: Container(
                              child: Text('Action Failed. Make sure you have an active internet connection'),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Dismiss'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                        );
                      });
                    }else{
                    Navigator.pop(context);
                    _showFailedPanel();
                  }
                }
                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}