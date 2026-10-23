# ac_widgets

High-performance, lightweight Flutter UI widgets for AutoCode replicated from `autocode-typescript` with clean, idiomatic Flutter architectures and zero unnecessary abstractions.

---

## Included Components

| Component | Description |
| :--- | :--- |
| **`AcDataManager`** | Core reactive data engine powering grids and repeaters. Handles in-memory/on-demand pagination, compound filtering, multi-column sorting, text search, selection, and tree hierarchies. |
| **`AcDatagrid`** | Virtualized high-performance table with sticky headers, draggable column resizing, sorting, column-specific filter popups, inline cell editing, tree-table support, selection checkboxes, and CSV export. |
| **`AcRepeater`** | Declarative list with integrated search, filter popup button, multi-tier sort popup button, zebra striping, empty states, and pagination. |
| **`AcPagination`** | Standalone or DataManager-bound pagination bar with first/prev/next/last buttons, page pills with ellipses, page size selector dropdown, and entry counter. |
| **`AcDataFilterPopup` & `AcDataFilterButton`** | Dual-mode filter popup supporting single-column filter popups (anchored to header cells) and multi-field compound filter builders (for toolbars) with active condition badges. |
| **`AcDataSortPopup` & `AcDataSortButton`** | Multi-tier sort priority builder and quick-sort trigger with active sort badges. |
| **`AcResizable` & `AcResizablePanels`** | Interactive 8-directional resizable containers and responsive split-view layouts with draggable dividers. |
| **`AcAccordion`, `AcCard`, `AcDrawer`, `AcModal`, `AcTabs`, `AcSlides`, `AcBreadcrumb`, `AcNavbar`** | Modular layout & navigation containers with collapsible drawers, modals, carousels, breadcrumbs, and responsive navbars. |
| **`AcAlert`, `AcBadge`, `AcSpinner`, `AcProgress`, `AcSkeleton`** | Status alerts, semantic badges, loading spinners, progress bars, and animated shimmer skeleton loaders. |
| **`AcButton`, `AcDropdown`, `AcTomSelectInput`, `AcFilePreview`** | Form controls with variant styling, searchable dropdowns, TomSelect-style multi-tag pickers, and file preview cards. |
| **`AcDDDatagrid` & `AcDDInputField`** | Schema-driven components that automatically inspect database metadata (`AcDataDictionary`) to generate datagrids and form inputs with automatic validation. |
| **`AcMessage`** | Complete toast notifications and SweetAlert-style modal confirmation dialogs (re-exported directly from `ac_message`). |

---

## Quick Start

### 1. Initializing `AcDataManager`

```dart
import 'package:ac_widgets/ac_widgets.dart';

final dataManager = AcDataManager(
  data: [
    {'id': '1', 'name': 'Alice', 'role': 'Developer', 'salary': 105000},
    {'id': '2', 'name': 'Bob', 'role': 'Designer', 'salary': 85000},
    {'id': '3', 'name': 'Charlie', 'role': 'Manager', 'salary': 120000},
  ],
  usePagination: true,
  pageSize: 10,
);
```

### 2. Using `AcDatagrid`

```dart
AcDatagrid(
  dataManager: dataManager,
  columns: [
    AcDatagridColumn(field: 'id', title: 'ID', width: 60),
    AcDatagridColumn(field: 'name', title: 'Full Name', width: 160),
    AcDatagridColumn(field: 'role', title: 'Designation', width: 140),
    AcDatagridColumn(
      field: 'salary',
      title: 'Salary',
      width: 120,
      dataType: AcDatagridColumnDataType.number,
    ),
  ],
  showSelectionCheckbox: true,
  showPagination: true,
)
```

### 3. Using `AcRepeater`

```dart
AcRepeater(
  dataManager: dataManager,
  filterFields: [
    AcFilterField(key: 'name', label: 'Name'),
    AcFilterField(key: 'role', label: 'Role'),
  ],
  sortFields: [
    AcSortField(key: 'name', label: 'Name'),
    AcSortField(key: 'salary', label: 'Salary'),
  ],
  itemBuilder: (context, row, index) {
    return ListTile(
      title: Text(row.getValue('name')),
      subtitle: Text(row.getValue('role')),
      trailing: Text('\$${row.getValue('salary')}'),
    );
  },
)
```

### 4. Using `AcResizablePanels`

```dart
AcResizablePanels(
  direction: Axis.horizontal,
  panels: [
    AcResizablePanel(initialWeight: 0.3, child: NavigationSidebar()),
    AcResizablePanel(initialWeight: 0.7, child: ContentArea()),
  ],
)
```

---

## Running the Showcase Example App

A full desktop-compatible interactive showcase is included under `example/`:

```bash
cd packages/ac_widgets/example
flutter run -d windows
```

