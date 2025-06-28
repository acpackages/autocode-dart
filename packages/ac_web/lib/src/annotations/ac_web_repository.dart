import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "summary": "An annotation to mark a class as a data repository.",
  "description": "This is a marker annotation used to identify a class that implements the repository pattern. A repository typically encapsulates data access logic for a specific domain entity, abstracting the underlying data source (e.g., a database, a remote API). The framework can use this annotation for dependency injection or to apply specific behaviors to repository classes.",
  "example": "@AcWebRepository()\nclass UserRepository {\n  final AcBaseSqlDao _dao;\n\n  UserRepository(this._dao);\n\n  Future<User?> findById(int id) async {\n    // ... logic to fetch a user from the database ...\n  }\n\n  Future<void> save(User user) async {\n    // ... logic to save a user to the database ...\n  }\n}"
}) */
@AcReflectable()
class AcWebRepository {
  /* AcDoc({
    "summary": "Creates the marker annotation for a repository."
  }) */
  const AcWebRepository();
}