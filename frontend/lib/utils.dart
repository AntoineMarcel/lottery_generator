import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

String tokenAddress = "0xD2a6b411b8235e92Ea8FeB95821800C467e10eE0";
String nftAddress = "0x4aF96CFC918988aE2852B25aB52583c604E63EAe";
String lotteryAddress = "0x43F4Bc4A9138673d3CF15933b28247338D4af964";
String speedyNode =
    "https://speedy-nodes-nyc.moralis.io/4ca02b18c4782872b71cc119/eth/rinkeby";

late Contract lotteryContract;
late Contract nftContract;
late ContractERC20 tokenContract;
late String tokenSymbol;
late String nftAbi;
late String lotteryAbi;

FormBuilderTextField intInput(
    BuildContext context, String name, String labelText) {
  return FormBuilderTextField(
    name: name,
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      labelText: labelText,
    ),
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly
    ],
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(context),
      FormBuilderValidators.numeric(context),
    ]),
  );
}

class LotteryStruct {
  String owner;
  final int tokenId;
  List<dynamic> players;
  final int entryPrice;
  int totalTokens;
  String winner;
  final DateTime lotteryStart;
  final DateTime lotteryEnd;
  final String imageUrl;
  bool ended;

  LotteryStruct(
    this.owner,
    this.tokenId,
    this.players,
    this.entryPrice,
    this.totalTokens,
    this.winner,
    this.lotteryStart,
    this.lotteryEnd,
    this.imageUrl,
    this.ended,
  );

  LotteryStruct.fromCall(List<dynamic> list, this.imageUrl)
      : owner = list[0],
        tokenId = int.parse(list[1].toString()),
        players = list[2],
        entryPrice = int.parse(list[3].toString()),
        totalTokens = int.parse(list[4].toString()),
        winner = list[5],
        lotteryStart = DateTime.fromMillisecondsSinceEpoch(
            int.parse(list[6].toString()) * 1000),
        lotteryEnd = DateTime.fromMillisecondsSinceEpoch(
            int.parse(list[7].toString()) * 1000),
        ended = list[8].toString().toLowerCase() == 'true';
}

List<LotteryStruct> lotteries = [];
