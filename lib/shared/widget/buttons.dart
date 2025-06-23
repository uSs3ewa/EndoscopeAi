// ====================================================
//  Файл содержит фунции для генерации кнопок
// ====================================================

import 'package:flutter/material.dart';
import 'package:endoscopy_ai/routes.dart';

// Создает кнопку с текстом `text`, которая при нажатии перебрасывает на
// страницу `route_path`, сохраняя текущее состояние.
Widget createRedirectButton(
  BuildContext context,
  String text,
  String routePath, {
  bool disable = false,
}) {
  return ElevatedButton(
    onPressed: disable
        ? null
        : () {
            Navigator.pushNamed(context, routePath);
          },
    child: Text(text),
  );
}

// Создает кнопу возвращения домой
Widget createBackHomeButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(
        context,
        Routes.homePage,
      ); // MAYBE BUG: мы стакаем куда идем, сохраняя предыдущие окна, поэтому при долго использовании при ложения может чтото сломаться
    },
    child: Text('Назад'),
  );
}
