library ac_widgets;

// Core Data Engine
export 'src/data_manager/ac_data_manager.dart';
export 'src/data_manager/ac_data_row.dart';
export 'src/data_manager/ac_on_demand_args.dart';
export 'src/data_manager/evaluators/ac_filter_evaluator.dart';
export 'src/data_manager/evaluators/ac_search_evaluator.dart';
export 'src/data_manager/evaluators/ac_sort_comparator.dart';

// Popups (Filter & Sort)
export 'src/popups/filter/ac_filter_field.dart';
export 'src/popups/filter/ac_data_filter_popup.dart';
export 'src/popups/filter/ac_data_filter_button.dart';
export 'src/popups/sort/ac_sort_field.dart';
export 'src/popups/sort/ac_data_sort_popup.dart';
export 'src/popups/sort/ac_data_sort_button.dart';

// Pagination
export 'src/pagination/ac_pagination.dart';

// Resizable & Split Layouts
export 'src/resizable/ac_resizable.dart';
export 'src/resizable/ac_resizable_panels.dart';

// Repeater
export 'src/repeater/ac_repeater.dart';

// Datagrid
export 'src/datagrid/ac_datagrid.dart';
export 'src/datagrid/ac_datagrid_column.dart';
export 'src/datagrid/export/ac_datagrid_csv_exporter.dart';

// Data Dictionary Schema Components
export 'src/data_dictionary/ac_dd_datagrid_column_manager.dart';
export 'src/data_dictionary/ac_dd_datagrid.dart';
export 'src/data_dictionary/ac_dd_input_field.dart';

// Feedback & Notification Components
export 'src/feedback/ac_alert.dart';
export 'src/feedback/ac_badge.dart';
export 'src/feedback/ac_spinner.dart';
export 'src/feedback/ac_progress.dart';
export 'src/feedback/ac_skeleton.dart';

// Layout & Container Components
export 'src/layout/ac_accordion.dart';
export 'src/layout/ac_card.dart';
export 'src/layout/ac_drawer.dart';
export 'src/layout/ac_modal.dart';
export 'src/layout/ac_tabs.dart';
export 'src/layout/ac_slides.dart';
export 'src/layout/ac_breadcrumb.dart';
export 'src/layout/ac_navbar.dart';

// Form & Input Components
export 'src/inputs/ac_button.dart';
export 'src/inputs/ac_dropdown.dart';
export 'src/inputs/ac_tom_select_input.dart';

// Media & Preview Components
export 'src/media/ac_file_preview.dart';

// Re-export AcMessage from ac_message package for complete feedback parity
export 'package:ac_message/ac_message.dart';

// JSON Engine & Dynamic UI Runtime
export 'src/json_engine/ac_action_registry.dart';
export 'src/json_engine/ac_element_dictionary.dart';
export 'src/json_engine/ac_expression_evaluator.dart';
export 'src/json_engine/ac_json_screen_renderer.dart';
export 'src/json_engine/ac_quickjs_runner.dart';
export 'src/json_engine/ac_register_default_builders.dart';
export 'src/json_engine/ac_screen_context.dart';
export 'src/json_engine/ac_widget_registry.dart';
