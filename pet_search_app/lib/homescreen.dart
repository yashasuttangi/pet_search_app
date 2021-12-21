import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState() {
    _filter.addListener(() {
      // Initialization
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio(); // for http requests
  String _searchText = "";
  List names =
      new List.empty(growable: true); // List to store names we get from API
  List filteredNames = new List.empty(
      growable: true); // List to store names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('My Pets App');

  void _getNames() async {
    final response = await dio.get(
        'https://60d075407de0b20017108b89.mockapi.io/api/v1/animals'); // Performing a GET request from the API
    // print(response.data);
    List tempList =
        new List.empty(growable: true); // Temporary list to append names
    for (int i = 0; i < response.data.length; i++) {
      tempList.add(response.data[i]);
    }
    // print("Templist = $tempList");

    // As the birthDate is given in the API,
    // Use the given birthDate and the current date to calculate the age of pets
    // and store it in the list templist[i]["age"]
    for (int i = 0; i < tempList.length; i++) {
      DateTime birthDate = DateTime.parse(tempList[i]['bornAt']);
      DateTime now = DateTime.now();
      int months = now.month - birthDate.month; // months difference
      int years = now.year - birthDate.year; // years difference
      int days = now.day - birthDate.day; // days difference
      if (months < 0 || (months == 0 && days < 0)) {
        years--;
        months += (days < 0 ? 11 : 12);
      }
      int age = months + (years * 12); // age of the pet
      tempList[i]['age'] = age.toString(); // conver the age from int to string
    }
    setState(() {
      names = tempList;
      filteredNames = names;
    });
  }

  // search
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search Pets...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('My Pets App');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  // Search implementation
  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List.empty(growable: true);
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]['name']
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            filteredNames[i]['age'].contains(_searchText)) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }

    // List View builder to generate the list of list tiles
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
          height: 100,
          width: double.maxFinite,
          child: Card(
            elevation: 5,
            child: new ListTile(
              title: Text(filteredNames[index]['name']),
              subtitle: Text("Age: ${filteredNames[index]['age']} months"),
              onTap: () => print(filteredNames[index][
                  'name']), // just for testing, printing the names clicked on the console. (Remove in production)
            ),
          ),
        );
      },
    );
  }

  // App Bar
  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  @override
  void initState() {
    _getNames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100), child: _buildBar(context)),
      body: _buildList(),
    );
  }
}
