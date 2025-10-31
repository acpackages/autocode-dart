class AcDataDictionaryAutoApiConfig{
  static String pathForDelete = 'delete';

  /* AcDoc({"summary": "The URL path segment for generated 'insert' routes."}) */
  static String pathForInsert = 'add';

  /* AcDoc({"summary": "The URL path segment for generated 'save' (upsert) routes."}) */
  static String pathForSave = 'save';

  /* AcDoc({"summary": "The URL path segment for generated 'select' (get) routes."}) */
  static String pathForSelect = 'get';

  /* AcDoc({"summary": "The URL path segment for generated 'select distinct' routes."}) */
  static String pathForSelectDistinct = 'unique';

  /* AcDoc({"summary": "The URL path segment for generated 'update' routes."}) */
  static String pathForUpdate = 'update';

  static String selectParameterQueryKey = "query";

  static String selectParameterPageNumberKey = "pageNumber";

  static String selectParameterPageSizeKey = "pageSize";

  static String selectParameterOrderByKey = "orderBy";

  static String selectParameterFiltersKey = "filters";

  static String selectParameterIncludeColumnsKey = "includeColumns";

  static String selectParameterExcludeColumnsKey = "excludeColumns";
}

