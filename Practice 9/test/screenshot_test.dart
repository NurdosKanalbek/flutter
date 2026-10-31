import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/books_screen.dart';
import 'package:shop/cart_screen.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('Generate screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final cart = Cart();
    cart.add(books[0]);
    cart.add(books[1]);

    final booksKey = GlobalKey();
    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: cart,
        child: RepaintBoundary(
          key: booksKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
              useMaterial3: true,
            ),
            home: const BooksScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final booksBoundary =
          booksKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final booksImage = await booksBoundary.toImage(pixelRatio: 2.0);
      final booksBytes = await booksImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      File('screenshot_books.png')
          .writeAsBytesSync(booksBytes!.buffer.asUint8List());
    });

    // Now for Cart Screen: increment one book to have quantity 2
    cart.increment(books[0]); // books[0] qty = 2, books[1] qty = 1

    final cartKey = GlobalKey();
    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: cart,
        child: RepaintBoundary(
          key: cartKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
              useMaterial3: true,
            ),
            home: const CartScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final cartBoundary =
          cartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final cartImage = await cartBoundary.toImage(pixelRatio: 2.0);
      final cartBytes = await cartImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      File('screenshot_cart.png')
          .writeAsBytesSync(cartBytes!.buffer.asUint8List());
    });
  });
}
