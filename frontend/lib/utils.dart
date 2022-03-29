import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

String tokenAddress = "0x7fB31050367377b3408f0AE011b4B1587c0305eB";
String nftAddress = "0xF81986B5303126565bDf6746662a4415c519bB23";
String lotteryAddress = "0x24F21B45531D995b480C8b2C413f3A058C40EF48";

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
