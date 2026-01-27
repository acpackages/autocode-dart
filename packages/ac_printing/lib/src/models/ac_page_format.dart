import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:autocode/autocode.dart';
import 'package:pdf/pdf.dart';

const Map<String,Map<String,dynamic>> acPageFormats = {
// ISO A Series (existing, fixed)
"4A0": { "name": "4A0", "widthMm": 1682, "heightMm": 2378, "title": "4A0", "isRoll": false },
"2A0": { "name": "2A0", "widthMm": 1189, "heightMm": 1682, "title": "2A0", "isRoll": false },
"A0": { "name": "A0", "widthMm": 841, "heightMm": 1189, "title": "A0", "isRoll": false },
"A1": { "name": "A1", "widthMm": 594, "heightMm": 841, "title": "A1", "isRoll": false },
"A2": { "name": "A2", "widthMm": 420, "heightMm": 594, "title": "A2", "isRoll": false },
"A3": { "name": "A3", "widthMm": 297, "heightMm": 420, "title": "A3", "isRoll": false },
"A4": { "name": "A4", "widthMm": 210, "heightMm": 297, "title": "A4", "isRoll": false },
"A5": { "name": "A5", "widthMm": 148, "heightMm": 210, "title": "A5", "isRoll": false },
"A6": { "name": "A6", "widthMm": 105, "heightMm": 148, "title": "A6", "isRoll": false },
"A7": { "name": "A7", "widthMm": 74, "heightMm": 105, "title": "A7", "isRoll": false },
"A8": { "name": "A8", "widthMm": 52, "heightMm": 74, "title": "A8", "isRoll": false },
"A9": { "name": "A9", "widthMm": 37, "heightMm": 52, "title": "A9", "isRoll": false },
"A10": { "name": "A10", "widthMm": 26, "heightMm": 37, "title": "A10", "isRoll": false },

// ISO B Series (existing, fixed)
"B0": { "name": "B0", "widthMm": 1000, "heightMm": 1414, "title": "B0", "isRoll": false },
"B1": { "name": "B1", "widthMm": 707, "heightMm": 1000, "title": "B1", "isRoll": false },
"B2": { "name": "B2", "widthMm": 500, "heightMm": 707, "title": "B2", "isRoll": false },
"B3": { "name": "B3", "widthMm": 353, "heightMm": 500, "title": "B3", "isRoll": false },
"B4": { "name": "B4", "widthMm": 250, "heightMm": 353, "title": "B4", "isRoll": false },
"B5": { "name": "B5", "widthMm": 176, "heightMm": 250, "title": "B5", "isRoll": false },
"B6": { "name": "B6", "widthMm": 125, "heightMm": 176, "title": "B6", "isRoll": false },
"B7": { "name": "B7", "widthMm": 88, "heightMm": 125, "title": "B7", "isRoll": false },
"B8": { "name": "B8", "widthMm": 62, "heightMm": 88, "title": "B8", "isRoll": false },
"B9": { "name": "B9", "widthMm": 44, "heightMm": 62, "title": "B9", "isRoll": false },
"B10": { "name": "B10", "widthMm": 31, "heightMm": 44, "title": "B10", "isRoll": false },

// ISO C Series (existing, fixed)
"C0": { "name": "C0", "widthMm": 917, "heightMm": 1297, "title": "C0", "isRoll": false },
"C1": { "name": "C1", "widthMm": 648, "heightMm": 917, "title": "C1", "isRoll": false },
"C2": { "name": "C2", "widthMm": 458, "heightMm": 648, "title": "C2", "isRoll": false },
"C3": { "name": "C3", "widthMm": 324, "heightMm": 458, "title": "C3", "isRoll": false },
"C4": { "name": "C4", "widthMm": 229, "heightMm": 324, "title": "C4", "isRoll": false },
"C5": { "name": "C5", "widthMm": 162, "heightMm": 229, "title": "C5", "isRoll": false },
"C6": { "name": "C6", "widthMm": 114, "heightMm": 162, "title": "C6", "isRoll": false },
"C7": { "name": "C7", "widthMm": 81, "heightMm": 114, "title": "C7", "isRoll": false },
"C8": { "name": "C8", "widthMm": 57, "heightMm": 81, "title": "C8", "isRoll": false },
"C9": { "name": "C9", "widthMm": 40, "heightMm": 57, "title": "C9", "isRoll": false },
"C10": { "name": "C10", "widthMm": 28, "heightMm": 40, "title": "C10", "isRoll": false },

// US/North American (existing + fixes/adds)
"EXECUTIVE": { "name": "EXECUTIVE", "widthMm": 190, "heightMm": 254, "title": "Executive", "isRoll": false },
"FOOLSCAP": { "name": "FOOLSCAP", "widthMm": 203, "heightMm": 330, "title": "Foolscap/Government", "isRoll": false },
"LEDGER": { "name": "LEDGER", "widthMm": 279, "heightMm": 432, "title": "Ledger", "isRoll": false }, // Landscape Tabloid
"TABLOID": { "name": "TABLOID", "widthMm": 279, "heightMm": 432, "title": "Tabloid", "isRoll": false }, // Explicit (same as Ledger)
"LEGAL": { "name": "LEGAL", "widthMm": 216, "heightMm": 356, "title": "Legal/Tabloid", "isRoll": false },
"LETTER": { "name": "LETTER", "widthMm": 216, "heightMm": 279, "title": "Letter", "isRoll": false },
"JUNIOR_LEGAL": { "name": "JUNIOR_LEGAL", "widthMm": 127, "heightMm": 203, "title": "Junior Legal", "isRoll": false },
"GOVERNMENT_LEGAL": { "name": "GOVERNMENT_LEGAL", "widthMm": 216, "heightMm": 330, "title": "Government Legal", "isRoll": false },
"HALF_LETTER": { "name": "HALF_LETTER", "widthMm": 140, "heightMm": 216, "title": "Half Letter", "isRoll": false },
"STATEMENT": { "name": "STATEMENT", "widthMm": 140, "heightMm": 216, "title": "Statement", "isRoll": false }, // Same as Half Letter

// ANSI Engineering (existing + explicit)
"ANSI_A": { "name": "ANSI_A", "widthMm": 216, "heightMm": 279, "title": "ANSI A (Letter)", "isRoll": false },
"ANSI_B": { "name": "ANSI_B", "widthMm": 279, "heightMm": 432, "title": "ANSI B (Tabloid)", "isRoll": false },
"ANSI_C": { "name": "ANSI_C", "widthMm": 432, "heightMm": 559, "title": "ANSI C", "isRoll": false },
"ANSI_D": { "name": "ANSI_D", "widthMm": 559, "heightMm": 864, "title": "ANSI D", "isRoll": false }, // Corrected from earlier 686
"ANSI_E": { "name": "ANSI_E", "widthMm": 864, "heightMm": 1118, "title": "ANSI E", "isRoll": false },

// Architectural (NEW: Common US blueprint sizes)
"ARCH_A": { "name": "ARCH_A", "widthMm": 229, "heightMm": 305, "title": "Architectural A", "isRoll": false },
"ARCH_B": { "name": "ARCH_B", "widthMm": 305, "heightMm": 457, "title": "Architectural B", "isRoll": false },
"ARCH_C": { "name": "ARCH_C", "widthMm": 457, "heightMm": 610, "title": "Architectural C", "isRoll": false },
"ARCH_D": { "name": "ARCH_D", "widthMm": 610, "heightMm": 914, "title": "Architectural D", "isRoll": false },
"ARCH_E": { "name": "ARCH_E", "widthMm": 914, "heightMm": 1219, "title": "Architectural E", "isRoll": false },
"ARCH_E1": { "name": "ARCH_E1", "widthMm": 762, "heightMm": 1067, "title": "Architectural E1", "isRoll": false },

// JIS B Series (NEW: Japanese standards, common in Asia)
"JIS_B0": { "name": "JIS_B0", "widthMm": 1030, "heightMm": 1456, "title": "JIS B0", "isRoll": false },
"JIS_B1": { "name": "JIS_B1", "widthMm": 728, "heightMm": 1030, "title": "JIS B1", "isRoll": false },
"JIS_B2": { "name": "JIS_B2", "widthMm": 515, "heightMm": 728, "title": "JIS B2", "isRoll": false },
"JIS_B3": { "name": "JIS_B3", "widthMm": 364, "heightMm": 515, "title": "JIS B3", "isRoll": false },
"JIS_B4": { "name": "JIS_B4", "widthMm": 257, "heightMm": 364, "title": "JIS B4", "isRoll": false },
"JIS_B5": { "name": "JIS_B5", "widthMm": 182, "heightMm": 257, "title": "JIS B5", "isRoll": false },

// Super/Plus Variants (NEW: Common for printing/posters)
"SUPER_A3": { "name": "SUPER_A3", "widthMm": 330, "heightMm": 483, "title": "Super A3 / A3+", "isRoll": false },
"SUPER_A4": { "name": "SUPER_A4", "widthMm": 235, "heightMm": 322, "title": "Super A4", "isRoll": false },

// RA/SRA Series (NEW: Printing raw/trimmed sheets, Europe/US)
"RA0": { "name": "RA0", "widthMm": 860, "heightMm": 1220, "title": "RA0 (Raw A0)", "isRoll": false },
"RA1": { "name": "RA1", "widthMm": 610, "heightMm": 860, "title": "RA1", "isRoll": false },
"RA2": { "name": "RA2", "widthMm": 430, "heightMm": 610, "title": "RA2", "isRoll": false },
"RA3": { "name": "RA3", "widthMm": 305, "heightMm": 430, "title": "RA3", "isRoll": false },
"RA4": { "name": "RA4", "widthMm": 215, "heightMm": 305, "title": "RA4", "isRoll": false },
"SRA0": { "name": "SRA0", "widthMm": 900, "heightMm": 1280, "title": "SRA0 (Supplemented RA0)", "isRoll": false },
"SRA1": { "name": "SRA1", "widthMm": 640, "heightMm": 900, "title": "SRA1", "isRoll": false },
"SRA2": { "name": "SRA2", "widthMm": 450, "heightMm": 640, "title": "SRA2", "isRoll": false },
"SRA3": { "name": "SRA3", "widthMm": 320, "heightMm": 450, "title": "SRA3", "isRoll": false },
"SRA4": { "name": "SRA4", "widthMm": 225, "heightMm": 320, "title": "SRA4", "isRoll": false },

// Postcard/Other (existing, fixed)
"POSTCARD": { "name": "POSTCARD", "widthMm": 105, "heightMm": 148, "title": "Postcard", "isRoll": false },

// Rolls (existing, fixed; height=0 for variable)
"ROLL_44": { "name": "ROLL_44", "widthMm": 44, "heightMm": 0, "title": "Roll 44", "isRoll": true },
"ROLL_58": { "name": "ROLL_58", "widthMm": 58, "heightMm": 0, "title": "Roll 58", "isRoll": true },
"ROLL_76": { "name": "ROLL_76", "widthMm": 76, "heightMm": 0, "title": "Roll 76", "isRoll": true },
"ROLL_80": { "name": "ROLL_80", "widthMm": 80, "heightMm": 0, "title": "Roll 80", "isRoll": true },
"ROLL_90": { "name": "ROLL_90", "widthMm": 90, "heightMm": 0, "title": "Roll 90", "isRoll": true }
};

@AcReflectable()
class AcPageFormat {
  static const String keyWidth = "width";
  static const String keyHeight = "height";
  static const String keyMarginLeft = "marginLeft";
  static const String keyMarginRight = "marginRight";
  static const String keyMarginTop = "marginTop";
  static const String keyMarginBottom = "marginBottom";
  static const String keyIsPortrait = "isPortrait";

  @AcBindJsonProperty(key: keyWidth)
  double width = 0.0;

  @AcBindJsonProperty(key: keyHeight)
  double height = 0.0;

  @AcBindJsonProperty(key: keyMarginLeft)
  double marginLeft = 0.0;

  @AcBindJsonProperty(key: keyMarginRight)
  double marginRight = 0.0;

  @AcBindJsonProperty(key: keyMarginTop)
  double marginTop = 0.0;

  @AcBindJsonProperty(key: keyMarginBottom)
  double marginBottom = 0.0;

  @AcBindJsonProperty(key: keyIsPortrait)
  bool isPortrait = true;

  // @AcBindJsonProperty(key: keyMarginBottom)
  // AcEnum marginBottom = 0.0;

  AcPageFormat();

  factory AcPageFormat.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcPageFormat();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  factory AcPageFormat.instanceFromName({
    required String name,
  }) {
    final instance = AcPageFormat();
    name = name.toUpperCase().trim();
    if(acPageFormats.containsKey(name)){
      Map<String,dynamic> pageDetails = Map.from(acPageFormats.get(name));
      instance.height = pageDetails.getDouble("heightMm");
      instance.width = pageDetails.getDouble("widthMm");
    }
    return instance;
  }


  AcPageFormat fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  Map<String, dynamic> toJson() {
    var result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    return result;
  }

  PdfPageFormat toPdfPageFormat() {
    return PdfPageFormat(
      (isPortrait?width:height) * PdfPageFormat.mm,
      (isPortrait?height:width) * PdfPageFormat.mm,  // null = roll / auto-length
      marginLeft:   marginLeft * PdfPageFormat.mm,
      marginRight:  marginRight * PdfPageFormat.mm,
      marginTop:    marginTop * PdfPageFormat.mm,
      marginBottom: marginBottom * PdfPageFormat.mm,
    );
  }

  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}