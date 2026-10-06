class AcPatchesAdminDashboard {
  static String renderHtml() {
    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ac_patches Admin Console</title>
  <style>
    :root {
      --bg: #0f172a;
      --card-bg: #1e293b;
      --border: #334155;
      --text: #f8fafc;
      --text-muted: #94a3b8;
      --primary: #6366f1;
      --primary-hover: #4f46e5;
      --success: #10b981;
      --warning: #f59e0b;
      --danger: #ef4444;
      --font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background-color: var(--bg);
      color: var(--text);
      font-family: var(--font-family);
      line-height: 1.5;
      padding: 24px;
    }

    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 24px;
      border-bottom: 1px solid var(--border);
      margin-bottom: 24px;
      flex-wrap: wrap;
      gap: 16px;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .brand h1 {
      font-size: 24px;
      font-weight: 700;
      letter-spacing: -0.5px;
    }

    .live-dot {
      display: inline-block;
      width: 10px;
      height: 10px;
      background: var(--success);
      border-radius: 50%;
      box-shadow: 0 0 8px var(--success);
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
      70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
      100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: 12px;
      flex-wrap: wrap;
    }

    select, input[type=text] {
      background: var(--card-bg);
      color: var(--text);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 8px 12px;
      font-size: 13px;
    }

    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
    }

    .badge-success { background: rgba(16, 185, 129, 0.15); color: var(--success); }
    .badge-warning { background: rgba(245, 158, 11, 0.15); color: var(--warning); }
    .badge-danger { background: rgba(239, 68, 68, 0.15); color: var(--danger); }
    .badge-primary { background: rgba(99, 102, 241, 0.15); color: var(--primary); }
    .badge-secondary { background: rgba(148, 163, 184, 0.15); color: var(--text-muted); }

    .metrics-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .metric-card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 20px;
    }

    .metric-title {
      font-size: 13px;
      font-weight: 500;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .metric-value {
      font-size: 28px;
      font-weight: 700;
      margin-top: 8px;
      color: var(--text);
    }

    /* Drag & Drop Upload Zone */
    .dropzone {
      border: 2px dashed var(--border);
      background: rgba(30, 41, 59, 0.5);
      border-radius: 12px;
      padding: 24px;
      text-align: center;
      margin-bottom: 24px;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .dropzone:hover, .dropzone.dragover {
      border-color: var(--primary);
      background: rgba(99, 102, 241, 0.1);
    }

    .dropzone-icon {
      font-size: 32px;
      margin-bottom: 8px;
    }

    .dropzone-text {
      font-size: 14px;
      color: var(--text-muted);
    }

    .dropzone-text strong {
      color: var(--primary);
    }

    .section {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 24px;
      margin-bottom: 24px;
    }

    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }

    .section-title {
      font-size: 18px;
      font-weight: 600;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
      font-size: 13px;
    }

    th {
      padding: 12px;
      border-bottom: 1px solid var(--border);
      color: var(--text-muted);
      font-weight: 600;
      font-size: 11px;
      text-transform: uppercase;
    }

    td {
      padding: 12px;
      border-bottom: 1px solid var(--border);
      vertical-align: middle;
    }

    tr:last-child td { border-bottom: none; }

    .btn {
      padding: 6px 12px;
      border-radius: 8px;
      border: none;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
      text-decoration: none;
      transition: all 0.2s ease;
    }

    .btn-primary { background: var(--primary); color: #fff; }
    .btn-primary:hover { background: var(--primary-hover); }
    .btn-danger { background: rgba(239, 68, 68, 0.15); color: var(--danger); border: 1px solid rgba(239, 68, 68, 0.3); }
    .btn-danger:hover { background: var(--danger); color: #fff; }
    .btn-secondary { background: var(--border); color: var(--text); }
    .btn-secondary:hover { background: #475569; }

    .progress-bar-bg {
      background: #334155;
      height: 6px;
      border-radius: 3px;
      overflow: hidden;
      width: 100%;
      margin-top: 6px;
    }

    .progress-bar-fill {
      background: var(--primary);
      height: 100%;
      transition: width 0.3s ease;
    }

    .event-feed {
      display: flex;
      flex-direction: column;
      gap: 8px;
      max-height: 280px;
      overflow-y: auto;
    }

    .event-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: rgba(15, 23, 42, 0.6);
      padding: 10px 14px;
      border-radius: 8px;
      border: 1px solid var(--border);
      font-size: 12px;
    }

    .slider-container {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    input[type=range] {
      accent-color: var(--primary);
      cursor: pointer;
    }

    /* Modal */
    .modal-overlay {
      display: none;
      position: fixed;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(0, 0, 0, 0.7);
      backdrop-filter: blur(4px);
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }

    .modal {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 24px;
      width: 90%;
      max-width: 440px;
    }

    .modal-title {
      font-size: 18px;
      font-weight: 700;
      margin-bottom: 16px;
    }

    .form-group {
      margin-bottom: 16px;
    }

    .form-group label {
      display: block;
      font-size: 12px;
      color: var(--text-muted);
      margin-bottom: 6px;
      text-transform: uppercase;
      font-weight: 600;
    }

    .form-group select, .form-group input {
      width: 100%;
    }

    .modal-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-top: 20px;
    }

    #upload-progress {
      display: none;
      margin-top: 10px;
    }
  </style>
</head>
<body>

  <header>
    <div class="brand">
      <h1>⚡ ac_patches</h1>
      <span class="live-dot" title="Server Live"></span>
      <span class="badge badge-success">Online</span>
    </div>
    <div class="header-actions">
      <select id="app-filter" onchange="fetchStatus()">
        <option value="">All Applications</option>
      </select>
      <select id="auto-refresh-select" onchange="updateRefreshInterval()">
        <option value="5000">Auto: 5s</option>
        <option value="10000" selected>Auto: 10s</option>
        <option value="30000">Auto: 30s</option>
        <option value="0">Auto: Paused</option>
      </select>
      <button class="btn btn-secondary" onclick="fetchStatus()">🔄 Refresh</button>
    </div>
  </header>

  <!-- Metrics Grid -->
  <div class="metrics-grid">
    <div class="metric-card">
      <div class="metric-title">Active Devices</div>
      <div class="metric-value" id="val-devices">-</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">Total Releases</div>
      <div class="metric-value" id="val-releases">-</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">Total Patches</div>
      <div class="metric-value" id="val-patches">-</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">Active Tracks</div>
      <div class="metric-value" id="val-tracks">-</div>
    </div>
    <div class="metric-card">
      <div class="metric-title">Health Rate</div>
      <div class="metric-value" id="val-health" style="color: var(--success);">-</div>
    </div>
  </div>

  <!-- Drag & Drop Upload Zone -->
  <div class="dropzone" id="dropzone" onclick="document.getElementById('file-input').click()">
    <input type="file" id="file-input" style="display: none;" accept=".acp1" onchange="handleFileSelect(event)">
    <div class="dropzone-icon">📦</div>
    <div class="dropzone-text">
      <strong>Click to upload</strong> or drag and drop an <code>.acp1</code> patch archive here
    </div>
    <div id="upload-progress">
      <div class="dropzone-text" id="upload-status-text">Uploading patch...</div>
      <div class="progress-bar-bg"><div class="progress-bar-fill" id="upload-progress-bar" style="width: 50%;"></div></div>
    </div>
  </div>

  <!-- Release Tracks & Staged Rollouts -->
  <div class="section">
    <div class="section-header">
      <h2 class="section-title">🚀 Release Tracks & Staged Rollouts</h2>
    </div>
    <table>
      <thead>
        <tr>
          <th>Track</th>
          <th>Active Patch</th>
          <th>Staged Rollout</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody id="tracks-body">
        <tr><td colspan="4" style="text-align: center; color: var(--text-muted);">Loading tracks...</td></tr>
      </tbody>
    </table>
  </div>

  <!-- Patches Inventory -->
  <div class="section">
    <div class="section-header">
      <h2 class="section-title">📦 Patches Inventory</h2>
    </div>
    <table>
      <thead>
        <tr>
          <th>Patch ID</th>
          <th>Release ID</th>
          <th>Platform / Arch</th>
          <th>Type</th>
          <th>Size</th>
          <th>Status</th>
          <th>Created</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody id="patches-body">
        <tr><td colspan="8" style="text-align: center; color: var(--text-muted);">Loading patches...</td></tr>
      </tbody>
    </table>
  </div>

  <!-- Releases -->
  <div class="section">
    <div class="section-header">
      <h2 class="section-title">🏷️ Base Releases</h2>
    </div>
    <table>
      <thead>
        <tr>
          <th>Release ID</th>
          <th>App ID</th>
          <th>Version</th>
          <th>Build #</th>
          <th>Platform</th>
          <th>Base Hash</th>
          <th>Registered</th>
        </tr>
      </thead>
      <tbody id="releases-body">
        <tr><td colspan="7" style="text-align: center; color: var(--text-muted);">Loading releases...</td></tr>
      </tbody>
    </table>
  </div>

  <!-- Connected Devices & Telemetry -->
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 24px;">
    <!-- Live Telemetry Feed -->
    <div class="section">
      <div class="section-header">
        <h2 class="section-title">📡 Live Telemetry Events</h2>
      </div>
      <div class="event-feed" id="events-feed">
        <div style="text-align: center; color: var(--text-muted); padding: 20px;">Loading events...</div>
      </div>
    </div>

    <!-- Active Devices Table -->
    <div class="section">
      <div class="section-header">
        <h2 class="section-title">📱 Registered Devices</h2>
      </div>
      <div style="max-height: 280px; overflow-y: auto;">
        <table>
          <thead>
            <tr>
              <th>Device</th>
              <th>Platform</th>
              <th>Patch</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody id="devices-body">
            <tr><td colspan="4" style="text-align: center; color: var(--text-muted);">Loading devices...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Deploy Patch Modal -->
  <div class="modal-overlay" id="deploy-modal">
    <div class="modal">
      <div class="modal-title">🚀 Deploy Patch to Track</div>
      <div class="form-group">
        <label>Patch ID</label>
        <input type="text" id="modal-patch-id" readonly style="opacity: 0.8;">
      </div>
      <div class="form-group">
        <label>Target Track</label>
        <select id="modal-track">
          <option value="stable">stable (Production)</option>
          <option value="beta">beta (Testing)</option>
          <option value="staging">staging (Internal)</option>
        </select>
      </div>
      <div class="form-group">
        <label>Rollout Percentage</label>
        <div class="slider-container">
          <input type="range" min="1" max="100" value="100" id="modal-rollout" oninput="document.getElementById('modal-rollout-val').textContent = this.value + '%'">
          <span id="modal-rollout-val" style="min-width: 45px; font-weight: 600;">100%</span>
        </div>
      </div>
      <div class="modal-actions">
        <button class="btn btn-secondary" onclick="closeDeployModal()">Cancel</button>
        <button class="btn btn-primary" onclick="confirmDeploy()">Deploy Patch</button>
      </div>
    </div>
  </div>

  <script>
    let refreshInterval = null;

    // Dropzone drag & drop handlers
    const dropzone = document.getElementById('dropzone');
    dropzone.addEventListener('dragover', (e) => { e.preventDefault(); dropzone.classList.add('dragover'); });
    dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
    dropzone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropzone.classList.remove('dragover');
      if (e.dataTransfer.files.length > 0) {
        uploadPatchFile(e.dataTransfer.files[0]);
      }
    });

    function handleFileSelect(e) {
      if (e.target.files.length > 0) {
        uploadPatchFile(e.target.files[0]);
      }
    }

    async function uploadPatchFile(file) {
      if (!file.name.endsWith('.acp1')) {
        alert('Only .acp1 patch archive files are supported.');
        return;
      }

      const progressDiv = document.getElementById('upload-progress');
      const statusText = document.getElementById('upload-status-text');
      const progressBar = document.getElementById('upload-progress-bar');

      progressDiv.style.display = 'block';
      statusText.textContent = 'Reading ' + file.name + '...';
      progressBar.style.width = '30%';

      try {
        const arrayBuffer = await file.arrayBuffer();
        statusText.textContent = 'Encoding and uploading...';
        progressBar.style.width = '60%';

        // Convert to base64 in chunks to handle large payloads cleanly
        let binary = '';
        const bytes = new Uint8List(arrayBuffer);
        const len = bytes.byteLength;
        const chunkSize = 32768;
        for (let i = 0; i < len; i += chunkSize) {
          const chunk = bytes.subarray(i, Math.min(i + chunkSize, len));
          binary += String.fromCharCode.apply(null, chunk);
        }
        const base64Str = btoa(binary);

        const resp = await fetch('/api/v1/patch/upload', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ bytesBase64: base64Str })
        });

        progressBar.style.width = '100%';
        if (resp.ok) {
          statusText.textContent = '✅ Patch uploaded successfully!';
          setTimeout(() => { progressDiv.style.display = 'none'; }, 2500);
          fetchStatus();
        } else {
          const err = await resp.text();
          statusText.textContent = '❌ Upload failed: ' + err;
        }
      } catch (err) {
        statusText.textContent = '❌ Error: ' + err;
      }
    }

    async function fetchStatus() {
      try {
        const appFilter = document.getElementById('app-filter').value;
        const url = appFilter ? `/api/v1/patch/status?appId=\${encodeURIComponent(appFilter)}` : '/api/v1/patch/status';
        const res = await fetch(url);
        if (res.ok) {
          const data = await res.json();
          renderDashboard(data);
        }
      } catch (err) {
        console.error('Failed to fetch status:', err);
      }
    }

    function renderDashboard(data) {
      document.getElementById('val-devices').textContent = data.deviceCount || 0;
      document.getElementById('val-releases').textContent = (data.releases || []).length;
      document.getElementById('val-patches').textContent = (data.patches || []).length;
      document.getElementById('val-tracks').textContent = (data.tracks || []).length;

      // Calculate health rate
      const events = data.recentEvents || [];
      const healthyEvents = events.filter(e => e.event_type === 'healthy').length;
      const rollbackEvents = events.filter(e => e.event_type === 'rolled_back').length;
      const totalDecisive = healthyEvents + rollbackEvents;
      if (totalDecisive > 0) {
        const rate = Math.round((healthyEvents / totalDecisive) * 100);
        document.getElementById('val-health').textContent = rate + '%';
        document.getElementById('val-health').style.color = rate >= 90 ? 'var(--success)' : (rate >= 70 ? 'var(--warning)' : 'var(--danger)');
      } else {
        document.getElementById('val-health').textContent = '100%';
      }

      // Populate app filter if empty
      const appSelect = document.getElementById('app-filter');
      if (appSelect.options.length <= 1 && data.apps && data.apps.length > 0) {
        data.apps.forEach(a => {
          const opt = document.createElement('option');
          opt.value = a.app_id;
          opt.textContent = `\${a.name || a.app_id} (\${a.app_id})`;
          appSelect.appendChild(opt);
        });
      }

      // Render Tracks
      const tracksBody = document.getElementById('tracks-body');
      if (!data.tracks || data.tracks.length === 0) {
        tracksBody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-muted);">No release tracks active.</td></tr>';
      } else {
        tracksBody.innerHTML = data.tracks.map(t => {
          const rollout = t.rollout_percentage || 100;
          return `
            <tr>
              <td><span class="badge badge-primary">\${t.name}</span></td>
              <td><strong>\${t.current_patch_id || 'None (Base Release)'}</strong></td>
              <td>
                <div class="slider-container">
                  <input type="range" min="1" max="100" value="\${rollout}" id="slider-\${t.name}" oninput="document.getElementById('pct-\${t.name}').textContent = this.value + '%'">
                  <span id="pct-\${t.name}" style="min-width: 45px; font-weight: 600;">\${rollout}%</span>
                  <button class="btn btn-primary" style="padding: 4px 8px; font-size: 11px;" onclick="updateRollout('\${t.name}', '\${t.current_patch_id}')">Apply</button>
                </div>
                <div class="progress-bar-bg"><div class="progress-bar-fill" style="width: \${rollout}%"></div></div>
              </td>
              <td>
                <button class="btn btn-danger" onclick="triggerRollback('\${t.app_id}', '\${t.name}')">Rollback Track</button>
              </td>
            </tr>
          `;
        }).join('');
      }

      // Render Patches
      const patchesBody = document.getElementById('patches-body');
      if (!data.patches || data.patches.length === 0) {
        patchesBody.innerHTML = '<tr><td colspan="8" style="text-align: center; color: var(--text-muted);">No patches uploaded yet.</td></tr>';
      } else {
        patchesBody.innerHTML = data.patches.map(p => `
          <tr>
            <td><strong>\${p.patch_id}</strong></td>
            <td>\${p.release_id}</td>
            <td><span class="badge badge-secondary">\${p.platform} (\${p.architecture || 'any'})</span></td>
            <td><span class="badge badge-primary">\${p.patch_type || 'dart'}</span></td>
            <td>\${(p.size_bytes / 1024).toFixed(1)} KB</td>
            <td><span class="badge \${p.status === 'active' ? 'badge-success' : 'badge-warning'}">\${p.status}</span></td>
            <td style="color: var(--text-muted); font-size: 11px;">\${p.created_at || ''}</td>
            <td>
              <div style="display: flex; gap: 6px;">
                <button class="btn btn-primary" style="padding: 4px 8px; font-size: 11px;" onclick="openDeployModal('\${p.patch_id}')">Deploy</button>
                <a class="btn btn-secondary" style="padding: 4px 8px; font-size: 11px;" href="/api/v1/patch/download/\${encodeURIComponent(p.patch_id)}" download>⬇️</a>
              </div>
            </td>
          </tr>
        `).join('');
      }

      // Render Releases
      const releasesBody = document.getElementById('releases-body');
      if (!data.releases || data.releases.length === 0) {
        releasesBody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: var(--text-muted);">No base releases registered yet.</td></tr>';
      } else {
        releasesBody.innerHTML = data.releases.map(r => `
          <tr>
            <td><strong>\${r.release_id}</strong></td>
            <td>\${r.app_id}</td>
            <td>\${r.version}</td>
            <td>\${r.build_number}</td>
            <td><span class="badge badge-secondary">\${r.platform} (\${r.architecture || 'x86_64'})</span></td>
            <td><code style="font-size: 11px; color: var(--text-muted);">\${(r.base_release_hash || '').substring(0, 16)}...</code></td>
            <td style="color: var(--text-muted); font-size: 11px;">\${r.created_at || ''}</td>
          </tr>
        `).join('');
      }

      // Render Devices
      const devicesBody = document.getElementById('devices-body');
      if (!data.devices || data.devices.length === 0) {
        devicesBody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: var(--text-muted);">No devices registered.</td></tr>';
      } else {
        devicesBody.innerHTML = data.devices.map(d => `
          <tr>
            <td><strong>\${d.installation_id}</strong></td>
            <td>\${d.platform || ''}</td>
            <td>\${d.current_patch_id || 'Base'}</td>
            <td>
              <span class="badge \${d.failure_count > 0 ? 'badge-danger' : 'badge-success'}">
                \${d.failure_count > 0 ? d.failure_count + ' fails' : 'Healthy'}
              </span>
            </td>
          </tr>
        `).join('');
      }

      // Render Events
      const eventsFeed = document.getElementById('events-feed');
      if (!events || events.length === 0) {
        eventsFeed.innerHTML = '<div style="text-align: center; color: var(--text-muted); padding: 20px;">No telemetry events recorded yet.</div>';
      } else {
        eventsFeed.innerHTML = events.map(e => {
          let badgeClass = 'badge-primary';
          if (e.event_type === 'healthy') badgeClass = 'badge-success';
          if (e.event_type === 'rolled_back') badgeClass = 'badge-danger';
          if (e.event_type === 'downloaded') badgeClass = 'badge-warning';

          return `
            <div class="event-item">
              <div>
                <span class="badge \${badgeClass}">\${e.event_type}</span>
                <strong style="margin-left: 8px;">\${e.patch_id}</strong>
                <span style="color: var(--text-muted); margin-left: 6px;">\${e.error_message || ''}</span>
              </div>
              <div style="color: var(--text-muted); font-size: 11px;">\${e.created_at || ''}</div>
            </div>
          `;
        }).join('');
      }
    }

    async function updateRollout(track, patchId) {
      if (!patchId || patchId === 'None (Base Release)') {
        alert('No active patch on this track.');
        return;
      }
      const pct = parseInt(document.getElementById('slider-' + track).value);
      try {
        const res = await fetch('/api/v1/patch/publish', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ patchId: patchId, track: track, rolloutPercentage: pct })
        });
        if (res.ok) {
          fetchStatus();
        } else {
          alert('Failed to update rollout');
        }
      } catch (err) {
        alert('Error: ' + err);
      }
    }

    async function triggerRollback(appId, track) {
      if (!confirm('Are you sure you want to roll back track "' + track + '"? All devices will revert to the base release.')) return;
      try {
        const res = await fetch('/api/v1/patch/rollback', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ appId: appId, track: track })
        });
        if (res.ok) {
          fetchStatus();
        } else {
          alert('Rollback failed');
        }
      } catch (err) {
        alert('Error: ' + err);
      }
    }

    function openDeployModal(patchId) {
      document.getElementById('modal-patch-id').value = patchId;
      document.getElementById('deploy-modal').style.display = 'flex';
    }

    function closeDeployModal() {
      document.getElementById('deploy-modal').style.display = 'none';
    }

    async function confirmDeploy() {
      const patchId = document.getElementById('modal-patch-id').value;
      const track = document.getElementById('modal-track').value;
      const rollout = parseInt(document.getElementById('modal-rollout').value);

      try {
        const res = await fetch('/api/v1/patch/publish', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ patchId: patchId, track: track, rolloutPercentage: rollout })
        });
        if (res.ok) {
          closeDeployModal();
          fetchStatus();
        } else {
          const err = await res.text();
          alert('Failed to deploy: ' + err);
        }
      } catch (err) {
        alert('Error: ' + err);
      }
    }

    function updateRefreshInterval() {
      if (refreshInterval) clearInterval(refreshInterval);
      const ms = parseInt(document.getElementById('auto-refresh-select').value);
      if (ms > 0) {
        refreshInterval = setInterval(fetchStatus, ms);
      }
    }

    fetchStatus();
    updateRefreshInterval();
  </script>
</body>
</html>
''';
  }
}
