import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection bluetoothConnection;

  bool _connected = false;
  bool _isDeviceListAvailable = false;
  bool isDisconnecting = false;
  bool get isConnected {
    return bluetoothConnection.isConnected;
  }

  List<BluetoothDevice> _deviceList = [];
  BluetoothDevice _device;

  Future<void> enableBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
    } else {
      await getPairedDevices();
    }
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException catch (error) {
      print(error.message);
    }

    if (!mounted) return;

    setState(() => _deviceList = devices);
  }

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state
        .then((value) => setState(() => _bluetoothState = value));

    enableBluetooth();

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isDeviceListAvailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (isConnected) {
      isDisconnecting = true;
      bluetoothConnection.dispose();
      bluetoothConnection = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    Future show(
      String message, {
      Duration duration: const Duration(seconds: 3),
    }) async {
      await new Future.delayed(new Duration(milliseconds: 100));
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text(
            message,
          ),
          duration: duration,
        ),
      );
    }

    List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
      List<DropdownMenuItem<BluetoothDevice>> items = [];
      if (_deviceList.isEmpty) {
        items.add(DropdownMenuItem(
          child: Text('NONE'),
        ));
      } else {
        _deviceList.forEach((device) {
          items.add(DropdownMenuItem(
            child: Text(device.name),
            value: device,
          ));
        });
      }
      return items;
    }

    void _connect() async {
      setState(() {
        _isDeviceListAvailable = true;
      });
      if (_device == null) {
        show('No device selected');
      } else {
        if (!isConnected) {
          await BluetoothConnection.toAddress(_device.address)
              .then((_connection) {
            print('Connected to the device');
            bluetoothConnection = _connection;
            setState(() {
              _connected = true;
            });

            bluetoothConnection.input.listen(null).onDone(() {
              if (isDisconnecting) {
                print('Disconnecting locally!');
              } else {
                print('Disconnected remotely!');
              }
              if (this.mounted) {
                setState(() {});
              }
            });
          }).catchError((error) {
            print('Cannot connect, exception occurred');
            print(error);
          });
          show('Device connected');

          setState(() => _isDeviceListAvailable = false);
        }
      }
    }

    void _disconnect() async {
      setState(() {
        _isDeviceListAvailable = true;
      });

      await bluetoothConnection.close();
      show('Device disconnected');
      if (!bluetoothConnection.isConnected) {
        setState(() {
          _connected = false;
          _isDeviceListAvailable = false;
        });
      }
    }

    void _sendMessage(String val) async {
    bluetoothConnection.output.add(utf8.encode("$val" + "\r\n"));
    await bluetoothConnection.output.allSent;
    show('Device Turned On');
    
  }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Terminator Helper'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info), onPressed: () {}),
          IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Enable Bluetooth',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Switch(
                    value: _bluetoothState.isEnabled,
                    activeColor: theme.primaryColor,
                    onChanged: (value) {
                      future() async {
                        value
                            ? FlutterBluetoothSerial.instance.requestEnable()
                            : FlutterBluetoothSerial.instance.requestDisable();

                        getPairedDevices();
                        _isDeviceListAvailable = false;

                        if (_connected) {
                          _disconnect();
                        }
                      }

                      future().then((_) {
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
            //SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Devices',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  DropdownButton(
                    items: _getDeviceItems(),
                    onChanged: (value) => setState(() => _device = value),
                    value: _device,
                  ),
                  FlatButton(
                    splashColor: Colors.cyan,
                    onPressed: _isDeviceListAvailable
                        ? null
                        : _connected ? _disconnect : _connect,
                    child: Text(_connected ? 'Disconnect' : 'Connect'),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    child: Container(
                      height: size.height * 0.07,
                      width: size.width * 0.24,
                      child: Center(
                        child: Text(
                          'Open',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      decoration: invertedbox,
                    ),
                    onTap: () => _sendMessage('1'),
                  ),
                  InkWell(
                    child: Container(
                      height: size.height * 0.07,
                      width: size.width * 0.24,
                      child: Center(
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      decoration: invertedbox,
                    ),
                    onTap: () => _sendMessage('2'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
