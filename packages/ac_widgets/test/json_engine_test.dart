import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_widgets/ac_widgets.dart';

void main() {
  setUpAll(() {
    acRegisterDefaultBuilders();
  });

  group('AcJsonScreenRenderer & JSON Engine Tests', () {
    testWidgets('renders column with flex children and gaps without layout exceptions', (tester) async {
      const screenJson = '''
      {
        "id": "test_flex_screen",
        "title": "Flex Test",
        "body": {
          "element": "act-column",
          "gap": "md",
          "children": [
            {
              "element": "act-row",
              "gap": 8,
              "children": [
                {
                  "element": "act-text-input",
                  "flex": 1,
                  "value": "Initial Value",
                  "prefixIcon": "search"
                },
                {
                  "element": "act-date-range-input",
                  "fromKey": "dateFrom",
                  "toKey": "dateTo"
                },
                {
                  "element": "act-button",
                  "label": "Filter"
                }
              ]
            },
            {
              "element": "act-gap",
              "size": "sm"
            },
            {
              "element": "act-card",
              "title": "Info Card",
              "child": {
                "element": "act-text",
                "text": "Card Content"
              }
            }
          ]
        }
      }
      ''';

      await tester.pumpWidget(
        MaterialApp(
          home: AcJsonScreenRenderer.fromJson(screenJson),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Flex Test'), findsOneWidget);
      expect(find.text('Initial Value'), findsOneWidget);
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Info Card'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('renders datagrid in list screen with zebra rows', (tester) async {
      const listScreenJson = '''
      {
        "id": "test_list_screen",
        "title": "Invoices",
        "type": "list",
        "state": {
          "items": [
            {"invoiceNo": "INV-001", "customer": "Acme Corp", "amount": 12500},
            {"invoiceNo": "INV-002", "customer": "Global Tech", "amount": 8900}
          ]
        },
        "body": {
          "element": "act-column",
          "children": [
            {
              "element": "act-row",
              "children": [
                {
                  "element": "act-text-input",
                  "flex": 1,
                  "placeholder": "Search..."
                }
              ]
            },
            {
              "element": "act-list",
              "columns": [
                {"label": "Invoice #", "field": "invoiceNo", "flex": 1},
                {"label": "Customer", "field": "customer", "flex": 2},
                {"label": "Amount", "field": "amount", "type": "amount", "flex": 1}
              ]
            }
          ]
        }
      }
      ''';

      await tester.pumpWidget(
        MaterialApp(
          home: AcJsonScreenRenderer.fromJson(listScreenJson),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Invoices'), findsOneWidget);
      expect(find.text('Invoice #'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('INV-001'), findsOneWidget);
      expect(find.text('INV-002'), findsOneWidget);
      expect(find.text('Acme Corp'), findsOneWidget);
    });
  });
}
