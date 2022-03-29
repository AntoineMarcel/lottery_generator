import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:frontend/utils.dart';
import 'package:frontend/new.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.isConnected}) : super(key: key);
  final bool isConnected;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isConnected = false;

  @override
  void initState() {
    setState(() => isConnected = widget.isConnected);
    super.initState();
  }

  void _connectMetamask() async {
    if (ethereum != null) {
      try {
        final accs = await ethereum!.requestAccount();
        accs;
        lotteryContract =
            Contract(lotteryAddress, lotteryAbi, provider!.getSigner());
        nftContract = Contract(nftAddress, nftAbi, provider!.getSigner());
        tokenContract = ContractERC20(tokenAddress, provider!.getSigner());
        setState(() => isConnected = true);
      } on EthereumUserRejected {
        print('User rejected the modal');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to the token lottery !"),
          actions: [
            ethereum != null
                ? isConnected
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _connectMetamask(),
                          icon: const Icon(Icons.door_back_door_outlined),
                          label: const Text("Connect my wallet"),
                        ),
                      )
                : Container(
                    decoration: const BoxDecoration(color: Colors.grey),
                    child: const Text(
                        "Please install Metamask to buy your ticket"),
                  ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                isConnected.toString(),
              ),
            ],
          ),
        ),
        floatingActionButton: !isConnected
            ? null
            : FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewLottery()),
                  );
                },
                child: const Icon(Icons.add),
              ),
      );
}
