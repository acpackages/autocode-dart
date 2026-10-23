import 'package:flutter/material.dart';
import 'package:ac_widgets/ac_widgets.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

void main() {
  runApp(const AcWidgetsShowcaseApp());
}

class AcWidgetsShowcaseApp extends StatelessWidget {
  const AcWidgetsShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoCode Widgets Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ShowcaseMainScreen(),
    );
  }
}

class ShowcaseMainScreen extends StatefulWidget {
  const ShowcaseMainScreen({super.key});

  @override
  State<ShowcaseMainScreen> createState() => _ShowcaseMainScreenState();
}

class _ShowcaseMainScreenState extends State<ShowcaseMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCode UI Widgets (ac_widgets)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.table_chart), text: 'AcDatagrid'),
            Tab(icon: Icon(Icons.view_agenda), text: 'AcRepeater'),
            Tab(icon: Icon(Icons.splitscreen), text: 'AcResizable & Panels'),
            Tab(icon: Icon(Icons.pages), text: 'AcPagination'),
            Tab(icon: Icon(Icons.schema), text: 'DataDictionary UI'),
            Tab(icon: Icon(Icons.widgets), text: 'Layout & UI Elements'),
            Tab(icon: Icon(Icons.notifications_active), text: 'AcMessage'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DatagridShowcaseTab(),
          RepeaterShowcaseTab(),
          ResizableShowcaseTab(),
          PaginationShowcaseTab(),
          DataDictionaryShowcaseTab(),
          UiElementsShowcaseTab(),
          MessageShowcaseTab(),
        ],
      ),
    );
  }
}

// ==========================================
// 1. AcDatagrid Tab
// ==========================================
class DatagridShowcaseTab extends StatefulWidget {
  const DatagridShowcaseTab({super.key});

  @override
  State<DatagridShowcaseTab> createState() => _DatagridShowcaseTabState();
}

class _DatagridShowcaseTabState extends State<DatagridShowcaseTab> {
  late AcDataManager _dataManager;
  final GlobalKey<State<AcDatagrid>> _datagridKey = GlobalKey();

  final List<Map<String, dynamic>> _mockEmployees = List.generate(40, (i) {
    final depts = ['Engineering', 'Design', 'Marketing', 'Finance', 'Operations'];
    return {
      'id': '${i + 1}',
      'name': 'Employee ${i + 1}',
      'dept': depts[i % depts.length],
      'salary': 50000 + (i * 2500),
      'active': i % 3 != 0,
    };
  });

  @override
  void initState() {
    super.initState();
    _dataManager = AcDataManager(
      data: _mockEmployees,
      usePagination: true,
      pageSize: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      AcDatagridColumn(field: 'id', title: 'ID', width: 60),
      AcDatagridColumn(field: 'name', title: 'Full Name', width: 160),
      AcDatagridColumn(field: 'dept', title: 'Department', width: 140),
      AcDatagridColumn(
        field: 'salary',
        title: 'Salary',
        width: 120,
        dataType: AcDatagridColumnDataType.number,
      ),
      AcDatagridColumn(
        field: 'active',
        title: 'Active Status',
        width: 110,
        dataType: AcDatagridColumnDataType.boolean,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'High-performance table with column resize, sort, filter popup, and inline edit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
                onPressed: () {
                  final csv = AcDatagridCsvExporter.exportToString(
                    dataManager: _dataManager,
                    columns: columns,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV exported (${csv.length} chars)')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: AcDatagrid(
                key: _datagridKey,
                dataManager: _dataManager,
                columns: columns,
                showSelectionCheckbox: true,
                showPagination: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. AcRepeater Tab
// ==========================================
class RepeaterShowcaseTab extends StatefulWidget {
  const RepeaterShowcaseTab({super.key});

  @override
  State<RepeaterShowcaseTab> createState() => _RepeaterShowcaseTabState();
}

class _RepeaterShowcaseTabState extends State<RepeaterShowcaseTab> {
  late AcDataManager _dataManager;

  final List<Map<String, dynamic>> _mockProducts = [
    {'id': '1', 'name': 'MacBook Pro 16', 'category': 'Laptops', 'price': 2499, 'stock': 12},
    {'id': '2', 'name': 'Dell XPS 15', 'category': 'Laptops', 'price': 1899, 'stock': 8},
    {'id': '3', 'name': 'iPad Pro 13', 'category': 'Tablets', 'price': 1299, 'stock': 25},
    {'id': '4', 'name': 'Sony WH-1000XM5', 'category': 'Audio', 'price': 399, 'stock': 40},
    {'id': '5', 'name': 'Keychron Q1 Pro', 'category': 'Peripherals', 'price': 199, 'stock': 15},
    {'id': '6', 'name': 'LG UltraFine 32', 'category': 'Monitors', 'price': 799, 'stock': 6},
    {'id': '7', 'name': 'Logitech MX Master 3S', 'category': 'Peripherals', 'price': 99, 'stock': 50},
  ];

  @override
  void initState() {
    super.initState();
    _dataManager = AcDataManager(
      data: _mockProducts,
      usePagination: true,
      pageSize: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AcRepeater(
          dataManager: _dataManager,
          filterFields: const [
            AcFilterField(key: 'name', label: 'Product Name'),
            AcFilterField(key: 'category', label: 'Category'),
            AcFilterField(key: 'price', label: 'Price', type: 'number'),
          ],
          sortFields: const [
            AcSortField(key: 'name', label: 'Product Name'),
            AcSortField(key: 'price', label: 'Price'),
            AcSortField(key: 'stock', label: 'Stock'),
          ],
          itemBuilder: (context, row, i) {
            return ListTile(
              leading: CircleAvatar(
                child: Text('${row.getValue('category')[0]}'),
              ),
              title: Text(row.getValue('name'), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Category: ${row.getValue('category')} • Stock: ${row.getValue('stock')} units'),
              trailing: Text(
                '\$${row.getValue('price')}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// 3. AcResizable & AcResizablePanels Tab
// ==========================================
class ResizableShowcaseTab extends StatelessWidget {
  const ResizableShowcaseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Interactive Draggable Split-Panes (AcResizablePanels):',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: AcResizablePanels(
                direction: Axis.horizontal,
                panels: [
                  AcResizablePanel(
                    initialWeight: 0.3,
                    child: Container(
                      color: Colors.blue.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Left Sidebar', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Drag the vertical bar to resize!'),
                        ],
                      ),
                    ),
                  ),
                  AcResizablePanel(
                    initialWeight: 0.7,
                    child: Container(
                      color: Colors.green.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(12),
                      child: const Center(
                        child: Text('Main Content Area (Flexible Weight: 70%)'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Standalone Resizable Box (AcResizable):',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Center(
              child: AcResizable(
                initialWidth: 260,
                initialHeight: 140,
                minWidth: 150,
                minHeight: 80,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Center(
                    child: Text(
                      'Drag right edge, bottom edge, or bottom-right corner to resize me!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. AcPagination Tab
// ==========================================
class PaginationShowcaseTab extends StatefulWidget {
  const PaginationShowcaseTab({super.key});

  @override
  State<PaginationShowcaseTab> createState() => _PaginationShowcaseTabState();
}

class _PaginationShowcaseTabState extends State<PaginationShowcaseTab> {
  int _activePage = 1;
  int _pageSize = 25;
  final int _totalItems = 284;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Standalone AcPagination Control:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Current Page: $_activePage | Rows Per Page: $_pageSize | Total Records: $_totalItems'),
                  const SizedBox(height: 16),
                  AcPagination(
                    activePage: _activePage,
                    pageSize: _pageSize,
                    totalRows: _totalItems,
                    showAddButton: true,
                    onAdd: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Row Triggered')),
                      );
                    },
                    onPageChange: (p) => setState(() => _activePage = p),
                    onPageSizeChange: (s) => setState(() {
                      _pageSize = s;
                      _activePage = 1;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. DataDictionary UI Tab
// ==========================================
class DataDictionaryShowcaseTab extends StatefulWidget {
  const DataDictionaryShowcaseTab({super.key});

  @override
  State<DataDictionaryShowcaseTab> createState() => _DataDictionaryShowcaseTabState();
}

class _DataDictionaryShowcaseTabState extends State<DataDictionaryShowcaseTab> {
  late AcDDTable _table;
  late AcDataManager _dm;

  @override
  void initState() {
    super.initState();
    // Build an in-memory schema table
    _table = AcDDTable()..tableName = 'customers';

    final idCol = AcDDTableColumn()
      ..columnName = 'id'
      ..columnType = AcEnumDDColumnType.integer
      ..columnProperties = {
        AcEnumDDColumnProperty.columnTitle.value: AcDDTableColumnProperty()
          ..propertyName = AcEnumDDColumnProperty.columnTitle
          ..propertyValue = 'Customer ID',
        AcEnumDDColumnProperty.notNull.value: AcDDTableColumnProperty()
          ..propertyName = AcEnumDDColumnProperty.notNull
          ..propertyValue = 'true',
      };

    final nameCol = AcDDTableColumn()
      ..columnName = 'fullName'
      ..columnType = AcEnumDDColumnType.string
      ..columnProperties = {
        AcEnumDDColumnProperty.columnTitle.value: AcDDTableColumnProperty()
          ..propertyName = AcEnumDDColumnProperty.columnTitle
          ..propertyValue = 'Full Name',
      };

    final emailCol = AcDDTableColumn()
      ..columnName = 'email'
      ..columnType = AcEnumDDColumnType.string
      ..columnProperties = {
        AcEnumDDColumnProperty.columnTitle.value: AcDDTableColumnProperty()
          ..propertyName = AcEnumDDColumnProperty.columnTitle
          ..propertyValue = 'Email Address',
      };

    final activeCol = AcDDTableColumn()
      ..columnName = 'isVerified'
      ..columnType = AcEnumDDColumnType.yesNo
      ..columnProperties = {
        AcEnumDDColumnProperty.columnTitle.value: AcDDTableColumnProperty()
          ..propertyName = AcEnumDDColumnProperty.columnTitle
          ..propertyValue = 'Verified Member',
      };

    _table.tableColumns = {
      'id': idCol,
      'fullName': nameCol,
      'email': emailCol,
      'isVerified': activeCol,
    };

    _dm = AcDataManager(
      data: [
        {'id': 101, 'fullName': 'Sarah Jenkins', 'email': 'sarah@example.com', 'isVerified': true},
        {'id': 102, 'fullName': 'Mark Peterson', 'email': 'mark@example.com', 'isVerified': false},
        {'id': 103, 'fullName': 'Elena Rostova', 'email': 'elena@example.com', 'isVerified': true},
      ],
      usePagination: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '1. Schema-Driven Grid (AcDDDatagrid generated from AcDDTable):',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: AcDDDatagrid(
                table: _table,
                tableName: 'customers',
                dataManager: _dm,
                showPagination: false,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '2. Schema-Driven Input Fields (AcDDInputField generated from AcDDTableColumn):',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AcDDInputField(
                    column: _table.tableColumns['fullName']!,
                    initialValue: 'John Doe',
                  ),
                  const SizedBox(height: 12),
                  AcDDInputField(
                    column: _table.tableColumns['email']!,
                    initialValue: 'john.doe@example.com',
                  ),
                  const SizedBox(height: 12),
                  AcDDInputField(
                    column: _table.tableColumns['isVerified']!,
                    initialValue: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. Layout & UI Elements Tab
// ==========================================
class UiElementsShowcaseTab extends StatefulWidget {
  const UiElementsShowcaseTab({super.key});

  @override
  State<UiElementsShowcaseTab> createState() => _UiElementsShowcaseTabState();
}

class _UiElementsShowcaseTabState extends State<UiElementsShowcaseTab> {
  List<String> _selectedFruits = ['apple', 'orange'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumb
          const AcBreadcrumb(
            items: [
              AcBreadcrumbItem(label: Text('Home'), icon: Icon(Icons.home, size: 16)),
              AcBreadcrumbItem(label: Text('Components')),
              AcBreadcrumbItem(label: Text('Showcase')),
            ],
          ),
          const SizedBox(height: 16),

          // Alerts
          const AcAlert(
            variant: AcAlertVariant.info,
            title: Text('Information'),
            dismissible: true,
            child: Text('This tab demonstrates all additional UI components replicated from TypeScript.'),
          ),
          const SizedBox(height: 12),
          const AcAlert(
            variant: AcAlertVariant.success,
            title: Text('System Operational'),
            dismissible: true,
            child: Text('All widgets are running smoothly with zero dependencies on HTML/DOM!'),
          ),
          const SizedBox(height: 16),

          // Badges, Spinners & Progress
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const AcBadge(child: Text('FEATURED')),
              AcBadge.count(count: 42),
              const AcBadge(variant: AcAlertVariant.success, child: Text('ACTIVE')),
              const AcSpinner(size: 24),
              SizedBox(
                width: 200,
                child: AcProgress(value: 0.72, showLabel: true),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AcButton(
                variant: AcButtonVariant.primary,
                icon: const Icon(Icons.send, size: 16),
                onPressed: () {},
                child: const Text('Primary Button'),
              ),
              AcButton(
                variant: AcButtonVariant.outline,
                onPressed: () {},
                child: const Text('Outline Button'),
              ),
              AcButton(
                variant: AcButtonVariant.danger,
                icon: const Icon(Icons.delete, size: 16),
                onPressed: () {},
                child: const Text('Danger Button'),
              ),
              AcButton(
                variant: AcButtonVariant.primary,
                isLoading: true,
                onPressed: () {},
                child: const Text('Loading...'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Multi-Select Tag Input (AcTomSelectInput)
          AcTomSelectInput<String>(
            label: 'Favorite Fruits',
            options: const [
              AcTomSelectOption(value: 'apple', label: 'Apple'),
              AcTomSelectOption(value: 'banana', label: 'Banana'),
              AcTomSelectOption(value: 'orange', label: 'Orange'),
              AcTomSelectOption(value: 'mango', label: 'Mango'),
              AcTomSelectOption(value: 'grape', label: 'Grape'),
            ],
            selectedValues: _selectedFruits,
            onChanged: (vals) => setState(() => _selectedFruits = vals),
          ),
          const SizedBox(height: 20),

          // Accordion
          const AcAccordion(
            allowMultipleExpanded: true,
            items: [
              AcAccordionItem(
                title: Text('What is AutoCode Widgets?'),
                content: Text('A modular library of high-performance UI widgets replicated from TypeScript to Dart.'),
                initiallyExpanded: true,
              ),
              AcAccordionItem(
                title: Text('Does it support Windows?'),
                content: Text('Yes! Native desktop Windows, macOS, Linux, Web, and mobile are fully supported.'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // File Preview
          const AcFilePreview(
            fileName: 'quarterly_report.pdf',
            fileSize: '3.8 MB',
            fileType: AcFileType.pdf,
          ),
          const SizedBox(height: 20),

          // Modal & Drawer triggers
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Modal (AcModal)'),
                onPressed: () {
                  AcModal.show(
                    context: context,
                    title: const Text('Confirmation Modal'),
                    body: const Text('This is a structured modal dialog with header, body, and action buttons.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.menu_open),
                label: const Text('Open Drawer (AcDrawer)'),
                onPressed: () {
                  AcDrawer.show(
                    context: context,
                    title: const Text('Right Drawer'),
                    placement: AcDrawerPlacement.right,
                    child: const Center(child: Text('Slide-out side drawer content')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. AcMessage Tab
// ==========================================
class MessageShowcaseTab extends StatelessWidget {
  const MessageShowcaseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Success Toast'),
              onPressed: () {
                AcMessage.success(
                  title: 'Success!',
                  message: 'Your profile has been updated.',
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.error, color: Colors.red),
              label: const Text('Error Toast'),
              onPressed: () {
                AcMessage.error(
                  title: 'Network Error',
                  message: 'Failed to connect to backend server.',
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.question_answer, color: Colors.amber),
              label: const Text('Confirm Modal Dialog'),
              onPressed: () async {
                final result = await AcMessage.confirm(
                  title: 'Delete Item?',
                  message: 'Are you sure you want to delete this record? This cannot be undone.',
                  confirmText: 'Delete',
                  denyText: 'Cancel',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Result: confirmed = ${result.confirmed}')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
