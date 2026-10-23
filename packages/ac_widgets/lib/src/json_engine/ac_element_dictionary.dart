/// Metadata definition describing an element's contract in the JSON UI engine.
class AcElementDefinition {
  /// Canonical identifier starting with `act-` (e.g. `act-select-party-input`).
  final String element;

  /// Human-readable description of purpose and usage.
  final String description;

  /// Category: 'layout' | 'input' | 'picker' | 'display' | 'action' | 'list' | 'special'.
  final String category;

  /// Map of property names to expected types (e.g. `{'label': 'String', 'required': 'bool'}`).
  final Map<String, String> properties;

  /// Default values for optional properties.
  final Map<String, dynamic> defaultValues;

  /// List of mandatory property keys.
  final List<String> requiredProperties;

  /// Supported dynamic input bindings (e.g. `{'value': 'dynamic', 'options': 'List'}`).
  final Map<String, String> inputs;

  /// Supported output actions / event callbacks (e.g. `{'onChanged': 'Event', 'onSelect': 'Event'}`).
  final Map<String, String> outputs;

  /// Whether this element can hold nested UI children.
  final bool allowsChildren;

  /// Validation metadata (min, max, pattern, etc.).
  final Map<String, dynamic>? validation;

  /// Compatibility aliases (e.g. `['picker.party', 'act-picker-party']`).
  final List<String> aliases;

  const AcElementDefinition({
    required this.element,
    required this.description,
    required this.category,
    this.properties = const {},
    this.defaultValues = const {},
    this.requiredProperties = const [],
    this.inputs = const {},
    this.outputs = const {},
    this.allowsChildren = false,
    this.validation,
    this.aliases = const [],
  });

  Map<String, dynamic> toJson() => {
    'element': element,
    'description': description,
    'category': category,
    'properties': properties,
    'defaultValues': defaultValues,
    'requiredProperties': requiredProperties,
    'inputs': inputs,
    'outputs': outputs,
    'allowsChildren': allowsChildren,
    'aliases': aliases,
    if (validation != null) 'validation': validation,
  };
}

/// Central registry of all UI element contracts and data-dictionary metadata.
class AcElementDictionary {
  AcElementDictionary._();

  static final Map<String, AcElementDefinition> _registry = {};
  static bool _initialized = false;

  /// Register an element definition.
  static void register(AcElementDefinition definition) {
    _registry[definition.element] = definition;
    for (final alias in definition.aliases) {
      _registry[alias] = definition;
    }
  }

  /// Get definition by element key or alias.
  static AcElementDefinition? get(String elementKey) {
    if (!_initialized) initDefaults();
    return _registry[elementKey];
  }

  /// All registered definitions (excluding duplicates from aliases).
  static List<AcElementDefinition> get allDefinitions {
    if (!_initialized) initDefaults();
    final seen = <String>{};
    final list = <AcElementDefinition>[];
    for (final def in _registry.values) {
      if (seen.add(def.element)) {
        list.add(def);
      }
    }
    return list;
  }

  /// Check if an element key is registered.
  static bool has(String elementKey) {
    if (!_initialized) initDefaults();
    return _registry.containsKey(elementKey);
  }

  /// Pre-populate the standard element catalog.
  static void initDefaults() {
    if (_initialized) return;
    _initialized = true;

    // ── Layout ───────────────────────────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-column',
      description: 'Vertical layout container',
      category: 'layout',
      properties: {'gap': 'double', 'padding': 'String|EdgeInsets', 'crossAxisAlignment': 'String'},
      allowsChildren: true,
      aliases: ['column'],
    ));

    register(const AcElementDefinition(
      element: 'act-row',
      description: 'Horizontal layout container',
      category: 'layout',
      properties: {'gap': 'double', 'padding': 'String|EdgeInsets', 'crossAxisAlignment': 'String', 'mainAxisAlignment': 'String'},
      allowsChildren: true,
      aliases: ['row'],
    ));

    register(const AcElementDefinition(
      element: 'act-card',
      description: 'Card container with border, elevation, and optional header',
      category: 'layout',
      properties: {'padding': 'String', 'margin': 'String', 'title': 'String'},
      allowsChildren: true,
      aliases: ['card'],
    ));

    register(const AcElementDefinition(
      element: 'act-section',
      description: 'Labeled content section with optional header actions',
      category: 'layout',
      properties: {'title': 'String', 'subtitle': 'String', 'collapsible': 'bool'},
      allowsChildren: true,
      aliases: ['section'],
    ));

    register(const AcElementDefinition(
      element: 'act-gap',
      description: 'Spacer providing horizontal or vertical empty distance',
      category: 'layout',
      properties: {'size': 'double|String', 'crossAxis': 'bool'},
      aliases: ['gap'],
    ));

    register(const AcElementDefinition(
      element: 'act-divider',
      description: 'Horizontal dividing line separating sections',
      category: 'layout',
      properties: {'color': 'String', 'thickness': 'double'},
      aliases: ['divider'],
    ));

    register(const AcElementDefinition(
      element: 'act-expand',
      description: 'Expands child to fill available space in Column/Row',
      category: 'layout',
      properties: {'flex': 'int'},
      allowsChildren: true,
      aliases: ['expand'],
    ));

    register(const AcElementDefinition(
      element: 'act-scroll',
      description: 'Scrollable container for overflow handling',
      category: 'layout',
      properties: {'direction': 'String', 'padding': 'String'},
      allowsChildren: true,
      aliases: ['scroll'],
    ));

    register(const AcElementDefinition(
      element: 'act-if',
      description: 'Conditional rendering node (then / else)',
      category: 'layout',
      properties: {'condition': 'String|bool', 'then': 'Map', 'else': 'Map'},
      aliases: ['if'],
    ));

    register(const AcElementDefinition(
      element: 'act-tabs',
      description: 'Tabbed container switching between child views',
      category: 'layout',
      properties: {'tabs': 'List<Map>', 'defaultIndex': 'int'},
      allowsChildren: true,
      aliases: ['tabs'],
    ));

    // ── Display ──────────────────────────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-text',
      description: 'Formatted typography text node',
      category: 'display',
      properties: {'value': 'String', 'style': 'String', 'color': 'String', 'align': 'String'},
      inputs: {'value': 'String'},
      aliases: ['text'],
    ));

    register(const AcElementDefinition(
      element: 'act-amount',
      description: 'Financial currency amount display formatted by locale',
      category: 'display',
      properties: {'value': 'num', 'currency': 'String', 'bold': 'bool'},
      inputs: {'value': 'num'},
      aliases: ['amount'],
    ));

    register(const AcElementDefinition(
      element: 'act-badge',
      description: 'Status pill badge with semantic background & foreground colors',
      category: 'display',
      properties: {'value': 'String', 'color': 'String', 'label': 'String'},
      inputs: {'value': 'String'},
      aliases: ['badge'],
    ));

    register(const AcElementDefinition(
      element: 'act-avatar',
      description: 'Circular user/entity initials or image avatar',
      category: 'display',
      properties: {'name': 'String', 'image': 'String', 'size': 'double'},
      aliases: ['avatar'],
    ));

    register(const AcElementDefinition(
      element: 'act-icon',
      description: 'Vector icon rendered from semantic name',
      category: 'display',
      properties: {'icon': 'String', 'size': 'double', 'color': 'String'},
      aliases: ['icon'],
    ));

    register(const AcElementDefinition(
      element: 'act-summary',
      description: 'Financial invoice summary card with subtotals, tax, and grand total',
      category: 'display',
      properties: {'items': 'List<Map>', 'total': 'num'},
      inputs: {'total': 'num'},
      aliases: ['summary'],
    ));

    register(const AcElementDefinition(
      element: 'act-info-table',
      description: 'Two-column key/value metadata display table',
      category: 'display',
      properties: {'rows': 'List<Map>'},
      aliases: ['info_table'],
    ));

    register(const AcElementDefinition(
      element: 'act-empty',
      description: 'Empty state illustration with icon, message, and call to action',
      category: 'display',
      properties: {'message': 'String', 'icon': 'String', 'action': 'Map'},
      aliases: ['empty'],
    ));

    register(const AcElementDefinition(
      element: 'act-loader',
      description: 'Loading spinner indicator',
      category: 'display',
      properties: {'visible': 'bool', 'size': 'double'},
      aliases: ['loader'],
    ));

    register(const AcElementDefinition(
      element: 'act-chip-bar',
      description: 'Horizontal scrollable bar of filter chips',
      category: 'display',
      properties: {'chips': 'List<Map>', 'active': 'String'},
      outputs: {'onSelect': 'Event'},
      aliases: ['chip_bar'],
    ));

    register(const AcElementDefinition(
      element: 'act-operation-status',
      description: 'Banner showing ongoing async background sync / operation status',
      category: 'display',
      properties: {'status': 'String', 'message': 'String'},
      aliases: ['operation_status'],
    ));

    register(const AcElementDefinition(
      element: 'act-lock-overlay',
      description: 'Read-only locked overlay for finalized/audited documents',
      category: 'display',
      properties: {'locked': 'bool', 'reason': 'String'},
      allowsChildren: true,
      aliases: ['lock_overlay'],
    ));

    // ── Actions ──────────────────────────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-button',
      description: 'Clickable button with icon, label, and variant styling',
      category: 'action',
      properties: {'label': 'String', 'variant': 'String', 'icon': 'String', 'disabled': 'bool'},
      outputs: {'action': 'Action'},
      aliases: ['button'],
    ));

    register(const AcElementDefinition(
      element: 'act-icon-action',
      description: 'Icon button with tooltip executing a declarative action',
      category: 'action',
      properties: {'icon': 'String', 'tooltip': 'String', 'color': 'String'},
      outputs: {'action': 'Action'},
      aliases: ['icon_action'],
    ));

    register(const AcElementDefinition(
      element: 'act-actions',
      description: 'Container row of action buttons with responsive wrapping',
      category: 'action',
      properties: {'align': 'String'},
      allowsChildren: true,
      aliases: ['actions'],
    ));

    register(const AcElementDefinition(
      element: 'act-swipe-actions',
      description: 'Swipe-to-reveal contextual action buttons (edit, delete, etc.)',
      category: 'action',
      properties: {'left': 'List<Map>', 'right': 'List<Map>'},
      allowsChildren: true,
      aliases: ['swipe_actions'],
    ));

    register(const AcElementDefinition(
      element: 'act-menu',
      description: 'Dropdown menu button opening a list of actions',
      category: 'action',
      properties: {'icon': 'String', 'items': 'List<Map>'},
      aliases: ['menu'],
    ));

    // ── Lists & Collections ──────────────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-list',
      description: 'Paginated or scrollable data list / table view backed by AcDatagrid',
      category: 'list',
      properties: {'url': 'String', 'pageSize': 'int', 'row': 'Map', 'empty': 'Map'},
      inputs: {'items': 'List'},
      outputs: {'onItemTap': 'Action', 'onReload': 'Action'},
      aliases: ['list'],
    ));

    register(const AcElementDefinition(
      element: 'act-repeater',
      description: 'Repeats a template widget for each item in an array (invoice lines, etc.)',
      category: 'list',
      properties: {'bind': 'String', 'itemDescriptor': 'Map', 'empty': 'Map'},
      inputs: {'items': 'List'},
      outputs: {'onAdd': 'Action', 'onRemove': 'Action'},
      aliases: ['repeater'],
    ));

    register(const AcElementDefinition(
      element: 'act-inline-list',
      description: 'Simple unpaginated inline list of items',
      category: 'list',
      properties: {'bind': 'String', 'row': 'Map'},
      aliases: ['inline_list'],
    ));

    // ── Base Inputs (-input suffix) ──────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-text-input',
      description: 'Single-line text input field',
      category: 'input',
      properties: {'label': 'String', 'placeholder': 'String', 'required': 'bool', 'readonly': 'bool'},
      inputs: {'value': 'String'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.text', 'act-input-text'],
    ));

    register(const AcElementDefinition(
      element: 'act-number-input',
      description: 'Numeric input field with stepper or decimal controls',
      category: 'input',
      properties: {'label': 'String', 'min': 'num', 'max': 'num', 'step': 'num'},
      inputs: {'value': 'num'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.number', 'act-input-number'],
    ));

    register(const AcElementDefinition(
      element: 'act-amount-input',
      description: 'Financial monetary input with currency prefix and formatting',
      category: 'input',
      properties: {'label': 'String', 'currency': 'String', 'required': 'bool'},
      inputs: {'value': 'num'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.amount', 'act-input-amount'],
    ));

    register(const AcElementDefinition(
      element: 'act-date-input',
      description: 'Calendar date picker input',
      category: 'input',
      properties: {'label': 'String', 'format': 'String', 'minDate': 'String', 'maxDate': 'String'},
      inputs: {'value': 'String'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.date', 'act-input-date'],
    ));

    register(const AcElementDefinition(
      element: 'act-date-range-input',
      description: 'Dual-date range picker (from / to)',
      category: 'input',
      properties: {'label': 'String', 'startBind': 'String', 'endBind': 'String'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.date_range', 'act-input-date-range'],
    ));

    register(const AcElementDefinition(
      element: 'act-multiline-input',
      description: 'Multi-line text area for notes, remarks, descriptions',
      category: 'input',
      properties: {'label': 'String', 'placeholder': 'String', 'rows': 'int'},
      inputs: {'value': 'String'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.multiline', 'act-input-multiline'],
    ));

    register(const AcElementDefinition(
      element: 'act-checkbox-input',
      description: 'Boolean checkbox input',
      category: 'input',
      properties: {'label': 'String'},
      inputs: {'value': 'bool'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.checkbox', 'act-input-checkbox'],
    ));

    register(const AcElementDefinition(
      element: 'act-toggle-input',
      description: 'Boolean switch / toggle control',
      category: 'input',
      properties: {'label': 'String'},
      inputs: {'value': 'bool'},
      outputs: {'onChange': 'Action'},
      aliases: ['input.toggle', 'act-input-toggle'],
    ));

    register(const AcElementDefinition(
      element: 'act-barcode-input',
      description: 'Barcode input with hardware scanner or camera support',
      category: 'input',
      properties: {'label': 'String', 'placeholder': 'String'},
      outputs: {'onScan': 'Action', 'onChange': 'Action'},
      aliases: ['input.barcode', 'act-input-barcode'],
    ));

    // ── Select Inputs (act-select-*-input) ───────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-select-input',
      description: 'Dropdown selection menu with static or state-bound options',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String', 'options': 'List', 'valueKey': 'String', 'labelKey': 'String'},
      inputs: {'value': 'dynamic', 'options': 'List'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['input.select', 'act-input-select'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-search-input',
      description: 'Searchable dropdown selection menu backed by AcTomSelectInput',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String', 'url': 'String', 'searchKey': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['input.search_select', 'act-input-search-select'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-party-input',
      description: 'Specialized searchable party picker with quick-add modal',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String', 'allowAddNew': 'bool'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.party', 'act-picker-party', 'act-select-customer-input', 'act-select-supplier-input'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-product-input',
      description: 'Specialized product picker emitting full item record (rate, tax, UOM)',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String', 'barcodeSupport': 'bool'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.product', 'act-picker-product'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-ledger-account-input',
      description: 'Specialized ledger account picker for finance forms',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.ledger_account', 'act-picker-ledger-account'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-payment-method-input',
      description: 'Specialized payment method selector (cash, bank, card, UPI)',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.payment_method', 'act-picker-payment-method'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-product-category-input',
      description: 'Specialized product category selector',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.product_category', 'act-picker-product-category'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-tax-rate-input',
      description: 'Specialized tax rate picker with percentage display',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.tax_rate', 'act-picker-tax-rate'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-uom-input',
      description: 'Specialized Unit of Measurement (UOM) selector',
      category: 'picker',
      properties: {'label': 'String', 'placeholder': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action', 'onSelect': 'Action'},
      aliases: ['picker.uom', 'act-picker-uom'],
    ));

    register(const AcElementDefinition(
      element: 'act-select-currency-input',
      description: 'Currency selector displaying ISO code and symbol',
      category: 'picker',
      properties: {'label': 'String'},
      inputs: {'value': 'dynamic'},
      outputs: {'onChange': 'Action'},
      aliases: ['picker.currency', 'act-picker-currency'],
    ));

    // ── Special ──────────────────────────────────────────────────────────────
    register(const AcElementDefinition(
      element: 'act-pos-cart',
      description: 'Point-of-sale active cart manager with item totals and tender',
      category: 'special',
      properties: {'bind': 'String'},
      outputs: {'onCheckout': 'Action', 'onClear': 'Action'},
      aliases: ['pos.cart'],
    ));

    register(const AcElementDefinition(
      element: 'act-pos-product-grid',
      description: 'Touch-optimized product grid for quick-tap addition to cart',
      category: 'special',
      properties: {'url': 'String', 'columns': 'int'},
      outputs: {'onProductTap': 'Action'},
      aliases: ['pos.product_grid'],
    ));
  }
}
