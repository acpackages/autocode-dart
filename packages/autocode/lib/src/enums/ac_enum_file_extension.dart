import 'package:ac_mirrors/ac_mirrors.dart';

/* AcDoc({
  "description": "Enumeration of common file extensions used across file types and formats.",
  "author": "Sanket Patel",
  "type": "development"
}) */
@AcReflectable()
enum AcEnumFileExtension {
  aac('aac'),
  aaf('aaf'),
  aca('aca'),
  accdb('accdb'),
  accde('accde'),
  accdt('accdt'),
  acx('acx'),
  adt('adt'),
  adts('adts'),
  afm('afm'),
  ai('ai'),
  aif('aif'),
  aifc('aifc'),
  aiff('aiff'),
  application('application'),
  art('art'),
  asd('asd'),
  asf('asf'),
  asi('asi'),
  asm('asm'),
  asr('asr'),
  asx('asx'),
  atom('atom'),
  au('au'),
  avi('avi'),
  axs('axs'),
  bas('bas'),
  bcpios('bcpio'),
  bin('bin'),
  bmp('bmp'),
  c('c'),
  cab('cab'),
  calx('calx'),
  cat('cat'),
  cdf('cdf'),
  chm('chm'),
  clp('clp'),
  cmx('cmx'),
  cnf('cnf'),
  cod('cod'),
  cpio('cpio'),
  cpp('cpp'),
  crd('crd'),
  crl('crl'),
  crt('crt'),
  csh('csh'),
  css('css'),
  csv('csv'),
  cur('cur'),
  dcr('dcr'),
  deploy('deploy'),
  der('der'),
  dib('dib'),
  dir('dir'),
  disco('disco'),
  dll('dll'),
  dllconfig('dllconfig'),
  dlm('dlm'),
  doc('doc'),
  docm('docm'),
  docx('docx'),
  dot('dot'),
  dotm('dotm'),
  dotx('dotx'),
  dsp('dsp'),
  dtd('dtd'),
  dvi('dvi'),
  dvr_ms('dvr_ms'),
  dwf('dwf'),
  dwp('dwp'),
  dxr('dxr'),
  eml('eml'),
  emz('emz'),
  eot('eot'),
  eps('eps'),
  etx('etx'),
  evy('evy'),
  exe('exe'),
  execonfig('execonfig'),
  f90('f90'),
  fbx('fbx'),
  fdf('fdf'),
  fif('fif'),
  fla('fla'),
  flac('flac'),
  flf('flf'),
  flr('flr'),
  flv('flv'),
  fox('fox'),
  fpx('fpx'),
  fst('fst'),
  ftl('ftl'),
  ftn('ftn'),
  gbx('gbx'),
  gdb('gdb'),
  gds('gds'),
  gif('gif'),
  git('git'),
  gpx('gpx'),
  gsi('gsi'),
  gtar('gtar'),
  gz('gz'),
  h('h'),
  har('har'),
  hbm('hbm'),
  hdd('hdd'),
  hdf('hdf'),
  html('html'),
  ico('ico'),
  ics('ics'),
  idml('idml'),
  ief('ief'),
  ini('ini'),
  iso('iso'),
  jar('jar'),
  java('java'),
  jpeg('jpeg'),
  jpg('jpg'),
  js('js'),
  json('json'),
  jsx('jsx'),
  log('log'),
  lua('lua'),
  md('md'),
  mht('mht'),
  mkv('mkv'),
  mp3('mp3'),
  mp4('mp4'),
  pdf('pdf'),
  php('php'),
  png('png'),
  pptx('pptx'),
  rar('rar'),
  sql('sql'),
  svg('svg'),
  tar('tar'),
  txt('txt'),
  xlsx('xlsx'),
  xml('xml'),
  zip('zip'),
  seven_z('7z'),
  three_gp('3gp');

  /* AcDoc({"description": "The string value of the file extension."}) */
  final String value;

  /* AcDoc({"description": "Constructor that sets the file extension string value."}) */
  const AcEnumFileExtension(this.value);

  /* AcDoc({
    "description": "Returns the enum value matching the provided string.",
    "params": [{"name": "value", "description": "The file extension as string."}],
    "returns": "Corresponding enum instance or null if no match found."
  }) */
  static AcEnumFileExtension? fromValue(String value) {
    try {
      return AcEnumFileExtension.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  /* AcDoc({
    "description": "Checks if the enum's string value matches another string.",
    "params": [{"name": "other", "description": "The value to compare."}],
    "returns": "true if values match, otherwise false."
  }) */
  bool equals(String other) => value == other;

  /* AcDoc({"description": "Returns the file extension as a string."}) */
  @override
  String toString() => value;

  dynamic toJson() {
    return value;
  }
}
