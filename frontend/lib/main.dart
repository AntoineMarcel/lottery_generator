import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/home.dart';
import 'package:frontend/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  bool _isConnected = false;
  dynamic _provider;
  await dotenv.load(fileName: ".env");

  if (ethereum != null &&
      ethereum!.isConnected() &&
      (await provider!.getNetwork()).name == "maticmum") {
    if ((await ethereum!.getAccounts()).isNotEmpty) {
      _provider = provider!.getSigner();
      connected = await provider!.getSigner().getAddress();
      _isConnected = true;
    } else {
      _provider = provider!;
    }
  } else {
    _provider = JsonRpcProvider(dotenv.env['SPEEDY_NODE']);
  }

  WidgetsFlutterBinding.ensureInitialized();
  lotteryAbi = await rootBundle.loadString("assets/LotteryGenerator.json");
  nftAbi = await rootBundle.loadString("assets/NFTCollection.json");

  lotteryContract = Contract(lotteryAddress, lotteryAbi, _provider);
  nftContract = Contract(nftAddress, nftAbi, _provider);
  tokenContract = ContractERC20(tokenAddress, _provider);
  tokenSymbol = await tokenContract.symbol;
  owner = await lotteryContract.call("owner");

  var _lotteries = await lotteryContract.call('getAllLoteries');

  for (List<dynamic> _lottery in _lotteries) {
    String tokenURI =
        await nftContract.call("tokenURI", [_lottery[1].toString()]);
    String readURI = await http.read(Uri.parse(tokenURI));

    lotteries
        .add(LotteryStruct.fromCall(_lottery, jsonDecode(readURI)["image"]));
  }

  runApp(MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        listTileTheme: ListTileThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        )),
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    title: 'Token Lottery',
    home: MyHomePage(isConnected: _isConnected),
  ));
}
