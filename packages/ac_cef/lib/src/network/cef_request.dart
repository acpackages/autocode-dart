enum CefResourceType {
  rtMainFrame,
  rtSubFrame,
  rtStylesheet,
  rtScript,
  rtImage,
  rtFontResource,
  rtSubResource,
  rtObject,
  rtMedia,
  rtWorker,
  rtSharedWorker,
  rtPrefetch,
  rtFavicon,
  rtXhr,
  rtPing,
  rtServiceWorker,
  rtCspReport,
  rtPluginResource,
  rtNavigationPreloadMainFrame,
  rtNavigationPreloadSubFrame,
}

enum CefTransitionType {
  ttLink(0),
  ttExplicit(1),
  ttAutoSubframe(3),
  ttManualSubframe(4),
  ttFormSubmit(7),
  ttReload(8);

  final int value;
  const CefTransitionType(this.value);
}

enum CefReferrerPolicy {
  referrerPolicyDefault,
  referrerPolicyClearReferrerOnTransitionFromSecureToInsecure,
  referrerPolicyReduceReferrerGranularityOnTransitionCrossOrigin,
  referrerPolicyOriginOnlyOnTransitionCrossOrigin,
  referrerPolicyNeverClearReferrer,
  referrerPolicyOrigin,
  referrerPolicyClearReferrerOnTransitionCrossOrigin,
  referrerPolicyOriginClearOnTransitionFromSecureToInsecure,
  referrerPolicyNoReferrer,
}

abstract class CefRequest {
  void dispose();
  int getIdentifier();
  bool isReadOnly();
  String getURL();
  void setURL(String url);
  String getMethod();
  void setMethod(String method);
  void setReferrer(String url, CefReferrerPolicy policy);
  String getReferrerURL();
  CefReferrerPolicy getReferrerPolicy();
  String? getHeaderByName(String name);
  void setHeaderByName(String name, String value, bool overwrite);
  Map<String, String> getHeaderMap();
  void setHeaderMap(Map<String, String> headerMap);
  int getFlags();
  void setFlags(int flags);
  String getFirstPartyForCookies();
  void setFirstPartyForCookies(String url);
  CefResourceType getResourceType();
  CefTransitionType getTransitionType();
}
