import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the arguments for a 'created' webhook.",
  "description": "This class encapsulates the data passed to a webhook that fires after the main `AcWeb` server instance has been created and initialized. It provides access to the `AcWeb` instance itself, allowing hooks to interact with the server.",
  "example": "void onServerCreated(AcWebHookCreatedArgs args) {\n  print('Web server has been created!');\n  // Access the server instance\n  final serverInstance = args.acWeb;\n  // ... register a new route or perform other setup ...\n}"
}) */
@AcReflectable()
class AcWebHookCreatedArgs {
  /* AcDoc({
    "summary": "The main `AcWeb` server instance that was just created."
  }) */
  final AcWeb acWeb;

  /* AcDoc({
    "summary": "Creates an instance of the arguments for the 'created' webhook.",
    "params": [
      {"name": "acWeb", "description": "The `AcWeb` server instance."}
    ]
  }) */
  AcWebHookCreatedArgs({required this.acWeb});
}