enum CefMenuItemType {
  none,
  command,
  check,
  radio,
  separator,
  submenu,
}

abstract class CefMenuModel {
  bool clear();
  int getCount();
  bool addSeparator();
  bool addItem(int commandId, String label);
  bool addCheckItem(int commandId, String label);
  bool addRadioItem(int commandId, String label, int groupId);
  CefMenuModel? addSubMenu(int commandId, String label);
  bool insertSeparatorAt(int index);
  bool insertItemAt(int index, int commandId, String label);
  bool insertCheckItemAt(int index, int commandId, String label);
  bool insertRadioItemAt(int index, int commandId, String label, int groupId);
  CefMenuModel? insertSubMenuAt(int index, int commandId, String label);
  bool remove(int commandId);
  bool removeAt(int index);
  int getIndexOf(int commandId);
  int getCommandIdAt(int index);
  bool setCommandIdAt(int index, int commandId);
  String getLabel(int commandId);
  String getLabelAt(int index);
  bool setLabel(int commandId, String label);
  bool setLabelAt(int index, String label);
  CefMenuItemType getType(int commandId);
  CefMenuItemType getTypeAt(int index);
  int getGroupId(int commandId);
  int getGroupIdAt(int index);
  bool setGroupId(int commandId, int groupId);
  bool setGroupIdAt(int index, int groupId);
  CefMenuModel? getSubMenu(int commandId);
  CefMenuModel? getSubMenuAt(int index);
  bool isVisible(int commandId);
  bool isVisibleAt(int index);
  bool setVisible(int commandId, bool visible);
  bool setVisibleAt(int index, bool visible);
  bool isEnabled(int commandId);
  bool isEnabledAt(int index);
  bool setEnabled(int commandId, bool enabled);
  bool setEnabledAt(int index, bool enabled);
  bool isChecked(int commandId);
  bool isCheckedAt(int index);
  bool setChecked(int commandId, bool checked);
  bool setCheckedAt(int index, bool checked);
}

enum CefMediaType {
  none,
  image,
  video,
  audio,
  file,
  plugin,
}

abstract class CefContextMenuParams {
  int getXCoord();
  int getYCoord();
  int getTypeFlags();
  String getLinkUrl();
  String getUnfilteredLinkUrl();
  String getSourceUrl();
  bool hasImageContents();
  String getPageUrl();
  String getFrameUrl();
  String getFrameCharset();
  CefMediaType getMediaType();
  int getMediaStateFlags();
  String getSelectionText();
  String getMisspelledWord();
  bool isEditable();
  bool isSpellCheckEnabled();
  int getEditStateFlags();
}
