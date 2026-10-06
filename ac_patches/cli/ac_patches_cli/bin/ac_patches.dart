import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:ac_patches_cli/ac_patches_cli.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'ac_patches',
    'ac_patches CLI — Production-grade self-hosted Flutter Over-The-Air (OTA) patching tool.',
  );

  runner.addCommand(InitCommand());
  runner.addCommand(KeysCommand());
  runner.addCommand(ReleaseCommand());
  runner.addCommand(PatchCommand());
  runner.addCommand(PublishCommand());
  runner.addCommand(RollbackCommand());
  runner.addCommand(DoctorCommand());
  runner.addCommand(StatusCommand());
  runner.addCommand(InspectCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e.message);
    print('');
    print(e.usage);
    exitCode = 64;
  } catch (e, st) {
    print('❌ Unexpected error: $e');
    print(st);
    exitCode = 1;
  }
}
