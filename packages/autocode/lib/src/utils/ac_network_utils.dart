import 'dart:io';

Future<List<String>> acGetIpAddresses() async {
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );

    final List<String> wifiIps = [];
    final List<String> lanIps = [];
    final List<String> otherLanIps = [];
    final List<String> fallbackIps = [];

    for (var interface in interfaces) {
      final name = interface.name.toLowerCase();

      // ❌ Skip unwanted/virtual interfaces
      if (name.contains('docker') ||
          name.contains('vbox') ||
          name.contains('vmware') ||
          name.contains('virtual') ||
          name.contains('loopback') ||
          name.contains('pseudo') ||
          name.contains('tunnel') ||
          name.contains('tap') ||
          name.contains('vpn') ||
          name.contains('wsl') ||
          name.contains('hns') || // Windows Host Network Service
          name.contains('hyper-v') ||
          name.contains('isatap') ||
          name.contains('teredo') ||
          name.contains('utun') || // macOS/Linux tunnel
          name.contains('awdl') || // macOS Apple Wireless Direct Link
          name.startsWith('veth') || // Linux virtual ethernet
          (name.startsWith('v') && name.contains('ethernet'))) { // Windows vEthernet
        continue;
      }

      for (var addr in interface.addresses) {
        final ip = addr.address;
        if (addr.isLoopback || ip == '127.0.0.1' || ip == '::1') continue;

        if (_isLan(ip)) {
          // ✅ Detect WiFi
          if (_isWifiInterface(name)) {
            if (!wifiIps.contains(ip)) wifiIps.add(ip);
          }
          // ✅ Detect Ethernet (LAN)
          else if (_isLanInterface(name)) {
            if (!lanIps.contains(ip)) lanIps.add(ip);
          } else {
            if (!otherLanIps.contains(ip)) otherLanIps.add(ip);
          }
        } else {
          if (!fallbackIps.contains(ip)) fallbackIps.add(ip);
        }
      }
    }

    // 🎯 Priority: WiFi → LAN → Other private LAN → Fallback non-loopback
    final primary = [...wifiIps, ...lanIps, ...otherLanIps];
    if (primary.isNotEmpty) {
      return primary;
    }
    return fallbackIps;
  } catch (_) {
    return [];
  }
}

Future<String?> acGetIpAddress() async {
  final ips = await acGetIpAddresses();
  return ips.isNotEmpty ? ips.first : null;
}

bool _isWifiInterface(String name) {
  return name.contains('wi-fi') ||
      name.contains('wifi') ||
      name.contains('wlan') ||
      name.contains('wireless') ||
      name.contains('wi'); // Fallback for various OS names
}

bool _isLanInterface(String name) {
  return name.contains('ethernet') ||
      name.contains('eth') || // Linux
      name.contains('en'); // macOS (en0), Linux (enp3s0)
}

bool _isLan(String ip) {
  return ip.startsWith('192.168.') ||
      ip.startsWith('10.') ||
      (ip.startsWith('172.') && _is172Private(ip)) ||
      ip.startsWith('100.');
}

bool _is172Private(String ip) {
  final parts = ip.split('.');
  if (parts.length < 2) return false;

  final second = int.tryParse(parts[1]) ?? 0;
  return second >= 16 && second <= 31;
}