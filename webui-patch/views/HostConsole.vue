<template>
  <div class="container-fluid px-4">
    <h1 class="page-title mt-3">Host Console Logs</h1>
    <p class="text-muted">Monitor host console output for configurable string patterns</p>

    <div class="card mt-4">
      <div class="card-header bg-dark text-white">
        Matched Host Events
      </div>
      <div class="card-body">
        <div v-if="items.length === 0" class="text-center py-4">
          No host console patterns matched yet.
        </div>
        <div v-for="(item, index) in items" :key="index" class="mb-4 p-3 border rounded bg-light">
          <div class="d-flex justify-content-between border-bottom pb-2 mb-2">
            <strong class="text-danger">🚨 Rule Matched: {{ item.rule }}</strong>
            <span class="text-muted">{{ formatDate(item.date) }}</span>
          </div>
          <pre class="mb-0 text-dark" style="white-space: pre-wrap;">{{ item.context }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HostConsole',
  data() {
    return {
      items: [],
    };
  },
  created() {
    this.getHostLogs();
  },
  methods: {
    async getHostLogs() {
    try {
      // 👇 改用 Managers/bmc 的 EventLog API
      const response = await fetch('/redfish/v1/Systems/system/LogServices/EventLog/Entries', {
        headers: { 'Accept': 'application/json' }
      });
      
      const data = await response.json();
      const allLogs = data.Members || [];
      
      this.items = [];

      allLogs.forEach(log => {
        const msg = log.Message || '';
        
        // 👇 只要包含我們的前綴，就直接用正則解析 Message
        if (msg.includes('HOST_PATTERN_MATCH|')) {
          const match = msg.match(/HOST_PATTERN_MATCH\|Rule=([^|]+)\|Context=([\s\S]+)/i);
          
          if (match) {
            // 解決 Invalid Date
            let formattedDate = "Unknown Time";
            if (log.Created) {
              try { formattedDate = new Date(log.Created).toLocaleString('zh-TW', { hour12: false }); } 
              catch (e) { formattedDate = log.Created; }
            }

            this.items.push({
              id: log.Id || Date.now(),
              date: formattedDate,
              rule: match[1].trim(),
              context: match[2].replace(/\\n/g, '\n').trim() 
            });
          }
        }
      });
      
    } catch (error) {
      console.error('Failed to fetch host logs', error);
      this.items = [];
    }
  },

    formatDate(date) {
      if (!date) return '';
      return new Date(date).toLocaleString();
    }
  }
};
</script>
