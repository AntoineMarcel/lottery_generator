import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:frontend/utils.dart';

class NewLottery extends StatefulWidget {
  const NewLottery({Key? key}) : super(key: key);

  @override
  State<NewLottery> createState() => _NewLottery();
}

class _NewLottery extends State<NewLottery> {
  bool creating = false;

  Future<bool> _create(int tokenId, int price, int duration) async {
    try {
      setState(() => creating = true);
      TransactionResponse approveTransaction =
          await nftContract.send("approve", [lotteryAddress, tokenId]);
      await approveTransaction.wait();

      TransactionResponse newLotTransaction = await lotteryContract
          .send("launchLottery", [tokenId, price, duration]);
      await newLotTransaction.wait();
      setState(() => creating = false);
      return true;
    } catch (e) {
      setState(() => creating = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormBuilderState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add a new lottery')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  intInput(context, "nft", "ID of the nft you own"),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: intInput(context, "price", "Price of the ticket"),
                  ),
                  intInput(
                      context, "duration", "Duration of the lottery (days)"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: creating
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              _formKey.currentState!.save();
                              try {
                                if (_formKey.currentState!.validate()) {
                                  if (await _create(
                                    int.parse(_formKey
                                        .currentState!.fields["nft"]!.value),
                                    int.parse(_formKey
                                        .currentState!.fields["price"]!.value),
                                    int.parse(_formKey.currentState!
                                        .fields["duration"]!.value),
                                  )) Navigator.pop(context);
                                }
                              } catch (e) {
                                print(e);
                              }
                            },
                            child: const Text('Create'),
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
