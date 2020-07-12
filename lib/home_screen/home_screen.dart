import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../helper.dart';

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
    return bluetoothConnection != null && bluetoothConnection.isConnected;
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

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          textAlign: TextAlign.center,
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _connect() async {
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

        setState(() {
          _connected = true;
          _isDeviceListAvailable = true;
        });
      }
    }
  }

  void _disconnect() async {
    // setState(() {
    //   _isDeviceListAvailable = true;
    // });

    await bluetoothConnection.close();
    show('Device disconnected');
    if (!bluetoothConnection.isConnected) {
      setState(() {
        _connected = false;
        _isDeviceListAvailable = true;
      });
    }
  }

  void _sendMessage(String val) async {
    show('Opening tray');
    bluetoothConnection.output.add(utf8.encode("$val" + "\r\n"));

    await bluetoothConnection.output.allSent;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Terminator Helper'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info), onPressed: () {}),
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                await getPairedDevices().then(
                  (value) => show('Device list updated'),
                );
              }),
        ],
      ),
      body: Container(
        height: size.height,
        width: size.width,
        padding: EdgeInsets.all(12),
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
            SizedBox(
              height: 20,
            ),
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
                    elevation: 8,
                  ),
                  FlatButton(
                    splashColor: theme.primaryColor,
                    onPressed: _connected ? _disconnect : _connect,
                    child: Text(_connected ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    child: openCloseBtn(size, 'Open'),
                    onTap: () => _sendMessage('1'),
                  ),
                  InkWell(
                    child: openCloseBtn(size, 'Close'),
                    onTap: () => _sendMessage('2'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    child: timerBtn(size, '30 Sec'),
                    onTap: () => _sendMessage('3'),
                  ),
                  InkWell(
                    child: timerBtn(size, '1 min'),
                    onTap: () => _sendMessage('4'),
                  ),
                  InkWell(
                    child: timerBtn(size, '2 min'),
                    onTap: () => _sendMessage('5'),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    child: timerBtn(size, '3 min'),
                    onTap: () => _sendMessage('6'),
                  ),
                  InkWell(
                    child: timerBtn(size, '4 min'),
                    onTap: () => _sendMessage('7'),
                  ),
                  InkWell(
                    child: timerBtn(size, '5 min'),
                    onTap: () => _sendMessage('8'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget openCloseBtn(Size size, val) {
    return Container(
      height: size.height * 0.07,
      width: size.width * 0.24,
      child: Center(
        child: Text(
          '$val',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
      ),
      decoration: invertedbox,
    );
  }

  Widget timerBtn(Size size, val) {
    return Container(
      height: size.height * 0.1,
      width: size.height * 0.1,
      child: Center(
        child: Text(
          '$val',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: circle,
    );
  }
}
