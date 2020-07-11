import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothState _bluetoothState;

  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection bluetoothConnection;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
