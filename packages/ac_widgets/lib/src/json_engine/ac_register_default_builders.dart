import 'ac_element_dictionary.dart';
import 'ac_widget_registry.dart';
import 'builders/ac_action_builders.dart';
import 'builders/ac_display_builders.dart';
import 'builders/ac_input_builders.dart';
import 'builders/ac_layout_builders.dart';
import 'builders/ac_list_builders.dart';
import 'builders/ac_special_builders.dart';

/// Registers all canonical `act-*`, `act-select-*-input`, and `act-*-input` builders
/// along with backward compatibility aliases into [AcWidgetRegistry].
void acRegisterDefaultBuilders() {
  AcElementDictionary.initDefaults();

  // ── Layout ─────────────────────────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-column', buildColumnElement, aliases: ['column']);
  AcWidgetRegistry.registerBuilder('act-row', buildRowElement, aliases: ['row']);
  AcWidgetRegistry.registerBuilder('act-card', buildCardElement, aliases: ['card']);
  AcWidgetRegistry.registerBuilder('act-section', buildSectionElement, aliases: ['section']);
  AcWidgetRegistry.registerBuilder('act-gap', buildGapElement, aliases: ['gap']);
  AcWidgetRegistry.registerBuilder('act-divider', buildDividerElement, aliases: ['divider']);
  AcWidgetRegistry.registerBuilder('act-expand', buildExpandElement, aliases: ['expand']);
  AcWidgetRegistry.registerBuilder('act-scroll', buildScrollElement, aliases: ['scroll']);
  AcWidgetRegistry.registerBuilder('act-if', buildIfElement, aliases: ['if']);
  AcWidgetRegistry.registerBuilder('act-tabs', buildTabsElement, aliases: ['tabs']);

  // ── Display ────────────────────────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-text', buildTextElement, aliases: ['text']);
  AcWidgetRegistry.registerBuilder('act-amount', buildAmountElement, aliases: ['amount']);
  AcWidgetRegistry.registerBuilder('act-badge', buildBadgeElement, aliases: ['badge']);
  AcWidgetRegistry.registerBuilder('act-avatar', buildAvatarElement, aliases: ['avatar']);
  AcWidgetRegistry.registerBuilder('act-icon', buildIconElement, aliases: ['icon']);
  AcWidgetRegistry.registerBuilder('act-summary', buildSummaryElement, aliases: ['summary']);
  AcWidgetRegistry.registerBuilder('act-info-table', buildInfoTableElement, aliases: ['info_table']);
  AcWidgetRegistry.registerBuilder('act-empty', buildEmptyElement, aliases: ['empty']);
  AcWidgetRegistry.registerBuilder('act-loader', buildLoaderElement, aliases: ['loader']);
  AcWidgetRegistry.registerBuilder('act-chip-bar', buildChipBarElement, aliases: ['chip_bar']);
  AcWidgetRegistry.registerBuilder('act-operation-status', buildOperationStatusElement, aliases: ['operation_status']);
  AcWidgetRegistry.registerBuilder('act-lock-overlay', buildLockOverlayElement, aliases: ['lock_overlay']);

  // ── Actions ────────────────────────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-button', buildButtonElement, aliases: ['button']);
  AcWidgetRegistry.registerBuilder('act-icon-action', buildIconActionElement, aliases: ['icon_action']);
  AcWidgetRegistry.registerBuilder('act-actions', buildActionsElement, aliases: ['actions']);
  AcWidgetRegistry.registerBuilder('act-swipe-actions', buildSwipeActionsElement, aliases: ['swipe_actions']);
  AcWidgetRegistry.registerBuilder('act-menu', buildMenuElement, aliases: ['menu']);

  // ── Lists & Collections ────────────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-list', buildListElement, aliases: ['list']);
  AcWidgetRegistry.registerBuilder('act-repeater', buildRepeaterElement, aliases: ['repeater']);
  AcWidgetRegistry.registerBuilder('act-inline-list', buildInlineListElement, aliases: ['inline_list']);

  // ── Base Inputs (-input suffix) ────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-text-input', buildTextInputElement, aliases: ['input.text', 'act-input-text']);
  AcWidgetRegistry.registerBuilder('act-number-input', buildNumberInputElement, aliases: ['input.number', 'act-input-number']);
  AcWidgetRegistry.registerBuilder('act-amount-input', buildAmountInputElement, aliases: ['input.amount', 'act-input-amount']);
  AcWidgetRegistry.registerBuilder('act-date-input', buildDateInputElement, aliases: ['input.date', 'act-input-date']);
  AcWidgetRegistry.registerBuilder('act-date-range-input', buildDateRangeInputElement, aliases: ['input.date_range', 'act-input-date-range']);
  AcWidgetRegistry.registerBuilder('act-multiline-input', buildMultilineInputElement, aliases: ['input.multiline', 'act-input-multiline']);
  AcWidgetRegistry.registerBuilder('act-checkbox-input', buildCheckboxInputElement, aliases: ['input.checkbox', 'act-input-checkbox']);
  AcWidgetRegistry.registerBuilder('act-toggle-input', buildToggleInputElement, aliases: ['input.toggle', 'act-input-toggle']);
  AcWidgetRegistry.registerBuilder('act-barcode-input', buildBarcodeInputElement, aliases: ['input.barcode', 'act-input-barcode']);

  // ── Select Inputs (act-select-*-input) ─────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-select-input', buildSelectInputElement, aliases: ['input.select', 'act-input-select']);
  AcWidgetRegistry.registerBuilder('act-select-search-input', buildSearchSelectInputElement, aliases: ['input.search_select', 'act-input-search-select']);
  AcWidgetRegistry.registerBuilder('act-select-party-input', buildPickerPartyElement, aliases: ['picker.party', 'act-picker-party', 'act-select-customer-input', 'act-select-supplier-input']);
  AcWidgetRegistry.registerBuilder('act-select-product-input', buildPickerProductElement, aliases: ['picker.product', 'act-picker-product']);
  AcWidgetRegistry.registerBuilder('act-select-ledger-account-input', buildPickerLedgerAccountElement, aliases: ['picker.ledger_account', 'act-picker-ledger-account']);
  AcWidgetRegistry.registerBuilder('act-select-payment-method-input', buildPickerPaymentMethodElement, aliases: ['picker.payment_method', 'act-picker-payment-method']);
  AcWidgetRegistry.registerBuilder('act-select-product-category-input', buildPickerProductCategoryElement, aliases: ['picker.product_category', 'act-picker-product-category']);
  AcWidgetRegistry.registerBuilder('act-select-tax-rate-input', buildPickerTaxRateElement, aliases: ['picker.tax_rate', 'act-picker-tax-rate']);
  AcWidgetRegistry.registerBuilder('act-select-uom-input', buildPickerUomElement, aliases: ['picker.uom', 'act-picker-uom']);
  AcWidgetRegistry.registerBuilder('act-select-currency-input', buildPickerCurrencyElement, aliases: ['picker.currency', 'act-picker-currency']);

  // ── Special ────────────────────────────────────────────────────────────────
  AcWidgetRegistry.registerBuilder('act-pos-cart', buildPosCartElement, aliases: ['pos.cart']);
  AcWidgetRegistry.registerBuilder('act-pos-product-grid', buildPosProductGridElement, aliases: ['pos.product_grid']);
}
