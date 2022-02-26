import 'package:flutter/material.dart';

class CuentaItem extends StatelessWidget {
  final data;
  const CuentaItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          "${data["nombre"]} ${data["apellido"]}",
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text("${data["cuenta"]}"),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "\$${data["dinero"]}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              "Saldo disponible",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
