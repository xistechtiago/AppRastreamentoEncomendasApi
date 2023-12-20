import 'package:rastreamento_encomendas/models/item_model.dart';
import 'package:rastreamento_encomendas/ui/components/bottomsheet_wrapper.dart';
import 'package:flutter/material.dart';

Widget buildNewItemComponent(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
    Function(ItemModel) onAdd) {
  final nameTextController = TextEditingController();
  final codeTextController = TextEditingController();
  List<String> dropOpcoes = ['Correios', 'MercadoLivre', 'Shopee', 'Amazon'];
  String? selectecItem = 'Correios';
  String _selectedValue;

  return BottomSheetWrapper(
    title: "Novo rastreamento",
    children: [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectecItem,
              hint: const Text('Selecione o tipo de rastreamento'),
              decoration : InputDecoration(
                  label: const Text('Tipo de rastreamento'),
            ),
              items: dropOpcoes
                .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style : TextStyle(fontSize: 24)),
            ))
            .toList(),
              onChanged:(value) {
               // setState(() {
                  _selectedValue = selectecItem;
               // });
              },
              isExpanded: true,
            ),

            SizedBox(height: 20),

            TextFormField(
              controller: nameTextController,
              decoration: InputDecoration(
                labelText: "Descrição",
              ),
            ),

            SizedBox(height: 20),

            TextFormField(
              controller: codeTextController,
              decoration: InputDecoration(
                labelText: "Codigo de rastreamento",
              ),
            ),
          ],
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          fixedSize: Size(340, 45),
          backgroundColor: Colors.teal
        ),
        onPressed: () {
          if (codeTextController.text.isEmpty) return;
          if (nameTextController.text.isEmpty) {
            nameTextController.text = codeTextController.text;
          }

          ItemModel newItem = ItemModel(
              title: nameTextController.text,
              code: codeTextController.text,
              info: []);

          onAdd(newItem);
          Navigator.of(context).pop();
        },
        child: Text("Rastrear encomenda"),
      )
    ],
  );
}
