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
  bool mining = false;
  int currentIndex = -1;

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
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          for (LotteryStruct _lottery in lotteries.reversed)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                tileColor:
                                    currentIndex == lotteries.indexOf(_lottery)
                                        ? Colors.black38
                                        : Colors.black,
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [Icon(Icons.attach_money)],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.arrow_forward_ios)
                                  ],
                                ),
                                title: Row(children: [
                                  Image.network(
                                    _lottery.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        "${_lottery.ended ? "Lottery ended\n" : "${_lottery.lotteryEnd.difference(DateTime.now()).inDays + 1} days lefts to get that unique NFT\n"}"
                                        "Entry price : ${_lottery.entryPrice.toString()}$tokenSymbol\n"
                                        "${_lottery.ended ? "Winner : ${_lottery.winner.toString()}\n" : ""}"
                                        "Number of players : ${_lottery.players.length}",
                                      ),
                                    ),
                                  ),
                                ]),
                                onTap: () {
                                  setState(() => currentIndex =
                                      lotteries.indexOf(_lottery));
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    currentIndex != -1
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Image.network(
                                  lotteries[currentIndex].imageUrl,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.contain,
                                ),
                                const Text("Earn that amazing NFT!"),
                                const Divider(),
                                if (isConnected &&
                                    lotteries[currentIndex].ended == false)
                                  mining
                                      ? const CircularProgressIndicator()
                                      : Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                            onPressed: () => {},
                                            icon: const Icon(
                                                Icons.attach_money_sharp),
                                            label: const Text("Buy my ticket"),
                                          ),
                                        ),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            lotteries[currentIndex]
                                                    .players
                                                    .isNotEmpty
                                                ? 'Tickets Owner'
                                                : 'No tickets Owner',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        for (var player
                                            in lotteries[currentIndex].players)
                                          Text(player),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
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
