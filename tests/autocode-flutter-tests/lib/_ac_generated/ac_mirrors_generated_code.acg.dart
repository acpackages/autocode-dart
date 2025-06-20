// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names, non_constant_identifier_names, unnecessary_brace_in_string_interps, unused_import, unnecessary_lambdas, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_mirrors/src/impl/generated.dart';
import 'package:autocode_flutter_tests/mirror_test/customer.dart';
import 'package:autocode/src/models/ac_cron_job.dart';
import 'package:autocode/src/annotations/ac_bind_json_property.dart';
import 'package:autocode/src/models/ac_event_execution_result.dart';
import 'package:autocode/src/models/ac_result.dart';
import 'package:autocode/src/core/ac_logger.dart';
import 'package:autocode/src/models/ac_hook_execution_result.dart';
import 'package:autocode/src/models/ac_hook_result.dart';
import 'package:ac_data_dictionary/src/models/ac_data_dictionary.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_function.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_stored_procedure.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_table.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_table_column.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_trigger.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_view.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_condition.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_condition_group.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_relationship.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_select_statement.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_table_column_property.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_table_property.dart';
import 'package:ac_data_dictionary/src/models/ac_dd_view_column.dart';
import 'package:ac_sql/src/models/ac_sql_connection.dart';
import 'package:ac_sql/src/models/ac_sql_dao_result.dart';
import 'package:ac_web/src/annotations/ac_web_authorize.dart';
import 'package:ac_web/src/annotations/ac_web_controller.dart';
import 'package:ac_web/src/annotations/ac_web_inject.dart';
import 'package:ac_web/src/annotations/ac_web_middleware.dart';
import 'package:ac_web/src/annotations/ac_web_repository.dart';
import 'package:ac_web/src/annotations/ac_web_route.dart';
import 'package:ac_web/src/annotations/ac_web_route_consumes.dart';
import 'package:ac_web/src/annotations/ac_web_route_meta.dart';
import 'package:ac_web/src/annotations/ac_web_route_meta_parameter.dart';
import 'package:ac_web/src/annotations/ac_web_route_produces.dart';
import 'package:ac_web/src/annotations/ac_web_service.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_body.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_cookie.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_form.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_header.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_path.dart';
import 'package:ac_web/src/annotations/ac_web_value_from_query.dart';
import 'package:ac_web/src/annotations/ac_web_view.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_contact.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_license.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_model.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_path.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_server.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_tag.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_components.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_content.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_external_docs.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_header.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_link.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_media_type.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_operation.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_parameter.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_route.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_request_body.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_response.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_schema.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_security_requirement.dart';
import 'package:ac_web/src/api-docs/models/ac_api_doc_security_scheme.dart';
import 'package:ac_web/src/models/ac_web_api_response.dart';
import 'package:ac_web/src/models/ac_web_hook_created_args.dart';
import 'package:ac_web/src/core/ac_web.dart';
import 'package:ac_web/src/models/ac_web_request.dart';
import 'package:ac_web/src/models/ac_web_response.dart';
import 'package:ac_web/src/models/ac_web_route_definition.dart';

String _symbolToName(Symbol symbol) => symbol.toString().split('\"')[1];

// Mirror for field 'name' in class 'Person'
class M6d241507e0ab23a0 implements AcVariableMirror {
  const M6d241507e0ab23a0();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for method 'getGreeting' in class 'Person'
class Madfef0730ba0e9f9 implements AcMethodMirror {
  const Madfef0730ba0e9f9();
  @override Symbol get simpleName => const Symbol('getGreeting');
  @override String getName() => 'getGreeting';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'Person'
class M7468b2c790b4be1e implements AcMethodMirror {
  const M7468b2c790b4be1e();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Person;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for method 'log' in class 'Loggable'
class Mb75bebd59e7a3b7e implements AcMethodMirror {
  const Mb75bebd59e7a3b7e();
  @override Symbol get simpleName => const Symbol('log');
  @override String getName() => 'log';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'defaultCountry' in class 'Customer'
class M9fe95b20beeb8a31 implements AcVariableMirror {
  const M9fe95b20beeb8a31();
  @override Symbol get simpleName => const Symbol('defaultCountry');
  @override String getName() => 'defaultCountry';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'totalCustomers' in class 'Customer'
class M6a574a6e6093bbe5 implements AcVariableMirror {
  const M6a574a6e6093bbe5();
  @override Symbol get simpleName => const Symbol('totalCustomers');
  @override String getName() => 'totalCustomers';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'id' in class 'Customer'
class Mf296313e6f0b8d2d implements AcVariableMirror {
  const Mf296313e6f0b8d2d();
  @override Symbol get simpleName => const Symbol('id');
  @override String getName() => 'id';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const FieldMeta(isSensitive: true)];
  @override Type get type => int;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'name' in class 'Customer'
class M3a2128f5312a161a implements AcVariableMirror {
  const M3a2128f5312a161a();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'email' in class 'Customer'
class Mdfeca4187812fa8b implements AcVariableMirror {
  const Mdfeca4187812fa8b();
  @override Symbol get simpleName => const Symbol('email');
  @override String getName() => 'email';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field '_notes' in class 'Customer'
class Ma404a45a39c66225 implements AcVariableMirror {
  const Ma404a45a39c66225();
  @override Symbol get simpleName => const Symbol('_notes');
  @override String getName() => '_notes';
  @override bool get isStatic => false;
  @override bool get isPrivate => true;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'createGuest' in class 'Customer'
class M61203e9df7ea9919 implements AcMethodMirror {
  const M61203e9df7ea9919();
  @override Symbol get simpleName => const Symbol('createGuest');
  @override String getName() => 'createGuest';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const MethodMeta('Creates a guest customer object.')];
  @override Type get returnType => Customer;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getGreeting' in class 'Customer'
class Md6ec705a93c83f78 implements AcMethodMirror {
  const Md6ec705a93c83f78();
  @override Symbol get simpleName => const Symbol('getGreeting');
  @override String getName() => 'getGreeting';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override, const MethodMeta('Generates a standard greeting.')];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'updateEmail' in class 'Customer'
class Mcb6e1d394131e63c implements AcMethodMirror {
  const Mcb6e1d394131e63c();
  @override Symbol get simpleName => const Symbol('updateEmail');
  @override String getName() => 'updateEmail';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'log' in class 'Customer'
class Mdc6136aedaf392c4 implements AcMethodMirror {
  const Mdc6136aedaf392c4();
  @override Symbol get simpleName => const Symbol('log');
  @override String getName() => 'log';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for accessor 'notes' in class 'Customer'
class M8851330a690be44a implements AcMethodMirror {
  const M8851330a690be44a();
  @override Symbol get simpleName => const Symbol('notes');
  @override String getName() => 'notes';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => true;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for accessor 'notes=' in class 'Customer'
class Mb479fe23b01a09af implements AcMethodMirror {
  const Mb479fe23b01a09af();
  @override Symbol get simpleName => const Symbol('notes=');
  @override String getName() => 'notes=';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => true;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'Customer'
class M01d64e1859a9980a implements AcMethodMirror {
  const M01d64e1859a9980a();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Customer;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'named' in class 'Customer'
class M1773752d54c0d897 implements AcMethodMirror {
  const M1773752d54c0d897();
  @override Symbol get simpleName => const Symbol('named');
  @override String getName() => 'named';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Customer;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "named";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CALLBACK' in class 'AcCronJob'
class M0ef8b675b24b22e9 implements AcVariableMirror {
  const M0ef8b675b24b22e9();
  @override Symbol get simpleName => const Symbol('KEY_CALLBACK');
  @override String getName() => 'KEY_CALLBACK';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DURATION' in class 'AcCronJob'
class M3453a61e1ab1bf95 implements AcVariableMirror {
  const M3453a61e1ab1bf95();
  @override Symbol get simpleName => const Symbol('KEY_DURATION');
  @override String getName() => 'KEY_DURATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXECUTION' in class 'AcCronJob'
class Me4cb111c04c4544c implements AcVariableMirror {
  const Me4cb111c04c4544c();
  @override Symbol get simpleName => const Symbol('KEY_EXECUTION');
  @override String getName() => 'KEY_EXECUTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_ID' in class 'AcCronJob'
class M8ba4c2ca7519e543 implements AcVariableMirror {
  const M8ba4c2ca7519e543();
  @override Symbol get simpleName => const Symbol('KEY_ID');
  @override String getName() => 'KEY_ID';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_LAST_EXECUTION_TIME' in class 'AcCronJob'
class M76387331b322ebf3 implements AcVariableMirror {
  const M76387331b322ebf3();
  @override Symbol get simpleName => const Symbol('KEY_LAST_EXECUTION_TIME');
  @override String getName() => 'KEY_LAST_EXECUTION_TIME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'id' in class 'AcCronJob'
class M6b3c4da2c4d14482 implements AcVariableMirror {
  const M6b3c4da2c4d14482();
  @override Symbol get simpleName => const Symbol('id');
  @override String getName() => 'id';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'execution' in class 'AcCronJob'
class M9d21ce8c6036bf19 implements AcVariableMirror {
  const M9d21ce8c6036bf19();
  @override Symbol get simpleName => const Symbol('execution');
  @override String getName() => 'execution';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'duration' in class 'AcCronJob'
class Mbfe30d8ad1c306cb implements AcVariableMirror {
  const Mbfe30d8ad1c306cb();
  @override Symbol get simpleName => const Symbol('duration');
  @override String getName() => 'duration';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, int>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'callback' in class 'AcCronJob'
class Ma7117821dbbd7ff8 implements AcVariableMirror {
  const Ma7117821dbbd7ff8();
  @override Symbol get simpleName => const Symbol('callback');
  @override String getName() => 'callback';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'callback', skipInToJson: true)];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'lastExecutionTime' in class 'AcCronJob'
class Mcc0ce806d48c044e implements AcVariableMirror {
  const Mcc0ce806d48c044e();
  @override Symbol get simpleName => const Symbol('lastExecutionTime');
  @override String getName() => 'lastExecutionTime';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'last_execution_time')];
  @override Type get type => DateTime;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcCronJob'
class M76125925f6eb050a implements AcMethodMirror {
  const M76125925f6eb050a();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcCronJob;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONTINUE_OPERATION' in class 'AcEventExecutionResult'
class M56f5cf6c152379f0 implements AcVariableMirror {
  const M56f5cf6c152379f0();
  @override Symbol get simpleName => const Symbol('KEY_CONTINUE_OPERATION');
  @override String getName() => 'KEY_CONTINUE_OPERATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HAS_RESULTS' in class 'AcEventExecutionResult'
class Mbd0560ed57c7c6a7 implements AcVariableMirror {
  const Mbd0560ed57c7c6a7();
  @override Symbol get simpleName => const Symbol('KEY_HAS_RESULTS');
  @override String getName() => 'KEY_HAS_RESULTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESULTS' in class 'AcEventExecutionResult'
class Mc27338acf5cebb54 implements AcVariableMirror {
  const Mc27338acf5cebb54();
  @override Symbol get simpleName => const Symbol('KEY_RESULTS');
  @override String getName() => 'KEY_RESULTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'continueOperation' in class 'AcEventExecutionResult'
class Mf59548cede1f50f2 implements AcVariableMirror {
  const Mf59548cede1f50f2();
  @override Symbol get simpleName => const Symbol('continueOperation');
  @override String getName() => 'continueOperation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'continue_operation')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'hasResults' in class 'AcEventExecutionResult'
class M3aa8b370e29a74b6 implements AcVariableMirror {
  const M3aa8b370e29a74b6();
  @override Symbol get simpleName => const Symbol('hasResults');
  @override String getName() => 'hasResults';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'has_results')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'results' in class 'AcEventExecutionResult'
class M0dc4bd80059a1e06 implements AcVariableMirror {
  const M0dc4bd80059a1e06();
  @override Symbol get simpleName => const Symbol('results');
  @override String getName() => 'results';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcEventExecutionResult'
class Mee40780a1f28980a implements AcMethodMirror {
  const Mee40780a1f28980a();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcEventExecutionResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONTINUE_OPERATION' in class 'AcHookExecutionResult'
class M9ef8b9119111b972 implements AcVariableMirror {
  const M9ef8b9119111b972();
  @override Symbol get simpleName => const Symbol('KEY_CONTINUE_OPERATION');
  @override String getName() => 'KEY_CONTINUE_OPERATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HAS_RESULTS' in class 'AcHookExecutionResult'
class M489510f4184847e8 implements AcVariableMirror {
  const M489510f4184847e8();
  @override Symbol get simpleName => const Symbol('KEY_HAS_RESULTS');
  @override String getName() => 'KEY_HAS_RESULTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESULTS' in class 'AcHookExecutionResult'
class Mbd0253fc521e335b implements AcVariableMirror {
  const Mbd0253fc521e335b();
  @override Symbol get simpleName => const Symbol('KEY_RESULTS');
  @override String getName() => 'KEY_RESULTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'continueOperation' in class 'AcHookExecutionResult'
class Meb30f98c47438aff implements AcVariableMirror {
  const Meb30f98c47438aff();
  @override Symbol get simpleName => const Symbol('continueOperation');
  @override String getName() => 'continueOperation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'continue_operation')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'hasResults' in class 'AcHookExecutionResult'
class M8d64be09e39b3d56 implements AcVariableMirror {
  const M8d64be09e39b3d56();
  @override Symbol get simpleName => const Symbol('hasResults');
  @override String getName() => 'hasResults';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'has_results')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'results' in class 'AcHookExecutionResult'
class M9149d64b1f96c66d implements AcVariableMirror {
  const M9149d64b1f96c66d();
  @override Symbol get simpleName => const Symbol('results');
  @override String getName() => 'results';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcHookExecutionResult'
class M4133807756b29200 implements AcMethodMirror {
  const M4133807756b29200();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcHookExecutionResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONTINUE_OPERATION' in class 'AcHookResult'
class Mbf18a52b4c400e41 implements AcVariableMirror {
  const Mbf18a52b4c400e41();
  @override Symbol get simpleName => const Symbol('KEY_CONTINUE_OPERATION');
  @override String getName() => 'KEY_CONTINUE_OPERATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CHANGES' in class 'AcHookResult'
class M6303aec5d605a310 implements AcVariableMirror {
  const M6303aec5d605a310();
  @override Symbol get simpleName => const Symbol('KEY_CHANGES');
  @override String getName() => 'KEY_CHANGES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'continueOperation' in class 'AcHookResult'
class M648f738e62bd8bf2 implements AcVariableMirror {
  const M648f738e62bd8bf2();
  @override Symbol get simpleName => const Symbol('continueOperation');
  @override String getName() => 'continueOperation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'continue_operation')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'changes' in class 'AcHookResult'
class Mee2c147503a52bb6 implements AcVariableMirror {
  const Mee2c147503a52bb6();
  @override Symbol get simpleName => const Symbol('changes');
  @override String getName() => 'changes';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcHookResult'
class M1be8fe0cdacc0e51 implements AcMethodMirror {
  const M1be8fe0cdacc0e51();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcHookResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'CODE_NOTHING_EXECUTED' in class 'AcResult'
class Mde5db6ae1ec8f9dc implements AcVariableMirror {
  const Mde5db6ae1ec8f9dc();
  @override Symbol get simpleName => const Symbol('CODE_NOTHING_EXECUTED');
  @override String getName() => 'CODE_NOTHING_EXECUTED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'CODE_SUCCESS' in class 'AcResult'
class M40dd057efac3d969 implements AcVariableMirror {
  const M40dd057efac3d969();
  @override Symbol get simpleName => const Symbol('CODE_SUCCESS');
  @override String getName() => 'CODE_SUCCESS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'CODE_FAILURE' in class 'AcResult'
class M41c516fcc735b3d5 implements AcVariableMirror {
  const M41c516fcc735b3d5();
  @override Symbol get simpleName => const Symbol('CODE_FAILURE');
  @override String getName() => 'CODE_FAILURE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'CODE_EXCEPTION' in class 'AcResult'
class M210b3c46d57c57e1 implements AcVariableMirror {
  const M210b3c46d57c57e1();
  @override Symbol get simpleName => const Symbol('CODE_EXCEPTION');
  @override String getName() => 'CODE_EXCEPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CODE' in class 'AcResult'
class M3d86634d598c6cab implements AcVariableMirror {
  const M3d86634d598c6cab();
  @override Symbol get simpleName => const Symbol('KEY_CODE');
  @override String getName() => 'KEY_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXCEPTION' in class 'AcResult'
class M151895bcdd6fb528 implements AcVariableMirror {
  const M151895bcdd6fb528();
  @override Symbol get simpleName => const Symbol('KEY_EXCEPTION');
  @override String getName() => 'KEY_EXCEPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_LOG' in class 'AcResult'
class M2ce1fa831e01b0e9 implements AcVariableMirror {
  const M2ce1fa831e01b0e9();
  @override Symbol get simpleName => const Symbol('KEY_LOG');
  @override String getName() => 'KEY_LOG';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_MESSAGE' in class 'AcResult'
class Mbf2760fe0d5a3600 implements AcVariableMirror {
  const Mbf2760fe0d5a3600();
  @override Symbol get simpleName => const Symbol('KEY_MESSAGE');
  @override String getName() => 'KEY_MESSAGE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OTHER_DETAILS' in class 'AcResult'
class M197b9fa78b1c8dc1 implements AcVariableMirror {
  const M197b9fa78b1c8dc1();
  @override Symbol get simpleName => const Symbol('KEY_OTHER_DETAILS');
  @override String getName() => 'KEY_OTHER_DETAILS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PREVIOUS_RESULT' in class 'AcResult'
class Mb1f0700e69fa4a2a implements AcVariableMirror {
  const Mb1f0700e69fa4a2a();
  @override Symbol get simpleName => const Symbol('KEY_PREVIOUS_RESULT');
  @override String getName() => 'KEY_PREVIOUS_RESULT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_STACK_TRACE' in class 'AcResult'
class M1f1004d8f7994cb4 implements AcVariableMirror {
  const M1f1004d8f7994cb4();
  @override Symbol get simpleName => const Symbol('KEY_STACK_TRACE');
  @override String getName() => 'KEY_STACK_TRACE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_STATUS' in class 'AcResult'
class Ma9b2d6566964866a implements AcVariableMirror {
  const Ma9b2d6566964866a();
  @override Symbol get simpleName => const Symbol('KEY_STATUS');
  @override String getName() => 'KEY_STATUS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VALUE' in class 'AcResult'
class M4ab861248291ad24 implements AcVariableMirror {
  const M4ab861248291ad24();
  @override Symbol get simpleName => const Symbol('KEY_VALUE');
  @override String getName() => 'KEY_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'logger' in class 'AcResult'
class Md68c822298f7d8c2 implements AcVariableMirror {
  const Md68c822298f7d8c2();
  @override Symbol get simpleName => const Symbol('logger');
  @override String getName() => 'logger';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcLogger;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'code' in class 'AcResult'
class M0875f932c86b155c implements AcVariableMirror {
  const M0875f932c86b155c();
  @override Symbol get simpleName => const Symbol('code');
  @override String getName() => 'code';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'exception' in class 'AcResult'
class M6e12abc911783373 implements AcVariableMirror {
  const M6e12abc911783373();
  @override Symbol get simpleName => const Symbol('exception');
  @override String getName() => 'exception';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'log' in class 'AcResult'
class M94a464b37f738207 implements AcVariableMirror {
  const M94a464b37f738207();
  @override Symbol get simpleName => const Symbol('log');
  @override String getName() => 'log';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'message' in class 'AcResult'
class Mfc91462df350f6a5 implements AcVariableMirror {
  const Mfc91462df350f6a5();
  @override Symbol get simpleName => const Symbol('message');
  @override String getName() => 'message';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'otherDetails' in class 'AcResult'
class M338e91f8cb214353 implements AcVariableMirror {
  const M338e91f8cb214353();
  @override Symbol get simpleName => const Symbol('otherDetails');
  @override String getName() => 'otherDetails';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'other_details')];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'stackTrace' in class 'AcResult'
class M5173b88859d9e805 implements AcVariableMirror {
  const M5173b88859d9e805();
  @override Symbol get simpleName => const Symbol('stackTrace');
  @override String getName() => 'stackTrace';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'stack_trace')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'status' in class 'AcResult'
class Md55e42c47f5ca1fb implements AcVariableMirror {
  const Md55e42c47f5ca1fb();
  @override Symbol get simpleName => const Symbol('status');
  @override String getName() => 'status';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'value' in class 'AcResult'
class M7a38a761ad3ff0b2 implements AcVariableMirror {
  const M7a38a761ad3ff0b2();
  @override Symbol get simpleName => const Symbol('value');
  @override String getName() => 'value';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'fromJson' in class 'AcResult'
class Mde34e1fe5dd6e7b2 implements AcMethodMirror {
  const Mde34e1fe5dd6e7b2();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isException' in class 'AcResult'
class M8a553033c960bbf6 implements AcMethodMirror {
  const M8a553033c960bbf6();
  @override Symbol get simpleName => const Symbol('isException');
  @override String getName() => 'isException';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isFailure' in class 'AcResult'
class Mb262f7674c164b54 implements AcMethodMirror {
  const Mb262f7674c164b54();
  @override Symbol get simpleName => const Symbol('isFailure');
  @override String getName() => 'isFailure';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isSuccess' in class 'AcResult'
class M57c34523837f760d implements AcMethodMirror {
  const M57c34523837f760d();
  @override Symbol get simpleName => const Symbol('isSuccess');
  @override String getName() => 'isSuccess';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'appendResultLog' in class 'AcResult'
class M02990f1ff687ce7d implements AcMethodMirror {
  const M02990f1ff687ce7d();
  @override Symbol get simpleName => const Symbol('appendResultLog');
  @override String getName() => 'appendResultLog';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'prependResultLog' in class 'AcResult'
class M6f9dc7d3fdef165f implements AcMethodMirror {
  const M6f9dc7d3fdef165f();
  @override Symbol get simpleName => const Symbol('prependResultLog');
  @override String getName() => 'prependResultLog';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setFromResult' in class 'AcResult'
class Me8e74b529464cbcd implements AcMethodMirror {
  const Me8e74b529464cbcd();
  @override Symbol get simpleName => const Symbol('setFromResult');
  @override String getName() => 'setFromResult';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setSuccess' in class 'AcResult'
class M39195b7ed3bc31a0 implements AcMethodMirror {
  const M39195b7ed3bc31a0();
  @override Symbol get simpleName => const Symbol('setSuccess');
  @override String getName() => 'setSuccess';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setFailure' in class 'AcResult'
class M45db3441e518ba21 implements AcMethodMirror {
  const M45db3441e518ba21();
  @override Symbol get simpleName => const Symbol('setFailure');
  @override String getName() => 'setFailure';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setException' in class 'AcResult'
class M43df868ea9dbeefe implements AcMethodMirror {
  const M43df868ea9dbeefe();
  @override Symbol get simpleName => const Symbol('setException');
  @override String getName() => 'setException';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcResult'
class M804db9f4004c3720 implements AcMethodMirror {
  const M804db9f4004c3720();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcResult'
class Mef519e01ff465da1 implements AcMethodMirror {
  const Mef519e01ff465da1();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcResult'
class Mf6c08044e6ee9856 implements AcMethodMirror {
  const Mf6c08044e6ee9856();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'instanceFromJson' in class 'AcResult'
class M6529e0622c07c6f4 implements AcMethodMirror {
  const M6529e0622c07c6f4();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "instanceFromJson";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DATA_DICTIONARIES' in class 'AcDataDictionary'
class M1e22c216e48dbb6b implements AcVariableMirror {
  const M1e22c216e48dbb6b();
  @override Symbol get simpleName => const Symbol('KEY_DATA_DICTIONARIES');
  @override String getName() => 'KEY_DATA_DICTIONARIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_FUNCTIONS' in class 'AcDataDictionary'
class M4d3a7c5d8cbcd9e1 implements AcVariableMirror {
  const M4d3a7c5d8cbcd9e1();
  @override Symbol get simpleName => const Symbol('KEY_FUNCTIONS');
  @override String getName() => 'KEY_FUNCTIONS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RELATIONSHIPS' in class 'AcDataDictionary'
class M61d29aba11fc31a4 implements AcVariableMirror {
  const M61d29aba11fc31a4();
  @override Symbol get simpleName => const Symbol('KEY_RELATIONSHIPS');
  @override String getName() => 'KEY_RELATIONSHIPS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_STORED_PROCEDURES' in class 'AcDataDictionary'
class Md8e6e446c78943e8 implements AcVariableMirror {
  const Md8e6e446c78943e8();
  @override Symbol get simpleName => const Symbol('KEY_STORED_PROCEDURES');
  @override String getName() => 'KEY_STORED_PROCEDURES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TABLES' in class 'AcDataDictionary'
class M1963531d9d867635 implements AcVariableMirror {
  const M1963531d9d867635();
  @override Symbol get simpleName => const Symbol('KEY_TABLES');
  @override String getName() => 'KEY_TABLES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TRIGGERS' in class 'AcDataDictionary'
class M556915a696814886 implements AcVariableMirror {
  const M556915a696814886();
  @override Symbol get simpleName => const Symbol('KEY_TRIGGERS');
  @override String getName() => 'KEY_TRIGGERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VERSION' in class 'AcDataDictionary'
class M4d2ac39af83dd6b1 implements AcVariableMirror {
  const M4d2ac39af83dd6b1();
  @override Symbol get simpleName => const Symbol('KEY_VERSION');
  @override String getName() => 'KEY_VERSION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VIEWS' in class 'AcDataDictionary'
class Md926ec335ee297c3 implements AcVariableMirror {
  const Md926ec335ee297c3();
  @override Symbol get simpleName => const Symbol('KEY_VIEWS');
  @override String getName() => 'KEY_VIEWS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'dataDictionaries' in class 'AcDataDictionary'
class Md5c0e64b88454acb implements AcVariableMirror {
  const Md5c0e64b88454acb();
  @override Symbol get simpleName => const Symbol('dataDictionaries');
  @override String getName() => 'dataDictionaries';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'data_dictionaries')];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'functions' in class 'AcDataDictionary'
class M94766791f9e8f4d1 implements AcVariableMirror {
  const M94766791f9e8f4d1();
  @override Symbol get simpleName => const Symbol('functions');
  @override String getName() => 'functions';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'relationships' in class 'AcDataDictionary'
class M07ac162dc7d9f32e implements AcVariableMirror {
  const M07ac162dc7d9f32e();
  @override Symbol get simpleName => const Symbol('relationships');
  @override String getName() => 'relationships';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'storedProcedures' in class 'AcDataDictionary'
class M0635a8e4d3ce0e23 implements AcVariableMirror {
  const M0635a8e4d3ce0e23();
  @override Symbol get simpleName => const Symbol('storedProcedures');
  @override String getName() => 'storedProcedures';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'stored_procedures')];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tables' in class 'AcDataDictionary'
class Mff2d6780f9a15404 implements AcVariableMirror {
  const Mff2d6780f9a15404();
  @override Symbol get simpleName => const Symbol('tables');
  @override String getName() => 'tables';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'triggers' in class 'AcDataDictionary'
class Mdcbf058e3680e7cf implements AcVariableMirror {
  const Mdcbf058e3680e7cf();
  @override Symbol get simpleName => const Symbol('triggers');
  @override String getName() => 'triggers';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'version' in class 'AcDataDictionary'
class M703263c97881e321 implements AcVariableMirror {
  const M703263c97881e321();
  @override Symbol get simpleName => const Symbol('version');
  @override String getName() => 'version';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'views' in class 'AcDataDictionary'
class M9b6f15aec576e852 implements AcVariableMirror {
  const M9b6f15aec576e852();
  @override Symbol get simpleName => const Symbol('views');
  @override String getName() => 'views';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDataDictionary'
class M921b3a1c3b679069 implements AcMethodMirror {
  const M921b3a1c3b679069();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDataDictionary;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJsonString' in class 'AcDataDictionary'
class M8c33e865c0209bc4 implements AcMethodMirror {
  const M8c33e865c0209bc4();
  @override Symbol get simpleName => const Symbol('fromJsonString');
  @override String getName() => 'fromJsonString';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDataDictionary;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getFunctions' in class 'AcDataDictionary'
class M4bb4da0fb5a2a2ed implements AcMethodMirror {
  const M4bb4da0fb5a2a2ed();
  @override Symbol get simpleName => const Symbol('getFunctions');
  @override String getName() => 'getFunctions';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, AcDDFunction>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getFunction' in class 'AcDataDictionary'
class Mfd4619bff2e04068 implements AcMethodMirror {
  const Mfd4619bff2e04068();
  @override Symbol get simpleName => const Symbol('getFunction');
  @override String getName() => 'getFunction';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDFunction;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getInstance' in class 'AcDataDictionary'
class Mbbdb5ff8b73e26c7 implements AcMethodMirror {
  const Mbbdb5ff8b73e26c7();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDataDictionary;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getRelationships' in class 'AcDataDictionary'
class M1d89f4769c787c05 implements AcMethodMirror {
  const M1d89f4769c787c05();
  @override Symbol get simpleName => const Symbol('getRelationships');
  @override String getName() => 'getRelationships';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDRelationship>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getStoredProcedures' in class 'AcDataDictionary'
class M840114ee225286cf implements AcMethodMirror {
  const M840114ee225286cf();
  @override Symbol get simpleName => const Symbol('getStoredProcedures');
  @override String getName() => 'getStoredProcedures';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, AcDDStoredProcedure>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getStoredProcedure' in class 'AcDataDictionary'
class M31400b2f18eb94ee implements AcMethodMirror {
  const M31400b2f18eb94ee();
  @override Symbol get simpleName => const Symbol('getStoredProcedure');
  @override String getName() => 'getStoredProcedure';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDStoredProcedure;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTable' in class 'AcDataDictionary'
class M82f42de91bf07374 implements AcMethodMirror {
  const M82f42de91bf07374();
  @override Symbol get simpleName => const Symbol('getTable');
  @override String getName() => 'getTable';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTable;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableColumn' in class 'AcDataDictionary'
class M79615d85912efa02 implements AcMethodMirror {
  const M79615d85912efa02();
  @override Symbol get simpleName => const Symbol('getTableColumn');
  @override String getName() => 'getTableColumn';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableColumnRelationships' in class 'AcDataDictionary'
class M1e3d604a758b3d71 implements AcMethodMirror {
  const M1e3d604a758b3d71();
  @override Symbol get simpleName => const Symbol('getTableColumnRelationships');
  @override String getName() => 'getTableColumnRelationships';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDRelationship>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableRelationships' in class 'AcDataDictionary'
class M61974d765ddcff7e implements AcMethodMirror {
  const M61974d765ddcff7e();
  @override Symbol get simpleName => const Symbol('getTableRelationships');
  @override String getName() => 'getTableRelationships';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDRelationship>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTables' in class 'AcDataDictionary'
class M5d61fed5ba2703d7 implements AcMethodMirror {
  const M5d61fed5ba2703d7();
  @override Symbol get simpleName => const Symbol('getTables');
  @override String getName() => 'getTables';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, AcDDTable>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTriggers' in class 'AcDataDictionary'
class M99dd33a9748a617a implements AcMethodMirror {
  const M99dd33a9748a617a();
  @override Symbol get simpleName => const Symbol('getTriggers');
  @override String getName() => 'getTriggers';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, AcDDTrigger>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTrigger' in class 'AcDataDictionary'
class Mc2d47157f7c80b70 implements AcMethodMirror {
  const Mc2d47157f7c80b70();
  @override Symbol get simpleName => const Symbol('getTrigger');
  @override String getName() => 'getTrigger';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTrigger;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getViews' in class 'AcDataDictionary'
class Mefa2676d07b529e6 implements AcMethodMirror {
  const Mefa2676d07b529e6();
  @override Symbol get simpleName => const Symbol('getViews');
  @override String getName() => 'getViews';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, AcDDView>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getView' in class 'AcDataDictionary'
class M6575190d1ffab10f implements AcMethodMirror {
  const M6575190d1ffab10f();
  @override Symbol get simpleName => const Symbol('getView');
  @override String getName() => 'getView';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDView;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'registerDataDictionary' in class 'AcDataDictionary'
class Mdde045db5541c629 implements AcMethodMirror {
  const Mdde045db5541c629();
  @override Symbol get simpleName => const Symbol('registerDataDictionary');
  @override String getName() => 'registerDataDictionary';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'registerDataDictionaryJsonString' in class 'AcDataDictionary'
class Ma1104f27640346ca implements AcMethodMirror {
  const Ma1104f27640346ca();
  @override Symbol get simpleName => const Symbol('registerDataDictionaryJsonString');
  @override String getName() => 'registerDataDictionaryJsonString';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDataDictionary'
class M0929c07fb5b9f4d0 implements AcMethodMirror {
  const M0929c07fb5b9f4d0();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDataDictionary;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableNames' in class 'AcDataDictionary'
class Mb7fb5e4a8013f983 implements AcMethodMirror {
  const Mb7fb5e4a8013f983();
  @override Symbol get simpleName => const Symbol('getTableNames');
  @override String getName() => 'getTableNames';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<String>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTablesList' in class 'AcDataDictionary'
class Mda447994eef0f9b7 implements AcMethodMirror {
  const Mda447994eef0f9b7();
  @override Symbol get simpleName => const Symbol('getTablesList');
  @override String getName() => 'getTablesList';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableColumnNames' in class 'AcDataDictionary'
class M42778f95b98e0c2c implements AcMethodMirror {
  const M42778f95b98e0c2c();
  @override Symbol get simpleName => const Symbol('getTableColumnNames');
  @override String getName() => 'getTableColumnNames';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<String>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableColumnsList' in class 'AcDataDictionary'
class M460e14fe8db21017 implements AcMethodMirror {
  const M460e14fe8db21017();
  @override Symbol get simpleName => const Symbol('getTableColumnsList');
  @override String getName() => 'getTableColumnsList';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableRelationshipsList' in class 'AcDataDictionary'
class M8a801b935047262a implements AcMethodMirror {
  const M8a801b935047262a();
  @override Symbol get simpleName => const Symbol('getTableRelationshipsList');
  @override String getName() => 'getTableRelationshipsList';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getTableTriggersList' in class 'AcDataDictionary'
class Maae21073bcc0a8c7 implements AcMethodMirror {
  const Maae21073bcc0a8c7();
  @override Symbol get simpleName => const Symbol('getTableTriggersList');
  @override String getName() => 'getTableTriggersList';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDataDictionary'
class M0944555113f378bf implements AcMethodMirror {
  const M0944555113f378bf();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDataDictionary'
class M310aa79b67c0a105 implements AcMethodMirror {
  const M310aa79b67c0a105();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DATABASE_TYPE' in class 'AcDDCondition'
class Mcf3e820f6bc59f6d implements AcVariableMirror {
  const Mcf3e820f6bc59f6d();
  @override Symbol get simpleName => const Symbol('KEY_DATABASE_TYPE');
  @override String getName() => 'KEY_DATABASE_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_NAME' in class 'AcDDCondition'
class Meb9651a1ee2cf45f implements AcVariableMirror {
  const Meb9651a1ee2cf45f();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_NAME');
  @override String getName() => 'KEY_COLUMN_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPERATOR' in class 'AcDDCondition'
class Mf8d40e78298efd15 implements AcVariableMirror {
  const Mf8d40e78298efd15();
  @override Symbol get simpleName => const Symbol('KEY_OPERATOR');
  @override String getName() => 'KEY_OPERATOR';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VALUE' in class 'AcDDCondition'
class Mfada93841cee33e5 implements AcVariableMirror {
  const Mfada93841cee33e5();
  @override Symbol get simpleName => const Symbol('KEY_VALUE');
  @override String getName() => 'KEY_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'databaseType' in class 'AcDDCondition'
class M3a56522845e9cac9 implements AcVariableMirror {
  const M3a56522845e9cac9();
  @override Symbol get simpleName => const Symbol('databaseType');
  @override String getName() => 'databaseType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'database_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnName' in class 'AcDDCondition'
class Medec4fed4a812437 implements AcVariableMirror {
  const Medec4fed4a812437();
  @override Symbol get simpleName => const Symbol('columnName');
  @override String getName() => 'columnName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'operator' in class 'AcDDCondition'
class M1c1f83437174de00 implements AcVariableMirror {
  const M1c1f83437174de00();
  @override Symbol get simpleName => const Symbol('operator');
  @override String getName() => 'operator';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'value' in class 'AcDDCondition'
class M05cc220786e78b5a implements AcVariableMirror {
  const M05cc220786e78b5a();
  @override Symbol get simpleName => const Symbol('value');
  @override String getName() => 'value';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'fromJson' in class 'AcDDCondition'
class M6c858e53a4f5dc17 implements AcMethodMirror {
  const M6c858e53a4f5dc17();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDCondition;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDCondition'
class M82b21da8591f9a1b implements AcMethodMirror {
  const M82b21da8591f9a1b();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDCondition'
class M0f9a35c4fd126743 implements AcMethodMirror {
  const M0f9a35c4fd126743();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDCondition'
class Mbc8a239c4c7242a4 implements AcMethodMirror {
  const Mbc8a239c4c7242a4();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDCondition;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'instanceFromJson' in class 'AcDDCondition'
class M076b646a51a66138 implements AcMethodMirror {
  const M076b646a51a66138();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDCondition;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "instanceFromJson";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DATABASE_TYPE' in class 'AcDDConditionGroup'
class Mc47cde962df37623 implements AcVariableMirror {
  const Mc47cde962df37623();
  @override Symbol get simpleName => const Symbol('KEY_DATABASE_TYPE');
  @override String getName() => 'KEY_DATABASE_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONDITIONS' in class 'AcDDConditionGroup'
class M653f358310c860b7 implements AcVariableMirror {
  const M653f358310c860b7();
  @override Symbol get simpleName => const Symbol('KEY_CONDITIONS');
  @override String getName() => 'KEY_CONDITIONS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPERATOR' in class 'AcDDConditionGroup'
class M38152fe6dec800e7 implements AcVariableMirror {
  const M38152fe6dec800e7();
  @override Symbol get simpleName => const Symbol('KEY_OPERATOR');
  @override String getName() => 'KEY_OPERATOR';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'databaseType' in class 'AcDDConditionGroup'
class M40ef7575cb9212d2 implements AcVariableMirror {
  const M40ef7575cb9212d2();
  @override Symbol get simpleName => const Symbol('databaseType');
  @override String getName() => 'databaseType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'database_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'conditions' in class 'AcDDConditionGroup'
class Md4def1d288a313e2 implements AcVariableMirror {
  const Md4def1d288a313e2();
  @override Symbol get simpleName => const Symbol('conditions');
  @override String getName() => 'conditions';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'operator' in class 'AcDDConditionGroup'
class M13743ee0967c4085 implements AcVariableMirror {
  const M13743ee0967c4085();
  @override Symbol get simpleName => const Symbol('operator');
  @override String getName() => 'operator';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'addCondition' in class 'AcDDConditionGroup'
class Mb5395ec8d54ec9dc implements AcMethodMirror {
  const Mb5395ec8d54ec9dc();
  @override Symbol get simpleName => const Symbol('addCondition');
  @override String getName() => 'addCondition';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDConditionGroup;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addConditionGroup' in class 'AcDDConditionGroup'
class M7f07161f6f47ca3e implements AcMethodMirror {
  const M7f07161f6f47ca3e();
  @override Symbol get simpleName => const Symbol('addConditionGroup');
  @override String getName() => 'addConditionGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDConditionGroup;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDConditionGroup'
class M6ce9e2f7ac114a8d implements AcMethodMirror {
  const M6ce9e2f7ac114a8d();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDConditionGroup;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDConditionGroup'
class Ma29642db6af062ef implements AcMethodMirror {
  const Ma29642db6af062ef();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDConditionGroup'
class Md99fdc0e7738b864 implements AcMethodMirror {
  const Md99fdc0e7738b864();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDConditionGroup'
class M8a2525725ec7aed5 implements AcMethodMirror {
  const M8a2525725ec7aed5();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDConditionGroup;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'instanceFromJson' in class 'AcDDConditionGroup'
class Me0788a83c7673bad implements AcMethodMirror {
  const Me0788a83c7673bad();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDConditionGroup;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "instanceFromJson";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_FUNCTION_NAME' in class 'AcDDFunction'
class Mda03d9d5e4f48ab2 implements AcVariableMirror {
  const Mda03d9d5e4f48ab2();
  @override Symbol get simpleName => const Symbol('KEY_FUNCTION_NAME');
  @override String getName() => 'KEY_FUNCTION_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_FUNCTION_CODE' in class 'AcDDFunction'
class Mf4848ecbb5b55fa7 implements AcVariableMirror {
  const Mf4848ecbb5b55fa7();
  @override Symbol get simpleName => const Symbol('KEY_FUNCTION_CODE');
  @override String getName() => 'KEY_FUNCTION_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'functionName' in class 'AcDDFunction'
class M00ec9bfcbf39bdb2 implements AcVariableMirror {
  const M00ec9bfcbf39bdb2();
  @override Symbol get simpleName => const Symbol('functionName');
  @override String getName() => 'functionName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'function_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'functionCode' in class 'AcDDFunction'
class Mcee054f0a74431a2 implements AcVariableMirror {
  const Mcee054f0a74431a2();
  @override Symbol get simpleName => const Symbol('functionCode');
  @override String getName() => 'functionCode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'function_code')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'getDropFunctionStatement' in class 'AcDDFunction'
class Ma3b064ab2974dded implements AcMethodMirror {
  const Ma3b064ab2974dded();
  @override Symbol get simpleName => const Symbol('getDropFunctionStatement');
  @override String getName() => 'getDropFunctionStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDFunction'
class M3c7ffa7370be4005 implements AcMethodMirror {
  const M3c7ffa7370be4005();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDFunction;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDFunction'
class M5cfda6b2c6b0d96c implements AcMethodMirror {
  const M5cfda6b2c6b0d96c();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateFunctionStatement' in class 'AcDDFunction'
class Maa3e0064eb601caa implements AcMethodMirror {
  const Maa3e0064eb601caa();
  @override Symbol get simpleName => const Symbol('getCreateFunctionStatement');
  @override String getName() => 'getCreateFunctionStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDFunction'
class Mb61fe830d2cc55c9 implements AcMethodMirror {
  const Mb61fe830d2cc55c9();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDFunction'
class M742ff0584cc35e01 implements AcMethodMirror {
  const M742ff0584cc35e01();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDFunction;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'instanceFromJson' in class 'AcDDFunction'
class M93368a8cf9dac838 implements AcMethodMirror {
  const M93368a8cf9dac838();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDFunction;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "instanceFromJson";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'getInstance' in class 'AcDDFunction'
class M83b815ca2965bb4a implements AcMethodMirror {
  const M83b815ca2965bb4a();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDFunction;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "getInstance";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CASCADE_DELETE_DESTINATION' in class 'AcDDRelationship'
class Me6881fd0119d3d11 implements AcVariableMirror {
  const Me6881fd0119d3d11();
  @override Symbol get simpleName => const Symbol('KEY_CASCADE_DELETE_DESTINATION');
  @override String getName() => 'KEY_CASCADE_DELETE_DESTINATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CASCADE_DELETE_SOURCE' in class 'AcDDRelationship'
class Mde643de26fceb137 implements AcVariableMirror {
  const Mde643de26fceb137();
  @override Symbol get simpleName => const Symbol('KEY_CASCADE_DELETE_SOURCE');
  @override String getName() => 'KEY_CASCADE_DELETE_SOURCE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESTINATION_COLUMN' in class 'AcDDRelationship'
class M399434b2f461e7a9 implements AcVariableMirror {
  const M399434b2f461e7a9();
  @override Symbol get simpleName => const Symbol('KEY_DESTINATION_COLUMN');
  @override String getName() => 'KEY_DESTINATION_COLUMN';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESTINATION_TABLE' in class 'AcDDRelationship'
class Mc9fcae17737b632f implements AcVariableMirror {
  const Mc9fcae17737b632f();
  @override Symbol get simpleName => const Symbol('KEY_DESTINATION_TABLE');
  @override String getName() => 'KEY_DESTINATION_TABLE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SOURCE_COLUMN' in class 'AcDDRelationship'
class Mca06b90f9f095fda implements AcVariableMirror {
  const Mca06b90f9f095fda();
  @override Symbol get simpleName => const Symbol('KEY_SOURCE_COLUMN');
  @override String getName() => 'KEY_SOURCE_COLUMN';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SOURCE_TABLE' in class 'AcDDRelationship'
class M9077b7e486afa1a8 implements AcVariableMirror {
  const M9077b7e486afa1a8();
  @override Symbol get simpleName => const Symbol('KEY_SOURCE_TABLE');
  @override String getName() => 'KEY_SOURCE_TABLE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'cascadeDeleteDestination' in class 'AcDDRelationship'
class M2bd1475cbe822cd6 implements AcVariableMirror {
  const M2bd1475cbe822cd6();
  @override Symbol get simpleName => const Symbol('cascadeDeleteDestination');
  @override String getName() => 'cascadeDeleteDestination';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'cascade_delete_destination')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'cascadeDeleteSource' in class 'AcDDRelationship'
class M0dd538671c0e3ce4 implements AcVariableMirror {
  const M0dd538671c0e3ce4();
  @override Symbol get simpleName => const Symbol('cascadeDeleteSource');
  @override String getName() => 'cascadeDeleteSource';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'cascade_delete_source')];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'destinationColumn' in class 'AcDDRelationship'
class M1f11afd4f8604b8c implements AcVariableMirror {
  const M1f11afd4f8604b8c();
  @override Symbol get simpleName => const Symbol('destinationColumn');
  @override String getName() => 'destinationColumn';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'destination_column')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'destinationTable' in class 'AcDDRelationship'
class M7b67d48ca24458c4 implements AcVariableMirror {
  const M7b67d48ca24458c4();
  @override Symbol get simpleName => const Symbol('destinationTable');
  @override String getName() => 'destinationTable';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'destination_table')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'sourceColumn' in class 'AcDDRelationship'
class Ma65e54191d57aa2a implements AcVariableMirror {
  const Ma65e54191d57aa2a();
  @override Symbol get simpleName => const Symbol('sourceColumn');
  @override String getName() => 'sourceColumn';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'source_column')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'sourceTable' in class 'AcDDRelationship'
class M1d184cd44bcd6bdc implements AcVariableMirror {
  const M1d184cd44bcd6bdc();
  @override Symbol get simpleName => const Symbol('sourceTable');
  @override String getName() => 'sourceTable';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'source_table')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'getInstances' in class 'AcDDRelationship'
class M6d9b2d2134d1d617 implements AcMethodMirror {
  const M6d9b2d2134d1d617();
  @override Symbol get simpleName => const Symbol('getInstances');
  @override String getName() => 'getInstances';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDRelationship>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDRelationship'
class M66be3e6a640c3e72 implements AcMethodMirror {
  const M66be3e6a640c3e72();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDRelationship;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateRelationshipStatement' in class 'AcDDRelationship'
class Mab9c5a74960a9829 implements AcMethodMirror {
  const Mab9c5a74960a9829();
  @override Symbol get simpleName => const Symbol('getCreateRelationshipStatement');
  @override String getName() => 'getCreateRelationshipStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDRelationship'
class M2715a0c885ff2522 implements AcMethodMirror {
  const M2715a0c885ff2522();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDRelationship'
class M886c30fa4db047fd implements AcMethodMirror {
  const M886c30fa4db047fd();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDRelationship'
class M7b38ff6b0dbb79a1 implements AcMethodMirror {
  const M7b38ff6b0dbb79a1();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDRelationship;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor 'instanceFromJson' in class 'AcDDRelationship'
class M9062255d58c316d0 implements AcMethodMirror {
  const M9062255d58c316d0();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDRelationship;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "instanceFromJson";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONDITION' in class 'AcDDSelectStatement'
class M2e33eb5783d05362 implements AcVariableMirror {
  const M2e33eb5783d05362();
  @override Symbol get simpleName => const Symbol('KEY_CONDITION');
  @override String getName() => 'KEY_CONDITION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONDITION_GROUP' in class 'AcDDSelectStatement'
class Me7a01bbd75e7a48d implements AcVariableMirror {
  const Me7a01bbd75e7a48d();
  @override Symbol get simpleName => const Symbol('KEY_CONDITION_GROUP');
  @override String getName() => 'KEY_CONDITION_GROUP';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DATABASE_TYPE' in class 'AcDDSelectStatement'
class M53255eed027c2691 implements AcVariableMirror {
  const M53255eed027c2691();
  @override Symbol get simpleName => const Symbol('KEY_DATABASE_TYPE');
  @override String getName() => 'KEY_DATABASE_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DATA_DICTIONARY_NAME' in class 'AcDDSelectStatement'
class M81827cdb0dde486a implements AcVariableMirror {
  const M81827cdb0dde486a();
  @override Symbol get simpleName => const Symbol('KEY_DATA_DICTIONARY_NAME');
  @override String getName() => 'KEY_DATA_DICTIONARY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXCLUDE_COLUMNS' in class 'AcDDSelectStatement'
class Md1db48b92cd560ea implements AcVariableMirror {
  const Md1db48b92cd560ea();
  @override Symbol get simpleName => const Symbol('KEY_EXCLUDE_COLUMNS');
  @override String getName() => 'KEY_EXCLUDE_COLUMNS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_INCLUDE_COLUMNS' in class 'AcDDSelectStatement'
class M112a4b4f9d6fa1c0 implements AcVariableMirror {
  const M112a4b4f9d6fa1c0();
  @override Symbol get simpleName => const Symbol('KEY_INCLUDE_COLUMNS');
  @override String getName() => 'KEY_INCLUDE_COLUMNS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_ORDER_BY' in class 'AcDDSelectStatement'
class Me7d69583bffb9718 implements AcVariableMirror {
  const Me7d69583bffb9718();
  @override Symbol get simpleName => const Symbol('KEY_ORDER_BY');
  @override String getName() => 'KEY_ORDER_BY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PAGE_NUMBER' in class 'AcDDSelectStatement'
class M446452f069a5c741 implements AcVariableMirror {
  const M446452f069a5c741();
  @override Symbol get simpleName => const Symbol('KEY_PAGE_NUMBER');
  @override String getName() => 'KEY_PAGE_NUMBER';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PAGE_SIZE' in class 'AcDDSelectStatement'
class Mc4116a722299e576 implements AcVariableMirror {
  const Mc4116a722299e576();
  @override Symbol get simpleName => const Symbol('KEY_PAGE_SIZE');
  @override String getName() => 'KEY_PAGE_SIZE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PARAMETERS' in class 'AcDDSelectStatement'
class M3d4594724e97ba6d implements AcVariableMirror {
  const M3d4594724e97ba6d();
  @override Symbol get simpleName => const Symbol('KEY_PARAMETERS');
  @override String getName() => 'KEY_PARAMETERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SELECT_STATEMENT' in class 'AcDDSelectStatement'
class Ma9a1a03a7e4d998f implements AcVariableMirror {
  const Ma9a1a03a7e4d998f();
  @override Symbol get simpleName => const Symbol('KEY_SELECT_STATEMENT');
  @override String getName() => 'KEY_SELECT_STATEMENT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SQL_STATEMENT' in class 'AcDDSelectStatement'
class Mdb3b7f1d62f660fe implements AcVariableMirror {
  const Mdb3b7f1d62f660fe();
  @override Symbol get simpleName => const Symbol('KEY_SQL_STATEMENT');
  @override String getName() => 'KEY_SQL_STATEMENT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TABLE_NAME' in class 'AcDDSelectStatement'
class Mbc4555dace3ba83a implements AcVariableMirror {
  const Mbc4555dace3ba83a();
  @override Symbol get simpleName => const Symbol('KEY_TABLE_NAME');
  @override String getName() => 'KEY_TABLE_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'condition' in class 'AcDDSelectStatement'
class M737b6b8187f45b57 implements AcVariableMirror {
  const M737b6b8187f45b57();
  @override Symbol get simpleName => const Symbol('condition');
  @override String getName() => 'condition';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'conditionGroup' in class 'AcDDSelectStatement'
class Meac0cc565b069535 implements AcVariableMirror {
  const Meac0cc565b069535();
  @override Symbol get simpleName => const Symbol('conditionGroup');
  @override String getName() => 'conditionGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'condition_group')];
  @override Type get type => AcDDConditionGroup;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'databaseType' in class 'AcDDSelectStatement'
class M24ca9923fa50a047 implements AcVariableMirror {
  const M24ca9923fa50a047();
  @override Symbol get simpleName => const Symbol('databaseType');
  @override String getName() => 'databaseType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'database_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'dataDictionaryName' in class 'AcDDSelectStatement'
class M66f5ea9f78702576 implements AcVariableMirror {
  const M66f5ea9f78702576();
  @override Symbol get simpleName => const Symbol('dataDictionaryName');
  @override String getName() => 'dataDictionaryName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'data_dictionary_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'excludeColumns' in class 'AcDDSelectStatement'
class M493f9622031175aa implements AcVariableMirror {
  const M493f9622031175aa();
  @override Symbol get simpleName => const Symbol('excludeColumns');
  @override String getName() => 'excludeColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'exclude_columns')];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'groupStack' in class 'AcDDSelectStatement'
class M274e320b047b0128 implements AcVariableMirror {
  const M274e320b047b0128();
  @override Symbol get simpleName => const Symbol('groupStack');
  @override String getName() => 'groupStack';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<AcDDConditionGroup>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'includeColumns' in class 'AcDDSelectStatement'
class M208dd0cfe833c441 implements AcVariableMirror {
  const M208dd0cfe833c441();
  @override Symbol get simpleName => const Symbol('includeColumns');
  @override String getName() => 'includeColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'include_columns')];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'orderBy' in class 'AcDDSelectStatement'
class M94c9364c2210252e implements AcVariableMirror {
  const M94c9364c2210252e();
  @override Symbol get simpleName => const Symbol('orderBy');
  @override String getName() => 'orderBy';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'order_by')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'pageNumber' in class 'AcDDSelectStatement'
class M460c787a554f9c0e implements AcVariableMirror {
  const M460c787a554f9c0e();
  @override Symbol get simpleName => const Symbol('pageNumber');
  @override String getName() => 'pageNumber';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'page_number')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'pageSize' in class 'AcDDSelectStatement'
class M793fa4aa4064c314 implements AcVariableMirror {
  const M793fa4aa4064c314();
  @override Symbol get simpleName => const Symbol('pageSize');
  @override String getName() => 'pageSize';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'page_size')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'parameters' in class 'AcDDSelectStatement'
class M23ef19b7ebf39ac6 implements AcVariableMirror {
  const M23ef19b7ebf39ac6();
  @override Symbol get simpleName => const Symbol('parameters');
  @override String getName() => 'parameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'selectStatement' in class 'AcDDSelectStatement'
class M1e50ce199bdccb9b implements AcVariableMirror {
  const M1e50ce199bdccb9b();
  @override Symbol get simpleName => const Symbol('selectStatement');
  @override String getName() => 'selectStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'select_statement')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'sqlStatement' in class 'AcDDSelectStatement'
class M4d2586dc7bed77e2 implements AcVariableMirror {
  const M4d2586dc7bed77e2();
  @override Symbol get simpleName => const Symbol('sqlStatement');
  @override String getName() => 'sqlStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'sql_statement')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tableName' in class 'AcDDSelectStatement'
class Mf067190563c7df31 implements AcVariableMirror {
  const Mf067190563c7df31();
  @override Symbol get simpleName => const Symbol('tableName');
  @override String getName() => 'tableName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'table_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'generateSqlStatement' in class 'AcDDSelectStatement'
class Mb8a796da2c6cb7aa implements AcMethodMirror {
  const Mb8a796da2c6cb7aa();
  @override Symbol get simpleName => const Symbol('generateSqlStatement');
  @override String getName() => 'generateSqlStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'instanceFromJson' in class 'AcDDSelectStatement'
class M48a34978b5549a3e implements AcMethodMirror {
  const M48a34978b5549a3e();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addCondition' in class 'AcDDSelectStatement'
class Md518ce409990888c implements AcMethodMirror {
  const Md518ce409990888c();
  @override Symbol get simpleName => const Symbol('addCondition');
  @override String getName() => 'addCondition';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addConditionGroup' in class 'AcDDSelectStatement'
class M98356381678c29c6 implements AcMethodMirror {
  const M98356381678c29c6();
  @override Symbol get simpleName => const Symbol('addConditionGroup');
  @override String getName() => 'addConditionGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'endGroup' in class 'AcDDSelectStatement'
class M9bf674ed733054d4 implements AcMethodMirror {
  const M9bf674ed733054d4();
  @override Symbol get simpleName => const Symbol('endGroup');
  @override String getName() => 'endGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDSelectStatement'
class M5d29bb97154388c7 implements AcMethodMirror {
  const M5d29bb97154388c7();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSqlStatement' in class 'AcDDSelectStatement'
class Me2bb581e1704a34c implements AcMethodMirror {
  const Me2bb581e1704a34c();
  @override Symbol get simpleName => const Symbol('getSqlStatement');
  @override String getName() => 'getSqlStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setConditionsFromFilters' in class 'AcDDSelectStatement'
class Me43545d000cd70a8 implements AcMethodMirror {
  const Me43545d000cd70a8();
  @override Symbol get simpleName => const Symbol('setConditionsFromFilters');
  @override String getName() => 'setConditionsFromFilters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setSqlCondition' in class 'AcDDSelectStatement'
class M388422b8aa85ddec implements AcMethodMirror {
  const M388422b8aa85ddec();
  @override Symbol get simpleName => const Symbol('setSqlCondition');
  @override String getName() => 'setSqlCondition';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setSqlConditionGroup' in class 'AcDDSelectStatement'
class M55bf960f78c4e111 implements AcMethodMirror {
  const M55bf960f78c4e111();
  @override Symbol get simpleName => const Symbol('setSqlConditionGroup');
  @override String getName() => 'setSqlConditionGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'setSqlLikeStringCondition' in class 'AcDDSelectStatement'
class M0a75c31171eec6f6 implements AcMethodMirror {
  const M0a75c31171eec6f6();
  @override Symbol get simpleName => const Symbol('setSqlLikeStringCondition');
  @override String getName() => 'setSqlLikeStringCondition';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'startGroup' in class 'AcDDSelectStatement'
class M5ea762698fe82050 implements AcMethodMirror {
  const M5ea762698fe82050();
  @override Symbol get simpleName => const Symbol('startGroup');
  @override String getName() => 'startGroup';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDSelectStatement'
class M8adbd82462c4f6d9 implements AcMethodMirror {
  const M8adbd82462c4f6d9();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDSelectStatement'
class M3590d46b5771c69a implements AcMethodMirror {
  const M3590d46b5771c69a();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDSelectStatement'
class M870fde1ff5aa6505 implements AcMethodMirror {
  const M870fde1ff5aa6505();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDSelectStatement;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_STORED_PROCEDURE_NAME' in class 'AcDDStoredProcedure'
class M04d23ba0254e6d8a implements AcVariableMirror {
  const M04d23ba0254e6d8a();
  @override Symbol get simpleName => const Symbol('KEY_STORED_PROCEDURE_NAME');
  @override String getName() => 'KEY_STORED_PROCEDURE_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_STORED_PROCEDURE_CODE' in class 'AcDDStoredProcedure'
class Md2c496ce1b614eb3 implements AcVariableMirror {
  const Md2c496ce1b614eb3();
  @override Symbol get simpleName => const Symbol('KEY_STORED_PROCEDURE_CODE');
  @override String getName() => 'KEY_STORED_PROCEDURE_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'storedProcedureName' in class 'AcDDStoredProcedure'
class M78732456a3a1f4c3 implements AcVariableMirror {
  const M78732456a3a1f4c3();
  @override Symbol get simpleName => const Symbol('storedProcedureName');
  @override String getName() => 'storedProcedureName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'stored_procedure_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'storedProcedureCode' in class 'AcDDStoredProcedure'
class Md440647e8b54ad51 implements AcVariableMirror {
  const Md440647e8b54ad51();
  @override Symbol get simpleName => const Symbol('storedProcedureCode');
  @override String getName() => 'storedProcedureCode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'stored_procedure_code')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDStoredProcedure'
class Mfacd7e05cb50a0d3 implements AcMethodMirror {
  const Mfacd7e05cb50a0d3();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDStoredProcedure;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getInstance' in class 'AcDDStoredProcedure'
class M006667b4ec0398d3 implements AcMethodMirror {
  const M006667b4ec0398d3();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDStoredProcedure;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDropStoredProcedureStatement' in class 'AcDDStoredProcedure'
class Mf0bb1c6a5020aa55 implements AcMethodMirror {
  const Mf0bb1c6a5020aa55();
  @override Symbol get simpleName => const Symbol('getDropStoredProcedureStatement');
  @override String getName() => 'getDropStoredProcedureStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDStoredProcedure'
class Mbccf01d4e5fffd4c implements AcMethodMirror {
  const Mbccf01d4e5fffd4c();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDStoredProcedure;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateStoredProcedureStatement' in class 'AcDDStoredProcedure'
class M4370131047f8ddb5 implements AcMethodMirror {
  const M4370131047f8ddb5();
  @override Symbol get simpleName => const Symbol('getCreateStoredProcedureStatement');
  @override String getName() => 'getCreateStoredProcedureStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDStoredProcedure'
class Mf5a130ca198d9ca9 implements AcMethodMirror {
  const Mf5a130ca198d9ca9();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDStoredProcedure'
class Mf9ae8b2baba8dea3 implements AcMethodMirror {
  const Mf9ae8b2baba8dea3();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_TABLE_COLUMNS' in class 'AcDDTable'
class Mc22bcdc079d71863 implements AcVariableMirror {
  const Mc22bcdc079d71863();
  @override Symbol get simpleName => const Symbol('KEY_TABLE_COLUMNS');
  @override String getName() => 'KEY_TABLE_COLUMNS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TABLE_NAME' in class 'AcDDTable'
class M1340c71279e339f3 implements AcVariableMirror {
  const M1340c71279e339f3();
  @override Symbol get simpleName => const Symbol('KEY_TABLE_NAME');
  @override String getName() => 'KEY_TABLE_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TABLE_PROPERTIES' in class 'AcDDTable'
class M2e7b45cd7bfd56bd implements AcVariableMirror {
  const M2e7b45cd7bfd56bd();
  @override Symbol get simpleName => const Symbol('KEY_TABLE_PROPERTIES');
  @override String getName() => 'KEY_TABLE_PROPERTIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'tableColumns' in class 'AcDDTable'
class Md41530dc08dee846 implements AcVariableMirror {
  const Md41530dc08dee846();
  @override Symbol get simpleName => const Symbol('tableColumns');
  @override String getName() => 'tableColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'table_columns')];
  @override Type get type => List<AcDDTableColumn>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tableName' in class 'AcDDTable'
class M45121b893345edc2 implements AcVariableMirror {
  const M45121b893345edc2();
  @override Symbol get simpleName => const Symbol('tableName');
  @override String getName() => 'tableName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'table_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tableProperties' in class 'AcDDTable'
class M76d257e220fc5785 implements AcVariableMirror {
  const M76d257e220fc5785();
  @override Symbol get simpleName => const Symbol('tableProperties');
  @override String getName() => 'tableProperties';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'table_properties')];
  @override Type get type => List<AcDDTableProperty>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDTable'
class Md469e73b947a25e0 implements AcMethodMirror {
  const Md469e73b947a25e0();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTable;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDropTableStatement' in class 'AcDDTable'
class M87608799d4b337b8 implements AcMethodMirror {
  const M87608799d4b337b8();
  @override Symbol get simpleName => const Symbol('getDropTableStatement');
  @override String getName() => 'getDropTableStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getInstance' in class 'AcDDTable'
class M3e7d3b0e8c809ec1 implements AcMethodMirror {
  const M3e7d3b0e8c809ec1();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTable;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getColumn' in class 'AcDDTable'
class M7d51cc3242520a4b implements AcMethodMirror {
  const M7d51cc3242520a4b();
  @override Symbol get simpleName => const Symbol('getColumn');
  @override String getName() => 'getColumn';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getColumnNames' in class 'AcDDTable'
class M4e948b2aba61001a implements AcMethodMirror {
  const M4e948b2aba61001a();
  @override Symbol get simpleName => const Symbol('getColumnNames');
  @override String getName() => 'getColumnNames';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<String>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateTableStatement' in class 'AcDDTable'
class Ma48cfe4623dbda0f implements AcMethodMirror {
  const Ma48cfe4623dbda0f();
  @override Symbol get simpleName => const Symbol('getCreateTableStatement');
  @override String getName() => 'getCreateTableStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getPrimaryKeyColumnName' in class 'AcDDTable'
class M24c8ae7d6e5f1953 implements AcMethodMirror {
  const M24c8ae7d6e5f1953();
  @override Symbol get simpleName => const Symbol('getPrimaryKeyColumnName');
  @override String getName() => 'getPrimaryKeyColumnName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getPrimaryKeyColumn' in class 'AcDDTable'
class Md38dfe4a037a2ac2 implements AcMethodMirror {
  const Md38dfe4a037a2ac2();
  @override Symbol get simpleName => const Symbol('getPrimaryKeyColumn');
  @override String getName() => 'getPrimaryKeyColumn';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getPrimaryKeyColumns' in class 'AcDDTable'
class M42c4a9eb71ef5d98 implements AcMethodMirror {
  const M42c4a9eb71ef5d98();
  @override Symbol get simpleName => const Symbol('getPrimaryKeyColumns');
  @override String getName() => 'getPrimaryKeyColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDTableColumn>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSearchQueryColumnNames' in class 'AcDDTable'
class Mcc9da341346d934f implements AcMethodMirror {
  const Mcc9da341346d934f();
  @override Symbol get simpleName => const Symbol('getSearchQueryColumnNames');
  @override String getName() => 'getSearchQueryColumnNames';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<String>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSearchQueryColumns' in class 'AcDDTable'
class Mdec03b985b3c9a0a implements AcMethodMirror {
  const Mdec03b985b3c9a0a();
  @override Symbol get simpleName => const Symbol('getSearchQueryColumns');
  @override String getName() => 'getSearchQueryColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDTableColumn>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getForeignKeyColumns' in class 'AcDDTable'
class Mdf020bdc2e6b048d implements AcMethodMirror {
  const Mdf020bdc2e6b048d();
  @override Symbol get simpleName => const Symbol('getForeignKeyColumns');
  @override String getName() => 'getForeignKeyColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDTableColumn>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getPluralName' in class 'AcDDTable'
class M90f6540a7f92d789 implements AcMethodMirror {
  const M90f6540a7f92d789();
  @override Symbol get simpleName => const Symbol('getPluralName');
  @override String getName() => 'getPluralName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSingularName' in class 'AcDDTable'
class Me21a2cf66bbd865b implements AcMethodMirror {
  const Me21a2cf66bbd865b();
  @override Symbol get simpleName => const Symbol('getSingularName');
  @override String getName() => 'getSingularName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSelectDistinctColumns' in class 'AcDDTable'
class Mca4ce591c51f5074 implements AcMethodMirror {
  const Mca4ce591c51f5074();
  @override Symbol get simpleName => const Symbol('getSelectDistinctColumns');
  @override String getName() => 'getSelectDistinctColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDTableColumn>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDTable'
class M27ca4757168969d0 implements AcMethodMirror {
  const M27ca4757168969d0();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTable;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDTable'
class M3d00d1437ee1250a implements AcMethodMirror {
  const M3d00d1437ee1250a();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDTable'
class Mf99890d4d0c4e70a implements AcMethodMirror {
  const Mf99890d4d0c4e70a();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_COLUMN_NAME' in class 'AcDDTableColumn'
class Mce69d5a1c4b4300b implements AcVariableMirror {
  const Mce69d5a1c4b4300b();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_NAME');
  @override String getName() => 'KEY_COLUMN_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_PROPERTIES' in class 'AcDDTableColumn'
class M1dbc351ffb71e51e implements AcVariableMirror {
  const M1dbc351ffb71e51e();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_PROPERTIES');
  @override String getName() => 'KEY_COLUMN_PROPERTIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_TYPE' in class 'AcDDTableColumn'
class Ma9a14f8a4af48e4d implements AcVariableMirror {
  const Ma9a14f8a4af48e4d();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_TYPE');
  @override String getName() => 'KEY_COLUMN_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_VALUE' in class 'AcDDTableColumn'
class M09803391e418ab4f implements AcVariableMirror {
  const M09803391e418ab4f();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_VALUE');
  @override String getName() => 'KEY_COLUMN_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'columnName' in class 'AcDDTableColumn'
class Md535693f66af4122 implements AcVariableMirror {
  const Md535693f66af4122();
  @override Symbol get simpleName => const Symbol('columnName');
  @override String getName() => 'columnName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnProperties' in class 'AcDDTableColumn'
class M3b31cfccc92b23c0 implements AcVariableMirror {
  const M3b31cfccc92b23c0();
  @override Symbol get simpleName => const Symbol('columnProperties');
  @override String getName() => 'columnProperties';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_properties')];
  @override Type get type => Map<String, AcDDTableColumnProperty>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnType' in class 'AcDDTableColumn'
class Ma609494c58ad624d implements AcVariableMirror {
  const Ma609494c58ad624d();
  @override Symbol get simpleName => const Symbol('columnType');
  @override String getName() => 'columnType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnValue' in class 'AcDDTableColumn'
class Md5809caa5ff3bc40 implements AcVariableMirror {
  const Md5809caa5ff3bc40();
  @override Symbol get simpleName => const Symbol('columnValue');
  @override String getName() => 'columnValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_value')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'table' in class 'AcDDTableColumn'
class M96424e678830aee6 implements AcVariableMirror {
  const M96424e678830aee6();
  @override Symbol get simpleName => const Symbol('table');
  @override String getName() => 'table';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(skipInFromJson: true, skipInToJson: true)];
  @override Type get type => AcDDTable;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'getInstance' in class 'AcDDTableColumn'
class M946361e3909c089a implements AcMethodMirror {
  const M946361e3909c089a();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'instanceFromJson' in class 'AcDDTableColumn'
class M3daf659386c58f6d implements AcMethodMirror {
  const M3daf659386c58f6d();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDropColumnStatement' in class 'AcDDTableColumn'
class M75e7a757d2105fc1 implements AcMethodMirror {
  const M75e7a757d2105fc1();
  @override Symbol get simpleName => const Symbol('getDropColumnStatement');
  @override String getName() => 'getDropColumnStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'checkInAutoNumber' in class 'AcDDTableColumn'
class Mfd17e7b231d43195 implements AcMethodMirror {
  const Mfd17e7b231d43195();
  @override Symbol get simpleName => const Symbol('checkInAutoNumber');
  @override String getName() => 'checkInAutoNumber';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'checkInModify' in class 'AcDDTableColumn'
class M939ebfa545c00f1b implements AcMethodMirror {
  const M939ebfa545c00f1b();
  @override Symbol get simpleName => const Symbol('checkInModify');
  @override String getName() => 'checkInModify';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'checkInSave' in class 'AcDDTableColumn'
class M81af702a1f1bd2a9 implements AcMethodMirror {
  const M81af702a1f1bd2a9();
  @override Symbol get simpleName => const Symbol('checkInSave');
  @override String getName() => 'checkInSave';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getAutoNumberLength' in class 'AcDDTableColumn'
class Mb032adf51d223cb8 implements AcMethodMirror {
  const Mb032adf51d223cb8();
  @override Symbol get simpleName => const Symbol('getAutoNumberLength');
  @override String getName() => 'getAutoNumberLength';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => int;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getAutoNumberPrefix' in class 'AcDDTableColumn'
class Mdae3b1cb3dfee229 implements AcMethodMirror {
  const Mdae3b1cb3dfee229();
  @override Symbol get simpleName => const Symbol('getAutoNumberPrefix');
  @override String getName() => 'getAutoNumberPrefix';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getAutoNumberPrefixLength' in class 'AcDDTableColumn'
class M50b44b96e3042a15 implements AcMethodMirror {
  const M50b44b96e3042a15();
  @override Symbol get simpleName => const Symbol('getAutoNumberPrefixLength');
  @override String getName() => 'getAutoNumberPrefixLength';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => int;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDefaultValue' in class 'AcDDTableColumn'
class Mbaf0cba24b6bec7f implements AcMethodMirror {
  const Mbaf0cba24b6bec7f();
  @override Symbol get simpleName => const Symbol('getDefaultValue');
  @override String getName() => 'getDefaultValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getColumnFormats' in class 'AcDDTableColumn'
class Me5b41e18e0ae62ef implements AcMethodMirror {
  const Me5b41e18e0ae62ef();
  @override Symbol get simpleName => const Symbol('getColumnFormats');
  @override String getName() => 'getColumnFormats';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<String>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getColumnTitle' in class 'AcDDTableColumn'
class M709f26d8bef46071 implements AcMethodMirror {
  const M709f26d8bef46071();
  @override Symbol get simpleName => const Symbol('getColumnTitle');
  @override String getName() => 'getColumnTitle';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getAddColumnStatement' in class 'AcDDTableColumn'
class Mee9916549323e2a6 implements AcMethodMirror {
  const Mee9916549323e2a6();
  @override Symbol get simpleName => const Symbol('getAddColumnStatement');
  @override String getName() => 'getAddColumnStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getColumnDefinitionForStatement' in class 'AcDDTableColumn'
class M832114c421853c54 implements AcMethodMirror {
  const M832114c421853c54();
  @override Symbol get simpleName => const Symbol('getColumnDefinitionForStatement');
  @override String getName() => 'getColumnDefinitionForStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method '_blobType' in class 'AcDDTableColumn'
class Mce921e6a5e8b6d1b implements AcMethodMirror {
  const Mce921e6a5e8b6d1b();
  @override Symbol get simpleName => const Symbol('_blobType');
  @override String getName() => '_blobType';
  @override bool get isStatic => false;
  @override bool get isPrivate => true;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method '_textType' in class 'AcDDTableColumn'
class Mbf234effefbf8e09 implements AcMethodMirror {
  const Mbf234effefbf8e09();
  @override Symbol get simpleName => const Symbol('_textType');
  @override String getName() => '_textType';
  @override bool get isStatic => false;
  @override bool get isPrivate => true;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method '_intType' in class 'AcDDTableColumn'
class M6331163a957c5325 implements AcMethodMirror {
  const M6331163a957c5325();
  @override Symbol get simpleName => const Symbol('_intType');
  @override String getName() => '_intType';
  @override bool get isStatic => false;
  @override bool get isPrivate => true;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getForeignKeyRelationships' in class 'AcDDTableColumn'
class Ma4082919e418c5a4 implements AcMethodMirror {
  const Ma4082919e418c5a4();
  @override Symbol get simpleName => const Symbol('getForeignKeyRelationships');
  @override String getName() => 'getForeignKeyRelationships';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => List<AcDDRelationship>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getSize' in class 'AcDDTableColumn'
class M17d4b0d6105108f7 implements AcMethodMirror {
  const M17d4b0d6105108f7();
  @override Symbol get simpleName => const Symbol('getSize');
  @override String getName() => 'getSize';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => int;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isAutoIncrement' in class 'AcDDTableColumn'
class M621d67f55c105c94 implements AcMethodMirror {
  const M621d67f55c105c94();
  @override Symbol get simpleName => const Symbol('isAutoIncrement');
  @override String getName() => 'isAutoIncrement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isAutoNumber' in class 'AcDDTableColumn'
class M9ceaba24e05f874d implements AcMethodMirror {
  const M9ceaba24e05f874d();
  @override Symbol get simpleName => const Symbol('isAutoNumber');
  @override String getName() => 'isAutoNumber';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isForeignKey' in class 'AcDDTableColumn'
class M1db42220649aff92 implements AcMethodMirror {
  const M1db42220649aff92();
  @override Symbol get simpleName => const Symbol('isForeignKey');
  @override String getName() => 'isForeignKey';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isInSearchQuery' in class 'AcDDTableColumn'
class Mab6a2e9bcc23a69a implements AcMethodMirror {
  const Mab6a2e9bcc23a69a();
  @override Symbol get simpleName => const Symbol('isInSearchQuery');
  @override String getName() => 'isInSearchQuery';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isNotNull' in class 'AcDDTableColumn'
class M30aad7bd64501ead implements AcMethodMirror {
  const M30aad7bd64501ead();
  @override Symbol get simpleName => const Symbol('isNotNull');
  @override String getName() => 'isNotNull';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isPrimaryKey' in class 'AcDDTableColumn'
class Me2696c2370f1b8c0 implements AcMethodMirror {
  const Me2696c2370f1b8c0();
  @override Symbol get simpleName => const Symbol('isPrimaryKey');
  @override String getName() => 'isPrimaryKey';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isRequired' in class 'AcDDTableColumn'
class Me9001968aece42fe implements AcMethodMirror {
  const Me9001968aece42fe();
  @override Symbol get simpleName => const Symbol('isRequired');
  @override String getName() => 'isRequired';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isSelectDistinct' in class 'AcDDTableColumn'
class M95ab65e79e452155 implements AcMethodMirror {
  const M95ab65e79e452155();
  @override Symbol get simpleName => const Symbol('isSelectDistinct');
  @override String getName() => 'isSelectDistinct';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isSetValuesNullBeforeDelete' in class 'AcDDTableColumn'
class M752d71fc0e0f09a3 implements AcMethodMirror {
  const M752d71fc0e0f09a3();
  @override Symbol get simpleName => const Symbol('isSetValuesNullBeforeDelete');
  @override String getName() => 'isSetValuesNullBeforeDelete';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'isUniqueKey' in class 'AcDDTableColumn'
class Meecc4c89834c045e implements AcMethodMirror {
  const Meecc4c89834c045e();
  @override Symbol get simpleName => const Symbol('isUniqueKey');
  @override String getName() => 'isUniqueKey';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDTableColumn'
class M45d4667858555fc4 implements AcMethodMirror {
  const M45d4667858555fc4();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDTableColumn'
class Mbf5fcd8f6ea28de9 implements AcMethodMirror {
  const Mbf5fcd8f6ea28de9();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDTableColumn'
class M94f5e4282cd429e7 implements AcMethodMirror {
  const M94f5e4282cd429e7();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_PROPERTY_NAME' in class 'AcDDTableColumnProperty'
class Mfd7596d15aa89a31 implements AcVariableMirror {
  const Mfd7596d15aa89a31();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTY_NAME');
  @override String getName() => 'KEY_PROPERTY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PROPERTY_VALUE' in class 'AcDDTableColumnProperty'
class M1e6c560c06b863f2 implements AcVariableMirror {
  const M1e6c560c06b863f2();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTY_VALUE');
  @override String getName() => 'KEY_PROPERTY_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'propertyName' in class 'AcDDTableColumnProperty'
class M42305d7d4eac8270 implements AcVariableMirror {
  const M42305d7d4eac8270();
  @override Symbol get simpleName => const Symbol('propertyName');
  @override String getName() => 'propertyName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'property_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'propertyValue' in class 'AcDDTableColumnProperty'
class Mea33ea48862cfa1d implements AcVariableMirror {
  const Mea33ea48862cfa1d();
  @override Symbol get simpleName => const Symbol('propertyValue');
  @override String getName() => 'propertyValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'property_value')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDTableColumnProperty'
class Mb5fc3f4ddf510748 implements AcMethodMirror {
  const Mb5fc3f4ddf510748();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumnProperty;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDTableColumnProperty'
class Md5566dbe6b33cec6 implements AcMethodMirror {
  const Md5566dbe6b33cec6();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableColumnProperty;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDTableColumnProperty'
class Meb0485c732dd7416 implements AcMethodMirror {
  const Meb0485c732dd7416();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDTableColumnProperty'
class Me697049cb041c9fb implements AcMethodMirror {
  const Me697049cb041c9fb();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_PROPERTY_NAME' in class 'AcDDTableProperty'
class Mf71dd056a3a098c9 implements AcVariableMirror {
  const Mf71dd056a3a098c9();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTY_NAME');
  @override String getName() => 'KEY_PROPERTY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PROPERTY_VALUE' in class 'AcDDTableProperty'
class M25e5e62d928ee80b implements AcVariableMirror {
  const M25e5e62d928ee80b();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTY_VALUE');
  @override String getName() => 'KEY_PROPERTY_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'propertyName' in class 'AcDDTableProperty'
class Me46bbc72eb91df01 implements AcVariableMirror {
  const Me46bbc72eb91df01();
  @override Symbol get simpleName => const Symbol('propertyName');
  @override String getName() => 'propertyName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'property_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'propertyValue' in class 'AcDDTableProperty'
class M1a5babb4b25ae60b implements AcVariableMirror {
  const M1a5babb4b25ae60b();
  @override Symbol get simpleName => const Symbol('propertyValue');
  @override String getName() => 'propertyValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'property_value')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDTableProperty'
class M1cbffe29de459fe8 implements AcMethodMirror {
  const M1cbffe29de459fe8();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableProperty;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDTableProperty'
class M9f54b335f2488332 implements AcMethodMirror {
  const M9f54b335f2488332();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTableProperty;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDTableProperty'
class M29f7faea2589fae4 implements AcMethodMirror {
  const M29f7faea2589fae4();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDTableProperty'
class M58ad1a943a4679c1 implements AcMethodMirror {
  const M58ad1a943a4679c1();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_ROW_OPERATION' in class 'AcDDTrigger'
class M0965efd9e217af35 implements AcVariableMirror {
  const M0965efd9e217af35();
  @override Symbol get simpleName => const Symbol('KEY_ROW_OPERATION');
  @override String getName() => 'KEY_ROW_OPERATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TABLE_NAME' in class 'AcDDTrigger'
class M3c1356aebf51bd58 implements AcVariableMirror {
  const M3c1356aebf51bd58();
  @override Symbol get simpleName => const Symbol('KEY_TABLE_NAME');
  @override String getName() => 'KEY_TABLE_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TRIGGER_CODE' in class 'AcDDTrigger'
class M93190b74116d1288 implements AcVariableMirror {
  const M93190b74116d1288();
  @override Symbol get simpleName => const Symbol('KEY_TRIGGER_CODE');
  @override String getName() => 'KEY_TRIGGER_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TRIGGER_EXECUTION' in class 'AcDDTrigger'
class M98c2a576fe40a387 implements AcVariableMirror {
  const M98c2a576fe40a387();
  @override Symbol get simpleName => const Symbol('KEY_TRIGGER_EXECUTION');
  @override String getName() => 'KEY_TRIGGER_EXECUTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TRIGGER_NAME' in class 'AcDDTrigger'
class M632dc160ebfe1c5d implements AcVariableMirror {
  const M632dc160ebfe1c5d();
  @override Symbol get simpleName => const Symbol('KEY_TRIGGER_NAME');
  @override String getName() => 'KEY_TRIGGER_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'rowOperation' in class 'AcDDTrigger'
class M555b02c4295faf21 implements AcVariableMirror {
  const M555b02c4295faf21();
  @override Symbol get simpleName => const Symbol('rowOperation');
  @override String getName() => 'rowOperation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'row_operation')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'triggerExecution' in class 'AcDDTrigger'
class M1a17592dfa4f3f9c implements AcVariableMirror {
  const M1a17592dfa4f3f9c();
  @override Symbol get simpleName => const Symbol('triggerExecution');
  @override String getName() => 'triggerExecution';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'trigger_execution')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tableName' in class 'AcDDTrigger'
class Mb765f944cdae9517 implements AcVariableMirror {
  const Mb765f944cdae9517();
  @override Symbol get simpleName => const Symbol('tableName');
  @override String getName() => 'tableName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'table_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'triggerName' in class 'AcDDTrigger'
class Mcb05b8b6dcf81ec7 implements AcVariableMirror {
  const Mcb05b8b6dcf81ec7();
  @override Symbol get simpleName => const Symbol('triggerName');
  @override String getName() => 'triggerName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'trigger_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'triggerCode' in class 'AcDDTrigger'
class M43a73113ce9060a5 implements AcVariableMirror {
  const M43a73113ce9060a5();
  @override Symbol get simpleName => const Symbol('triggerCode');
  @override String getName() => 'triggerCode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'trigger_code')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDTrigger'
class M441f3b7fb63b47ca implements AcMethodMirror {
  const M441f3b7fb63b47ca();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTrigger;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getInstance' in class 'AcDDTrigger'
class Mcc50b39dc9bf375d implements AcMethodMirror {
  const Mcc50b39dc9bf375d();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTrigger;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDropTriggerStatement' in class 'AcDDTrigger'
class M7f9ed72d7972a20b implements AcMethodMirror {
  const M7f9ed72d7972a20b();
  @override Symbol get simpleName => const Symbol('getDropTriggerStatement');
  @override String getName() => 'getDropTriggerStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateTriggerStatement' in class 'AcDDTrigger'
class Ma84b7d61f6361597 implements AcMethodMirror {
  const Ma84b7d61f6361597();
  @override Symbol get simpleName => const Symbol('getCreateTriggerStatement');
  @override String getName() => 'getCreateTriggerStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDTrigger'
class M57909d1e66644159 implements AcMethodMirror {
  const M57909d1e66644159();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDTrigger;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDTrigger'
class Med16cd8a85fab6bf implements AcMethodMirror {
  const Med16cd8a85fab6bf();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDTrigger'
class M82493b422ae3a661 implements AcMethodMirror {
  const M82493b422ae3a661();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_VIEW_NAME' in class 'AcDDView'
class Mcaf13e1bccf2aa73 implements AcVariableMirror {
  const Mcaf13e1bccf2aa73();
  @override Symbol get simpleName => const Symbol('KEY_VIEW_NAME');
  @override String getName() => 'KEY_VIEW_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VIEW_COLUMNS' in class 'AcDDView'
class Mc3dd1c3d7a17ec0b implements AcVariableMirror {
  const Mc3dd1c3d7a17ec0b();
  @override Symbol get simpleName => const Symbol('KEY_VIEW_COLUMNS');
  @override String getName() => 'KEY_VIEW_COLUMNS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VIEW_QUERY' in class 'AcDDView'
class Md22a398f08c1dbeb implements AcVariableMirror {
  const Md22a398f08c1dbeb();
  @override Symbol get simpleName => const Symbol('KEY_VIEW_QUERY');
  @override String getName() => 'KEY_VIEW_QUERY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'viewName' in class 'AcDDView'
class M4b873c77bfa32178 implements AcVariableMirror {
  const M4b873c77bfa32178();
  @override Symbol get simpleName => const Symbol('viewName');
  @override String getName() => 'viewName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'view_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'viewQuery' in class 'AcDDView'
class M036fc5f0426f3283 implements AcVariableMirror {
  const M036fc5f0426f3283();
  @override Symbol get simpleName => const Symbol('viewQuery');
  @override String getName() => 'viewQuery';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'view_query')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'viewColumns' in class 'AcDDView'
class Mfb3bf3136509be0d implements AcVariableMirror {
  const Mfb3bf3136509be0d();
  @override Symbol get simpleName => const Symbol('viewColumns');
  @override String getName() => 'viewColumns';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'view_columns')];
  @override Type get type => Map<String, AcDDViewColumn>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDView'
class Mc4a09c9676e80872 implements AcMethodMirror {
  const Mc4a09c9676e80872();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDView;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getInstance' in class 'AcDDView'
class M4af346f5cea5193d implements AcMethodMirror {
  const M4af346f5cea5193d();
  @override Symbol get simpleName => const Symbol('getInstance');
  @override String getName() => 'getInstance';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDView;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDView'
class M69f3f39002b5557b implements AcMethodMirror {
  const M69f3f39002b5557b();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDView;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getDropViewStatement' in class 'AcDDView'
class Ma6bae536b828f716 implements AcMethodMirror {
  const Ma6bae536b828f716();
  @override Symbol get simpleName => const Symbol('getDropViewStatement');
  @override String getName() => 'getDropViewStatement';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'getCreateViewStatement' in class 'AcDDView'
class M54ccd8c8f968eaa8 implements AcMethodMirror {
  const M54ccd8c8f968eaa8();
  @override Symbol get simpleName => const Symbol('getCreateViewStatement');
  @override String getName() => 'getCreateViewStatement';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDView'
class Mc546cf69de035504 implements AcMethodMirror {
  const Mc546cf69de035504();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDView'
class M1c51cc772f3675c5 implements AcMethodMirror {
  const M1c51cc772f3675c5();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_COLUMN_NAME' in class 'AcDDViewColumn'
class M9f7f00881cfe2071 implements AcVariableMirror {
  const M9f7f00881cfe2071();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_NAME');
  @override String getName() => 'KEY_COLUMN_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_PROPERTIES' in class 'AcDDViewColumn'
class Mc3d83dbd9174a8b3 implements AcVariableMirror {
  const Mc3d83dbd9174a8b3();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_PROPERTIES');
  @override String getName() => 'KEY_COLUMN_PROPERTIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_TYPE' in class 'AcDDViewColumn'
class Ma13f1ee8eb395c2b implements AcVariableMirror {
  const Ma13f1ee8eb395c2b();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_TYPE');
  @override String getName() => 'KEY_COLUMN_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_VALUE' in class 'AcDDViewColumn'
class Mae6102bee5ba4c33 implements AcVariableMirror {
  const Mae6102bee5ba4c33();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_VALUE');
  @override String getName() => 'KEY_COLUMN_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_SOURCE' in class 'AcDDViewColumn'
class M414c94010a199727 implements AcVariableMirror {
  const M414c94010a199727();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_SOURCE');
  @override String getName() => 'KEY_COLUMN_SOURCE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COLUMN_SOURCE_NAME' in class 'AcDDViewColumn'
class M3bb0cdd3fe2121f8 implements AcVariableMirror {
  const M3bb0cdd3fe2121f8();
  @override Symbol get simpleName => const Symbol('KEY_COLUMN_SOURCE_NAME');
  @override String getName() => 'KEY_COLUMN_SOURCE_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'columnName' in class 'AcDDViewColumn'
class M5fb0321e3fff0b6f implements AcVariableMirror {
  const M5fb0321e3fff0b6f();
  @override Symbol get simpleName => const Symbol('columnName');
  @override String getName() => 'columnName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnProperties' in class 'AcDDViewColumn'
class Mae3cba52168707b8 implements AcVariableMirror {
  const Mae3cba52168707b8();
  @override Symbol get simpleName => const Symbol('columnProperties');
  @override String getName() => 'columnProperties';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_properties')];
  @override Type get type => Map<String, AcDDTableColumnProperty>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnType' in class 'AcDDViewColumn'
class M78da5e2f9da4e150 implements AcVariableMirror {
  const M78da5e2f9da4e150();
  @override Symbol get simpleName => const Symbol('columnType');
  @override String getName() => 'columnType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnValue' in class 'AcDDViewColumn'
class M45c0cee8d05cd968 implements AcVariableMirror {
  const M45c0cee8d05cd968();
  @override Symbol get simpleName => const Symbol('columnValue');
  @override String getName() => 'columnValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_value')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnSource' in class 'AcDDViewColumn'
class M8edc04cbd2f26cf3 implements AcVariableMirror {
  const M8edc04cbd2f26cf3();
  @override Symbol get simpleName => const Symbol('columnSource');
  @override String getName() => 'columnSource';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_source')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'columnSourceName' in class 'AcDDViewColumn'
class Mf79ead82a9c1a7e4 implements AcVariableMirror {
  const Mf79ead82a9c1a7e4();
  @override Symbol get simpleName => const Symbol('columnSourceName');
  @override String getName() => 'columnSourceName';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'column_source_name')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcDDViewColumn'
class Md97a9570203f3f10 implements AcMethodMirror {
  const Md97a9570203f3f10();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDViewColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcDDViewColumn'
class Mdd06595648ff33d9 implements AcMethodMirror {
  const Mdd06595648ff33d9();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDViewColumn;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcDDViewColumn'
class M859a4b30df128544 implements AcMethodMirror {
  const M859a4b30df128544();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcDDViewColumn'
class Mb559ea6ec392781e implements AcMethodMirror {
  const Mb559ea6ec392781e();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcDDViewColumn'
class M12837a79cdf481a2 implements AcMethodMirror {
  const M12837a79cdf481a2();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcDDViewColumn;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONNECTION_PORT' in class 'AcSqlConnection'
class Ma89df40ab04a8323 implements AcVariableMirror {
  const Ma89df40ab04a8323();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_PORT');
  @override String getName() => 'KEY_CONNECTION_PORT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECTION_HOSTNAME' in class 'AcSqlConnection'
class Md8be7f100d8cba4e implements AcVariableMirror {
  const Md8be7f100d8cba4e();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_HOSTNAME');
  @override String getName() => 'KEY_CONNECTION_HOSTNAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECTION_USERNAME' in class 'AcSqlConnection'
class Mc53dbcd230de29d8 implements AcVariableMirror {
  const Mc53dbcd230de29d8();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_USERNAME');
  @override String getName() => 'KEY_CONNECTION_USERNAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECTION_PASSWORD' in class 'AcSqlConnection'
class M70a1347a4c99c39c implements AcVariableMirror {
  const M70a1347a4c99c39c();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_PASSWORD');
  @override String getName() => 'KEY_CONNECTION_PASSWORD';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECTION_DATABASE' in class 'AcSqlConnection'
class Ma479e5be8abfd3a1 implements AcVariableMirror {
  const Ma479e5be8abfd3a1();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_DATABASE');
  @override String getName() => 'KEY_CONNECTION_DATABASE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECTION_OPTIONS' in class 'AcSqlConnection'
class Md77bf85396662aed implements AcVariableMirror {
  const Md77bf85396662aed();
  @override Symbol get simpleName => const Symbol('KEY_CONNECTION_OPTIONS');
  @override String getName() => 'KEY_CONNECTION_OPTIONS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'port' in class 'AcSqlConnection'
class M16fe2a7a3c15b6b6 implements AcVariableMirror {
  const M16fe2a7a3c15b6b6();
  @override Symbol get simpleName => const Symbol('port');
  @override String getName() => 'port';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'hostname' in class 'AcSqlConnection'
class Me53964ed6e9aa264 implements AcVariableMirror {
  const Me53964ed6e9aa264();
  @override Symbol get simpleName => const Symbol('hostname');
  @override String getName() => 'hostname';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'username' in class 'AcSqlConnection'
class M13d43215d354bcbc implements AcVariableMirror {
  const M13d43215d354bcbc();
  @override Symbol get simpleName => const Symbol('username');
  @override String getName() => 'username';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'password' in class 'AcSqlConnection'
class M87c0f9107ca70f2c implements AcVariableMirror {
  const M87c0f9107ca70f2c();
  @override Symbol get simpleName => const Symbol('password');
  @override String getName() => 'password';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'database' in class 'AcSqlConnection'
class Ma8cb4772cdce2b8c implements AcVariableMirror {
  const Ma8cb4772cdce2b8c();
  @override Symbol get simpleName => const Symbol('database');
  @override String getName() => 'database';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'options' in class 'AcSqlConnection'
class M7f8d9106eb52bb55 implements AcVariableMirror {
  const M7f8d9106eb52bb55();
  @override Symbol get simpleName => const Symbol('options');
  @override String getName() => 'options';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcSqlConnection'
class M1e410a1092aa4f77 implements AcMethodMirror {
  const M1e410a1092aa4f77();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcSqlConnection;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcSqlConnection'
class Mfccaebb14dcfa807 implements AcMethodMirror {
  const Mfccaebb14dcfa807();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcSqlConnection;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcSqlConnection'
class M8f8e5375c216ca9f implements AcMethodMirror {
  const M8f8e5375c216ca9f();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcSqlConnection'
class M0f76c46f46b2b3f9 implements AcMethodMirror {
  const M0f76c46f46b2b3f9();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_ROWS' in class 'AcSqlDaoResult'
class Mdfc3f900ef1b2d3a implements AcVariableMirror {
  const Mdfc3f900ef1b2d3a();
  @override Symbol get simpleName => const Symbol('KEY_ROWS');
  @override String getName() => 'KEY_ROWS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_AFFECTED_ROWS_COUNT' in class 'AcSqlDaoResult'
class M736292deed2395e0 implements AcVariableMirror {
  const M736292deed2395e0();
  @override Symbol get simpleName => const Symbol('KEY_AFFECTED_ROWS_COUNT');
  @override String getName() => 'KEY_AFFECTED_ROWS_COUNT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_LAST_INSERTED_ID' in class 'AcSqlDaoResult'
class M88963cab9d3eede3 implements AcVariableMirror {
  const M88963cab9d3eede3();
  @override Symbol get simpleName => const Symbol('KEY_LAST_INSERTED_ID');
  @override String getName() => 'KEY_LAST_INSERTED_ID';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPERATION' in class 'AcSqlDaoResult'
class M527b99c876a8085f implements AcVariableMirror {
  const M527b99c876a8085f();
  @override Symbol get simpleName => const Symbol('KEY_OPERATION');
  @override String getName() => 'KEY_OPERATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PRIMARY_KEY_COLUMN' in class 'AcSqlDaoResult'
class M70c2cc00d4f05951 implements AcVariableMirror {
  const M70c2cc00d4f05951();
  @override Symbol get simpleName => const Symbol('KEY_PRIMARY_KEY_COLUMN');
  @override String getName() => 'KEY_PRIMARY_KEY_COLUMN';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PRIMARY_KEY_VALUE' in class 'AcSqlDaoResult'
class M170008f24163ee83 implements AcVariableMirror {
  const M170008f24163ee83();
  @override Symbol get simpleName => const Symbol('KEY_PRIMARY_KEY_VALUE');
  @override String getName() => 'KEY_PRIMARY_KEY_VALUE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TOTAL_ROWS' in class 'AcSqlDaoResult'
class M44d6d00467793782 implements AcVariableMirror {
  const M44d6d00467793782();
  @override Symbol get simpleName => const Symbol('KEY_TOTAL_ROWS');
  @override String getName() => 'KEY_TOTAL_ROWS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'rows' in class 'AcSqlDaoResult'
class M64c05af915d80fcd implements AcVariableMirror {
  const M64c05af915d80fcd();
  @override Symbol get simpleName => const Symbol('rows');
  @override String getName() => 'rows';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<Map<String, dynamic>>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'affectedRowsCount' in class 'AcSqlDaoResult'
class M01124673935ca022 implements AcVariableMirror {
  const M01124673935ca022();
  @override Symbol get simpleName => const Symbol('affectedRowsCount');
  @override String getName() => 'affectedRowsCount';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'affected_rows_count')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'lastInsertedId' in class 'AcSqlDaoResult'
class Mdf58a5e31ab84124 implements AcVariableMirror {
  const Mdf58a5e31ab84124();
  @override Symbol get simpleName => const Symbol('lastInsertedId');
  @override String getName() => 'lastInsertedId';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'last_inserted_id')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'lastInsertedIds' in class 'AcSqlDaoResult'
class M44973a525ed4ce42 implements AcVariableMirror {
  const M44973a525ed4ce42();
  @override Symbol get simpleName => const Symbol('lastInsertedIds');
  @override String getName() => 'lastInsertedIds';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'last_inserted_id')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'operation' in class 'AcSqlDaoResult'
class Mb08e7e28057635ff implements AcVariableMirror {
  const Mb08e7e28057635ff();
  @override Symbol get simpleName => const Symbol('operation');
  @override String getName() => 'operation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'primaryKeyColumn' in class 'AcSqlDaoResult'
class M0d3cf8c5d620909f implements AcVariableMirror {
  const M0d3cf8c5d620909f();
  @override Symbol get simpleName => const Symbol('primaryKeyColumn');
  @override String getName() => 'primaryKeyColumn';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'primary_key_column')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'primaryKeyValue' in class 'AcSqlDaoResult'
class Ma712bf38474a2db2 implements AcVariableMirror {
  const Ma712bf38474a2db2();
  @override Symbol get simpleName => const Symbol('primaryKeyValue');
  @override String getName() => 'primaryKeyValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'primary_key_value')];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'totalRows' in class 'AcSqlDaoResult'
class Mb06beceaad9b798c implements AcVariableMirror {
  const Mb06beceaad9b798c();
  @override Symbol get simpleName => const Symbol('totalRows');
  @override String getName() => 'totalRows';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'total_rows')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'hasAffectedRows' in class 'AcSqlDaoResult'
class M30f83f012277b402 implements AcMethodMirror {
  const M30f83f012277b402();
  @override Symbol get simpleName => const Symbol('hasAffectedRows');
  @override String getName() => 'hasAffectedRows';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'hasRows' in class 'AcSqlDaoResult'
class M153c8979bf3610f4 implements AcMethodMirror {
  const M153c8979bf3610f4();
  @override Symbol get simpleName => const Symbol('hasRows');
  @override String getName() => 'hasRows';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => bool;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'rowsCount' in class 'AcSqlDaoResult'
class M409c0a3e06ddebc9 implements AcMethodMirror {
  const M409c0a3e06ddebc9();
  @override Symbol get simpleName => const Symbol('rowsCount');
  @override String getName() => 'rowsCount';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => int;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcSqlDaoResult'
class Mb179cef78fc073e3 implements AcMethodMirror {
  const Mb179cef78fc073e3();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcSqlDaoResult;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'roles' in class 'AcWebAuthorize'
class M5a0414cf6dbd50e3 implements AcVariableMirror {
  const M5a0414cf6dbd50e3();
  @override Symbol get simpleName => const Symbol('roles');
  @override String getName() => 'roles';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<String>;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebAuthorize'
class Mda2d1956d1a90bd4 implements AcMethodMirror {
  const Mda2d1956d1a90bd4();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebAuthorize;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for constructor '' in class 'AcWebController'
class M92ec7de2c9b968fc implements AcMethodMirror {
  const M92ec7de2c9b968fc();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebController;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for constructor '' in class 'AcWebInject'
class M241dd71b55dca1b2 implements AcMethodMirror {
  const M241dd71b55dca1b2();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebInject;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'middlewareClass' in class 'AcWebMiddleware'
class Mbcba40424263aaab implements AcVariableMirror {
  const Mbcba40424263aaab();
  @override Symbol get simpleName => const Symbol('middlewareClass');
  @override String getName() => 'middlewareClass';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebMiddleware'
class M5d575f5ed9a75ed6 implements AcMethodMirror {
  const M5d575f5ed9a75ed6();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebMiddleware;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for constructor '' in class 'AcWebRepository'
class M070975eead5aa895 implements AcMethodMirror {
  const M070975eead5aa895();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRepository;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'path' in class 'AcWebRoute'
class M19b8763a485682af implements AcVariableMirror {
  const M19b8763a485682af();
  @override Symbol get simpleName => const Symbol('path');
  @override String getName() => 'path';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'method' in class 'AcWebRoute'
class M904827e4d70c63e4 implements AcVariableMirror {
  const M904827e4d70c63e4();
  @override Symbol get simpleName => const Symbol('method');
  @override String getName() => 'method';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebRoute'
class M4f4b1661c1e4dcf9 implements AcMethodMirror {
  const M4f4b1661c1e4dcf9();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRoute;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'contentType' in class 'AcWebRouteConsumes'
class M7b040c33e51e78fc implements AcVariableMirror {
  const M7b040c33e51e78fc();
  @override Symbol get simpleName => const Symbol('contentType');
  @override String getName() => 'contentType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebRouteConsumes'
class Mee1c3a5ef0da5a15 implements AcMethodMirror {
  const Mee1c3a5ef0da5a15();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteConsumes;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'summary' in class 'AcWebRouteMeta'
class M8ff0a79a72d94d61 implements AcVariableMirror {
  const M8ff0a79a72d94d61();
  @override Symbol get simpleName => const Symbol('summary');
  @override String getName() => 'summary';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcWebRouteMeta'
class M13d0b9d8a2ec354c implements AcVariableMirror {
  const M13d0b9d8a2ec354c();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'parameters' in class 'AcWebRouteMeta'
class Mdcdbd6744d3ee300 implements AcVariableMirror {
  const Mdcdbd6744d3ee300();
  @override Symbol get simpleName => const Symbol('parameters');
  @override String getName() => 'parameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'tags' in class 'AcWebRouteMeta'
class M9ef5c99560837590 implements AcVariableMirror {
  const M9ef5c99560837590();
  @override Symbol get simpleName => const Symbol('tags');
  @override String getName() => 'tags';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebRouteMeta'
class M187774dd13359d01 implements AcMethodMirror {
  const M187774dd13359d01();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteMeta;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'description' in class 'AcWebRouteMetaParameter'
class Md606da09b40254ec implements AcVariableMirror {
  const Md606da09b40254ec();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'name' in class 'AcWebRouteMetaParameter'
class M11f57326d0853820 implements AcVariableMirror {
  const M11f57326d0853820();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'required' in class 'AcWebRouteMetaParameter'
class Md0e24e393f073125 implements AcVariableMirror {
  const Md0e24e393f073125();
  @override Symbol get simpleName => const Symbol('required');
  @override String getName() => 'required';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'explode' in class 'AcWebRouteMetaParameter'
class M14b3d85a845b7bde implements AcVariableMirror {
  const M14b3d85a845b7bde();
  @override Symbol get simpleName => const Symbol('explode');
  @override String getName() => 'explode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for field 'schema' in class 'AcWebRouteMetaParameter'
class Mf360f3300ebe176b implements AcVariableMirror {
  const Mf360f3300ebe176b();
  @override Symbol get simpleName => const Symbol('schema');
  @override String getName() => 'schema';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebRouteMetaParameter'
class M89bf2f88fc479018 implements AcMethodMirror {
  const M89bf2f88fc479018();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteMetaParameter;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'contentType' in class 'AcWebRouteProduces'
class M5288478453ea7372 implements AcVariableMirror {
  const M5288478453ea7372();
  @override Symbol get simpleName => const Symbol('contentType');
  @override String getName() => 'contentType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebRouteProduces'
class M8f1145a6ad4ee8b2 implements AcMethodMirror {
  const M8f1145a6ad4ee8b2();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteProduces;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for constructor '' in class 'AcWebService'
class M0d01afe740300c92 implements AcMethodMirror {
  const M0d01afe740300c92();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebService;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromBody'
class Med6ac07431c74c5c implements AcVariableMirror {
  const Med6ac07431c74c5c();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromBody'
class Mffbfabfc67528791 implements AcMethodMirror {
  const Mffbfabfc67528791();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromBody;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromCookie'
class M38f19780c59fa517 implements AcVariableMirror {
  const M38f19780c59fa517();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromCookie'
class M7b6fbcf21f09dc02 implements AcMethodMirror {
  const M7b6fbcf21f09dc02();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromCookie;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromForm'
class M1914092aa3911162 implements AcVariableMirror {
  const M1914092aa3911162();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromForm'
class M30794200c9033e73 implements AcMethodMirror {
  const M30794200c9033e73();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromForm;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromHeader'
class M121e0e5d8b299743 implements AcVariableMirror {
  const M121e0e5d8b299743();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromHeader'
class M93723e07f0564669 implements AcMethodMirror {
  const M93723e07f0564669();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromHeader;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromPath'
class Ma5ab706bd0b385a7 implements AcVariableMirror {
  const Ma5ab706bd0b385a7();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromPath'
class M93b6bfcd1a7dd1e8 implements AcMethodMirror {
  const M93b6bfcd1a7dd1e8();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromPath;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'key' in class 'AcWebValueFromQuery'
class M0ffb54f88208c73c implements AcVariableMirror {
  const M0ffb54f88208c73c();
  @override Symbol get simpleName => const Symbol('key');
  @override String getName() => 'key';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebValueFromQuery'
class M15857efa5d8becb7 implements AcMethodMirror {
  const M15857efa5d8becb7();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebValueFromQuery;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for constructor '' in class 'AcWebView'
class Mad976384d34f8b1e implements AcMethodMirror {
  const Mad976384d34f8b1e();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebView;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONTACT' in class 'AcApiDoc'
class M098c2c3fec214a71 implements AcVariableMirror {
  const M098c2c3fec214a71();
  @override Symbol get simpleName => const Symbol('KEY_CONTACT');
  @override String getName() => 'KEY_CONTACT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_COMPONENTS' in class 'AcApiDoc'
class Mc09d9f97b12389cc implements AcVariableMirror {
  const Mc09d9f97b12389cc();
  @override Symbol get simpleName => const Symbol('KEY_COMPONENTS');
  @override String getName() => 'KEY_COMPONENTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDoc'
class Md68dbc9e8c8f5458 implements AcVariableMirror {
  const Md68dbc9e8c8f5458();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_LICENSE' in class 'AcApiDoc'
class Mbb7b3ba5df32ebd5 implements AcVariableMirror {
  const Mbb7b3ba5df32ebd5();
  @override Symbol get simpleName => const Symbol('KEY_LICENSE');
  @override String getName() => 'KEY_LICENSE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_MODELS' in class 'AcApiDoc'
class M8cb0c8306f25e9e7 implements AcVariableMirror {
  const M8cb0c8306f25e9e7();
  @override Symbol get simpleName => const Symbol('KEY_MODELS');
  @override String getName() => 'KEY_MODELS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PATHS' in class 'AcApiDoc'
class M619cdde9a83d3059 implements AcVariableMirror {
  const M619cdde9a83d3059();
  @override Symbol get simpleName => const Symbol('KEY_PATHS');
  @override String getName() => 'KEY_PATHS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SERVERS' in class 'AcApiDoc'
class M7521ac465c91bbe2 implements AcVariableMirror {
  const M7521ac465c91bbe2();
  @override Symbol get simpleName => const Symbol('KEY_SERVERS');
  @override String getName() => 'KEY_SERVERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TAGS' in class 'AcApiDoc'
class M4a4723f61f7479c0 implements AcVariableMirror {
  const M4a4723f61f7479c0();
  @override Symbol get simpleName => const Symbol('KEY_TAGS');
  @override String getName() => 'KEY_TAGS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TERMS_OF_SERVICE' in class 'AcApiDoc'
class M81486ff3b69a1f28 implements AcVariableMirror {
  const M81486ff3b69a1f28();
  @override Symbol get simpleName => const Symbol('KEY_TERMS_OF_SERVICE');
  @override String getName() => 'KEY_TERMS_OF_SERVICE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TITLE' in class 'AcApiDoc'
class Ma025f4cabb61bb34 implements AcVariableMirror {
  const Ma025f4cabb61bb34();
  @override Symbol get simpleName => const Symbol('KEY_TITLE');
  @override String getName() => 'KEY_TITLE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_VERSION' in class 'AcApiDoc'
class Me337ca9ee387a516 implements AcVariableMirror {
  const Me337ca9ee387a516();
  @override Symbol get simpleName => const Symbol('KEY_VERSION');
  @override String getName() => 'KEY_VERSION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'contact' in class 'AcApiDoc'
class M82612e0e92804d5f implements AcVariableMirror {
  const M82612e0e92804d5f();
  @override Symbol get simpleName => const Symbol('contact');
  @override String getName() => 'contact';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocContact;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'components' in class 'AcApiDoc'
class Mbb401f6b98884989 implements AcVariableMirror {
  const Mbb401f6b98884989();
  @override Symbol get simpleName => const Symbol('components');
  @override String getName() => 'components';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDoc'
class M7fca063678a41944 implements AcVariableMirror {
  const M7fca063678a41944();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'license' in class 'AcApiDoc'
class M8eb0f9ed3899f240 implements AcVariableMirror {
  const M8eb0f9ed3899f240();
  @override Symbol get simpleName => const Symbol('license');
  @override String getName() => 'license';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocLicense;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'models' in class 'AcApiDoc'
class M6f00602261a92dd4 implements AcVariableMirror {
  const M6f00602261a92dd4();
  @override Symbol get simpleName => const Symbol('models');
  @override String getName() => 'models';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'models', arrayType: AcApiDocModel)];
  @override Type get type => Map<String, AcApiDocModel>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'paths' in class 'AcApiDoc'
class M0f2a2a713be5861b implements AcVariableMirror {
  const M0f2a2a713be5861b();
  @override Symbol get simpleName => const Symbol('paths');
  @override String getName() => 'paths';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'paths', arrayType: AcApiDocPath)];
  @override Type get type => List<AcApiDocPath>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'servers' in class 'AcApiDoc'
class Mac6cfd51854eee50 implements AcVariableMirror {
  const Mac6cfd51854eee50();
  @override Symbol get simpleName => const Symbol('servers');
  @override String getName() => 'servers';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'servers', arrayType: AcApiDocServer)];
  @override Type get type => List<AcApiDocServer>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'tags' in class 'AcApiDoc'
class M1354c4c232b91943 implements AcVariableMirror {
  const M1354c4c232b91943();
  @override Symbol get simpleName => const Symbol('tags');
  @override String getName() => 'tags';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'tags', arrayType: AcApiDocTag)];
  @override Type get type => List<AcApiDocTag>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'termsOfService' in class 'AcApiDoc'
class M8931976c16a61519 implements AcVariableMirror {
  const M8931976c16a61519();
  @override Symbol get simpleName => const Symbol('termsOfService');
  @override String getName() => 'termsOfService';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'termsOfService')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'title' in class 'AcApiDoc'
class M40c20aca4a50f99d implements AcVariableMirror {
  const M40c20aca4a50f99d();
  @override Symbol get simpleName => const Symbol('title');
  @override String getName() => 'title';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'version' in class 'AcApiDoc'
class Mb3b0627596ddca67 implements AcVariableMirror {
  const Mb3b0627596ddca67();
  @override Symbol get simpleName => const Symbol('version');
  @override String getName() => 'version';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDoc'
class M98c3955ac48aa464 implements AcMethodMirror {
  const M98c3955ac48aa464();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addModel' in class 'AcApiDoc'
class Me11fabdadf119ff5 implements AcMethodMirror {
  const Me11fabdadf119ff5();
  @override Symbol get simpleName => const Symbol('addModel');
  @override String getName() => 'addModel';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addPath' in class 'AcApiDoc'
class Mc7fd3b8b8a3dc027 implements AcMethodMirror {
  const Mc7fd3b8b8a3dc027();
  @override Symbol get simpleName => const Symbol('addPath');
  @override String getName() => 'addPath';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addServer' in class 'AcApiDoc'
class M55f3ac196603dc43 implements AcMethodMirror {
  const M55f3ac196603dc43();
  @override Symbol get simpleName => const Symbol('addServer');
  @override String getName() => 'addServer';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addTag' in class 'AcApiDoc'
class M743d490910b1d7c8 implements AcMethodMirror {
  const M743d490910b1d7c8();
  @override Symbol get simpleName => const Symbol('addTag');
  @override String getName() => 'addTag';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDoc'
class Mc3921d2b879de5c4 implements AcMethodMirror {
  const Mc3921d2b879de5c4();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDoc;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDoc'
class Meebc79e790b64134 implements AcMethodMirror {
  const Meebc79e790b64134();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDoc'
class M16366179bab580a5 implements AcMethodMirror {
  const M16366179bab580a5();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_SCHEMAS' in class 'AcApiDocComponents'
class M08e34b50fe4536ee implements AcVariableMirror {
  const M08e34b50fe4536ee();
  @override Symbol get simpleName => const Symbol('KEY_SCHEMAS');
  @override String getName() => 'KEY_SCHEMAS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'schemas' in class 'AcApiDocComponents'
class M87dd3b7185ba6a09 implements AcVariableMirror {
  const M87dd3b7185ba6a09();
  @override Symbol get simpleName => const Symbol('schemas');
  @override String getName() => 'schemas';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocSchema>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocComponents'
class Mf3fdd6f0143a39f5 implements AcMethodMirror {
  const Mf3fdd6f0143a39f5();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocComponents;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocComponents'
class M75d40e8588d10b7a implements AcMethodMirror {
  const M75d40e8588d10b7a();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocComponents;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocComponents'
class M328c77a6d4606bd8 implements AcMethodMirror {
  const M328c77a6d4606bd8();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocComponents'
class Mc6139c1dd676c9d1 implements AcMethodMirror {
  const Mc6139c1dd676c9d1();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_EMAIL' in class 'AcApiDocContact'
class Me29e8491e8623689 implements AcVariableMirror {
  const Me29e8491e8623689();
  @override Symbol get simpleName => const Symbol('KEY_EMAIL');
  @override String getName() => 'KEY_EMAIL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_NAME' in class 'AcApiDocContact'
class M91c857d449d83482 implements AcVariableMirror {
  const M91c857d449d83482();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcApiDocContact'
class Mf6ee15aed17d3ffb implements AcVariableMirror {
  const Mf6ee15aed17d3ffb();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'email' in class 'AcApiDocContact'
class M6843558f2e2e36da implements AcVariableMirror {
  const M6843558f2e2e36da();
  @override Symbol get simpleName => const Symbol('email');
  @override String getName() => 'email';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'name' in class 'AcApiDocContact'
class M48a34fac1557c67f implements AcVariableMirror {
  const M48a34fac1557c67f();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcApiDocContact'
class M9d2ae9339751ba7b implements AcVariableMirror {
  const M9d2ae9339751ba7b();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocContact'
class M415fba0b6448851e implements AcMethodMirror {
  const M415fba0b6448851e();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocContact;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocContact'
class M89dbe143a95a637d implements AcMethodMirror {
  const M89dbe143a95a637d();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocContact;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocContact'
class Mf27de754550e3cf6 implements AcMethodMirror {
  const Mf27de754550e3cf6();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocContact'
class M5accdae2b38bbf96 implements AcMethodMirror {
  const M5accdae2b38bbf96();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_SCHEMA' in class 'AcApiDocContent'
class M3553855cd3b32e6e implements AcVariableMirror {
  const M3553855cd3b32e6e();
  @override Symbol get simpleName => const Symbol('KEY_SCHEMA');
  @override String getName() => 'KEY_SCHEMA';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXAMPLES' in class 'AcApiDocContent'
class M6e95fa82ba4fef32 implements AcVariableMirror {
  const M6e95fa82ba4fef32();
  @override Symbol get simpleName => const Symbol('KEY_EXAMPLES');
  @override String getName() => 'KEY_EXAMPLES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_ENCODING' in class 'AcApiDocContent'
class Mccc7d9f4bfd4b878 implements AcVariableMirror {
  const Mccc7d9f4bfd4b878();
  @override Symbol get simpleName => const Symbol('KEY_ENCODING');
  @override String getName() => 'KEY_ENCODING';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'schema' in class 'AcApiDocContent'
class M1649e573d0d9f9be implements AcVariableMirror {
  const M1649e573d0d9f9be();
  @override Symbol get simpleName => const Symbol('schema');
  @override String getName() => 'schema';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'examples' in class 'AcApiDocContent'
class Me5b8f89c7d6d762a implements AcVariableMirror {
  const Me5b8f89c7d6d762a();
  @override Symbol get simpleName => const Symbol('examples');
  @override String getName() => 'examples';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'encoding' in class 'AcApiDocContent'
class M4811340949b1baeb implements AcVariableMirror {
  const M4811340949b1baeb();
  @override Symbol get simpleName => const Symbol('encoding');
  @override String getName() => 'encoding';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocContent'
class Ma66ee97b8229b26c implements AcMethodMirror {
  const Ma66ee97b8229b26c();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocContent;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocContent'
class M941e211f15ad1858 implements AcMethodMirror {
  const M941e211f15ad1858();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocContent;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocContent'
class M4402441f4a07bcf3 implements AcMethodMirror {
  const M4402441f4a07bcf3();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocContent'
class Me546a57b72c5c2b2 implements AcMethodMirror {
  const Me546a57b72c5c2b2();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocContent'
class Mad0b26e4a687a8f8 implements AcMethodMirror {
  const Mad0b26e4a687a8f8();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocContent;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocExternalDocs'
class Me934830e5ac25f84 implements AcVariableMirror {
  const Me934830e5ac25f84();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcApiDocExternalDocs'
class M8b6c122966ce0184 implements AcVariableMirror {
  const M8b6c122966ce0184();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'description' in class 'AcApiDocExternalDocs'
class M71003aa8b1f6dee7 implements AcVariableMirror {
  const M71003aa8b1f6dee7();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcApiDocExternalDocs'
class Md83e4039b0ce8c56 implements AcVariableMirror {
  const Md83e4039b0ce8c56();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocExternalDocs'
class M65bd4525d75ed04d implements AcMethodMirror {
  const M65bd4525d75ed04d();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocExternalDocs;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocExternalDocs'
class M1c4067e70e49efad implements AcMethodMirror {
  const M1c4067e70e49efad();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocExternalDocs;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocExternalDocs'
class M3c9b617135e7bf36 implements AcMethodMirror {
  const M3c9b617135e7bf36();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocExternalDocs'
class M202e9402c072c177 implements AcMethodMirror {
  const M202e9402c072c177();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocHeader'
class Me96537d188b35433 implements AcVariableMirror {
  const Me96537d188b35433();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_REQUIRED' in class 'AcApiDocHeader'
class M4a5330987a4d7323 implements AcVariableMirror {
  const M4a5330987a4d7323();
  @override Symbol get simpleName => const Symbol('KEY_REQUIRED');
  @override String getName() => 'KEY_REQUIRED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DEPRECATED' in class 'AcApiDocHeader'
class Mc1210197121a5192 implements AcVariableMirror {
  const Mc1210197121a5192();
  @override Symbol get simpleName => const Symbol('KEY_DEPRECATED');
  @override String getName() => 'KEY_DEPRECATED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SCHEMA' in class 'AcApiDocHeader'
class M7c48f98f3274939e implements AcVariableMirror {
  const M7c48f98f3274939e();
  @override Symbol get simpleName => const Symbol('KEY_SCHEMA');
  @override String getName() => 'KEY_SCHEMA';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'description' in class 'AcApiDocHeader'
class Me524d258b6ecfebe implements AcVariableMirror {
  const Me524d258b6ecfebe();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'required' in class 'AcApiDocHeader'
class Mac49b6ae2ee122db implements AcVariableMirror {
  const Mac49b6ae2ee122db();
  @override Symbol get simpleName => const Symbol('required');
  @override String getName() => 'required';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'deprecated' in class 'AcApiDocHeader'
class Mea5e8bc614919be8 implements AcVariableMirror {
  const Mea5e8bc614919be8();
  @override Symbol get simpleName => const Symbol('deprecated');
  @override String getName() => 'deprecated';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'schema' in class 'AcApiDocHeader'
class Ma0ee3337ef2d87dd implements AcVariableMirror {
  const Ma0ee3337ef2d87dd();
  @override Symbol get simpleName => const Symbol('schema');
  @override String getName() => 'schema';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocHeader'
class Mb1f39558a9a6d26e implements AcMethodMirror {
  const Mb1f39558a9a6d26e();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocHeader;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocHeader'
class Mc08b3a8417709dd8 implements AcMethodMirror {
  const Mc08b3a8417709dd8();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocHeader;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocHeader'
class M5348e73b095d6ad5 implements AcMethodMirror {
  const M5348e73b095d6ad5();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocHeader'
class M8ffdcb837e8cbf50 implements AcMethodMirror {
  const M8ffdcb837e8cbf50();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_NAME' in class 'AcApiDocLicense'
class M944709435e9a6171 implements AcVariableMirror {
  const M944709435e9a6171();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcApiDocLicense'
class M8754598beee400e6 implements AcVariableMirror {
  const M8754598beee400e6();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'name' in class 'AcApiDocLicense'
class Ma4c41a905a24b6f1 implements AcVariableMirror {
  const Ma4c41a905a24b6f1();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcApiDocLicense'
class M0c1f0bb57eab9844 implements AcVariableMirror {
  const M0c1f0bb57eab9844();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocLicense'
class Med4ec1dd5fefa4d9 implements AcMethodMirror {
  const Med4ec1dd5fefa4d9();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocLicense;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocLicense'
class Mb41a35f9980e470d implements AcMethodMirror {
  const Mb41a35f9980e470d();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocLicense;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocLicense'
class M9fe954e29866a356 implements AcMethodMirror {
  const M9fe954e29866a356();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocLicense'
class Md22f83c099538f98 implements AcMethodMirror {
  const Md22f83c099538f98();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_OPERATION_ID' in class 'AcApiDocLink'
class M602eda30b9878c56 implements AcVariableMirror {
  const M602eda30b9878c56();
  @override Symbol get simpleName => const Symbol('KEY_OPERATION_ID');
  @override String getName() => 'KEY_OPERATION_ID';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PARAMETERS' in class 'AcApiDocLink'
class M90ee4b6ef0c6b6e6 implements AcVariableMirror {
  const M90ee4b6ef0c6b6e6();
  @override Symbol get simpleName => const Symbol('KEY_PARAMETERS');
  @override String getName() => 'KEY_PARAMETERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocLink'
class M8360af8c282a1d8e implements AcVariableMirror {
  const M8360af8c282a1d8e();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'operationId' in class 'AcApiDocLink'
class Mcbea47bc302f91df implements AcVariableMirror {
  const Mcbea47bc302f91df();
  @override Symbol get simpleName => const Symbol('operationId');
  @override String getName() => 'operationId';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'operationId')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'parameters' in class 'AcApiDocLink'
class M85dca8f7afa3dfd0 implements AcVariableMirror {
  const M85dca8f7afa3dfd0();
  @override Symbol get simpleName => const Symbol('parameters');
  @override String getName() => 'parameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocLink'
class Mf8965120fed83533 implements AcVariableMirror {
  const Mf8965120fed83533();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocLink'
class Mf3bf9f4cb81cf241 implements AcMethodMirror {
  const Mf3bf9f4cb81cf241();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocLink;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocLink'
class M88fe0e0f047786e7 implements AcMethodMirror {
  const M88fe0e0f047786e7();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocLink;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocLink'
class M3e51152c715764f8 implements AcMethodMirror {
  const M3e51152c715764f8();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocLink'
class M977e1425c82f0e01 implements AcMethodMirror {
  const M977e1425c82f0e01();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_SCHEMA' in class 'AcApiDocMediaType'
class M8aa4f78fe5f562b2 implements AcVariableMirror {
  const M8aa4f78fe5f562b2();
  @override Symbol get simpleName => const Symbol('KEY_SCHEMA');
  @override String getName() => 'KEY_SCHEMA';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXAMPLES' in class 'AcApiDocMediaType'
class Mcbd8594a28fc2b88 implements AcVariableMirror {
  const Mcbd8594a28fc2b88();
  @override Symbol get simpleName => const Symbol('KEY_EXAMPLES');
  @override String getName() => 'KEY_EXAMPLES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'schema' in class 'AcApiDocMediaType'
class Me27ad6c98efa9ace implements AcVariableMirror {
  const Me27ad6c98efa9ace();
  @override Symbol get simpleName => const Symbol('schema');
  @override String getName() => 'schema';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'examples' in class 'AcApiDocMediaType'
class Ma31220393207bdc5 implements AcVariableMirror {
  const Ma31220393207bdc5();
  @override Symbol get simpleName => const Symbol('examples');
  @override String getName() => 'examples';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocMediaType'
class M99fec1149b6819e4 implements AcMethodMirror {
  const M99fec1149b6819e4();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocMediaType;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocMediaType'
class Med124b17ec2e9168 implements AcMethodMirror {
  const Med124b17ec2e9168();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocMediaType;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocMediaType'
class M2550993b98c024ca implements AcMethodMirror {
  const M2550993b98c024ca();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocMediaType'
class M8a5067efe1b06f0d implements AcMethodMirror {
  const M8a5067efe1b06f0d();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_NAME' in class 'AcApiDocModel'
class M18d68821a0b7ac72 implements AcVariableMirror {
  const M18d68821a0b7ac72();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TYPE' in class 'AcApiDocModel'
class M2dcbd259f3b3f580 implements AcVariableMirror {
  const M2dcbd259f3b3f580();
  @override Symbol get simpleName => const Symbol('KEY_TYPE');
  @override String getName() => 'KEY_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PROPERTIES' in class 'AcApiDocModel'
class M6ae1b159d4690c53 implements AcVariableMirror {
  const M6ae1b159d4690c53();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTIES');
  @override String getName() => 'KEY_PROPERTIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'name' in class 'AcApiDocModel'
class M7e9780b3d59e51fe implements AcVariableMirror {
  const M7e9780b3d59e51fe();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'type' in class 'AcApiDocModel'
class M76f611e91f17238d implements AcVariableMirror {
  const M76f611e91f17238d();
  @override Symbol get simpleName => const Symbol('type');
  @override String getName() => 'type';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'properties' in class 'AcApiDocModel'
class M22b19fe49d784861 implements AcVariableMirror {
  const M22b19fe49d784861();
  @override Symbol get simpleName => const Symbol('properties');
  @override String getName() => 'properties';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocModel'
class M79a2b52b6dc7695f implements AcMethodMirror {
  const M79a2b52b6dc7695f();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocModel;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocModel'
class M6f62c53323be1794 implements AcMethodMirror {
  const M6f62c53323be1794();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocModel;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocModel'
class M3a248ffdaea8c127 implements AcMethodMirror {
  const M3a248ffdaea8c127();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocModel'
class Me3fe8716c12f121d implements AcMethodMirror {
  const Me3fe8716c12f121d();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocOperation'
class M8115e0145e35253b implements AcVariableMirror {
  const M8115e0145e35253b();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PARAMETERS' in class 'AcApiDocOperation'
class M7dbcf2923cbf37b5 implements AcVariableMirror {
  const M7dbcf2923cbf37b5();
  @override Symbol get simpleName => const Symbol('KEY_PARAMETERS');
  @override String getName() => 'KEY_PARAMETERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESPONSES' in class 'AcApiDocOperation'
class Mdeab33256aa62da3 implements AcVariableMirror {
  const Mdeab33256aa62da3();
  @override Symbol get simpleName => const Symbol('KEY_RESPONSES');
  @override String getName() => 'KEY_RESPONSES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SUMMARY' in class 'AcApiDocOperation'
class M0655259fb4d07cde implements AcVariableMirror {
  const M0655259fb4d07cde();
  @override Symbol get simpleName => const Symbol('KEY_SUMMARY');
  @override String getName() => 'KEY_SUMMARY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'summary' in class 'AcApiDocOperation'
class Mbe26d51234d61f11 implements AcVariableMirror {
  const Mbe26d51234d61f11();
  @override Symbol get simpleName => const Symbol('summary');
  @override String getName() => 'summary';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocOperation'
class Mfcc48715bfbb4f95 implements AcVariableMirror {
  const Mfcc48715bfbb4f95();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'parameters' in class 'AcApiDocOperation'
class Mafe28f5826d5678f implements AcVariableMirror {
  const Mafe28f5826d5678f();
  @override Symbol get simpleName => const Symbol('parameters');
  @override String getName() => 'parameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'parameters', arrayType: AcApiDocParameter)];
  @override Type get type => List<AcApiDocParameter>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'responses' in class 'AcApiDocOperation'
class Mf20f0b997a4a60d4 implements AcVariableMirror {
  const Mf20f0b997a4a60d4();
  @override Symbol get simpleName => const Symbol('responses');
  @override String getName() => 'responses';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocResponse>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocOperation'
class Me9ce5d99ee180e94 implements AcMethodMirror {
  const Me9ce5d99ee180e94();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocOperation;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocOperation'
class Maf4153956c4f706f implements AcMethodMirror {
  const Maf4153956c4f706f();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocOperation;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocOperation'
class M9c3214b81029557b implements AcMethodMirror {
  const M9c3214b81029557b();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocOperation'
class M63bdbc662224f19b implements AcMethodMirror {
  const M63bdbc662224f19b();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocOperation'
class M0cf568cd6a29ff9a implements AcMethodMirror {
  const M0cf568cd6a29ff9a();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocOperation;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocParameter'
class M537c2de2f866ce3f implements AcVariableMirror {
  const M537c2de2f866ce3f();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXPLODE' in class 'AcApiDocParameter'
class M90d47ec76d1a2ea5 implements AcVariableMirror {
  const M90d47ec76d1a2ea5();
  @override Symbol get simpleName => const Symbol('KEY_EXPLODE');
  @override String getName() => 'KEY_EXPLODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_IN' in class 'AcApiDocParameter'
class Md66f0ff9e6141732 implements AcVariableMirror {
  const Md66f0ff9e6141732();
  @override Symbol get simpleName => const Symbol('KEY_IN');
  @override String getName() => 'KEY_IN';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_NAME' in class 'AcApiDocParameter'
class Mccb11778c0037a93 implements AcVariableMirror {
  const Mccb11778c0037a93();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_REQUIRED' in class 'AcApiDocParameter'
class Md12d72883a170a98 implements AcVariableMirror {
  const Md12d72883a170a98();
  @override Symbol get simpleName => const Symbol('KEY_REQUIRED');
  @override String getName() => 'KEY_REQUIRED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SCHEMA' in class 'AcApiDocParameter'
class M81d327ff6a2ed548 implements AcVariableMirror {
  const M81d327ff6a2ed548();
  @override Symbol get simpleName => const Symbol('KEY_SCHEMA');
  @override String getName() => 'KEY_SCHEMA';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'description' in class 'AcApiDocParameter'
class Mcd32ecf3a62537b3 implements AcVariableMirror {
  const Mcd32ecf3a62537b3();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'inValue' in class 'AcApiDocParameter'
class Mbaf9f9846c1b8733 implements AcVariableMirror {
  const Mbaf9f9846c1b8733();
  @override Symbol get simpleName => const Symbol('inValue');
  @override String getName() => 'inValue';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'in')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'name' in class 'AcApiDocParameter'
class Mcaf0e44f73d44065 implements AcVariableMirror {
  const Mcaf0e44f73d44065();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'required' in class 'AcApiDocParameter'
class M6fa84264833adb2f implements AcVariableMirror {
  const M6fa84264833adb2f();
  @override Symbol get simpleName => const Symbol('required');
  @override String getName() => 'required';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'explode' in class 'AcApiDocParameter'
class Mddfe86963b142612 implements AcVariableMirror {
  const Mddfe86963b142612();
  @override Symbol get simpleName => const Symbol('explode');
  @override String getName() => 'explode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'schema' in class 'AcApiDocParameter'
class Mfc9d2ddd6e084353 implements AcVariableMirror {
  const Mfc9d2ddd6e084353();
  @override Symbol get simpleName => const Symbol('schema');
  @override String getName() => 'schema';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocParameter'
class Ma418e906933cf1bb implements AcMethodMirror {
  const Ma418e906933cf1bb();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocParameter;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocParameter'
class Ma9d21780cc5f616a implements AcMethodMirror {
  const Ma9d21780cc5f616a();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocParameter;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocParameter'
class M61523d86d1e4644d implements AcMethodMirror {
  const M61523d86d1e4644d();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocParameter'
class M3ddbcf8843346c52 implements AcMethodMirror {
  const M3ddbcf8843346c52();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocParameter'
class Mf3070972d03fe0c8 implements AcMethodMirror {
  const Mf3070972d03fe0c8();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocParameter;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_URL' in class 'AcApiDocPath'
class M2a11951f4bd0e5cc implements AcVariableMirror {
  const M2a11951f4bd0e5cc();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONNECT' in class 'AcApiDocPath'
class M808b31b861199e58 implements AcVariableMirror {
  const M808b31b861199e58();
  @override Symbol get simpleName => const Symbol('KEY_CONNECT');
  @override String getName() => 'KEY_CONNECT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_GET' in class 'AcApiDocPath'
class Mad6095b42dee4055 implements AcVariableMirror {
  const Mad6095b42dee4055();
  @override Symbol get simpleName => const Symbol('KEY_GET');
  @override String getName() => 'KEY_GET';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PUT' in class 'AcApiDocPath'
class Me8ab0527f616b182 implements AcVariableMirror {
  const Me8ab0527f616b182();
  @override Symbol get simpleName => const Symbol('KEY_PUT');
  @override String getName() => 'KEY_PUT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_POST' in class 'AcApiDocPath'
class M4027c1cad4acc1ad implements AcVariableMirror {
  const M4027c1cad4acc1ad();
  @override Symbol get simpleName => const Symbol('KEY_POST');
  @override String getName() => 'KEY_POST';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DELETE' in class 'AcApiDocPath'
class M45d37fca23829630 implements AcVariableMirror {
  const M45d37fca23829630();
  @override Symbol get simpleName => const Symbol('KEY_DELETE');
  @override String getName() => 'KEY_DELETE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPTIONS' in class 'AcApiDocPath'
class Md78ea4b0dea6e8e7 implements AcVariableMirror {
  const Md78ea4b0dea6e8e7();
  @override Symbol get simpleName => const Symbol('KEY_OPTIONS');
  @override String getName() => 'KEY_OPTIONS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HEAD' in class 'AcApiDocPath'
class Med55954b0f6ee4db implements AcVariableMirror {
  const Med55954b0f6ee4db();
  @override Symbol get simpleName => const Symbol('KEY_HEAD');
  @override String getName() => 'KEY_HEAD';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PATCH' in class 'AcApiDocPath'
class M8ebd1984eb983bce implements AcVariableMirror {
  const M8ebd1984eb983bce();
  @override Symbol get simpleName => const Symbol('KEY_PATCH');
  @override String getName() => 'KEY_PATCH';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TRACE' in class 'AcApiDocPath'
class M9bb979e7db9f5692 implements AcVariableMirror {
  const M9bb979e7db9f5692();
  @override Symbol get simpleName => const Symbol('KEY_TRACE');
  @override String getName() => 'KEY_TRACE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'url' in class 'AcApiDocPath'
class M2a930bbc367d3493 implements AcVariableMirror {
  const M2a930bbc367d3493();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'connect' in class 'AcApiDocPath'
class Mbdde124ac521b04d implements AcVariableMirror {
  const Mbdde124ac521b04d();
  @override Symbol get simpleName => const Symbol('connect');
  @override String getName() => 'connect';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'get' in class 'AcApiDocPath'
class M603c7113bfc43f21 implements AcVariableMirror {
  const M603c7113bfc43f21();
  @override Symbol get simpleName => const Symbol('get');
  @override String getName() => 'get';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'put' in class 'AcApiDocPath'
class M2760ab04dcfa92da implements AcVariableMirror {
  const M2760ab04dcfa92da();
  @override Symbol get simpleName => const Symbol('put');
  @override String getName() => 'put';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'post' in class 'AcApiDocPath'
class Mb9aca487be52fc81 implements AcVariableMirror {
  const Mb9aca487be52fc81();
  @override Symbol get simpleName => const Symbol('post');
  @override String getName() => 'post';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'delete' in class 'AcApiDocPath'
class M9e4d0109a993721b implements AcVariableMirror {
  const M9e4d0109a993721b();
  @override Symbol get simpleName => const Symbol('delete');
  @override String getName() => 'delete';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'options' in class 'AcApiDocPath'
class M4733bd1c01fdbd0f implements AcVariableMirror {
  const M4733bd1c01fdbd0f();
  @override Symbol get simpleName => const Symbol('options');
  @override String getName() => 'options';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'head' in class 'AcApiDocPath'
class M311f0ac31574f48b implements AcVariableMirror {
  const M311f0ac31574f48b();
  @override Symbol get simpleName => const Symbol('head');
  @override String getName() => 'head';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'patch' in class 'AcApiDocPath'
class M72a5473f0f90f66e implements AcVariableMirror {
  const M72a5473f0f90f66e();
  @override Symbol get simpleName => const Symbol('patch');
  @override String getName() => 'patch';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'trace' in class 'AcApiDocPath'
class M8bea8355be11d879 implements AcVariableMirror {
  const M8bea8355be11d879();
  @override Symbol get simpleName => const Symbol('trace');
  @override String getName() => 'trace';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocPath'
class M8b38d3ac3b358772 implements AcMethodMirror {
  const M8b38d3ac3b358772();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocPath;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocPath'
class Mca1c75d11b27fd7f implements AcMethodMirror {
  const Mca1c75d11b27fd7f();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocPath;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocPath'
class Mcc9ea065e875008d implements AcMethodMirror {
  const Mcc9ea065e875008d();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocPath'
class M2f8c34bc3ed51130 implements AcMethodMirror {
  const M2f8c34bc3ed51130();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocPath'
class Ma715721fe3d47bda implements AcMethodMirror {
  const Ma715721fe3d47bda();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocPath;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocRequestBody'
class M05cb130933268b36 implements AcVariableMirror {
  const M05cb130933268b36();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONTENT' in class 'AcApiDocRequestBody'
class Mf90ba39749bcebab implements AcVariableMirror {
  const Mf90ba39749bcebab();
  @override Symbol get simpleName => const Symbol('KEY_CONTENT');
  @override String getName() => 'KEY_CONTENT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_REQUIRED' in class 'AcApiDocRequestBody'
class Mf979aa7623cdbb8b implements AcVariableMirror {
  const Mf979aa7623cdbb8b();
  @override Symbol get simpleName => const Symbol('KEY_REQUIRED');
  @override String getName() => 'KEY_REQUIRED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'description' in class 'AcApiDocRequestBody'
class M1599af3b14c3c0c4 implements AcVariableMirror {
  const M1599af3b14c3c0c4();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'content' in class 'AcApiDocRequestBody'
class M4a1ac7df78a4eb65 implements AcVariableMirror {
  const M4a1ac7df78a4eb65();
  @override Symbol get simpleName => const Symbol('content');
  @override String getName() => 'content';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocContent>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'required' in class 'AcApiDocRequestBody'
class Mfbe346f8e0f4981d implements AcVariableMirror {
  const Mfbe346f8e0f4981d();
  @override Symbol get simpleName => const Symbol('required');
  @override String getName() => 'required';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocRequestBody'
class Me60dc6e30226433f implements AcMethodMirror {
  const Me60dc6e30226433f();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRequestBody;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocRequestBody'
class M56a2280721ff7b54 implements AcMethodMirror {
  const M56a2280721ff7b54();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRequestBody;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addContent' in class 'AcApiDocRequestBody'
class Mcd89b682c012d42e implements AcMethodMirror {
  const Mcd89b682c012d42e();
  @override Symbol get simpleName => const Symbol('addContent');
  @override String getName() => 'addContent';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocRequestBody'
class Mfaf23088d059f56d implements AcMethodMirror {
  const Mfaf23088d059f56d();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocRequestBody'
class Mb0dd2c1cd7a81789 implements AcMethodMirror {
  const Mb0dd2c1cd7a81789();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocRequestBody'
class Me6b1f191b52b867e implements AcMethodMirror {
  const Me6b1f191b52b867e();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRequestBody;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CODE' in class 'AcApiDocResponse'
class M5740cfe42f4c44d9 implements AcVariableMirror {
  const M5740cfe42f4c44d9();
  @override Symbol get simpleName => const Symbol('KEY_CODE');
  @override String getName() => 'KEY_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocResponse'
class M78d5946a483e84e5 implements AcVariableMirror {
  const M78d5946a483e84e5();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HEADERS' in class 'AcApiDocResponse'
class Mc2a421c100178d99 implements AcVariableMirror {
  const Mc2a421c100178d99();
  @override Symbol get simpleName => const Symbol('KEY_HEADERS');
  @override String getName() => 'KEY_HEADERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONTENT' in class 'AcApiDocResponse'
class M75e950f54b9f7cc9 implements AcVariableMirror {
  const M75e950f54b9f7cc9();
  @override Symbol get simpleName => const Symbol('KEY_CONTENT');
  @override String getName() => 'KEY_CONTENT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_LINKS' in class 'AcApiDocResponse'
class Md71982608f347421 implements AcVariableMirror {
  const Md71982608f347421();
  @override Symbol get simpleName => const Symbol('KEY_LINKS');
  @override String getName() => 'KEY_LINKS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'code' in class 'AcApiDocResponse'
class Mdec0c74ff9a28a85 implements AcVariableMirror {
  const Mdec0c74ff9a28a85();
  @override Symbol get simpleName => const Symbol('code');
  @override String getName() => 'code';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocResponse'
class Mfbc84a9e91484fc7 implements AcVariableMirror {
  const Mfbc84a9e91484fc7();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'headers' in class 'AcApiDocResponse'
class M2c6368040dd3bc89 implements AcVariableMirror {
  const M2c6368040dd3bc89();
  @override Symbol get simpleName => const Symbol('headers');
  @override String getName() => 'headers';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocHeader>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'content' in class 'AcApiDocResponse'
class M3fcb2b623ff4795b implements AcVariableMirror {
  const M3fcb2b623ff4795b();
  @override Symbol get simpleName => const Symbol('content');
  @override String getName() => 'content';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocContent>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'links' in class 'AcApiDocResponse'
class M2c97e80472ac2c9c implements AcVariableMirror {
  const M2c97e80472ac2c9c();
  @override Symbol get simpleName => const Symbol('links');
  @override String getName() => 'links';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, AcApiDocLink>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocResponse'
class M0ac58d408ebed183 implements AcMethodMirror {
  const M0ac58d408ebed183();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addContent' in class 'AcApiDocResponse'
class M5a5b998f180be9eb implements AcMethodMirror {
  const M5a5b998f180be9eb();
  @override Symbol get simpleName => const Symbol('addContent');
  @override String getName() => 'addContent';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => dynamic;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocResponse'
class M0573079cc0217cc5 implements AcMethodMirror {
  const M0573079cc0217cc5();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocResponse'
class M92e8c4e800f78743 implements AcMethodMirror {
  const M92e8c4e800f78743();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocResponse'
class M2f9c3e6d78323882 implements AcMethodMirror {
  const M2f9c3e6d78323882();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocResponse'
class M1d544d2fb9edc0a8 implements AcMethodMirror {
  const M1d544d2fb9edc0a8();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocResponse;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_TAGS' in class 'AcApiDocRoute'
class Mb272e33113c0b1bf implements AcVariableMirror {
  const Mb272e33113c0b1bf();
  @override Symbol get simpleName => const Symbol('KEY_TAGS');
  @override String getName() => 'KEY_TAGS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SUMMARY' in class 'AcApiDocRoute'
class Mc895a8fa6df0d3ef implements AcVariableMirror {
  const Mc895a8fa6df0d3ef();
  @override Symbol get simpleName => const Symbol('KEY_SUMMARY');
  @override String getName() => 'KEY_SUMMARY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocRoute'
class M09dcc36a1e006c0e implements AcVariableMirror {
  const M09dcc36a1e006c0e();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPERATION_ID' in class 'AcApiDocRoute'
class Ma9dfb0d556228907 implements AcVariableMirror {
  const Ma9dfb0d556228907();
  @override Symbol get simpleName => const Symbol('KEY_OPERATION_ID');
  @override String getName() => 'KEY_OPERATION_ID';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PARAMETERS' in class 'AcApiDocRoute'
class M0e86e439945087b7 implements AcVariableMirror {
  const M0e86e439945087b7();
  @override Symbol get simpleName => const Symbol('KEY_PARAMETERS');
  @override String getName() => 'KEY_PARAMETERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_REQUEST_BODY' in class 'AcApiDocRoute'
class M8341684c832825e4 implements AcVariableMirror {
  const M8341684c832825e4();
  @override Symbol get simpleName => const Symbol('KEY_REQUEST_BODY');
  @override String getName() => 'KEY_REQUEST_BODY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESPONSES' in class 'AcApiDocRoute'
class Mca7cab942e58f1a5 implements AcVariableMirror {
  const Mca7cab942e58f1a5();
  @override Symbol get simpleName => const Symbol('KEY_RESPONSES');
  @override String getName() => 'KEY_RESPONSES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONSUMES' in class 'AcApiDocRoute'
class M159d4f2aa62cc8cc implements AcVariableMirror {
  const M159d4f2aa62cc8cc();
  @override Symbol get simpleName => const Symbol('KEY_CONSUMES');
  @override String getName() => 'KEY_CONSUMES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PRODUCES' in class 'AcApiDocRoute'
class Mf4f8b63c851099f6 implements AcVariableMirror {
  const Mf4f8b63c851099f6();
  @override Symbol get simpleName => const Symbol('KEY_PRODUCES');
  @override String getName() => 'KEY_PRODUCES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DEPRECATED' in class 'AcApiDocRoute'
class Mffa812b27531e86c implements AcVariableMirror {
  const Mffa812b27531e86c();
  @override Symbol get simpleName => const Symbol('KEY_DEPRECATED');
  @override String getName() => 'KEY_DEPRECATED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SECURITY' in class 'AcApiDocRoute'
class M2ea15d0841769e4f implements AcVariableMirror {
  const M2ea15d0841769e4f();
  @override Symbol get simpleName => const Symbol('KEY_SECURITY');
  @override String getName() => 'KEY_SECURITY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'tags' in class 'AcApiDocRoute'
class M02bc30c534bb63ef implements AcVariableMirror {
  const M02bc30c534bb63ef();
  @override Symbol get simpleName => const Symbol('tags');
  @override String getName() => 'tags';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'summary' in class 'AcApiDocRoute'
class M640d652988c20f45 implements AcVariableMirror {
  const M640d652988c20f45();
  @override Symbol get simpleName => const Symbol('summary');
  @override String getName() => 'summary';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocRoute'
class M75b5c61fe0bf7594 implements AcVariableMirror {
  const M75b5c61fe0bf7594();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'operationId' in class 'AcApiDocRoute'
class M0bac4baa7c372109 implements AcVariableMirror {
  const M0bac4baa7c372109();
  @override Symbol get simpleName => const Symbol('operationId');
  @override String getName() => 'operationId';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'parameters' in class 'AcApiDocRoute'
class M5ddb54f0566ef0db implements AcVariableMirror {
  const M5ddb54f0566ef0db();
  @override Symbol get simpleName => const Symbol('parameters');
  @override String getName() => 'parameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<AcApiDocParameter>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'requestBody' in class 'AcApiDocRoute'
class Me6b0c0ff763e248e implements AcVariableMirror {
  const Me6b0c0ff763e248e();
  @override Symbol get simpleName => const Symbol('requestBody');
  @override String getName() => 'requestBody';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRequestBody;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'responses' in class 'AcApiDocRoute'
class M3b2c492a0339efbb implements AcVariableMirror {
  const M3b2c492a0339efbb();
  @override Symbol get simpleName => const Symbol('responses');
  @override String getName() => 'responses';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<AcApiDocResponse>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'consumes' in class 'AcApiDocRoute'
class Md8de352ce9783445 implements AcVariableMirror {
  const Md8de352ce9783445();
  @override Symbol get simpleName => const Symbol('consumes');
  @override String getName() => 'consumes';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'produces' in class 'AcApiDocRoute'
class Mba60ff4ff97fcdfb implements AcVariableMirror {
  const Mba60ff4ff97fcdfb();
  @override Symbol get simpleName => const Symbol('produces');
  @override String getName() => 'produces';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'deprecated' in class 'AcApiDocRoute'
class M49b7240dcec6dc0f implements AcVariableMirror {
  const M49b7240dcec6dc0f();
  @override Symbol get simpleName => const Symbol('deprecated');
  @override String getName() => 'deprecated';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => bool;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'security' in class 'AcApiDocRoute'
class Me1f2fd0570b8e4e4 implements AcVariableMirror {
  const Me1f2fd0570b8e4e4();
  @override Symbol get simpleName => const Symbol('security');
  @override String getName() => 'security';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocRoute'
class Md51dc28aa674682e implements AcMethodMirror {
  const Md51dc28aa674682e();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocRoute'
class Md565afd55f963ac1 implements AcMethodMirror {
  const Md565afd55f963ac1();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addParameter' in class 'AcApiDocRoute'
class Mec93c1f73f362d12 implements AcMethodMirror {
  const Mec93c1f73f362d12();
  @override Symbol get simpleName => const Symbol('addParameter');
  @override String getName() => 'addParameter';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addResponse' in class 'AcApiDocRoute'
class M960130c282a914ad implements AcMethodMirror {
  const M960130c282a914ad();
  @override Symbol get simpleName => const Symbol('addResponse');
  @override String getName() => 'addResponse';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'addTag' in class 'AcApiDocRoute'
class M326bcfc9fe8e3535 implements AcMethodMirror {
  const M326bcfc9fe8e3535();
  @override Symbol get simpleName => const Symbol('addTag');
  @override String getName() => 'addTag';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocRoute'
class Mc395c8385b880178 implements AcMethodMirror {
  const Mc395c8385b880178();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocRoute'
class Me2e58daba531f1c0 implements AcMethodMirror {
  const Me2e58daba531f1c0();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocRoute'
class Ma34b28261f04c425 implements AcMethodMirror {
  const Ma34b28261f04c425();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocRoute;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_TYPE' in class 'AcApiDocSchema'
class Mda6ea4092f33cd63 implements AcVariableMirror {
  const Mda6ea4092f33cd63();
  @override Symbol get simpleName => const Symbol('KEY_TYPE');
  @override String getName() => 'KEY_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_FORMAT' in class 'AcApiDocSchema'
class Mf0e6f88d99e7ccc5 implements AcVariableMirror {
  const Mf0e6f88d99e7ccc5();
  @override Symbol get simpleName => const Symbol('KEY_FORMAT');
  @override String getName() => 'KEY_FORMAT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TITLE' in class 'AcApiDocSchema'
class M9079561e836f8360 implements AcVariableMirror {
  const M9079561e836f8360();
  @override Symbol get simpleName => const Symbol('KEY_TITLE');
  @override String getName() => 'KEY_TITLE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocSchema'
class M1074330d11f2642f implements AcVariableMirror {
  const M1074330d11f2642f();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PROPERTIES' in class 'AcApiDocSchema'
class M916a8b88b2a0e893 implements AcVariableMirror {
  const M916a8b88b2a0e893();
  @override Symbol get simpleName => const Symbol('KEY_PROPERTIES');
  @override String getName() => 'KEY_PROPERTIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_REQUIRED' in class 'AcApiDocSchema'
class M9bff556a14bd7f89 implements AcVariableMirror {
  const M9bff556a14bd7f89();
  @override Symbol get simpleName => const Symbol('KEY_REQUIRED');
  @override String getName() => 'KEY_REQUIRED';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_ITEMS' in class 'AcApiDocSchema'
class M5699acedf504800e implements AcVariableMirror {
  const M5699acedf504800e();
  @override Symbol get simpleName => const Symbol('KEY_ITEMS');
  @override String getName() => 'KEY_ITEMS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_ENUM' in class 'AcApiDocSchema'
class Mddad70746d6bb5b6 implements AcVariableMirror {
  const Mddad70746d6bb5b6();
  @override Symbol get simpleName => const Symbol('KEY_ENUM');
  @override String getName() => 'KEY_ENUM';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'type' in class 'AcApiDocSchema'
class M21bfa7195afed747 implements AcVariableMirror {
  const M21bfa7195afed747();
  @override Symbol get simpleName => const Symbol('type');
  @override String getName() => 'type';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'format' in class 'AcApiDocSchema'
class Me559682be0e64f20 implements AcVariableMirror {
  const Me559682be0e64f20();
  @override Symbol get simpleName => const Symbol('format');
  @override String getName() => 'format';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'title' in class 'AcApiDocSchema'
class Mce3ce5f0cdf818d2 implements AcVariableMirror {
  const Mce3ce5f0cdf818d2();
  @override Symbol get simpleName => const Symbol('title');
  @override String getName() => 'title';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocSchema'
class M707df3cbc092b5f1 implements AcVariableMirror {
  const M707df3cbc092b5f1();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'properties' in class 'AcApiDocSchema'
class M3420c9ff13b58f35 implements AcVariableMirror {
  const M3420c9ff13b58f35();
  @override Symbol get simpleName => const Symbol('properties');
  @override String getName() => 'properties';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'required' in class 'AcApiDocSchema'
class M8ac1687624b3bf67 implements AcVariableMirror {
  const M8ac1687624b3bf67();
  @override Symbol get simpleName => const Symbol('required');
  @override String getName() => 'required';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<String>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'items' in class 'AcApiDocSchema'
class M754dd5d1d39add7a implements AcVariableMirror {
  const M754dd5d1d39add7a();
  @override Symbol get simpleName => const Symbol('items');
  @override String getName() => 'items';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'enumValues' in class 'AcApiDocSchema'
class Me9ea0524886f02c2 implements AcVariableMirror {
  const Me9ea0524886f02c2();
  @override Symbol get simpleName => const Symbol('enumValues');
  @override String getName() => 'enumValues';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocSchema'
class M87c168628e237c77 implements AcMethodMirror {
  const M87c168628e237c77();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSchema;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocSchema'
class Md7b0679141aafa53 implements AcMethodMirror {
  const Md7b0679141aafa53();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSchema;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocSchema'
class M4c1131b6758d377c implements AcMethodMirror {
  const M4c1131b6758d377c();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocSchema'
class Mda26ef9fcc3738fa implements AcMethodMirror {
  const Mda26ef9fcc3738fa();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocSchema'
class M3fe35d2ae26f1ffc implements AcMethodMirror {
  const M3fe35d2ae26f1ffc();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSchema;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_REQUIREMENTS' in class 'AcApiDocSecurityRequirement'
class Ma89b57344343d154 implements AcVariableMirror {
  const Ma89b57344343d154();
  @override Symbol get simpleName => const Symbol('KEY_REQUIREMENTS');
  @override String getName() => 'KEY_REQUIREMENTS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'requirements' in class 'AcApiDocSecurityRequirement'
class Mde4646d95fdcdeb1 implements AcVariableMirror {
  const Mde4646d95fdcdeb1();
  @override Symbol get simpleName => const Symbol('requirements');
  @override String getName() => 'requirements';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocSecurityRequirement'
class M9df224c01abef487 implements AcMethodMirror {
  const M9df224c01abef487();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityRequirement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocSecurityRequirement'
class M8777f04e8c5ce542 implements AcMethodMirror {
  const M8777f04e8c5ce542();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityRequirement;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocSecurityRequirement'
class M069b48db74052b52 implements AcMethodMirror {
  const M069b48db74052b52();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocSecurityRequirement'
class Ma049ce68a2ed0d24 implements AcMethodMirror {
  const Ma049ce68a2ed0d24();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocSecurityRequirement'
class M7223b0b4424857d4 implements AcMethodMirror {
  const M7223b0b4424857d4();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityRequirement;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_TYPE' in class 'AcApiDocSecurityScheme'
class M57c8f5086e64886f implements AcVariableMirror {
  const M57c8f5086e64886f();
  @override Symbol get simpleName => const Symbol('KEY_TYPE');
  @override String getName() => 'KEY_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocSecurityScheme'
class M2e6e195659337c03 implements AcVariableMirror {
  const M2e6e195659337c03();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_NAME' in class 'AcApiDocSecurityScheme'
class M2faa3b71ea1f648a implements AcVariableMirror {
  const M2faa3b71ea1f648a();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_IN' in class 'AcApiDocSecurityScheme'
class Md0b93ad315a9ae22 implements AcVariableMirror {
  const Md0b93ad315a9ae22();
  @override Symbol get simpleName => const Symbol('KEY_IN');
  @override String getName() => 'KEY_IN';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SCHEME' in class 'AcApiDocSecurityScheme'
class M96f870dcd76affc2 implements AcVariableMirror {
  const M96f870dcd76affc2();
  @override Symbol get simpleName => const Symbol('KEY_SCHEME');
  @override String getName() => 'KEY_SCHEME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_BEARER_FORMAT' in class 'AcApiDocSecurityScheme'
class M9f10f7fd5d63a930 implements AcVariableMirror {
  const M9f10f7fd5d63a930();
  @override Symbol get simpleName => const Symbol('KEY_BEARER_FORMAT');
  @override String getName() => 'KEY_BEARER_FORMAT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_FLOWS' in class 'AcApiDocSecurityScheme'
class M42dc09340666049a implements AcVariableMirror {
  const M42dc09340666049a();
  @override Symbol get simpleName => const Symbol('KEY_FLOWS');
  @override String getName() => 'KEY_FLOWS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_OPENID_CONNECT_URL' in class 'AcApiDocSecurityScheme'
class Mf4e55bd8f5b31dca implements AcVariableMirror {
  const Mf4e55bd8f5b31dca();
  @override Symbol get simpleName => const Symbol('KEY_OPENID_CONNECT_URL');
  @override String getName() => 'KEY_OPENID_CONNECT_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'type' in class 'AcApiDocSecurityScheme'
class M543866960bf126b4 implements AcVariableMirror {
  const M543866960bf126b4();
  @override Symbol get simpleName => const Symbol('type');
  @override String getName() => 'type';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocSecurityScheme'
class M99f86f117ccd9a9f implements AcVariableMirror {
  const M99f86f117ccd9a9f();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'name' in class 'AcApiDocSecurityScheme'
class Mf0e9f76e8071c8d8 implements AcVariableMirror {
  const Mf0e9f76e8071c8d8();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'in_' in class 'AcApiDocSecurityScheme'
class M72b32274ae3a02a7 implements AcVariableMirror {
  const M72b32274ae3a02a7();
  @override Symbol get simpleName => const Symbol('in_');
  @override String getName() => 'in_';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'scheme' in class 'AcApiDocSecurityScheme'
class Me77badfb01326c93 implements AcVariableMirror {
  const Me77badfb01326c93();
  @override Symbol get simpleName => const Symbol('scheme');
  @override String getName() => 'scheme';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'bearerFormat' in class 'AcApiDocSecurityScheme'
class Md1e8b7af196ba1ce implements AcVariableMirror {
  const Md1e8b7af196ba1ce();
  @override Symbol get simpleName => const Symbol('bearerFormat');
  @override String getName() => 'bearerFormat';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'flows' in class 'AcApiDocSecurityScheme'
class Mcc0055b41ab8ea28 implements AcVariableMirror {
  const Mcc0055b41ab8ea28();
  @override Symbol get simpleName => const Symbol('flows');
  @override String getName() => 'flows';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => List<dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'openIdConnectUrl' in class 'AcApiDocSecurityScheme'
class M45f1f52285ac305d implements AcVariableMirror {
  const M45f1f52285ac305d();
  @override Symbol get simpleName => const Symbol('openIdConnectUrl');
  @override String getName() => 'openIdConnectUrl';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocSecurityScheme'
class M8f354200a2b514eb implements AcMethodMirror {
  const M8f354200a2b514eb();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityScheme;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocSecurityScheme'
class M944bd1e26a53005d implements AcMethodMirror {
  const M944bd1e26a53005d();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityScheme;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocSecurityScheme'
class M0d18e0533ecff9e0 implements AcMethodMirror {
  const M0d18e0533ecff9e0();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocSecurityScheme'
class Mdf27f29ded041be7 implements AcMethodMirror {
  const Mdf27f29ded041be7();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocSecurityScheme'
class M7f653c41f10d6f5c implements AcMethodMirror {
  const M7f653c41f10d6f5c();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocSecurityScheme;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocServer'
class M9ba271dc0429675d implements AcVariableMirror {
  const M9ba271dc0429675d();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_TITLE' in class 'AcApiDocServer'
class Me33ef7ddb1ed50b6 implements AcVariableMirror {
  const Me33ef7ddb1ed50b6();
  @override Symbol get simpleName => const Symbol('KEY_TITLE');
  @override String getName() => 'KEY_TITLE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcApiDocServer'
class M79eb4001b52b509b implements AcVariableMirror {
  const M79eb4001b52b509b();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'description' in class 'AcApiDocServer'
class M71cb2e5e44abe58b implements AcVariableMirror {
  const M71cb2e5e44abe58b();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'title' in class 'AcApiDocServer'
class Md6d9cc3b384cd38d implements AcVariableMirror {
  const Md6d9cc3b384cd38d();
  @override Symbol get simpleName => const Symbol('title');
  @override String getName() => 'title';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcApiDocServer'
class M115917123e74c3a3 implements AcVariableMirror {
  const M115917123e74c3a3();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocServer'
class Mfda998d1b77bec1f implements AcMethodMirror {
  const Mfda998d1b77bec1f();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocServer;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocServer'
class M5fb8cecd36b3f44d implements AcMethodMirror {
  const M5fb8cecd36b3f44d();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocServer;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocServer'
class Mb7494c526c42d241 implements AcMethodMirror {
  const Mb7494c526c42d241();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocServer'
class Mb666766f30a52dfa implements AcMethodMirror {
  const Mb666766f30a52dfa();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocServer'
class M1294ce2dc502f60e implements AcMethodMirror {
  const M1294ce2dc502f60e();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocServer;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_NAME' in class 'AcApiDocTag'
class M9931a8f8518f9b74 implements AcVariableMirror {
  const M9931a8f8518f9b74();
  @override Symbol get simpleName => const Symbol('KEY_NAME');
  @override String getName() => 'KEY_NAME';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DESCRIPTION' in class 'AcApiDocTag'
class M21a3d2e7be9d4fbb implements AcVariableMirror {
  const M21a3d2e7be9d4fbb();
  @override Symbol get simpleName => const Symbol('KEY_DESCRIPTION');
  @override String getName() => 'KEY_DESCRIPTION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_EXTERNAL_DOCS' in class 'AcApiDocTag'
class M3359486dd7b6bffe implements AcVariableMirror {
  const M3359486dd7b6bffe();
  @override Symbol get simpleName => const Symbol('KEY_EXTERNAL_DOCS');
  @override String getName() => 'KEY_EXTERNAL_DOCS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'name' in class 'AcApiDocTag'
class M72f6557db3e83ceb implements AcVariableMirror {
  const M72f6557db3e83ceb();
  @override Symbol get simpleName => const Symbol('name');
  @override String getName() => 'name';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'description' in class 'AcApiDocTag'
class Md7cdcfc8f103f5df implements AcVariableMirror {
  const Md7cdcfc8f103f5df();
  @override Symbol get simpleName => const Symbol('description');
  @override String getName() => 'description';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'externalDocs' in class 'AcApiDocTag'
class M4609063ae1597f37 implements AcVariableMirror {
  const M4609063ae1597f37();
  @override Symbol get simpleName => const Symbol('externalDocs');
  @override String getName() => 'externalDocs';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'externalDocs')];
  @override Type get type => AcApiDocExternalDocs;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcApiDocTag'
class M83a8b7601702b5a2 implements AcMethodMirror {
  const M83a8b7601702b5a2();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocTag;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcApiDocTag'
class Mf4eedf40dc188659 implements AcMethodMirror {
  const Mf4eedf40dc188659();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocTag;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcApiDocTag'
class M11212360d3f8f4ab implements AcMethodMirror {
  const M11212360d3f8f4ab();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcApiDocTag'
class Me1efdbfe9a61fb62 implements AcMethodMirror {
  const Me1efdbfe9a61fb62();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for constructor '' in class 'AcApiDocTag'
class M8a92ab8308bc17c9 implements AcMethodMirror {
  const M8a92ab8308bc17c9();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcApiDocTag;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}


// Mirror for field 'acWeb' in class 'AcWebHookCreatedArgs'
class M07a06972d1620730 implements AcVariableMirror {
  const M07a06972d1620730();
  @override Symbol get simpleName => const Symbol('acWeb');
  @override String getName() => 'acWeb';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcWeb;
  @override bool get isFinal => true;
  @override bool get isConst => false;
}
// Mirror for constructor '' in class 'AcWebHookCreatedArgs'
class M458afe870b81b575 implements AcMethodMirror {
  const M458afe870b81b575();
  @override Symbol get simpleName => const Symbol('');
  @override String getName() => '';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebHookCreatedArgs;
  @override bool get isConstructor => true;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_COOKIES' in class 'AcWebRequest'
class M7418a406760823a1 implements AcVariableMirror {
  const M7418a406760823a1();
  @override Symbol get simpleName => const Symbol('KEY_COOKIES');
  @override String getName() => 'KEY_COOKIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_BODY' in class 'AcWebRequest'
class Me3ae618514e0680c implements AcVariableMirror {
  const Me3ae618514e0680c();
  @override Symbol get simpleName => const Symbol('KEY_BODY');
  @override String getName() => 'KEY_BODY';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_FILES' in class 'AcWebRequest'
class Me6ae5017fffeb884 implements AcVariableMirror {
  const Me6ae5017fffeb884();
  @override Symbol get simpleName => const Symbol('KEY_FILES');
  @override String getName() => 'KEY_FILES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_GET' in class 'AcWebRequest'
class Mc57450b5f20729d8 implements AcVariableMirror {
  const Mc57450b5f20729d8();
  @override Symbol get simpleName => const Symbol('KEY_GET');
  @override String getName() => 'KEY_GET';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HEADERS' in class 'AcWebRequest'
class Mb760fd5112d31a17 implements AcVariableMirror {
  const Mb760fd5112d31a17();
  @override Symbol get simpleName => const Symbol('KEY_HEADERS');
  @override String getName() => 'KEY_HEADERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_METHOD' in class 'AcWebRequest'
class M3258403b4fd719fd implements AcVariableMirror {
  const M3258403b4fd719fd();
  @override Symbol get simpleName => const Symbol('KEY_METHOD');
  @override String getName() => 'KEY_METHOD';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_PATH_PAREMETERS' in class 'AcWebRequest'
class M6caf512624276939 implements AcVariableMirror {
  const M6caf512624276939();
  @override Symbol get simpleName => const Symbol('KEY_PATH_PAREMETERS');
  @override String getName() => 'KEY_PATH_PAREMETERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_POST' in class 'AcWebRequest'
class Me12a594f93222909 implements AcVariableMirror {
  const Me12a594f93222909();
  @override Symbol get simpleName => const Symbol('KEY_POST');
  @override String getName() => 'KEY_POST';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SESSION' in class 'AcWebRequest'
class M28d536680fa74fb2 implements AcVariableMirror {
  const M28d536680fa74fb2();
  @override Symbol get simpleName => const Symbol('KEY_SESSION');
  @override String getName() => 'KEY_SESSION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcWebRequest'
class Ma40dc9c66db00c21 implements AcVariableMirror {
  const Ma40dc9c66db00c21();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'body' in class 'AcWebRequest'
class M211dfbc211ff3394 implements AcVariableMirror {
  const M211dfbc211ff3394();
  @override Symbol get simpleName => const Symbol('body');
  @override String getName() => 'body';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'cookies' in class 'AcWebRequest'
class Mb682f5df3b1e41ab implements AcVariableMirror {
  const Mb682f5df3b1e41ab();
  @override Symbol get simpleName => const Symbol('cookies');
  @override String getName() => 'cookies';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'files' in class 'AcWebRequest'
class Ma7be951be626f730 implements AcVariableMirror {
  const Ma7be951be626f730();
  @override Symbol get simpleName => const Symbol('files');
  @override String getName() => 'files';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'get' in class 'AcWebRequest'
class M18660e0ef1a39405 implements AcVariableMirror {
  const M18660e0ef1a39405();
  @override Symbol get simpleName => const Symbol('get');
  @override String getName() => 'get';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'headers' in class 'AcWebRequest'
class M464b7e0119422661 implements AcVariableMirror {
  const M464b7e0119422661();
  @override Symbol get simpleName => const Symbol('headers');
  @override String getName() => 'headers';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'method' in class 'AcWebRequest'
class Mc428f45bcfbf45f9 implements AcVariableMirror {
  const Mc428f45bcfbf45f9();
  @override Symbol get simpleName => const Symbol('method');
  @override String getName() => 'method';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'pathParameters' in class 'AcWebRequest'
class Mb4a78e16d2a00a23 implements AcVariableMirror {
  const Mb4a78e16d2a00a23();
  @override Symbol get simpleName => const Symbol('pathParameters');
  @override String getName() => 'pathParameters';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'post' in class 'AcWebRequest'
class M72f33d767a3aeb67 implements AcVariableMirror {
  const M72f33d767a3aeb67();
  @override Symbol get simpleName => const Symbol('post');
  @override String getName() => 'post';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'session' in class 'AcWebRequest'
class M497256d07e944edd implements AcVariableMirror {
  const M497256d07e944edd();
  @override Symbol get simpleName => const Symbol('session');
  @override String getName() => 'session';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcWebRequest'
class M38d6a6138678a65a implements AcVariableMirror {
  const M38d6a6138678a65a();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcWebRequest'
class Mf7b96f64bae980eb implements AcMethodMirror {
  const Mf7b96f64bae980eb();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRequest;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcWebRequest'
class M5ccdb55d8d1115d1 implements AcMethodMirror {
  const M5ccdb55d8d1115d1();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRequest;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcWebRequest'
class M4a69930d48ae7faf implements AcMethodMirror {
  const M4a69930d48ae7faf();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcWebRequest'
class M092f26b4af4d492c implements AcMethodMirror {
  const M092f26b4af4d492c();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_COOKIES' in class 'AcWebResponse'
class Me28be97acd6a2640 implements AcVariableMirror {
  const Me28be97acd6a2640();
  @override Symbol get simpleName => const Symbol('KEY_COOKIES');
  @override String getName() => 'KEY_COOKIES';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_CONTENT' in class 'AcWebResponse'
class M931844f07d30121c implements AcVariableMirror {
  const M931844f07d30121c();
  @override Symbol get simpleName => const Symbol('KEY_CONTENT');
  @override String getName() => 'KEY_CONTENT';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HEADERS' in class 'AcWebResponse'
class M627edca5433799fa implements AcVariableMirror {
  const M627edca5433799fa();
  @override Symbol get simpleName => const Symbol('KEY_HEADERS');
  @override String getName() => 'KEY_HEADERS';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESPONSE_CODE' in class 'AcWebResponse'
class M4027f19aeb8af921 implements AcVariableMirror {
  const M4027f19aeb8af921();
  @override Symbol get simpleName => const Symbol('KEY_RESPONSE_CODE');
  @override String getName() => 'KEY_RESPONSE_CODE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_RESPONSE_TYPE' in class 'AcWebResponse'
class Mda682cea3b7c2879 implements AcVariableMirror {
  const Mda682cea3b7c2879();
  @override Symbol get simpleName => const Symbol('KEY_RESPONSE_TYPE');
  @override String getName() => 'KEY_RESPONSE_TYPE';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_SESSION' in class 'AcWebResponse'
class M8ac276bb1743bbe9 implements AcVariableMirror {
  const M8ac276bb1743bbe9();
  @override Symbol get simpleName => const Symbol('KEY_SESSION');
  @override String getName() => 'KEY_SESSION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'cookies' in class 'AcWebResponse'
class M3b540ea495e3043e implements AcVariableMirror {
  const M3b540ea495e3043e();
  @override Symbol get simpleName => const Symbol('cookies');
  @override String getName() => 'cookies';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'content' in class 'AcWebResponse'
class Maa469c892724e62d implements AcVariableMirror {
  const Maa469c892724e62d();
  @override Symbol get simpleName => const Symbol('content');
  @override String getName() => 'content';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'headers' in class 'AcWebResponse'
class Mbcefa3df9fcfd3a3 implements AcVariableMirror {
  const Mbcefa3df9fcfd3a3();
  @override Symbol get simpleName => const Symbol('headers');
  @override String getName() => 'headers';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'responseCode' in class 'AcWebResponse'
class Mb68dbf5422910755 implements AcVariableMirror {
  const Mb68dbf5422910755();
  @override Symbol get simpleName => const Symbol('responseCode');
  @override String getName() => 'responseCode';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'response_code')];
  @override Type get type => int;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'responseType' in class 'AcWebResponse'
class M78826b98bda98f6d implements AcVariableMirror {
  const M78826b98bda98f6d();
  @override Symbol get simpleName => const Symbol('responseType');
  @override String getName() => 'responseType';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [const AcBindJsonProperty(key: 'response_type')];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'session' in class 'AcWebResponse'
class M53838207dc396c01 implements AcVariableMirror {
  const M53838207dc396c01();
  @override Symbol get simpleName => const Symbol('session');
  @override String getName() => 'session';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => Map<String, dynamic>;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'internalError' in class 'AcWebResponse'
class Mcbbbf532e1555c31 implements AcMethodMirror {
  const Mcbbbf532e1555c31();
  @override Symbol get simpleName => const Symbol('internalError');
  @override String getName() => 'internalError';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'json' in class 'AcWebResponse'
class M914679ec4e1961d7 implements AcMethodMirror {
  const M914679ec4e1961d7();
  @override Symbol get simpleName => const Symbol('json');
  @override String getName() => 'json';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'notFound' in class 'AcWebResponse'
class M9abfa68205bb5c43 implements AcMethodMirror {
  const M9abfa68205bb5c43();
  @override Symbol get simpleName => const Symbol('notFound');
  @override String getName() => 'notFound';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'raw' in class 'AcWebResponse'
class M0d4330e287745b3e implements AcMethodMirror {
  const M0d4330e287745b3e();
  @override Symbol get simpleName => const Symbol('raw');
  @override String getName() => 'raw';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'redirect' in class 'AcWebResponse'
class M9a56959364c8a60b implements AcMethodMirror {
  const M9a56959364c8a60b();
  @override Symbol get simpleName => const Symbol('redirect');
  @override String getName() => 'redirect';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'view' in class 'AcWebResponse'
class M120819f2d824029f implements AcMethodMirror {
  const M120819f2d824029f();
  @override Symbol get simpleName => const Symbol('view');
  @override String getName() => 'view';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcWebResponse'
class M5c3d31a3c022342b implements AcMethodMirror {
  const M5c3d31a3c022342b();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebResponse;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcWebResponse'
class M18ae0b024a124370 implements AcMethodMirror {
  const M18ae0b024a124370();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcWebResponse'
class M60095219ebbbb372 implements AcMethodMirror {
  const M60095219ebbbb372();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for field 'KEY_CONTROLLER' in class 'AcWebRouteDefinition'
class Mb77d37a6ce72f10b implements AcVariableMirror {
  const Mb77d37a6ce72f10b();
  @override Symbol get simpleName => const Symbol('KEY_CONTROLLER');
  @override String getName() => 'KEY_CONTROLLER';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_HANDLER' in class 'AcWebRouteDefinition'
class Me3b58f1631033efa implements AcVariableMirror {
  const Me3b58f1631033efa();
  @override Symbol get simpleName => const Symbol('KEY_HANDLER');
  @override String getName() => 'KEY_HANDLER';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_DOCUMENTATION' in class 'AcWebRouteDefinition'
class Mac676813a32617f7 implements AcVariableMirror {
  const Mac676813a32617f7();
  @override Symbol get simpleName => const Symbol('KEY_DOCUMENTATION');
  @override String getName() => 'KEY_DOCUMENTATION';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_METHOD' in class 'AcWebRouteDefinition'
class Mf95c69c60522725a implements AcVariableMirror {
  const Mf95c69c60522725a();
  @override Symbol get simpleName => const Symbol('KEY_METHOD');
  @override String getName() => 'KEY_METHOD';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'KEY_URL' in class 'AcWebRouteDefinition'
class M4a58110353bf1cd5 implements AcVariableMirror {
  const M4a58110353bf1cd5();
  @override Symbol get simpleName => const Symbol('KEY_URL');
  @override String getName() => 'KEY_URL';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => true;
}
// Mirror for field 'controller' in class 'AcWebRouteDefinition'
class M9f5216d42f8766c6 implements AcVariableMirror {
  const M9f5216d42f8766c6();
  @override Symbol get simpleName => const Symbol('controller');
  @override String getName() => 'controller';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'handler' in class 'AcWebRouteDefinition'
class M92264e97bca8ae52 implements AcVariableMirror {
  const M92264e97bca8ae52();
  @override Symbol get simpleName => const Symbol('handler');
  @override String getName() => 'handler';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => dynamic;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'documentation' in class 'AcWebRouteDefinition'
class Mb1a0095ea15f2b74 implements AcVariableMirror {
  const Mb1a0095ea15f2b74();
  @override Symbol get simpleName => const Symbol('documentation');
  @override String getName() => 'documentation';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => AcApiDocRoute;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'method' in class 'AcWebRouteDefinition'
class M916f946984a64e17 implements AcVariableMirror {
  const M916f946984a64e17();
  @override Symbol get simpleName => const Symbol('method');
  @override String getName() => 'method';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for field 'url' in class 'AcWebRouteDefinition'
class Ma5fd545a52ff4eb0 implements AcVariableMirror {
  const Ma5fd545a52ff4eb0();
  @override Symbol get simpleName => const Symbol('url');
  @override String getName() => 'url';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get type => String;
  @override bool get isFinal => false;
  @override bool get isConst => false;
}
// Mirror for method 'instanceFromJson' in class 'AcWebRouteDefinition'
class Mf4e6d6cb2012ed4a implements AcMethodMirror {
  const Mf4e6d6cb2012ed4a();
  @override Symbol get simpleName => const Symbol('instanceFromJson');
  @override String getName() => 'instanceFromJson';
  @override bool get isStatic => true;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteDefinition;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'fromJson' in class 'AcWebRouteDefinition'
class Mdde683f4b3804407 implements AcMethodMirror {
  const Mdde683f4b3804407();
  @override Symbol get simpleName => const Symbol('fromJson');
  @override String getName() => 'fromJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => AcWebRouteDefinition;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toJson' in class 'AcWebRouteDefinition'
class M2966903212510efe implements AcMethodMirror {
  const M2966903212510efe();
  @override Symbol get simpleName => const Symbol('toJson');
  @override String getName() => 'toJson';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [];
  @override Type get returnType => Map<String, dynamic>;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}
// Mirror for method 'toString' in class 'AcWebRouteDefinition'
class Mef57e637b53c3087 implements AcMethodMirror {
  const Mef57e637b53c3087();
  @override Symbol get simpleName => const Symbol('toString');
  @override String getName() => 'toString';
  @override bool get isStatic => false;
  @override bool get isPrivate => false;
  @override List<Object> get metadata => const [override];
  @override Type get returnType => String;
  @override bool get isConstructor => false;
  @override bool get isGetter => false;
  @override bool get isSetter => false;
  @override String get constructorName => "";
  @override List<AcParameterMirror> get parameters => const [];
}

// Mirror for class 'Person' from package:autocode_flutter_tests/mirror_test/customer.dart
class M9de5013872b008c0 extends GeneratedAcClassMirror<Person> {
  const M9de5013872b008c0();
  @override final Symbol simpleName = const Symbol('Person');
  @override final Type reflectedType = Person;
  @override final bool isAbstract = true;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [acReflectable];
  @override String getName() => "Person";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('name'): const M6d241507e0ab23a0(),
    const Symbol('getGreeting'): const Madfef0730ba0e9f9(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override Person newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    throw UnimplementedError("Cannot instantiate an abstract class \"Person\".");
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as Person;
    switch(memberName) {
      case const Symbol('name'): return instance.name;
      case const Symbol('getGreeting'): return instance.getGreeting();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"Person\".");
    }
  }
}
// Mirror for class 'Loggable' from package:autocode_flutter_tests/mirror_test/customer.dart
class Medbdbc3ddc5e0fa2 extends GeneratedAcClassMirror<Loggable> {
  const Medbdbc3ddc5e0fa2();
  @override final Symbol simpleName = const Symbol('Loggable');
  @override final Type reflectedType = Loggable;
  @override final bool isAbstract = true;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [acReflectable];
  @override String getName() => "Loggable";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('log'): const Mb75bebd59e7a3b7e(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override Loggable newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    throw UnimplementedError("Cannot instantiate an abstract class \"Loggable\".");
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as Loggable;
    switch(memberName) {
      case const Symbol('log'): instance.log(positionalArgs[0]); break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"Loggable\".");
    }
  }
}
// Mirror for class 'Customer' from package:autocode_flutter_tests/mirror_test/customer.dart
class M1816c8f57495f99d extends GeneratedAcClassMirror<Customer> {
  const M1816c8f57495f99d();
  @override final Symbol simpleName = const Symbol('Customer');
  @override final Type reflectedType = Customer;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [classAnnotation];
  @override String getName() => "Customer";
  @override AcClassMirror? get superclass => acReflectClass(Person);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('id'): const Mf296313e6f0b8d2d(),
    const Symbol('name'): const M3a2128f5312a161a(),
    const Symbol('email'): const Mdfeca4187812fa8b(),
    const Symbol('_notes'): const Ma404a45a39c66225(),
    const Symbol('getGreeting'): const Md6ec705a93c83f78(),
    const Symbol('updateEmail'): const Mcb6e1d394131e63c(),
    const Symbol('log'): const Mdc6136aedaf392c4(),
    const Symbol('notes'): const M8851330a690be44a(),
    const Symbol('notes='): const Mb479fe23b01a09af(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M01d64e1859a9980a(),
    "named": const M1773752d54c0d897(),
  };
  @override Customer newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return Customer(id: namedArgs[const Symbol('id')], name: namedArgs[const Symbol('name')], email: namedArgs[const Symbol('email')]);
      case "named": return Customer.named(id: namedArgs[const Symbol('id')], name: namedArgs[const Symbol('name')], email: namedArgs[const Symbol('email')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as Customer;
    switch(memberName) {
      case const Symbol('id'): return instance.id;
      case const Symbol('name'): return instance.name;
      case const Symbol('email'): return instance.email;
      case const Symbol("email="): instance.email = positionalArgs[0]; break;
      case const Symbol('getGreeting'): return instance.getGreeting();
      case const Symbol('updateEmail'): instance.updateEmail(positionalArgs[0]); break;
      case const Symbol('log'): instance.log(positionalArgs[0]); break;
      case const Symbol('notes'): return instance.notes;
      case const Symbol('notes='): instance.notes = positionalArgs[0]; break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"Customer\".");
    }
  }
}
// Mirror for class 'AcCronJob' from package:autocode/src/models/ac_cron_job.dart
class Mb7e4f802e54e406b extends GeneratedAcClassMirror<AcCronJob> {
  const Mb7e4f802e54e406b();
  @override final Symbol simpleName = const Symbol('AcCronJob');
  @override final Type reflectedType = AcCronJob;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcCronJob";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('id'): const M6b3c4da2c4d14482(),
    const Symbol('execution'): const M9d21ce8c6036bf19(),
    const Symbol('duration'): const Mbfe30d8ad1c306cb(),
    const Symbol('callback'): const Ma7117821dbbd7ff8(),
    const Symbol('lastExecutionTime'): const Mcc0ce806d48c044e(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M76125925f6eb050a(),
  };
  @override AcCronJob newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcCronJob(positionalArgs[0], positionalArgs[1], positionalArgs[2], positionalArgs[3]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcCronJob;
    switch(memberName) {
      case const Symbol('id'): return instance.id;
      case const Symbol("id="): instance.id = positionalArgs[0]; break;
      case const Symbol('execution'): return instance.execution;
      case const Symbol("execution="): instance.execution = positionalArgs[0]; break;
      case const Symbol('duration'): return instance.duration;
      case const Symbol("duration="): instance.duration = positionalArgs[0]; break;
      case const Symbol('callback'): return instance.callback;
      case const Symbol("callback="): instance.callback = positionalArgs[0]; break;
      case const Symbol('lastExecutionTime'): return instance.lastExecutionTime;
      case const Symbol("lastExecutionTime="): instance.lastExecutionTime = positionalArgs[0]; break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcCronJob\".");
    }
  }
}
// Mirror for class 'AcEventExecutionResult' from package:autocode/src/models/ac_event_execution_result.dart
class Mf232179b81a97a4a extends GeneratedAcClassMirror<AcEventExecutionResult> {
  const Mf232179b81a97a4a();
  @override final Symbol simpleName = const Symbol('AcEventExecutionResult');
  @override final Type reflectedType = AcEventExecutionResult;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcEventExecutionResult";
  @override AcClassMirror? get superclass => acReflectClass(AcResult);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('continueOperation'): const Mf59548cede1f50f2(),
    const Symbol('hasResults'): const M3aa8b370e29a74b6(),
    const Symbol('results'): const M0dc4bd80059a1e06(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mee40780a1f28980a(),
  };
  @override AcEventExecutionResult newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcEventExecutionResult(continueOperation: namedArgs[const Symbol('continueOperation')], hasResults: namedArgs[const Symbol('hasResults')], results: namedArgs[const Symbol('results')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcEventExecutionResult;
    switch(memberName) {
      case const Symbol('continueOperation'): return instance.continueOperation;
      case const Symbol("continueOperation="): instance.continueOperation = positionalArgs[0]; break;
      case const Symbol('hasResults'): return instance.hasResults;
      case const Symbol("hasResults="): instance.hasResults = positionalArgs[0]; break;
      case const Symbol('results'): return instance.results;
      case const Symbol("results="): instance.results = positionalArgs[0]; break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcEventExecutionResult\".");
    }
  }
}
// Mirror for class 'AcHookExecutionResult' from package:autocode/src/models/ac_hook_execution_result.dart
class Mb9a613430d432993 extends GeneratedAcClassMirror<AcHookExecutionResult> {
  const Mb9a613430d432993();
  @override final Symbol simpleName = const Symbol('AcHookExecutionResult');
  @override final Type reflectedType = AcHookExecutionResult;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcHookExecutionResult";
  @override AcClassMirror? get superclass => acReflectClass(AcResult);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('continueOperation'): const Meb30f98c47438aff(),
    const Symbol('hasResults'): const M8d64be09e39b3d56(),
    const Symbol('results'): const M9149d64b1f96c66d(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M4133807756b29200(),
  };
  @override AcHookExecutionResult newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcHookExecutionResult(continueOperation: namedArgs[const Symbol('continueOperation')], hasResults: namedArgs[const Symbol('hasResults')], results: namedArgs[const Symbol('results')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcHookExecutionResult;
    switch(memberName) {
      case const Symbol('continueOperation'): return instance.continueOperation;
      case const Symbol("continueOperation="): instance.continueOperation = positionalArgs[0]; break;
      case const Symbol('hasResults'): return instance.hasResults;
      case const Symbol("hasResults="): instance.hasResults = positionalArgs[0]; break;
      case const Symbol('results'): return instance.results;
      case const Symbol("results="): instance.results = positionalArgs[0]; break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcHookExecutionResult\".");
    }
  }
}
// Mirror for class 'AcHookResult' from package:autocode/src/models/ac_hook_result.dart
class Mc25dfe08452d40b4 extends GeneratedAcClassMirror<AcHookResult> {
  const Mc25dfe08452d40b4();
  @override final Symbol simpleName = const Symbol('AcHookResult');
  @override final Type reflectedType = AcHookResult;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcHookResult";
  @override AcClassMirror? get superclass => acReflectClass(AcResult);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('continueOperation'): const M648f738e62bd8bf2(),
    const Symbol('changes'): const Mee2c147503a52bb6(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M1be8fe0cdacc0e51(),
  };
  @override AcHookResult newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcHookResult(continueOperation: namedArgs[const Symbol('continueOperation')], changes: namedArgs[const Symbol('changes')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcHookResult;
    switch(memberName) {
      case const Symbol('continueOperation'): return instance.continueOperation;
      case const Symbol("continueOperation="): instance.continueOperation = positionalArgs[0]; break;
      case const Symbol('changes'): return instance.changes;
      case const Symbol("changes="): instance.changes = positionalArgs[0]; break;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcHookResult\".");
    }
  }
}
// Mirror for class 'AcResult' from package:autocode/src/models/ac_result.dart
class M178ccbf6b44e0b5c extends GeneratedAcClassMirror<AcResult> {
  const M178ccbf6b44e0b5c();
  @override final Symbol simpleName = const Symbol('AcResult');
  @override final Type reflectedType = AcResult;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcResult";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('logger'): const Md68c822298f7d8c2(),
    const Symbol('code'): const M0875f932c86b155c(),
    const Symbol('exception'): const M6e12abc911783373(),
    const Symbol('log'): const M94a464b37f738207(),
    const Symbol('message'): const Mfc91462df350f6a5(),
    const Symbol('otherDetails'): const M338e91f8cb214353(),
    const Symbol('stackTrace'): const M5173b88859d9e805(),
    const Symbol('status'): const Md55e42c47f5ca1fb(),
    const Symbol('value'): const M7a38a761ad3ff0b2(),
    const Symbol('fromJson'): const Mde34e1fe5dd6e7b2(),
    const Symbol('isException'): const M8a553033c960bbf6(),
    const Symbol('isFailure'): const Mb262f7674c164b54(),
    const Symbol('isSuccess'): const M57c34523837f760d(),
    const Symbol('appendResultLog'): const M02990f1ff687ce7d(),
    const Symbol('prependResultLog'): const M6f9dc7d3fdef165f(),
    const Symbol('setFromResult'): const Me8e74b529464cbcd(),
    const Symbol('setSuccess'): const M39195b7ed3bc31a0(),
    const Symbol('setFailure'): const M45db3441e518ba21(),
    const Symbol('setException'): const M43df868ea9dbeefe(),
    const Symbol('toJson'): const M804db9f4004c3720(),
    const Symbol('toString'): const Mef519e01ff465da1(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mf6c08044e6ee9856(),
    "instanceFromJson": const M6529e0622c07c6f4(),
  };
  @override AcResult newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcResult();
      case "instanceFromJson": return AcResult.instanceFromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcResult;
    switch(memberName) {
      case const Symbol('logger'): return instance.logger;
      case const Symbol("logger="): instance.logger = positionalArgs[0]; break;
      case const Symbol('code'): return instance.code;
      case const Symbol("code="): instance.code = positionalArgs[0]; break;
      case const Symbol('exception'): return instance.exception;
      case const Symbol("exception="): instance.exception = positionalArgs[0]; break;
      case const Symbol('log'): return instance.log;
      case const Symbol("log="): instance.log = positionalArgs[0]; break;
      case const Symbol('message'): return instance.message;
      case const Symbol("message="): instance.message = positionalArgs[0]; break;
      case const Symbol('otherDetails'): return instance.otherDetails;
      case const Symbol("otherDetails="): instance.otherDetails = positionalArgs[0]; break;
      case const Symbol('stackTrace'): return instance.stackTrace;
      case const Symbol("stackTrace="): instance.stackTrace = positionalArgs[0]; break;
      case const Symbol('status'): return instance.status;
      case const Symbol("status="): instance.status = positionalArgs[0]; break;
      case const Symbol('value'): return instance.value;
      case const Symbol("value="): instance.value = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('isException'): return instance.isException();
      case const Symbol('isFailure'): return instance.isFailure();
      case const Symbol('isSuccess'): return instance.isSuccess();
      case const Symbol('appendResultLog'): return instance.appendResultLog(result: namedArgs[const Symbol('result')]);
      case const Symbol('prependResultLog'): return instance.prependResultLog(result: namedArgs[const Symbol('result')]);
      case const Symbol('setFromResult'): return instance.setFromResult(result: namedArgs[const Symbol('result')], message: namedArgs[const Symbol('message')], logger: namedArgs[const Symbol('logger')]);
      case const Symbol('setSuccess'): return instance.setSuccess(value: namedArgs[const Symbol('value')], message: namedArgs[const Symbol('message')], logger: namedArgs[const Symbol('logger')]);
      case const Symbol('setFailure'): return instance.setFailure(value: namedArgs[const Symbol('value')], message: namedArgs[const Symbol('message')], logger: namedArgs[const Symbol('logger')]);
      case const Symbol('setException'): return instance.setException(exception: namedArgs[const Symbol('exception')], message: namedArgs[const Symbol('message')], logger: namedArgs[const Symbol('logger')], logException: namedArgs[const Symbol('logException')], stackTrace: namedArgs[const Symbol('stackTrace')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcResult\".");
    }
  }
}
// Mirror for class 'AcDataDictionary' from package:ac_data_dictionary/src/models/ac_data_dictionary.dart
class Mfe32d12cf4c1dcaf extends GeneratedAcClassMirror<AcDataDictionary> {
  const Mfe32d12cf4c1dcaf();
  @override final Symbol simpleName = const Symbol('AcDataDictionary');
  @override final Type reflectedType = AcDataDictionary;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDataDictionary";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('functions'): const M94766791f9e8f4d1(),
    const Symbol('relationships'): const M07ac162dc7d9f32e(),
    const Symbol('storedProcedures'): const M0635a8e4d3ce0e23(),
    const Symbol('tables'): const Mff2d6780f9a15404(),
    const Symbol('triggers'): const Mdcbf058e3680e7cf(),
    const Symbol('version'): const M703263c97881e321(),
    const Symbol('views'): const M9b6f15aec576e852(),
    const Symbol('fromJson'): const M0929c07fb5b9f4d0(),
    const Symbol('getTableNames'): const Mb7fb5e4a8013f983(),
    const Symbol('getTablesList'): const Mda447994eef0f9b7(),
    const Symbol('getTableColumnNames'): const M42778f95b98e0c2c(),
    const Symbol('getTableColumnsList'): const M460e14fe8db21017(),
    const Symbol('getTableRelationshipsList'): const M8a801b935047262a(),
    const Symbol('getTableTriggersList'): const Maae21073bcc0a8c7(),
    const Symbol('toJson'): const M0944555113f378bf(),
    const Symbol('toString'): const M310aa79b67c0a105(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDataDictionary newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDataDictionary;
    switch(memberName) {
      case const Symbol('functions'): return instance.functions;
      case const Symbol("functions="): instance.functions = positionalArgs[0]; break;
      case const Symbol('relationships'): return instance.relationships;
      case const Symbol("relationships="): instance.relationships = positionalArgs[0]; break;
      case const Symbol('storedProcedures'): return instance.storedProcedures;
      case const Symbol("storedProcedures="): instance.storedProcedures = positionalArgs[0]; break;
      case const Symbol('tables'): return instance.tables;
      case const Symbol("tables="): instance.tables = positionalArgs[0]; break;
      case const Symbol('triggers'): return instance.triggers;
      case const Symbol("triggers="): instance.triggers = positionalArgs[0]; break;
      case const Symbol('version'): return instance.version;
      case const Symbol("version="): instance.version = positionalArgs[0]; break;
      case const Symbol('views'): return instance.views;
      case const Symbol("views="): instance.views = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('getTableNames'): return instance.getTableNames();
      case const Symbol('getTablesList'): return instance.getTablesList();
      case const Symbol('getTableColumnNames'): return instance.getTableColumnNames(tableName: namedArgs[const Symbol('tableName')]);
      case const Symbol('getTableColumnsList'): return instance.getTableColumnsList(tableName: namedArgs[const Symbol('tableName')]);
      case const Symbol('getTableRelationshipsList'): return instance.getTableRelationshipsList(tableName: namedArgs[const Symbol('tableName')], asDestination: namedArgs[const Symbol('asDestination')]);
      case const Symbol('getTableTriggersList'): return instance.getTableTriggersList(tableName: namedArgs[const Symbol('tableName')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDataDictionary\".");
    }
  }
}
// Mirror for class 'AcDDCondition' from package:ac_data_dictionary/src/models/ac_dd_condition.dart
class Ma517f98f8ca98662 extends GeneratedAcClassMirror<AcDDCondition> {
  const Ma517f98f8ca98662();
  @override final Symbol simpleName = const Symbol('AcDDCondition');
  @override final Type reflectedType = AcDDCondition;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDCondition";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('databaseType'): const M3a56522845e9cac9(),
    const Symbol('columnName'): const Medec4fed4a812437(),
    const Symbol('operator'): const M1c1f83437174de00(),
    const Symbol('value'): const M05cc220786e78b5a(),
    const Symbol('fromJson'): const M6c858e53a4f5dc17(),
    const Symbol('toJson'): const M82b21da8591f9a1b(),
    const Symbol('toString'): const M0f9a35c4fd126743(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mbc8a239c4c7242a4(),
    "instanceFromJson": const M076b646a51a66138(),
  };
  @override AcDDCondition newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDCondition();
      case "instanceFromJson": return AcDDCondition.instanceFromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDCondition;
    switch(memberName) {
      case const Symbol('databaseType'): return instance.databaseType;
      case const Symbol("databaseType="): instance.databaseType = positionalArgs[0]; break;
      case const Symbol('columnName'): return instance.columnName;
      case const Symbol("columnName="): instance.columnName = positionalArgs[0]; break;
      case const Symbol('operator'): return instance.operator;
      case const Symbol("operator="): instance.operator = positionalArgs[0]; break;
      case const Symbol('value'): return instance.value;
      case const Symbol("value="): instance.value = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDCondition\".");
    }
  }
}
// Mirror for class 'AcDDConditionGroup' from package:ac_data_dictionary/src/models/ac_dd_condition_group.dart
class M2a6f21ebb7456698 extends GeneratedAcClassMirror<AcDDConditionGroup> {
  const M2a6f21ebb7456698();
  @override final Symbol simpleName = const Symbol('AcDDConditionGroup');
  @override final Type reflectedType = AcDDConditionGroup;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDConditionGroup";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('databaseType'): const M40ef7575cb9212d2(),
    const Symbol('conditions'): const Md4def1d288a313e2(),
    const Symbol('operator'): const M13743ee0967c4085(),
    const Symbol('addCondition'): const Mb5395ec8d54ec9dc(),
    const Symbol('addConditionGroup'): const M7f07161f6f47ca3e(),
    const Symbol('fromJson'): const M6ce9e2f7ac114a8d(),
    const Symbol('toJson'): const Ma29642db6af062ef(),
    const Symbol('toString'): const Md99fdc0e7738b864(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M8a2525725ec7aed5(),
    "instanceFromJson": const Me0788a83c7673bad(),
  };
  @override AcDDConditionGroup newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDConditionGroup();
      case "instanceFromJson": return AcDDConditionGroup.instanceFromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDConditionGroup;
    switch(memberName) {
      case const Symbol('databaseType'): return instance.databaseType;
      case const Symbol("databaseType="): instance.databaseType = positionalArgs[0]; break;
      case const Symbol('conditions'): return instance.conditions;
      case const Symbol("conditions="): instance.conditions = positionalArgs[0]; break;
      case const Symbol('operator'): return instance.operator;
      case const Symbol("operator="): instance.operator = positionalArgs[0]; break;
      case const Symbol('addCondition'): return instance.addCondition(columnName: namedArgs[const Symbol('columnName')], operator: namedArgs[const Symbol('operator')], value: namedArgs[const Symbol('value')]);
      case const Symbol('addConditionGroup'): return instance.addConditionGroup(conditions: namedArgs[const Symbol('conditions')], operator: namedArgs[const Symbol('operator')]);
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDConditionGroup\".");
    }
  }
}
// Mirror for class 'AcDDFunction' from package:ac_data_dictionary/src/models/ac_dd_function.dart
class Md9f09978b1af32b8 extends GeneratedAcClassMirror<AcDDFunction> {
  const Md9f09978b1af32b8();
  @override final Symbol simpleName = const Symbol('AcDDFunction');
  @override final Type reflectedType = AcDDFunction;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDFunction";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('functionName'): const M00ec9bfcbf39bdb2(),
    const Symbol('functionCode'): const Mcee054f0a74431a2(),
    const Symbol('fromJson'): const M3c7ffa7370be4005(),
    const Symbol('toJson'): const M5cfda6b2c6b0d96c(),
    const Symbol('getCreateFunctionStatement'): const Maa3e0064eb601caa(),
    const Symbol('toString'): const Mb61fe830d2cc55c9(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M742ff0584cc35e01(),
    "instanceFromJson": const M93368a8cf9dac838(),
    "getInstance": const M83b815ca2965bb4a(),
  };
  @override AcDDFunction newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDFunction();
      case "instanceFromJson": return AcDDFunction.instanceFromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case "getInstance": return AcDDFunction.getInstance(functionName: namedArgs[const Symbol('functionName')], dataDictionaryName: namedArgs[const Symbol('dataDictionaryName')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDFunction;
    switch(memberName) {
      case const Symbol('functionName'): return instance.functionName;
      case const Symbol("functionName="): instance.functionName = positionalArgs[0]; break;
      case const Symbol('functionCode'): return instance.functionCode;
      case const Symbol("functionCode="): instance.functionCode = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('getCreateFunctionStatement'): return instance.getCreateFunctionStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDFunction\".");
    }
  }
}
// Mirror for class 'AcDDRelationship' from package:ac_data_dictionary/src/models/ac_dd_relationship.dart
class M95af1c3af8cb7557 extends GeneratedAcClassMirror<AcDDRelationship> {
  const M95af1c3af8cb7557();
  @override final Symbol simpleName = const Symbol('AcDDRelationship');
  @override final Type reflectedType = AcDDRelationship;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDRelationship";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('cascadeDeleteDestination'): const M2bd1475cbe822cd6(),
    const Symbol('cascadeDeleteSource'): const M0dd538671c0e3ce4(),
    const Symbol('destinationColumn'): const M1f11afd4f8604b8c(),
    const Symbol('destinationTable'): const M7b67d48ca24458c4(),
    const Symbol('sourceColumn'): const Ma65e54191d57aa2a(),
    const Symbol('sourceTable'): const M1d184cd44bcd6bdc(),
    const Symbol('fromJson'): const M66be3e6a640c3e72(),
    const Symbol('getCreateRelationshipStatement'): const Mab9c5a74960a9829(),
    const Symbol('toJson'): const M2715a0c885ff2522(),
    const Symbol('toString'): const M886c30fa4db047fd(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M7b38ff6b0dbb79a1(),
    "instanceFromJson": const M9062255d58c316d0(),
  };
  @override AcDDRelationship newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDRelationship();
      case "instanceFromJson": return AcDDRelationship.instanceFromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDRelationship;
    switch(memberName) {
      case const Symbol('cascadeDeleteDestination'): return instance.cascadeDeleteDestination;
      case const Symbol("cascadeDeleteDestination="): instance.cascadeDeleteDestination = positionalArgs[0]; break;
      case const Symbol('cascadeDeleteSource'): return instance.cascadeDeleteSource;
      case const Symbol("cascadeDeleteSource="): instance.cascadeDeleteSource = positionalArgs[0]; break;
      case const Symbol('destinationColumn'): return instance.destinationColumn;
      case const Symbol("destinationColumn="): instance.destinationColumn = positionalArgs[0]; break;
      case const Symbol('destinationTable'): return instance.destinationTable;
      case const Symbol("destinationTable="): instance.destinationTable = positionalArgs[0]; break;
      case const Symbol('sourceColumn'): return instance.sourceColumn;
      case const Symbol("sourceColumn="): instance.sourceColumn = positionalArgs[0]; break;
      case const Symbol('sourceTable'): return instance.sourceTable;
      case const Symbol("sourceTable="): instance.sourceTable = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('getCreateRelationshipStatement'): return instance.getCreateRelationshipStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDRelationship\".");
    }
  }
}
// Mirror for class 'AcDDSelectStatement' from package:ac_data_dictionary/src/models/ac_dd_select_statement.dart
class M53011bdc418686a6 extends GeneratedAcClassMirror<AcDDSelectStatement> {
  const M53011bdc418686a6();
  @override final Symbol simpleName = const Symbol('AcDDSelectStatement');
  @override final Type reflectedType = AcDDSelectStatement;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDSelectStatement";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('condition'): const M737b6b8187f45b57(),
    const Symbol('conditionGroup'): const Meac0cc565b069535(),
    const Symbol('databaseType'): const M24ca9923fa50a047(),
    const Symbol('dataDictionaryName'): const M66f5ea9f78702576(),
    const Symbol('excludeColumns'): const M493f9622031175aa(),
    const Symbol('groupStack'): const M274e320b047b0128(),
    const Symbol('includeColumns'): const M208dd0cfe833c441(),
    const Symbol('orderBy'): const M94c9364c2210252e(),
    const Symbol('pageNumber'): const M460c787a554f9c0e(),
    const Symbol('pageSize'): const M793fa4aa4064c314(),
    const Symbol('parameters'): const M23ef19b7ebf39ac6(),
    const Symbol('selectStatement'): const M1e50ce199bdccb9b(),
    const Symbol('sqlStatement'): const M4d2586dc7bed77e2(),
    const Symbol('tableName'): const Mf067190563c7df31(),
    const Symbol('addCondition'): const Md518ce409990888c(),
    const Symbol('addConditionGroup'): const M98356381678c29c6(),
    const Symbol('endGroup'): const M9bf674ed733054d4(),
    const Symbol('fromJson'): const M5d29bb97154388c7(),
    const Symbol('getSqlStatement'): const Me2bb581e1704a34c(),
    const Symbol('setConditionsFromFilters'): const Me43545d000cd70a8(),
    const Symbol('setSqlCondition'): const M388422b8aa85ddec(),
    const Symbol('setSqlConditionGroup'): const M55bf960f78c4e111(),
    const Symbol('setSqlLikeStringCondition'): const M0a75c31171eec6f6(),
    const Symbol('startGroup'): const M5ea762698fe82050(),
    const Symbol('toJson'): const M8adbd82462c4f6d9(),
    const Symbol('toString'): const M3590d46b5771c69a(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M870fde1ff5aa6505(),
  };
  @override AcDDSelectStatement newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDSelectStatement(tableName: namedArgs[const Symbol('tableName')], dataDictionaryName: namedArgs[const Symbol('dataDictionaryName')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDSelectStatement;
    switch(memberName) {
      case const Symbol('condition'): return instance.condition;
      case const Symbol("condition="): instance.condition = positionalArgs[0]; break;
      case const Symbol('conditionGroup'): return instance.conditionGroup;
      case const Symbol("conditionGroup="): instance.conditionGroup = positionalArgs[0]; break;
      case const Symbol('databaseType'): return instance.databaseType;
      case const Symbol("databaseType="): instance.databaseType = positionalArgs[0]; break;
      case const Symbol('dataDictionaryName'): return instance.dataDictionaryName;
      case const Symbol("dataDictionaryName="): instance.dataDictionaryName = positionalArgs[0]; break;
      case const Symbol('excludeColumns'): return instance.excludeColumns;
      case const Symbol("excludeColumns="): instance.excludeColumns = positionalArgs[0]; break;
      case const Symbol('groupStack'): return instance.groupStack;
      case const Symbol("groupStack="): instance.groupStack = positionalArgs[0]; break;
      case const Symbol('includeColumns'): return instance.includeColumns;
      case const Symbol("includeColumns="): instance.includeColumns = positionalArgs[0]; break;
      case const Symbol('orderBy'): return instance.orderBy;
      case const Symbol("orderBy="): instance.orderBy = positionalArgs[0]; break;
      case const Symbol('pageNumber'): return instance.pageNumber;
      case const Symbol("pageNumber="): instance.pageNumber = positionalArgs[0]; break;
      case const Symbol('pageSize'): return instance.pageSize;
      case const Symbol("pageSize="): instance.pageSize = positionalArgs[0]; break;
      case const Symbol('parameters'): return instance.parameters;
      case const Symbol("parameters="): instance.parameters = positionalArgs[0]; break;
      case const Symbol('selectStatement'): return instance.selectStatement;
      case const Symbol("selectStatement="): instance.selectStatement = positionalArgs[0]; break;
      case const Symbol('sqlStatement'): return instance.sqlStatement;
      case const Symbol("sqlStatement="): instance.sqlStatement = positionalArgs[0]; break;
      case const Symbol('tableName'): return instance.tableName;
      case const Symbol("tableName="): instance.tableName = positionalArgs[0]; break;
      case const Symbol('addCondition'): return instance.addCondition(columnName: namedArgs[const Symbol('columnName')], operator: namedArgs[const Symbol('operator')], value: namedArgs[const Symbol('value')]);
      case const Symbol('addConditionGroup'): return instance.addConditionGroup(conditions: namedArgs[const Symbol('conditions')], operator: namedArgs[const Symbol('operator')]);
      case const Symbol('endGroup'): return instance.endGroup();
      case const Symbol('fromJson'): instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]); break;
      case const Symbol('getSqlStatement'): return instance.getSqlStatement(skipCondition: namedArgs[const Symbol('skipCondition')], skipSelectStatement: namedArgs[const Symbol('skipSelectStatement')], skipLimit: namedArgs[const Symbol('skipLimit')]);
      case const Symbol('setConditionsFromFilters'): return instance.setConditionsFromFilters(filters: namedArgs[const Symbol('filters')]);
      case const Symbol('setSqlCondition'): return instance.setSqlCondition(acDDCondition: namedArgs[const Symbol('acDDCondition')]);
      case const Symbol('setSqlConditionGroup'): return instance.setSqlConditionGroup(acDDConditionGroup: namedArgs[const Symbol('acDDConditionGroup')], includeParenthesis: namedArgs[const Symbol('includeParenthesis')]);
      case const Symbol('setSqlLikeStringCondition'): return instance.setSqlLikeStringCondition(acDDCondition: namedArgs[const Symbol('acDDCondition')], includeEnd: namedArgs[const Symbol('includeEnd')], includeInBetween: namedArgs[const Symbol('includeInBetween')], includeStart: namedArgs[const Symbol('includeStart')]);
      case const Symbol('startGroup'): return instance.startGroup(operator: namedArgs[const Symbol('operator')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDSelectStatement\".");
    }
  }
}
// Mirror for class 'AcDDStoredProcedure' from package:ac_data_dictionary/src/models/ac_dd_stored_procedure.dart
class Me042b0895f903542 extends GeneratedAcClassMirror<AcDDStoredProcedure> {
  const Me042b0895f903542();
  @override final Symbol simpleName = const Symbol('AcDDStoredProcedure');
  @override final Type reflectedType = AcDDStoredProcedure;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDStoredProcedure";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('storedProcedureName'): const M78732456a3a1f4c3(),
    const Symbol('storedProcedureCode'): const Md440647e8b54ad51(),
    const Symbol('fromJson'): const Mbccf01d4e5fffd4c(),
    const Symbol('getCreateStoredProcedureStatement'): const M4370131047f8ddb5(),
    const Symbol('toJson'): const Mf5a130ca198d9ca9(),
    const Symbol('toString'): const Mf9ae8b2baba8dea3(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDStoredProcedure newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDStoredProcedure;
    switch(memberName) {
      case const Symbol('storedProcedureName'): return instance.storedProcedureName;
      case const Symbol("storedProcedureName="): instance.storedProcedureName = positionalArgs[0]; break;
      case const Symbol('storedProcedureCode'): return instance.storedProcedureCode;
      case const Symbol("storedProcedureCode="): instance.storedProcedureCode = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('getCreateStoredProcedureStatement'): return instance.getCreateStoredProcedureStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDStoredProcedure\".");
    }
  }
}
// Mirror for class 'AcDDTable' from package:ac_data_dictionary/src/models/ac_dd_table.dart
class M18b4d03ffdbf7b96 extends GeneratedAcClassMirror<AcDDTable> {
  const M18b4d03ffdbf7b96();
  @override final Symbol simpleName = const Symbol('AcDDTable');
  @override final Type reflectedType = AcDDTable;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDTable";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('tableColumns'): const Md41530dc08dee846(),
    const Symbol('tableName'): const M45121b893345edc2(),
    const Symbol('tableProperties'): const M76d257e220fc5785(),
    const Symbol('getColumn'): const M7d51cc3242520a4b(),
    const Symbol('getColumnNames'): const M4e948b2aba61001a(),
    const Symbol('getCreateTableStatement'): const Ma48cfe4623dbda0f(),
    const Symbol('getPrimaryKeyColumnName'): const M24c8ae7d6e5f1953(),
    const Symbol('getPrimaryKeyColumn'): const Md38dfe4a037a2ac2(),
    const Symbol('getPrimaryKeyColumns'): const M42c4a9eb71ef5d98(),
    const Symbol('getSearchQueryColumnNames'): const Mcc9da341346d934f(),
    const Symbol('getSearchQueryColumns'): const Mdec03b985b3c9a0a(),
    const Symbol('getForeignKeyColumns'): const Mdf020bdc2e6b048d(),
    const Symbol('getPluralName'): const M90f6540a7f92d789(),
    const Symbol('getSingularName'): const Me21a2cf66bbd865b(),
    const Symbol('getSelectDistinctColumns'): const Mca4ce591c51f5074(),
    const Symbol('fromJson'): const M27ca4757168969d0(),
    const Symbol('toJson'): const M3d00d1437ee1250a(),
    const Symbol('toString'): const Mf99890d4d0c4e70a(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDTable newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDTable;
    switch(memberName) {
      case const Symbol('tableColumns'): return instance.tableColumns;
      case const Symbol("tableColumns="): instance.tableColumns = positionalArgs[0]; break;
      case const Symbol('tableName'): return instance.tableName;
      case const Symbol("tableName="): instance.tableName = positionalArgs[0]; break;
      case const Symbol('tableProperties'): return instance.tableProperties;
      case const Symbol("tableProperties="): instance.tableProperties = positionalArgs[0]; break;
      case const Symbol('getColumn'): return instance.getColumn(positionalArgs[0]);
      case const Symbol('getColumnNames'): return instance.getColumnNames();
      case const Symbol('getCreateTableStatement'): return instance.getCreateTableStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('getPrimaryKeyColumnName'): return instance.getPrimaryKeyColumnName();
      case const Symbol('getPrimaryKeyColumn'): return instance.getPrimaryKeyColumn();
      case const Symbol('getPrimaryKeyColumns'): return instance.getPrimaryKeyColumns();
      case const Symbol('getSearchQueryColumnNames'): return instance.getSearchQueryColumnNames();
      case const Symbol('getSearchQueryColumns'): return instance.getSearchQueryColumns();
      case const Symbol('getForeignKeyColumns'): return instance.getForeignKeyColumns();
      case const Symbol('getPluralName'): return instance.getPluralName();
      case const Symbol('getSingularName'): return instance.getSingularName();
      case const Symbol('getSelectDistinctColumns'): return instance.getSelectDistinctColumns();
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDTable\".");
    }
  }
}
// Mirror for class 'AcDDTableColumn' from package:ac_data_dictionary/src/models/ac_dd_table_column.dart
class Md7f6176436681ad5 extends GeneratedAcClassMirror<AcDDTableColumn> {
  const Md7f6176436681ad5();
  @override final Symbol simpleName = const Symbol('AcDDTableColumn');
  @override final Type reflectedType = AcDDTableColumn;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDTableColumn";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('columnName'): const Md535693f66af4122(),
    const Symbol('columnProperties'): const M3b31cfccc92b23c0(),
    const Symbol('columnType'): const Ma609494c58ad624d(),
    const Symbol('columnValue'): const Md5809caa5ff3bc40(),
    const Symbol('table'): const M96424e678830aee6(),
    const Symbol('checkInAutoNumber'): const Mfd17e7b231d43195(),
    const Symbol('checkInModify'): const M939ebfa545c00f1b(),
    const Symbol('checkInSave'): const M81af702a1f1bd2a9(),
    const Symbol('getAutoNumberLength'): const Mb032adf51d223cb8(),
    const Symbol('getAutoNumberPrefix'): const Mdae3b1cb3dfee229(),
    const Symbol('getAutoNumberPrefixLength'): const M50b44b96e3042a15(),
    const Symbol('getDefaultValue'): const Mbaf0cba24b6bec7f(),
    const Symbol('getColumnFormats'): const Me5b41e18e0ae62ef(),
    const Symbol('getColumnTitle'): const M709f26d8bef46071(),
    const Symbol('getAddColumnStatement'): const Mee9916549323e2a6(),
    const Symbol('getColumnDefinitionForStatement'): const M832114c421853c54(),
    const Symbol('_blobType'): const Mce921e6a5e8b6d1b(),
    const Symbol('_textType'): const Mbf234effefbf8e09(),
    const Symbol('_intType'): const M6331163a957c5325(),
    const Symbol('getForeignKeyRelationships'): const Ma4082919e418c5a4(),
    const Symbol('getSize'): const M17d4b0d6105108f7(),
    const Symbol('isAutoIncrement'): const M621d67f55c105c94(),
    const Symbol('isAutoNumber'): const M9ceaba24e05f874d(),
    const Symbol('isForeignKey'): const M1db42220649aff92(),
    const Symbol('isInSearchQuery'): const Mab6a2e9bcc23a69a(),
    const Symbol('isNotNull'): const M30aad7bd64501ead(),
    const Symbol('isPrimaryKey'): const Me2696c2370f1b8c0(),
    const Symbol('isRequired'): const Me9001968aece42fe(),
    const Symbol('isSelectDistinct'): const M95ab65e79e452155(),
    const Symbol('isSetValuesNullBeforeDelete'): const M752d71fc0e0f09a3(),
    const Symbol('isUniqueKey'): const Meecc4c89834c045e(),
    const Symbol('fromJson'): const M45d4667858555fc4(),
    const Symbol('toJson'): const Mbf5fcd8f6ea28de9(),
    const Symbol('toString'): const M94f5e4282cd429e7(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDTableColumn newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDTableColumn;
    switch(memberName) {
      case const Symbol('columnName'): return instance.columnName;
      case const Symbol("columnName="): instance.columnName = positionalArgs[0]; break;
      case const Symbol('columnProperties'): return instance.columnProperties;
      case const Symbol("columnProperties="): instance.columnProperties = positionalArgs[0]; break;
      case const Symbol('columnType'): return instance.columnType;
      case const Symbol("columnType="): instance.columnType = positionalArgs[0]; break;
      case const Symbol('columnValue'): return instance.columnValue;
      case const Symbol("columnValue="): instance.columnValue = positionalArgs[0]; break;
      case const Symbol('table'): return instance.table;
      case const Symbol("table="): instance.table = positionalArgs[0]; break;
      case const Symbol('checkInAutoNumber'): return instance.checkInAutoNumber();
      case const Symbol('checkInModify'): return instance.checkInModify();
      case const Symbol('checkInSave'): return instance.checkInSave();
      case const Symbol('getAutoNumberLength'): return instance.getAutoNumberLength();
      case const Symbol('getAutoNumberPrefix'): return instance.getAutoNumberPrefix();
      case const Symbol('getAutoNumberPrefixLength'): return instance.getAutoNumberPrefixLength();
      case const Symbol('getDefaultValue'): return instance.getDefaultValue();
      case const Symbol('getColumnFormats'): return instance.getColumnFormats();
      case const Symbol('getColumnTitle'): return instance.getColumnTitle();
      case const Symbol('getAddColumnStatement'): return instance.getAddColumnStatement(tableName: namedArgs[const Symbol('tableName')], databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('getColumnDefinitionForStatement'): return instance.getColumnDefinitionForStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('getForeignKeyRelationships'): return instance.getForeignKeyRelationships();
      case const Symbol('getSize'): return instance.getSize();
      case const Symbol('isAutoIncrement'): return instance.isAutoIncrement();
      case const Symbol('isAutoNumber'): return instance.isAutoNumber();
      case const Symbol('isForeignKey'): return instance.isForeignKey();
      case const Symbol('isInSearchQuery'): return instance.isInSearchQuery();
      case const Symbol('isNotNull'): return instance.isNotNull();
      case const Symbol('isPrimaryKey'): return instance.isPrimaryKey();
      case const Symbol('isRequired'): return instance.isRequired();
      case const Symbol('isSelectDistinct'): return instance.isSelectDistinct();
      case const Symbol('isSetValuesNullBeforeDelete'): return instance.isSetValuesNullBeforeDelete();
      case const Symbol('isUniqueKey'): return instance.isUniqueKey();
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDTableColumn\".");
    }
  }
}
// Mirror for class 'AcDDTableColumnProperty' from package:ac_data_dictionary/src/models/ac_dd_table_column_property.dart
class M6317e0d183c3ecbb extends GeneratedAcClassMirror<AcDDTableColumnProperty> {
  const M6317e0d183c3ecbb();
  @override final Symbol simpleName = const Symbol('AcDDTableColumnProperty');
  @override final Type reflectedType = AcDDTableColumnProperty;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDTableColumnProperty";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('propertyName'): const M42305d7d4eac8270(),
    const Symbol('propertyValue'): const Mea33ea48862cfa1d(),
    const Symbol('fromJson'): const Md5566dbe6b33cec6(),
    const Symbol('toJson'): const Meb0485c732dd7416(),
    const Symbol('toString'): const Me697049cb041c9fb(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDTableColumnProperty newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDTableColumnProperty;
    switch(memberName) {
      case const Symbol('propertyName'): return instance.propertyName;
      case const Symbol("propertyName="): instance.propertyName = positionalArgs[0]; break;
      case const Symbol('propertyValue'): return instance.propertyValue;
      case const Symbol("propertyValue="): instance.propertyValue = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDTableColumnProperty\".");
    }
  }
}
// Mirror for class 'AcDDTableProperty' from package:ac_data_dictionary/src/models/ac_dd_table_property.dart
class Mdb3734d0dfc95927 extends GeneratedAcClassMirror<AcDDTableProperty> {
  const Mdb3734d0dfc95927();
  @override final Symbol simpleName = const Symbol('AcDDTableProperty');
  @override final Type reflectedType = AcDDTableProperty;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDTableProperty";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('propertyName'): const Me46bbc72eb91df01(),
    const Symbol('propertyValue'): const M1a5babb4b25ae60b(),
    const Symbol('fromJson'): const M9f54b335f2488332(),
    const Symbol('toJson'): const M29f7faea2589fae4(),
    const Symbol('toString'): const M58ad1a943a4679c1(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDTableProperty newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDTableProperty;
    switch(memberName) {
      case const Symbol('propertyName'): return instance.propertyName;
      case const Symbol("propertyName="): instance.propertyName = positionalArgs[0]; break;
      case const Symbol('propertyValue'): return instance.propertyValue;
      case const Symbol("propertyValue="): instance.propertyValue = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDTableProperty\".");
    }
  }
}
// Mirror for class 'AcDDTrigger' from package:ac_data_dictionary/src/models/ac_dd_trigger.dart
class M8421f8b971ce0eb5 extends GeneratedAcClassMirror<AcDDTrigger> {
  const M8421f8b971ce0eb5();
  @override final Symbol simpleName = const Symbol('AcDDTrigger');
  @override final Type reflectedType = AcDDTrigger;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDTrigger";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('rowOperation'): const M555b02c4295faf21(),
    const Symbol('triggerExecution'): const M1a17592dfa4f3f9c(),
    const Symbol('tableName'): const Mb765f944cdae9517(),
    const Symbol('triggerName'): const Mcb05b8b6dcf81ec7(),
    const Symbol('triggerCode'): const M43a73113ce9060a5(),
    const Symbol('getCreateTriggerStatement'): const Ma84b7d61f6361597(),
    const Symbol('fromJson'): const M57909d1e66644159(),
    const Symbol('toJson'): const Med16cd8a85fab6bf(),
    const Symbol('toString'): const M82493b422ae3a661(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDTrigger newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDTrigger;
    switch(memberName) {
      case const Symbol('rowOperation'): return instance.rowOperation;
      case const Symbol("rowOperation="): instance.rowOperation = positionalArgs[0]; break;
      case const Symbol('triggerExecution'): return instance.triggerExecution;
      case const Symbol("triggerExecution="): instance.triggerExecution = positionalArgs[0]; break;
      case const Symbol('tableName'): return instance.tableName;
      case const Symbol("tableName="): instance.tableName = positionalArgs[0]; break;
      case const Symbol('triggerName'): return instance.triggerName;
      case const Symbol("triggerName="): instance.triggerName = positionalArgs[0]; break;
      case const Symbol('triggerCode'): return instance.triggerCode;
      case const Symbol("triggerCode="): instance.triggerCode = positionalArgs[0]; break;
      case const Symbol('getCreateTriggerStatement'): return instance.getCreateTriggerStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDTrigger\".");
    }
  }
}
// Mirror for class 'AcDDView' from package:ac_data_dictionary/src/models/ac_dd_view.dart
class Ma2cb0993a55207b1 extends GeneratedAcClassMirror<AcDDView> {
  const Ma2cb0993a55207b1();
  @override final Symbol simpleName = const Symbol('AcDDView');
  @override final Type reflectedType = AcDDView;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDView";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('viewName'): const M4b873c77bfa32178(),
    const Symbol('viewQuery'): const M036fc5f0426f3283(),
    const Symbol('viewColumns'): const Mfb3bf3136509be0d(),
    const Symbol('fromJson'): const M69f3f39002b5557b(),
    const Symbol('getCreateViewStatement'): const M54ccd8c8f968eaa8(),
    const Symbol('toJson'): const Mc546cf69de035504(),
    const Symbol('toString'): const M1c51cc772f3675c5(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcDDView newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDView;
    switch(memberName) {
      case const Symbol('viewName'): return instance.viewName;
      case const Symbol("viewName="): instance.viewName = positionalArgs[0]; break;
      case const Symbol('viewQuery'): return instance.viewQuery;
      case const Symbol("viewQuery="): instance.viewQuery = positionalArgs[0]; break;
      case const Symbol('viewColumns'): return instance.viewColumns;
      case const Symbol("viewColumns="): instance.viewColumns = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('getCreateViewStatement'): return instance.getCreateViewStatement(databaseType: namedArgs[const Symbol('databaseType')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDView\".");
    }
  }
}
// Mirror for class 'AcDDViewColumn' from package:ac_data_dictionary/src/models/ac_dd_view_column.dart
class Meba4079f0b558179 extends GeneratedAcClassMirror<AcDDViewColumn> {
  const Meba4079f0b558179();
  @override final Symbol simpleName = const Symbol('AcDDViewColumn');
  @override final Type reflectedType = AcDDViewColumn;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcDDViewColumn";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('columnName'): const M5fb0321e3fff0b6f(),
    const Symbol('columnProperties'): const Mae3cba52168707b8(),
    const Symbol('columnType'): const M78da5e2f9da4e150(),
    const Symbol('columnValue'): const M45c0cee8d05cd968(),
    const Symbol('columnSource'): const M8edc04cbd2f26cf3(),
    const Symbol('columnSourceName'): const Mf79ead82a9c1a7e4(),
    const Symbol('fromJson'): const Mdd06595648ff33d9(),
    const Symbol('toJson'): const M859a4b30df128544(),
    const Symbol('toString'): const Mb559ea6ec392781e(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M12837a79cdf481a2(),
  };
  @override AcDDViewColumn newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcDDViewColumn();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcDDViewColumn;
    switch(memberName) {
      case const Symbol('columnName'): return instance.columnName;
      case const Symbol("columnName="): instance.columnName = positionalArgs[0]; break;
      case const Symbol('columnProperties'): return instance.columnProperties;
      case const Symbol("columnProperties="): instance.columnProperties = positionalArgs[0]; break;
      case const Symbol('columnType'): return instance.columnType;
      case const Symbol("columnType="): instance.columnType = positionalArgs[0]; break;
      case const Symbol('columnValue'): return instance.columnValue;
      case const Symbol("columnValue="): instance.columnValue = positionalArgs[0]; break;
      case const Symbol('columnSource'): return instance.columnSource;
      case const Symbol("columnSource="): instance.columnSource = positionalArgs[0]; break;
      case const Symbol('columnSourceName'): return instance.columnSourceName;
      case const Symbol("columnSourceName="): instance.columnSourceName = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcDDViewColumn\".");
    }
  }
}
// Mirror for class 'AcSqlConnection' from package:ac_sql/src/models/ac_sql_connection.dart
class M0549a1820c2aa7ea extends GeneratedAcClassMirror<AcSqlConnection> {
  const M0549a1820c2aa7ea();
  @override final Symbol simpleName = const Symbol('AcSqlConnection');
  @override final Type reflectedType = AcSqlConnection;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcSqlConnection";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('port'): const M16fe2a7a3c15b6b6(),
    const Symbol('hostname'): const Me53964ed6e9aa264(),
    const Symbol('username'): const M13d43215d354bcbc(),
    const Symbol('password'): const M87c0f9107ca70f2c(),
    const Symbol('database'): const Ma8cb4772cdce2b8c(),
    const Symbol('options'): const M7f8d9106eb52bb55(),
    const Symbol('fromJson'): const Mfccaebb14dcfa807(),
    const Symbol('toJson'): const M8f8e5375c216ca9f(),
    const Symbol('toString'): const M0f76c46f46b2b3f9(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcSqlConnection newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcSqlConnection;
    switch(memberName) {
      case const Symbol('port'): return instance.port;
      case const Symbol("port="): instance.port = positionalArgs[0]; break;
      case const Symbol('hostname'): return instance.hostname;
      case const Symbol("hostname="): instance.hostname = positionalArgs[0]; break;
      case const Symbol('username'): return instance.username;
      case const Symbol("username="): instance.username = positionalArgs[0]; break;
      case const Symbol('password'): return instance.password;
      case const Symbol("password="): instance.password = positionalArgs[0]; break;
      case const Symbol('database'): return instance.database;
      case const Symbol("database="): instance.database = positionalArgs[0]; break;
      case const Symbol('options'): return instance.options;
      case const Symbol("options="): instance.options = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcSqlConnection\".");
    }
  }
}
// Mirror for class 'AcSqlDaoResult' from package:ac_sql/src/models/ac_sql_dao_result.dart
class M84ddf7ecf475fedc extends GeneratedAcClassMirror<AcSqlDaoResult> {
  const M84ddf7ecf475fedc();
  @override final Symbol simpleName = const Symbol('AcSqlDaoResult');
  @override final Type reflectedType = AcSqlDaoResult;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcSqlDaoResult";
  @override AcClassMirror? get superclass => acReflectClass(AcResult);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('rows'): const M64c05af915d80fcd(),
    const Symbol('affectedRowsCount'): const M01124673935ca022(),
    const Symbol('lastInsertedId'): const Mdf58a5e31ab84124(),
    const Symbol('lastInsertedIds'): const M44973a525ed4ce42(),
    const Symbol('operation'): const Mb08e7e28057635ff(),
    const Symbol('primaryKeyColumn'): const M0d3cf8c5d620909f(),
    const Symbol('primaryKeyValue'): const Ma712bf38474a2db2(),
    const Symbol('totalRows'): const Mb06beceaad9b798c(),
    const Symbol('hasAffectedRows'): const M30f83f012277b402(),
    const Symbol('hasRows'): const M153c8979bf3610f4(),
    const Symbol('rowsCount'): const M409c0a3e06ddebc9(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mb179cef78fc073e3(),
  };
  @override AcSqlDaoResult newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcSqlDaoResult(operation: namedArgs[const Symbol('operation')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcSqlDaoResult;
    switch(memberName) {
      case const Symbol('rows'): return instance.rows;
      case const Symbol("rows="): instance.rows = positionalArgs[0]; break;
      case const Symbol('affectedRowsCount'): return instance.affectedRowsCount;
      case const Symbol("affectedRowsCount="): instance.affectedRowsCount = positionalArgs[0]; break;
      case const Symbol('lastInsertedId'): return instance.lastInsertedId;
      case const Symbol("lastInsertedId="): instance.lastInsertedId = positionalArgs[0]; break;
      case const Symbol('lastInsertedIds'): return instance.lastInsertedIds;
      case const Symbol("lastInsertedIds="): instance.lastInsertedIds = positionalArgs[0]; break;
      case const Symbol('operation'): return instance.operation;
      case const Symbol("operation="): instance.operation = positionalArgs[0]; break;
      case const Symbol('primaryKeyColumn'): return instance.primaryKeyColumn;
      case const Symbol("primaryKeyColumn="): instance.primaryKeyColumn = positionalArgs[0]; break;
      case const Symbol('primaryKeyValue'): return instance.primaryKeyValue;
      case const Symbol("primaryKeyValue="): instance.primaryKeyValue = positionalArgs[0]; break;
      case const Symbol('totalRows'): return instance.totalRows;
      case const Symbol("totalRows="): instance.totalRows = positionalArgs[0]; break;
      case const Symbol('hasAffectedRows'): return instance.hasAffectedRows();
      case const Symbol('hasRows'): return instance.hasRows();
      case const Symbol('rowsCount'): return instance.rowsCount();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcSqlDaoResult\".");
    }
  }
}
// Mirror for class 'AcWebAuthorize' from package:ac_web/src/annotations/ac_web_authorize.dart
class M2baf6f01ec86f544 extends GeneratedAcClassMirror<AcWebAuthorize> {
  const M2baf6f01ec86f544();
  @override final Symbol simpleName = const Symbol('AcWebAuthorize');
  @override final Type reflectedType = AcWebAuthorize;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebAuthorize";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('roles'): const M5a0414cf6dbd50e3(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mda2d1956d1a90bd4(),
  };
  @override AcWebAuthorize newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebAuthorize(roles: namedArgs[const Symbol('roles')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebAuthorize;
    switch(memberName) {
      case const Symbol('roles'): return instance.roles;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebAuthorize\".");
    }
  }
}
// Mirror for class 'AcWebController' from package:ac_web/src/annotations/ac_web_controller.dart
class Md8e9680648b80da9 extends GeneratedAcClassMirror<AcWebController> {
  const Md8e9680648b80da9();
  @override final Symbol simpleName = const Symbol('AcWebController');
  @override final Type reflectedType = AcWebController;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebController";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M92ec7de2c9b968fc(),
  };
  @override AcWebController newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebController();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebController;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebController\".");
    }
  }
}
// Mirror for class 'AcWebInject' from package:ac_web/src/annotations/ac_web_inject.dart
class Ma7d862ba95e1a82d extends GeneratedAcClassMirror<AcWebInject> {
  const Ma7d862ba95e1a82d();
  @override final Symbol simpleName = const Symbol('AcWebInject');
  @override final Type reflectedType = AcWebInject;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebInject";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M241dd71b55dca1b2(),
  };
  @override AcWebInject newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebInject();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebInject;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebInject\".");
    }
  }
}
// Mirror for class 'AcWebMiddleware' from package:ac_web/src/annotations/ac_web_middleware.dart
class M872c7741b2654035 extends GeneratedAcClassMirror<AcWebMiddleware> {
  const M872c7741b2654035();
  @override final Symbol simpleName = const Symbol('AcWebMiddleware');
  @override final Type reflectedType = AcWebMiddleware;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebMiddleware";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('middlewareClass'): const Mbcba40424263aaab(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M5d575f5ed9a75ed6(),
  };
  @override AcWebMiddleware newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebMiddleware(positionalArgs[0]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebMiddleware;
    switch(memberName) {
      case const Symbol('middlewareClass'): return instance.middlewareClass;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebMiddleware\".");
    }
  }
}
// Mirror for class 'AcWebRepository' from package:ac_web/src/annotations/ac_web_repository.dart
class M03c0f02de75fdabf extends GeneratedAcClassMirror<AcWebRepository> {
  const M03c0f02de75fdabf();
  @override final Symbol simpleName = const Symbol('AcWebRepository');
  @override final Type reflectedType = AcWebRepository;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRepository";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M070975eead5aa895(),
  };
  @override AcWebRepository newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRepository();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRepository;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRepository\".");
    }
  }
}
// Mirror for class 'AcWebRoute' from package:ac_web/src/annotations/ac_web_route.dart
class M5de18f4e1b29ec4d extends GeneratedAcClassMirror<AcWebRoute> {
  const M5de18f4e1b29ec4d();
  @override final Symbol simpleName = const Symbol('AcWebRoute');
  @override final Type reflectedType = AcWebRoute;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRoute";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('path'): const M19b8763a485682af(),
    const Symbol('method'): const M904827e4d70c63e4(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M4f4b1661c1e4dcf9(),
  };
  @override AcWebRoute newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRoute(positionalArgs[0], method: namedArgs[const Symbol('method')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRoute;
    switch(memberName) {
      case const Symbol('path'): return instance.path;
      case const Symbol('method'): return instance.method;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRoute\".");
    }
  }
}
// Mirror for class 'AcWebRouteConsumes' from package:ac_web/src/annotations/ac_web_route_consumes.dart
class M9bb45b697573a801 extends GeneratedAcClassMirror<AcWebRouteConsumes> {
  const M9bb45b697573a801();
  @override final Symbol simpleName = const Symbol('AcWebRouteConsumes');
  @override final Type reflectedType = AcWebRouteConsumes;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRouteConsumes";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('contentType'): const M7b040c33e51e78fc(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mee1c3a5ef0da5a15(),
  };
  @override AcWebRouteConsumes newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRouteConsumes(positionalArgs[0]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRouteConsumes;
    switch(memberName) {
      case const Symbol('contentType'): return instance.contentType;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRouteConsumes\".");
    }
  }
}
// Mirror for class 'AcWebRouteMeta' from package:ac_web/src/annotations/ac_web_route_meta.dart
class Mdce8c0e2f45729fa extends GeneratedAcClassMirror<AcWebRouteMeta> {
  const Mdce8c0e2f45729fa();
  @override final Symbol simpleName = const Symbol('AcWebRouteMeta');
  @override final Type reflectedType = AcWebRouteMeta;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRouteMeta";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('summary'): const M8ff0a79a72d94d61(),
    const Symbol('description'): const M13d0b9d8a2ec354c(),
    const Symbol('parameters'): const Mdcdbd6744d3ee300(),
    const Symbol('tags'): const M9ef5c99560837590(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M187774dd13359d01(),
  };
  @override AcWebRouteMeta newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRouteMeta(summary: namedArgs[const Symbol('summary')], description: namedArgs[const Symbol('description')], parameters: namedArgs[const Symbol('parameters')], tags: namedArgs[const Symbol('tags')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRouteMeta;
    switch(memberName) {
      case const Symbol('summary'): return instance.summary;
      case const Symbol('description'): return instance.description;
      case const Symbol('parameters'): return instance.parameters;
      case const Symbol('tags'): return instance.tags;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRouteMeta\".");
    }
  }
}
// Mirror for class 'AcWebRouteMetaParameter' from package:ac_web/src/annotations/ac_web_route_meta_parameter.dart
class Md74f8b43d45589a8 extends GeneratedAcClassMirror<AcWebRouteMetaParameter> {
  const Md74f8b43d45589a8();
  @override final Symbol simpleName = const Symbol('AcWebRouteMetaParameter');
  @override final Type reflectedType = AcWebRouteMetaParameter;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRouteMetaParameter";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const Md606da09b40254ec(),
    const Symbol('name'): const M11f57326d0853820(),
    const Symbol('required'): const Md0e24e393f073125(),
    const Symbol('explode'): const M14b3d85a845b7bde(),
    const Symbol('schema'): const Mf360f3300ebe176b(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M89bf2f88fc479018(),
  };
  @override AcWebRouteMetaParameter newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRouteMetaParameter(description: namedArgs[const Symbol('description')], name: namedArgs[const Symbol('name')], required: namedArgs[const Symbol('required')], explode: namedArgs[const Symbol('explode')], schema: namedArgs[const Symbol('schema')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRouteMetaParameter;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol('name'): return instance.name;
      case const Symbol('required'): return instance.required;
      case const Symbol('explode'): return instance.explode;
      case const Symbol('schema'): return instance.schema;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRouteMetaParameter\".");
    }
  }
}
// Mirror for class 'AcWebRouteProduces' from package:ac_web/src/annotations/ac_web_route_produces.dart
class Me22c0f10728938fe extends GeneratedAcClassMirror<AcWebRouteProduces> {
  const Me22c0f10728938fe();
  @override final Symbol simpleName = const Symbol('AcWebRouteProduces');
  @override final Type reflectedType = AcWebRouteProduces;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRouteProduces";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('contentType'): const M5288478453ea7372(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M8f1145a6ad4ee8b2(),
  };
  @override AcWebRouteProduces newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebRouteProduces(positionalArgs[0]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRouteProduces;
    switch(memberName) {
      case const Symbol('contentType'): return instance.contentType;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRouteProduces\".");
    }
  }
}
// Mirror for class 'AcWebService' from package:ac_web/src/annotations/ac_web_service.dart
class M8c7560d77c2b9fad extends GeneratedAcClassMirror<AcWebService> {
  const M8c7560d77c2b9fad();
  @override final Symbol simpleName = const Symbol('AcWebService');
  @override final Type reflectedType = AcWebService;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebService";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M0d01afe740300c92(),
  };
  @override AcWebService newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebService();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebService;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebService\".");
    }
  }
}
// Mirror for class 'AcWebValueFromBody' from package:ac_web/src/annotations/ac_web_value_from_body.dart
class M02c3b522bd6efe0b extends GeneratedAcClassMirror<AcWebValueFromBody> {
  const M02c3b522bd6efe0b();
  @override final Symbol simpleName = const Symbol('AcWebValueFromBody');
  @override final Type reflectedType = AcWebValueFromBody;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromBody";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const Med6ac07431c74c5c(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mffbfabfc67528791(),
  };
  @override AcWebValueFromBody newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromBody(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromBody;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromBody\".");
    }
  }
}
// Mirror for class 'AcWebValueFromCookie' from package:ac_web/src/annotations/ac_web_value_from_cookie.dart
class M90149e3a29b1be81 extends GeneratedAcClassMirror<AcWebValueFromCookie> {
  const M90149e3a29b1be81();
  @override final Symbol simpleName = const Symbol('AcWebValueFromCookie');
  @override final Type reflectedType = AcWebValueFromCookie;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromCookie";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const M38f19780c59fa517(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M7b6fbcf21f09dc02(),
  };
  @override AcWebValueFromCookie newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromCookie(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromCookie;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromCookie\".");
    }
  }
}
// Mirror for class 'AcWebValueFromForm' from package:ac_web/src/annotations/ac_web_value_from_form.dart
class M33c21270ff8b8433 extends GeneratedAcClassMirror<AcWebValueFromForm> {
  const M33c21270ff8b8433();
  @override final Symbol simpleName = const Symbol('AcWebValueFromForm');
  @override final Type reflectedType = AcWebValueFromForm;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromForm";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const M1914092aa3911162(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M30794200c9033e73(),
  };
  @override AcWebValueFromForm newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromForm(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromForm;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromForm\".");
    }
  }
}
// Mirror for class 'AcWebValueFromHeader' from package:ac_web/src/annotations/ac_web_value_from_header.dart
class M7fbaa93addc0a6b2 extends GeneratedAcClassMirror<AcWebValueFromHeader> {
  const M7fbaa93addc0a6b2();
  @override final Symbol simpleName = const Symbol('AcWebValueFromHeader');
  @override final Type reflectedType = AcWebValueFromHeader;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromHeader";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const M121e0e5d8b299743(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M93723e07f0564669(),
  };
  @override AcWebValueFromHeader newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromHeader(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromHeader;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromHeader\".");
    }
  }
}
// Mirror for class 'AcWebValueFromPath' from package:ac_web/src/annotations/ac_web_value_from_path.dart
class Mb6152f2d9f9e3453 extends GeneratedAcClassMirror<AcWebValueFromPath> {
  const Mb6152f2d9f9e3453();
  @override final Symbol simpleName = const Symbol('AcWebValueFromPath');
  @override final Type reflectedType = AcWebValueFromPath;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromPath";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const Ma5ab706bd0b385a7(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M93b6bfcd1a7dd1e8(),
  };
  @override AcWebValueFromPath newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromPath(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromPath;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromPath\".");
    }
  }
}
// Mirror for class 'AcWebValueFromQuery' from package:ac_web/src/annotations/ac_web_value_from_query.dart
class M4f7d583e7d694601 extends GeneratedAcClassMirror<AcWebValueFromQuery> {
  const M4f7d583e7d694601();
  @override final Symbol simpleName = const Symbol('AcWebValueFromQuery');
  @override final Type reflectedType = AcWebValueFromQuery;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebValueFromQuery";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('key'): const M0ffb54f88208c73c(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M15857efa5d8becb7(),
  };
  @override AcWebValueFromQuery newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebValueFromQuery(key: namedArgs[const Symbol('key')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebValueFromQuery;
    switch(memberName) {
      case const Symbol('key'): return instance.key;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebValueFromQuery\".");
    }
  }
}
// Mirror for class 'AcWebView' from package:ac_web/src/annotations/ac_web_view.dart
class Me39d769858824c2a extends GeneratedAcClassMirror<AcWebView> {
  const Me39d769858824c2a();
  @override final Symbol simpleName = const Symbol('AcWebView');
  @override final Type reflectedType = AcWebView;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebView";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mad976384d34f8b1e(),
  };
  @override AcWebView newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebView();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebView;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebView\".");
    }
  }
}
// Mirror for class 'AcApiDoc' from package:ac_web/src/api-docs/models/ac_api_doc.dart
class Mb09ba0f6f09f9f5d extends GeneratedAcClassMirror<AcApiDoc> {
  const Mb09ba0f6f09f9f5d();
  @override final Symbol simpleName = const Symbol('AcApiDoc');
  @override final Type reflectedType = AcApiDoc;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDoc";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('contact'): const M82612e0e92804d5f(),
    const Symbol('components'): const Mbb401f6b98884989(),
    const Symbol('description'): const M7fca063678a41944(),
    const Symbol('license'): const M8eb0f9ed3899f240(),
    const Symbol('models'): const M6f00602261a92dd4(),
    const Symbol('paths'): const M0f2a2a713be5861b(),
    const Symbol('servers'): const Mac6cfd51854eee50(),
    const Symbol('tags'): const M1354c4c232b91943(),
    const Symbol('termsOfService'): const M8931976c16a61519(),
    const Symbol('title'): const M40c20aca4a50f99d(),
    const Symbol('version'): const Mb3b0627596ddca67(),
    const Symbol('addModel'): const Me11fabdadf119ff5(),
    const Symbol('addPath'): const Mc7fd3b8b8a3dc027(),
    const Symbol('addServer'): const M55f3ac196603dc43(),
    const Symbol('addTag'): const M743d490910b1d7c8(),
    const Symbol('fromJson'): const Mc3921d2b879de5c4(),
    const Symbol('toJson'): const Meebc79e790b64134(),
    const Symbol('toString'): const M16366179bab580a5(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDoc newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDoc;
    switch(memberName) {
      case const Symbol('contact'): return instance.contact;
      case const Symbol("contact="): instance.contact = positionalArgs[0]; break;
      case const Symbol('components'): return instance.components;
      case const Symbol("components="): instance.components = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('license'): return instance.license;
      case const Symbol("license="): instance.license = positionalArgs[0]; break;
      case const Symbol('models'): return instance.models;
      case const Symbol("models="): instance.models = positionalArgs[0]; break;
      case const Symbol('paths'): return instance.paths;
      case const Symbol("paths="): instance.paths = positionalArgs[0]; break;
      case const Symbol('servers'): return instance.servers;
      case const Symbol("servers="): instance.servers = positionalArgs[0]; break;
      case const Symbol('tags'): return instance.tags;
      case const Symbol("tags="): instance.tags = positionalArgs[0]; break;
      case const Symbol('termsOfService'): return instance.termsOfService;
      case const Symbol("termsOfService="): instance.termsOfService = positionalArgs[0]; break;
      case const Symbol('title'): return instance.title;
      case const Symbol("title="): instance.title = positionalArgs[0]; break;
      case const Symbol('version'): return instance.version;
      case const Symbol("version="): instance.version = positionalArgs[0]; break;
      case const Symbol('addModel'): return instance.addModel(model: namedArgs[const Symbol('model')]);
      case const Symbol('addPath'): return instance.addPath(path: namedArgs[const Symbol('path')]);
      case const Symbol('addServer'): return instance.addServer(server: namedArgs[const Symbol('server')]);
      case const Symbol('addTag'): return instance.addTag(tag: namedArgs[const Symbol('tag')]);
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDoc\".");
    }
  }
}
// Mirror for class 'AcApiDocComponents' from package:ac_web/src/api-docs/models/ac_api_doc_components.dart
class M5936e5c29743238f extends GeneratedAcClassMirror<AcApiDocComponents> {
  const M5936e5c29743238f();
  @override final Symbol simpleName = const Symbol('AcApiDocComponents');
  @override final Type reflectedType = AcApiDocComponents;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocComponents";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('schemas'): const M87dd3b7185ba6a09(),
    const Symbol('fromJson'): const M75d40e8588d10b7a(),
    const Symbol('toJson'): const M328c77a6d4606bd8(),
    const Symbol('toString'): const Mc6139c1dd676c9d1(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocComponents newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocComponents;
    switch(memberName) {
      case const Symbol('schemas'): return instance.schemas;
      case const Symbol("schemas="): instance.schemas = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocComponents\".");
    }
  }
}
// Mirror for class 'AcApiDocContact' from package:ac_web/src/api-docs/models/ac_api_doc_contact.dart
class M25735064d6523bdc extends GeneratedAcClassMirror<AcApiDocContact> {
  const M25735064d6523bdc();
  @override final Symbol simpleName = const Symbol('AcApiDocContact');
  @override final Type reflectedType = AcApiDocContact;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocContact";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('email'): const M6843558f2e2e36da(),
    const Symbol('name'): const M48a34fac1557c67f(),
    const Symbol('url'): const M9d2ae9339751ba7b(),
    const Symbol('fromJson'): const M89dbe143a95a637d(),
    const Symbol('toJson'): const Mf27de754550e3cf6(),
    const Symbol('toString'): const M5accdae2b38bbf96(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocContact newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocContact;
    switch(memberName) {
      case const Symbol('email'): return instance.email;
      case const Symbol("email="): instance.email = positionalArgs[0]; break;
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocContact\".");
    }
  }
}
// Mirror for class 'AcApiDocContent' from package:ac_web/src/api-docs/models/ac_api_doc_content.dart
class M347f55ae3d9e7f7c extends GeneratedAcClassMirror<AcApiDocContent> {
  const M347f55ae3d9e7f7c();
  @override final Symbol simpleName = const Symbol('AcApiDocContent');
  @override final Type reflectedType = AcApiDocContent;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocContent";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('schema'): const M1649e573d0d9f9be(),
    const Symbol('examples'): const Me5b8f89c7d6d762a(),
    const Symbol('encoding'): const M4811340949b1baeb(),
    const Symbol('fromJson'): const M941e211f15ad1858(),
    const Symbol('toJson'): const M4402441f4a07bcf3(),
    const Symbol('toString'): const Me546a57b72c5c2b2(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mad0b26e4a687a8f8(),
  };
  @override AcApiDocContent newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocContent(encoding: namedArgs[const Symbol('encoding')], schema: namedArgs[const Symbol('schema')], examples: namedArgs[const Symbol('examples')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocContent;
    switch(memberName) {
      case const Symbol('schema'): return instance.schema;
      case const Symbol("schema="): instance.schema = positionalArgs[0]; break;
      case const Symbol('examples'): return instance.examples;
      case const Symbol("examples="): instance.examples = positionalArgs[0]; break;
      case const Symbol('encoding'): return instance.encoding;
      case const Symbol("encoding="): instance.encoding = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocContent\".");
    }
  }
}
// Mirror for class 'AcApiDocExternalDocs' from package:ac_web/src/api-docs/models/ac_api_doc_external_docs.dart
class Mf1d62b84786a422b extends GeneratedAcClassMirror<AcApiDocExternalDocs> {
  const Mf1d62b84786a422b();
  @override final Symbol simpleName = const Symbol('AcApiDocExternalDocs');
  @override final Type reflectedType = AcApiDocExternalDocs;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocExternalDocs";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const M71003aa8b1f6dee7(),
    const Symbol('url'): const Md83e4039b0ce8c56(),
    const Symbol('fromJson'): const M1c4067e70e49efad(),
    const Symbol('toJson'): const M3c9b617135e7bf36(),
    const Symbol('toString'): const M202e9402c072c177(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocExternalDocs newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocExternalDocs;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocExternalDocs\".");
    }
  }
}
// Mirror for class 'AcApiDocHeader' from package:ac_web/src/api-docs/models/ac_api_doc_header.dart
class M942705159fa28c42 extends GeneratedAcClassMirror<AcApiDocHeader> {
  const M942705159fa28c42();
  @override final Symbol simpleName = const Symbol('AcApiDocHeader');
  @override final Type reflectedType = AcApiDocHeader;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocHeader";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const Me524d258b6ecfebe(),
    const Symbol('required'): const Mac49b6ae2ee122db(),
    const Symbol('deprecated'): const Mea5e8bc614919be8(),
    const Symbol('schema'): const Ma0ee3337ef2d87dd(),
    const Symbol('fromJson'): const Mc08b3a8417709dd8(),
    const Symbol('toJson'): const M5348e73b095d6ad5(),
    const Symbol('toString'): const M8ffdcb837e8cbf50(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocHeader newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocHeader;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('required'): return instance.required;
      case const Symbol("required="): instance.required = positionalArgs[0]; break;
      case const Symbol('deprecated'): return instance.deprecated;
      case const Symbol("deprecated="): instance.deprecated = positionalArgs[0]; break;
      case const Symbol('schema'): return instance.schema;
      case const Symbol("schema="): instance.schema = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocHeader\".");
    }
  }
}
// Mirror for class 'AcApiDocLicense' from package:ac_web/src/api-docs/models/ac_api_doc_license.dart
class M15aff0c905daed6e extends GeneratedAcClassMirror<AcApiDocLicense> {
  const M15aff0c905daed6e();
  @override final Symbol simpleName = const Symbol('AcApiDocLicense');
  @override final Type reflectedType = AcApiDocLicense;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocLicense";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('name'): const Ma4c41a905a24b6f1(),
    const Symbol('url'): const M0c1f0bb57eab9844(),
    const Symbol('fromJson'): const Mb41a35f9980e470d(),
    const Symbol('toJson'): const M9fe954e29866a356(),
    const Symbol('toString'): const Md22f83c099538f98(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocLicense newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocLicense;
    switch(memberName) {
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocLicense\".");
    }
  }
}
// Mirror for class 'AcApiDocLink' from package:ac_web/src/api-docs/models/ac_api_doc_link.dart
class M93b91dfd648bf950 extends GeneratedAcClassMirror<AcApiDocLink> {
  const M93b91dfd648bf950();
  @override final Symbol simpleName = const Symbol('AcApiDocLink');
  @override final Type reflectedType = AcApiDocLink;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocLink";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('operationId'): const Mcbea47bc302f91df(),
    const Symbol('parameters'): const M85dca8f7afa3dfd0(),
    const Symbol('description'): const Mf8965120fed83533(),
    const Symbol('fromJson'): const M88fe0e0f047786e7(),
    const Symbol('toJson'): const M3e51152c715764f8(),
    const Symbol('toString'): const M977e1425c82f0e01(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocLink newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocLink;
    switch(memberName) {
      case const Symbol('operationId'): return instance.operationId;
      case const Symbol("operationId="): instance.operationId = positionalArgs[0]; break;
      case const Symbol('parameters'): return instance.parameters;
      case const Symbol("parameters="): instance.parameters = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocLink\".");
    }
  }
}
// Mirror for class 'AcApiDocMediaType' from package:ac_web/src/api-docs/models/ac_api_doc_media_type.dart
class M4f0b076ce374759b extends GeneratedAcClassMirror<AcApiDocMediaType> {
  const M4f0b076ce374759b();
  @override final Symbol simpleName = const Symbol('AcApiDocMediaType');
  @override final Type reflectedType = AcApiDocMediaType;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocMediaType";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('schema'): const Me27ad6c98efa9ace(),
    const Symbol('examples'): const Ma31220393207bdc5(),
    const Symbol('fromJson'): const Med124b17ec2e9168(),
    const Symbol('toJson'): const M2550993b98c024ca(),
    const Symbol('toString'): const M8a5067efe1b06f0d(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocMediaType newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocMediaType;
    switch(memberName) {
      case const Symbol('schema'): return instance.schema;
      case const Symbol("schema="): instance.schema = positionalArgs[0]; break;
      case const Symbol('examples'): return instance.examples;
      case const Symbol("examples="): instance.examples = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocMediaType\".");
    }
  }
}
// Mirror for class 'AcApiDocModel' from package:ac_web/src/api-docs/models/ac_api_doc_model.dart
class Mf106bb0c62c6621b extends GeneratedAcClassMirror<AcApiDocModel> {
  const Mf106bb0c62c6621b();
  @override final Symbol simpleName = const Symbol('AcApiDocModel');
  @override final Type reflectedType = AcApiDocModel;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocModel";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('name'): const M7e9780b3d59e51fe(),
    const Symbol('type'): const M76f611e91f17238d(),
    const Symbol('properties'): const M22b19fe49d784861(),
    const Symbol('fromJson'): const M6f62c53323be1794(),
    const Symbol('toJson'): const M3a248ffdaea8c127(),
    const Symbol('toString'): const Me3fe8716c12f121d(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcApiDocModel newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocModel;
    switch(memberName) {
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('type'): return instance.type;
      case const Symbol("type="): instance.type = positionalArgs[0]; break;
      case const Symbol('properties'): return instance.properties;
      case const Symbol("properties="): instance.properties = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocModel\".");
    }
  }
}
// Mirror for class 'AcApiDocOperation' from package:ac_web/src/api-docs/models/ac_api_doc_operation.dart
class M6c25c1bc590eb458 extends GeneratedAcClassMirror<AcApiDocOperation> {
  const M6c25c1bc590eb458();
  @override final Symbol simpleName = const Symbol('AcApiDocOperation');
  @override final Type reflectedType = AcApiDocOperation;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocOperation";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('summary'): const Mbe26d51234d61f11(),
    const Symbol('description'): const Mfcc48715bfbb4f95(),
    const Symbol('parameters'): const Mafe28f5826d5678f(),
    const Symbol('responses'): const Mf20f0b997a4a60d4(),
    const Symbol('fromJson'): const Maf4153956c4f706f(),
    const Symbol('toJson'): const M9c3214b81029557b(),
    const Symbol('toString'): const M63bdbc662224f19b(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M0cf568cd6a29ff9a(),
  };
  @override AcApiDocOperation newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocOperation();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocOperation;
    switch(memberName) {
      case const Symbol('summary'): return instance.summary;
      case const Symbol("summary="): instance.summary = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('parameters'): return instance.parameters;
      case const Symbol("parameters="): instance.parameters = positionalArgs[0]; break;
      case const Symbol('responses'): return instance.responses;
      case const Symbol("responses="): instance.responses = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocOperation\".");
    }
  }
}
// Mirror for class 'AcApiDocParameter' from package:ac_web/src/api-docs/models/ac_api_doc_parameter.dart
class M2c324ecf1995a970 extends GeneratedAcClassMirror<AcApiDocParameter> {
  const M2c324ecf1995a970();
  @override final Symbol simpleName = const Symbol('AcApiDocParameter');
  @override final Type reflectedType = AcApiDocParameter;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocParameter";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const Mcd32ecf3a62537b3(),
    const Symbol('inValue'): const Mbaf9f9846c1b8733(),
    const Symbol('name'): const Mcaf0e44f73d44065(),
    const Symbol('required'): const M6fa84264833adb2f(),
    const Symbol('explode'): const Mddfe86963b142612(),
    const Symbol('schema'): const Mfc9d2ddd6e084353(),
    const Symbol('fromJson'): const Ma9d21780cc5f616a(),
    const Symbol('toJson'): const M61523d86d1e4644d(),
    const Symbol('toString'): const M3ddbcf8843346c52(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Mf3070972d03fe0c8(),
  };
  @override AcApiDocParameter newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocParameter(name: namedArgs[const Symbol('name')], inValue: namedArgs[const Symbol('inValue')], required: namedArgs[const Symbol('required')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocParameter;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('inValue'): return instance.inValue;
      case const Symbol("inValue="): instance.inValue = positionalArgs[0]; break;
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('required'): return instance.required;
      case const Symbol("required="): instance.required = positionalArgs[0]; break;
      case const Symbol('explode'): return instance.explode;
      case const Symbol("explode="): instance.explode = positionalArgs[0]; break;
      case const Symbol('schema'): return instance.schema;
      case const Symbol("schema="): instance.schema = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocParameter\".");
    }
  }
}
// Mirror for class 'AcApiDocPath' from package:ac_web/src/api-docs/models/ac_api_doc_path.dart
class M27932937112bbe36 extends GeneratedAcClassMirror<AcApiDocPath> {
  const M27932937112bbe36();
  @override final Symbol simpleName = const Symbol('AcApiDocPath');
  @override final Type reflectedType = AcApiDocPath;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocPath";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('url'): const M2a930bbc367d3493(),
    const Symbol('connect'): const Mbdde124ac521b04d(),
    const Symbol('get'): const M603c7113bfc43f21(),
    const Symbol('put'): const M2760ab04dcfa92da(),
    const Symbol('post'): const Mb9aca487be52fc81(),
    const Symbol('delete'): const M9e4d0109a993721b(),
    const Symbol('options'): const M4733bd1c01fdbd0f(),
    const Symbol('head'): const M311f0ac31574f48b(),
    const Symbol('patch'): const M72a5473f0f90f66e(),
    const Symbol('trace'): const M8bea8355be11d879(),
    const Symbol('fromJson'): const Mca1c75d11b27fd7f(),
    const Symbol('toJson'): const Mcc9ea065e875008d(),
    const Symbol('toString'): const M2f8c34bc3ed51130(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Ma715721fe3d47bda(),
  };
  @override AcApiDocPath newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocPath();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocPath;
    switch(memberName) {
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('connect'): return instance.connect;
      case const Symbol("connect="): instance.connect = positionalArgs[0]; break;
      case const Symbol('get'): return instance.get;
      case const Symbol("get="): instance.get = positionalArgs[0]; break;
      case const Symbol('put'): return instance.put;
      case const Symbol("put="): instance.put = positionalArgs[0]; break;
      case const Symbol('post'): return instance.post;
      case const Symbol("post="): instance.post = positionalArgs[0]; break;
      case const Symbol('delete'): return instance.delete;
      case const Symbol("delete="): instance.delete = positionalArgs[0]; break;
      case const Symbol('options'): return instance.options;
      case const Symbol("options="): instance.options = positionalArgs[0]; break;
      case const Symbol('head'): return instance.head;
      case const Symbol("head="): instance.head = positionalArgs[0]; break;
      case const Symbol('patch'): return instance.patch;
      case const Symbol("patch="): instance.patch = positionalArgs[0]; break;
      case const Symbol('trace'): return instance.trace;
      case const Symbol("trace="): instance.trace = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocPath\".");
    }
  }
}
// Mirror for class 'AcApiDocRequestBody' from package:ac_web/src/api-docs/models/ac_api_doc_request_body.dart
class M66db2128cbc36980 extends GeneratedAcClassMirror<AcApiDocRequestBody> {
  const M66db2128cbc36980();
  @override final Symbol simpleName = const Symbol('AcApiDocRequestBody');
  @override final Type reflectedType = AcApiDocRequestBody;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocRequestBody";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const M1599af3b14c3c0c4(),
    const Symbol('content'): const M4a1ac7df78a4eb65(),
    const Symbol('required'): const Mfbe346f8e0f4981d(),
    const Symbol('fromJson'): const M56a2280721ff7b54(),
    const Symbol('addContent'): const Mcd89b682c012d42e(),
    const Symbol('toJson'): const Mfaf23088d059f56d(),
    const Symbol('toString'): const Mb0dd2c1cd7a81789(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Me6b1f191b52b867e(),
  };
  @override AcApiDocRequestBody newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocRequestBody();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocRequestBody;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('content'): return instance.content;
      case const Symbol("content="): instance.content = positionalArgs[0]; break;
      case const Symbol('required'): return instance.required;
      case const Symbol("required="): instance.required = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('addContent'): instance.addContent(content: namedArgs[const Symbol('content')]); break;
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocRequestBody\".");
    }
  }
}
// Mirror for class 'AcApiDocResponse' from package:ac_web/src/api-docs/models/ac_api_doc_response.dart
class M37056022a4d2e09b extends GeneratedAcClassMirror<AcApiDocResponse> {
  const M37056022a4d2e09b();
  @override final Symbol simpleName = const Symbol('AcApiDocResponse');
  @override final Type reflectedType = AcApiDocResponse;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocResponse";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('code'): const Mdec0c74ff9a28a85(),
    const Symbol('description'): const Mfbc84a9e91484fc7(),
    const Symbol('headers'): const M2c6368040dd3bc89(),
    const Symbol('content'): const M3fcb2b623ff4795b(),
    const Symbol('links'): const M2c97e80472ac2c9c(),
    const Symbol('addContent'): const M5a5b998f180be9eb(),
    const Symbol('fromJson'): const M0573079cc0217cc5(),
    const Symbol('toJson'): const M92e8c4e800f78743(),
    const Symbol('toString'): const M2f9c3e6d78323882(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M1d544d2fb9edc0a8(),
  };
  @override AcApiDocResponse newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocResponse();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocResponse;
    switch(memberName) {
      case const Symbol('code'): return instance.code;
      case const Symbol("code="): instance.code = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('headers'): return instance.headers;
      case const Symbol("headers="): instance.headers = positionalArgs[0]; break;
      case const Symbol('content'): return instance.content;
      case const Symbol("content="): instance.content = positionalArgs[0]; break;
      case const Symbol('links'): return instance.links;
      case const Symbol("links="): instance.links = positionalArgs[0]; break;
      case const Symbol('addContent'): instance.addContent(content: namedArgs[const Symbol('content')]); break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocResponse\".");
    }
  }
}
// Mirror for class 'AcApiDocRoute' from package:ac_web/src/api-docs/models/ac_api_doc_route.dart
class M42d7c58ed1b04b3c extends GeneratedAcClassMirror<AcApiDocRoute> {
  const M42d7c58ed1b04b3c();
  @override final Symbol simpleName = const Symbol('AcApiDocRoute');
  @override final Type reflectedType = AcApiDocRoute;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocRoute";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('tags'): const M02bc30c534bb63ef(),
    const Symbol('summary'): const M640d652988c20f45(),
    const Symbol('description'): const M75b5c61fe0bf7594(),
    const Symbol('operationId'): const M0bac4baa7c372109(),
    const Symbol('parameters'): const M5ddb54f0566ef0db(),
    const Symbol('requestBody'): const Me6b0c0ff763e248e(),
    const Symbol('responses'): const M3b2c492a0339efbb(),
    const Symbol('consumes'): const Md8de352ce9783445(),
    const Symbol('produces'): const Mba60ff4ff97fcdfb(),
    const Symbol('deprecated'): const M49b7240dcec6dc0f(),
    const Symbol('security'): const Me1f2fd0570b8e4e4(),
    const Symbol('fromJson'): const Md565afd55f963ac1(),
    const Symbol('addParameter'): const Mec93c1f73f362d12(),
    const Symbol('addResponse'): const M960130c282a914ad(),
    const Symbol('addTag'): const M326bcfc9fe8e3535(),
    const Symbol('toJson'): const Mc395c8385b880178(),
    const Symbol('toString'): const Me2e58daba531f1c0(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const Ma34b28261f04c425(),
  };
  @override AcApiDocRoute newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocRoute();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocRoute;
    switch(memberName) {
      case const Symbol('tags'): return instance.tags;
      case const Symbol("tags="): instance.tags = positionalArgs[0]; break;
      case const Symbol('summary'): return instance.summary;
      case const Symbol("summary="): instance.summary = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('operationId'): return instance.operationId;
      case const Symbol("operationId="): instance.operationId = positionalArgs[0]; break;
      case const Symbol('parameters'): return instance.parameters;
      case const Symbol("parameters="): instance.parameters = positionalArgs[0]; break;
      case const Symbol('requestBody'): return instance.requestBody;
      case const Symbol("requestBody="): instance.requestBody = positionalArgs[0]; break;
      case const Symbol('responses'): return instance.responses;
      case const Symbol("responses="): instance.responses = positionalArgs[0]; break;
      case const Symbol('consumes'): return instance.consumes;
      case const Symbol("consumes="): instance.consumes = positionalArgs[0]; break;
      case const Symbol('produces'): return instance.produces;
      case const Symbol("produces="): instance.produces = positionalArgs[0]; break;
      case const Symbol('deprecated'): return instance.deprecated;
      case const Symbol("deprecated="): instance.deprecated = positionalArgs[0]; break;
      case const Symbol('security'): return instance.security;
      case const Symbol("security="): instance.security = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('addParameter'): return instance.addParameter(parameter: namedArgs[const Symbol('parameter')]);
      case const Symbol('addResponse'): return instance.addResponse(response: namedArgs[const Symbol('response')]);
      case const Symbol('addTag'): return instance.addTag(tag: namedArgs[const Symbol('tag')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocRoute\".");
    }
  }
}
// Mirror for class 'AcApiDocSchema' from package:ac_web/src/api-docs/models/ac_api_doc_schema.dart
class Me89d03398bee8173 extends GeneratedAcClassMirror<AcApiDocSchema> {
  const Me89d03398bee8173();
  @override final Symbol simpleName = const Symbol('AcApiDocSchema');
  @override final Type reflectedType = AcApiDocSchema;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocSchema";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('type'): const M21bfa7195afed747(),
    const Symbol('format'): const Me559682be0e64f20(),
    const Symbol('title'): const Mce3ce5f0cdf818d2(),
    const Symbol('description'): const M707df3cbc092b5f1(),
    const Symbol('properties'): const M3420c9ff13b58f35(),
    const Symbol('required'): const M8ac1687624b3bf67(),
    const Symbol('items'): const M754dd5d1d39add7a(),
    const Symbol('enumValues'): const Me9ea0524886f02c2(),
    const Symbol('fromJson'): const Md7b0679141aafa53(),
    const Symbol('toJson'): const M4c1131b6758d377c(),
    const Symbol('toString'): const Mda26ef9fcc3738fa(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M3fe35d2ae26f1ffc(),
  };
  @override AcApiDocSchema newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocSchema();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocSchema;
    switch(memberName) {
      case const Symbol('type'): return instance.type;
      case const Symbol("type="): instance.type = positionalArgs[0]; break;
      case const Symbol('format'): return instance.format;
      case const Symbol("format="): instance.format = positionalArgs[0]; break;
      case const Symbol('title'): return instance.title;
      case const Symbol("title="): instance.title = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('properties'): return instance.properties;
      case const Symbol("properties="): instance.properties = positionalArgs[0]; break;
      case const Symbol('required'): return instance.required;
      case const Symbol("required="): instance.required = positionalArgs[0]; break;
      case const Symbol('items'): return instance.items;
      case const Symbol("items="): instance.items = positionalArgs[0]; break;
      case const Symbol('enumValues'): return instance.enumValues;
      case const Symbol("enumValues="): instance.enumValues = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocSchema\".");
    }
  }
}
// Mirror for class 'AcApiDocSecurityRequirement' from package:ac_web/src/api-docs/models/ac_api_doc_security_requirement.dart
class M1c430afef1e87984 extends GeneratedAcClassMirror<AcApiDocSecurityRequirement> {
  const M1c430afef1e87984();
  @override final Symbol simpleName = const Symbol('AcApiDocSecurityRequirement');
  @override final Type reflectedType = AcApiDocSecurityRequirement;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocSecurityRequirement";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('requirements'): const Mde4646d95fdcdeb1(),
    const Symbol('fromJson'): const M8777f04e8c5ce542(),
    const Symbol('toJson'): const M069b48db74052b52(),
    const Symbol('toString'): const Ma049ce68a2ed0d24(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M7223b0b4424857d4(),
  };
  @override AcApiDocSecurityRequirement newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocSecurityRequirement();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocSecurityRequirement;
    switch(memberName) {
      case const Symbol('requirements'): return instance.requirements;
      case const Symbol("requirements="): instance.requirements = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocSecurityRequirement\".");
    }
  }
}
// Mirror for class 'AcApiDocSecurityScheme' from package:ac_web/src/api-docs/models/ac_api_doc_security_scheme.dart
class M67e50b4e037a57c1 extends GeneratedAcClassMirror<AcApiDocSecurityScheme> {
  const M67e50b4e037a57c1();
  @override final Symbol simpleName = const Symbol('AcApiDocSecurityScheme');
  @override final Type reflectedType = AcApiDocSecurityScheme;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocSecurityScheme";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('type'): const M543866960bf126b4(),
    const Symbol('description'): const M99f86f117ccd9a9f(),
    const Symbol('name'): const Mf0e9f76e8071c8d8(),
    const Symbol('in_'): const M72b32274ae3a02a7(),
    const Symbol('scheme'): const Me77badfb01326c93(),
    const Symbol('bearerFormat'): const Md1e8b7af196ba1ce(),
    const Symbol('flows'): const Mcc0055b41ab8ea28(),
    const Symbol('openIdConnectUrl'): const M45f1f52285ac305d(),
    const Symbol('fromJson'): const M944bd1e26a53005d(),
    const Symbol('toJson'): const M0d18e0533ecff9e0(),
    const Symbol('toString'): const Mdf27f29ded041be7(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M7f653c41f10d6f5c(),
  };
  @override AcApiDocSecurityScheme newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocSecurityScheme();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocSecurityScheme;
    switch(memberName) {
      case const Symbol('type'): return instance.type;
      case const Symbol("type="): instance.type = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('in_'): return instance.in_;
      case const Symbol("in_="): instance.in_ = positionalArgs[0]; break;
      case const Symbol('scheme'): return instance.scheme;
      case const Symbol("scheme="): instance.scheme = positionalArgs[0]; break;
      case const Symbol('bearerFormat'): return instance.bearerFormat;
      case const Symbol("bearerFormat="): instance.bearerFormat = positionalArgs[0]; break;
      case const Symbol('flows'): return instance.flows;
      case const Symbol("flows="): instance.flows = positionalArgs[0]; break;
      case const Symbol('openIdConnectUrl'): return instance.openIdConnectUrl;
      case const Symbol("openIdConnectUrl="): instance.openIdConnectUrl = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocSecurityScheme\".");
    }
  }
}
// Mirror for class 'AcApiDocServer' from package:ac_web/src/api-docs/models/ac_api_doc_server.dart
class Mc8d89388685152a3 extends GeneratedAcClassMirror<AcApiDocServer> {
  const Mc8d89388685152a3();
  @override final Symbol simpleName = const Symbol('AcApiDocServer');
  @override final Type reflectedType = AcApiDocServer;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocServer";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('description'): const M71cb2e5e44abe58b(),
    const Symbol('title'): const Md6d9cc3b384cd38d(),
    const Symbol('url'): const M115917123e74c3a3(),
    const Symbol('fromJson'): const M5fb8cecd36b3f44d(),
    const Symbol('toJson'): const Mb7494c526c42d241(),
    const Symbol('toString'): const Mb666766f30a52dfa(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M1294ce2dc502f60e(),
  };
  @override AcApiDocServer newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocServer(url: namedArgs[const Symbol('url')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocServer;
    switch(memberName) {
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('title'): return instance.title;
      case const Symbol("title="): instance.title = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocServer\".");
    }
  }
}
// Mirror for class 'AcApiDocTag' from package:ac_web/src/api-docs/models/ac_api_doc_tag.dart
class M503f5e94bc342480 extends GeneratedAcClassMirror<AcApiDocTag> {
  const M503f5e94bc342480();
  @override final Symbol simpleName = const Symbol('AcApiDocTag');
  @override final Type reflectedType = AcApiDocTag;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcApiDocTag";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('name'): const M72f6557db3e83ceb(),
    const Symbol('description'): const Md7cdcfc8f103f5df(),
    const Symbol('externalDocs'): const M4609063ae1597f37(),
    const Symbol('fromJson'): const Mf4eedf40dc188659(),
    const Symbol('toJson'): const M11212360d3f8f4ab(),
    const Symbol('toString'): const Me1efdbfe9a61fb62(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M8a92ab8308bc17c9(),
  };
  @override AcApiDocTag newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcApiDocTag();
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcApiDocTag;
    switch(memberName) {
      case const Symbol('name'): return instance.name;
      case const Symbol("name="): instance.name = positionalArgs[0]; break;
      case const Symbol('description'): return instance.description;
      case const Symbol("description="): instance.description = positionalArgs[0]; break;
      case const Symbol('externalDocs'): return instance.externalDocs;
      case const Symbol("externalDocs="): instance.externalDocs = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(jsonData: namedArgs[const Symbol('jsonData')]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcApiDocTag\".");
    }
  }
}
// Mirror for class 'AcWebApiResponse' from package:ac_web/src/models/ac_web_api_response.dart
class M5183449a5dac52e2 extends GeneratedAcClassMirror<AcWebApiResponse> {
  const M5183449a5dac52e2();
  @override final Symbol simpleName = const Symbol('AcWebApiResponse');
  @override final Type reflectedType = AcWebApiResponse;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebApiResponse";
  @override AcClassMirror? get superclass => acReflectClass(AcResult);
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcWebApiResponse newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebApiResponse;
    switch(memberName) {
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebApiResponse\".");
    }
  }
}
// Mirror for class 'AcWebHookCreatedArgs' from package:ac_web/src/models/ac_web_hook_created_args.dart
class M40fae87520b67a0f extends GeneratedAcClassMirror<AcWebHookCreatedArgs> {
  const M40fae87520b67a0f();
  @override final Symbol simpleName = const Symbol('AcWebHookCreatedArgs');
  @override final Type reflectedType = AcWebHookCreatedArgs;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebHookCreatedArgs";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('acWeb'): const M07a06972d1620730(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
    "": const M458afe870b81b575(),
  };
  @override AcWebHookCreatedArgs newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      case "": return AcWebHookCreatedArgs(acWeb: namedArgs[const Symbol('acWeb')]);
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebHookCreatedArgs;
    switch(memberName) {
      case const Symbol('acWeb'): return instance.acWeb;
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebHookCreatedArgs\".");
    }
  }
}
// Mirror for class 'AcWebRequest' from package:ac_web/src/models/ac_web_request.dart
class Mcb2ba195c6d99f07 extends GeneratedAcClassMirror<AcWebRequest> {
  const Mcb2ba195c6d99f07();
  @override final Symbol simpleName = const Symbol('AcWebRequest');
  @override final Type reflectedType = AcWebRequest;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRequest";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('body'): const M211dfbc211ff3394(),
    const Symbol('cookies'): const Mb682f5df3b1e41ab(),
    const Symbol('files'): const Ma7be951be626f730(),
    const Symbol('get'): const M18660e0ef1a39405(),
    const Symbol('headers'): const M464b7e0119422661(),
    const Symbol('method'): const Mc428f45bcfbf45f9(),
    const Symbol('pathParameters'): const Mb4a78e16d2a00a23(),
    const Symbol('post'): const M72f33d767a3aeb67(),
    const Symbol('session'): const M497256d07e944edd(),
    const Symbol('url'): const M38d6a6138678a65a(),
    const Symbol('fromJson'): const M5ccdb55d8d1115d1(),
    const Symbol('toJson'): const M4a69930d48ae7faf(),
    const Symbol('toString'): const M092f26b4af4d492c(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcWebRequest newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRequest;
    switch(memberName) {
      case const Symbol('body'): return instance.body;
      case const Symbol("body="): instance.body = positionalArgs[0]; break;
      case const Symbol('cookies'): return instance.cookies;
      case const Symbol("cookies="): instance.cookies = positionalArgs[0]; break;
      case const Symbol('files'): return instance.files;
      case const Symbol("files="): instance.files = positionalArgs[0]; break;
      case const Symbol('get'): return instance.get;
      case const Symbol("get="): instance.get = positionalArgs[0]; break;
      case const Symbol('headers'): return instance.headers;
      case const Symbol("headers="): instance.headers = positionalArgs[0]; break;
      case const Symbol('method'): return instance.method;
      case const Symbol("method="): instance.method = positionalArgs[0]; break;
      case const Symbol('pathParameters'): return instance.pathParameters;
      case const Symbol("pathParameters="): instance.pathParameters = positionalArgs[0]; break;
      case const Symbol('post'): return instance.post;
      case const Symbol("post="): instance.post = positionalArgs[0]; break;
      case const Symbol('session'): return instance.session;
      case const Symbol("session="): instance.session = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(positionalArgs[0]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRequest\".");
    }
  }
}
// Mirror for class 'AcWebResponse' from package:ac_web/src/models/ac_web_response.dart
class M6c675e0b5baa07ad extends GeneratedAcClassMirror<AcWebResponse> {
  const M6c675e0b5baa07ad();
  @override final Symbol simpleName = const Symbol('AcWebResponse');
  @override final Type reflectedType = AcWebResponse;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebResponse";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('cookies'): const M3b540ea495e3043e(),
    const Symbol('content'): const Maa469c892724e62d(),
    const Symbol('headers'): const Mbcefa3df9fcfd3a3(),
    const Symbol('responseCode'): const Mb68dbf5422910755(),
    const Symbol('responseType'): const M78826b98bda98f6d(),
    const Symbol('session'): const M53838207dc396c01(),
    const Symbol('fromJson'): const M5c3d31a3c022342b(),
    const Symbol('toJson'): const M18ae0b024a124370(),
    const Symbol('toString'): const M60095219ebbbb372(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcWebResponse newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebResponse;
    switch(memberName) {
      case const Symbol('cookies'): return instance.cookies;
      case const Symbol("cookies="): instance.cookies = positionalArgs[0]; break;
      case const Symbol('content'): return instance.content;
      case const Symbol("content="): instance.content = positionalArgs[0]; break;
      case const Symbol('headers'): return instance.headers;
      case const Symbol("headers="): instance.headers = positionalArgs[0]; break;
      case const Symbol('responseCode'): return instance.responseCode;
      case const Symbol("responseCode="): instance.responseCode = positionalArgs[0]; break;
      case const Symbol('responseType'): return instance.responseType;
      case const Symbol("responseType="): instance.responseType = positionalArgs[0]; break;
      case const Symbol('session'): return instance.session;
      case const Symbol("session="): instance.session = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(positionalArgs[0]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebResponse\".");
    }
  }
}
// Mirror for class 'AcWebRouteDefinition' from package:ac_web/src/models/ac_web_route_definition.dart
class M047a80c0cd4ab4ce extends GeneratedAcClassMirror<AcWebRouteDefinition> {
  const M047a80c0cd4ab4ce();
  @override final Symbol simpleName = const Symbol('AcWebRouteDefinition');
  @override final Type reflectedType = AcWebRouteDefinition;
  @override final bool isAbstract = false;
  @override bool get isEnum => false;
  @override final bool isStatic = false;
  @override final bool isPrivate = false;
  @override final List<Object> metadata = const [const AcReflectable()];
  @override String getName() => "AcWebRouteDefinition";
  @override AcClassMirror? get superclass => null;
  @override List<AcClassMirror> get superinterfaces => const [];
  @override Map<Symbol, AcDeclarationMirror> get instanceMembers => const {
    const Symbol('controller'): const M9f5216d42f8766c6(),
    const Symbol('handler'): const M92264e97bca8ae52(),
    const Symbol('documentation'): const Mb1a0095ea15f2b74(),
    const Symbol('method'): const M916f946984a64e17(),
    const Symbol('url'): const Ma5fd545a52ff4eb0(),
    const Symbol('fromJson'): const Mdde683f4b3804407(),
    const Symbol('toJson'): const M2966903212510efe(),
    const Symbol('toString'): const Mef57e637b53c3087(),
  };
  @override Map<Symbol, AcDeclarationMirror> get staticMembers => const {};
  @override Map<String, AcMethodMirror> get constructors => const {
  };
  @override AcWebRouteDefinition newInstance(String constructorName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    switch(constructorName) {
      default: throw UnimplementedError("Constructor \"$constructorName\" not found or supported.");
    }
  }
  @override dynamic invoke(Object target, Symbol memberName, List<dynamic> positionalArgs, [Map<Symbol, dynamic> namedArgs = const {}]) {
    final instance = target as AcWebRouteDefinition;
    switch(memberName) {
      case const Symbol('controller'): return instance.controller;
      case const Symbol("controller="): instance.controller = positionalArgs[0]; break;
      case const Symbol('handler'): return instance.handler;
      case const Symbol("handler="): instance.handler = positionalArgs[0]; break;
      case const Symbol('documentation'): return instance.documentation;
      case const Symbol("documentation="): instance.documentation = positionalArgs[0]; break;
      case const Symbol('method'): return instance.method;
      case const Symbol("method="): instance.method = positionalArgs[0]; break;
      case const Symbol('url'): return instance.url;
      case const Symbol("url="): instance.url = positionalArgs[0]; break;
      case const Symbol('fromJson'): return instance.fromJson(positionalArgs[0]);
      case const Symbol('toJson'): return instance.toJson();
      case const Symbol('toString'): return instance.toString();
      default: throw UnimplementedError("Cannot invoke \"${_symbolToName(memberName)}\" on \"AcWebRouteDefinition\".");
    }
  }
}

final Map<Type, AcClassMirror> generatedMirrors = {
  Person: const M9de5013872b008c0(),
  Loggable: const Medbdbc3ddc5e0fa2(),
  Customer: const M1816c8f57495f99d(),
  AcCronJob: const Mb7e4f802e54e406b(),
  AcEventExecutionResult: const Mf232179b81a97a4a(),
  AcHookExecutionResult: const Mb9a613430d432993(),
  AcHookResult: const Mc25dfe08452d40b4(),
  AcResult: const M178ccbf6b44e0b5c(),
  AcDataDictionary: const Mfe32d12cf4c1dcaf(),
  AcDDCondition: const Ma517f98f8ca98662(),
  AcDDConditionGroup: const M2a6f21ebb7456698(),
  AcDDFunction: const Md9f09978b1af32b8(),
  AcDDRelationship: const M95af1c3af8cb7557(),
  AcDDSelectStatement: const M53011bdc418686a6(),
  AcDDStoredProcedure: const Me042b0895f903542(),
  AcDDTable: const M18b4d03ffdbf7b96(),
  AcDDTableColumn: const Md7f6176436681ad5(),
  AcDDTableColumnProperty: const M6317e0d183c3ecbb(),
  AcDDTableProperty: const Mdb3734d0dfc95927(),
  AcDDTrigger: const M8421f8b971ce0eb5(),
  AcDDView: const Ma2cb0993a55207b1(),
  AcDDViewColumn: const Meba4079f0b558179(),
  AcSqlConnection: const M0549a1820c2aa7ea(),
  AcSqlDaoResult: const M84ddf7ecf475fedc(),
  AcWebAuthorize: const M2baf6f01ec86f544(),
  AcWebController: const Md8e9680648b80da9(),
  AcWebInject: const Ma7d862ba95e1a82d(),
  AcWebMiddleware: const M872c7741b2654035(),
  AcWebRepository: const M03c0f02de75fdabf(),
  AcWebRoute: const M5de18f4e1b29ec4d(),
  AcWebRouteConsumes: const M9bb45b697573a801(),
  AcWebRouteMeta: const Mdce8c0e2f45729fa(),
  AcWebRouteMetaParameter: const Md74f8b43d45589a8(),
  AcWebRouteProduces: const Me22c0f10728938fe(),
  AcWebService: const M8c7560d77c2b9fad(),
  AcWebValueFromBody: const M02c3b522bd6efe0b(),
  AcWebValueFromCookie: const M90149e3a29b1be81(),
  AcWebValueFromForm: const M33c21270ff8b8433(),
  AcWebValueFromHeader: const M7fbaa93addc0a6b2(),
  AcWebValueFromPath: const Mb6152f2d9f9e3453(),
  AcWebValueFromQuery: const M4f7d583e7d694601(),
  AcWebView: const Me39d769858824c2a(),
  AcApiDoc: const Mb09ba0f6f09f9f5d(),
  AcApiDocComponents: const M5936e5c29743238f(),
  AcApiDocContact: const M25735064d6523bdc(),
  AcApiDocContent: const M347f55ae3d9e7f7c(),
  AcApiDocExternalDocs: const Mf1d62b84786a422b(),
  AcApiDocHeader: const M942705159fa28c42(),
  AcApiDocLicense: const M15aff0c905daed6e(),
  AcApiDocLink: const M93b91dfd648bf950(),
  AcApiDocMediaType: const M4f0b076ce374759b(),
  AcApiDocModel: const Mf106bb0c62c6621b(),
  AcApiDocOperation: const M6c25c1bc590eb458(),
  AcApiDocParameter: const M2c324ecf1995a970(),
  AcApiDocPath: const M27932937112bbe36(),
  AcApiDocRequestBody: const M66db2128cbc36980(),
  AcApiDocResponse: const M37056022a4d2e09b(),
  AcApiDocRoute: const M42d7c58ed1b04b3c(),
  AcApiDocSchema: const Me89d03398bee8173(),
  AcApiDocSecurityRequirement: const M1c430afef1e87984(),
  AcApiDocSecurityScheme: const M67e50b4e037a57c1(),
  AcApiDocServer: const Mc8d89388685152a3(),
  AcApiDocTag: const M503f5e94bc342480(),
  AcWebApiResponse: const M5183449a5dac52e2(),
  AcWebHookCreatedArgs: const M40fae87520b67a0f(),
  AcWebRequest: const Mcb2ba195c6d99f07(),
  AcWebResponse: const M6c675e0b5baa07ad(),
  AcWebRouteDefinition: const M047a80c0cd4ab4ce(),
};

void acMirrorsInitialize() { initializeAcMirrors(generatedMirrors); }
