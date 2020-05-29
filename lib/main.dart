import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    bluetoothConnectoinState();
  }

  Future<void> bluetoothConnectoinState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } catch (error) {
      print(error);
    }

    bluetooth.onStateChanged().listen((event) {
      switch (event) {
        case FlutterBluetoothSerial.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = true;
          });
          break;

        case FlutterBluetoothSerial.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;

        default:
          print(event);
          break;
      }

      setState(() {
        _devicesList = devices;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<BluetoothDevice>> _getDeviceList() {
      List<DropdownMenuItem<BluetoothDevice>> items = [];
      if (_devicesList.isEmpty) {
        items.add(DropdownMenuItem(
          child: Text('NONE'),
        ));
      } else {
        _devicesList.forEach((device) {
          items.add(DropdownMenuItem(
            child: Text(device.name),
            value: device,
          ));
        });
      }
      return items;
    }

    void _connect() {
      if (_device == null) {
        SnackBar(content: Text('No Device Selected'));
      } else {
        bluetooth.isConnected.then((isConnected) {
          if (!isConnected) {
            bluetooth
                .connect(_device)
                .timeout(Duration(seconds: 10))
                .catchError((error) {
              setState(() => _pressed = false);
            });
            setState(() => _pressed = true);
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Arduino Controller"),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Text('Devices'),
                  DropdownButton(
                    items: null, //to be added _getDeviceList()
                    onChanged: (val) => setState(() => _device = val),
                    value: _device,
                  ),
                  FlatButton(
                    onPressed:
                        null, //_pressed ? null : _connected ? _disconnect : _connect,
                    child: Text(_connected ? 'Disconnect' : 'Connect'),
                  )
                ],
              ),
            ),
            Card(
              elevation: 1,
              child: Row(
                children: <Widget>[
                  Text('Device 1'),
                  FlatButton(
                    onPressed:
                        null, //_connected ? _sendOnMessageToBluetooth : null,
                    child: Text('On'),
                  ),
                  FlatButton(
                    onPressed:
                        null, //_connected ? _sendOffMessageToBluetooth : null,
                    child: Text("OFF"),
                  ),
                ],
              ),
            ),
            Container(
                child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'NOTE: If the device is not listed above'
                    'open settings and pair the device',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
