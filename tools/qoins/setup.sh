#!/bin/bash

# QOINs Cost Management System Setup Script
# Sets up directory structure, configuration files, and dependencies

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QOINS_ROOT="$SCRIPT_DIR"

echo "🚀 Setting up QOINs Cost Management System..."
echo "Installation directory: $QOINS_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for required dependencies
check_dependencies() {
    print_status "Checking dependencies..."

    # Check for Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi

    # Check for pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is required but not installed"
        exit 1
    fi

    # Check for curl
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi

    # Check for jq (for JSON processing)
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found - installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq 2>/dev/null || {
                print_error "Please install jq manually: brew install jq"
                exit 1
            }
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get update && sudo apt-get install -y jq 2>/dev/null || {
                print_error "Please install jq manually: sudo apt install jq"
                exit 1
            }
        fi
    fi

    print_success "All dependencies satisfied"
}

# Create directory structure
create_directories() {
    print_status "Creating directory structure..."

    local dirs=(
        "config"
        "collectors"
        "analyzers"
        "dashboard"
        "alerts"
        "reports"
        "data"
        "scripts"
        "logs"
        "backups"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$QOINS_ROOT/$dir"
        print_status "Created directory: $dir"
    done

    print_success "Directory structure created"
}

# Create configuration files
create_config_files() {
    print_status "Creating configuration files..."

    # Main configuration file
    cat > "$QOINS_ROOT/config/config.yml" << 'EOF'
# QOINs Configuration File
# Copy this to config.yml and customize for your setup

budget:
  monthly_limit: 110.00
  currency: "USD"
  alerts:
    - threshold: 75
      channels: ["email", "terminal"]
    - threshold: 85
      channels: ["email", "terminal"]
    - threshold: 95
      channels: ["email", "slack", "terminal"]

services:
  openai:
    api_key: "${OPENAI_API_KEY}"
    budget_limit: 50.00
    tracking_enabled: true
    endpoint: "https://api.openai.com/v1"

  anthropic:
    api_key: "${ANTHROPIC_API_KEY}"
    budget_limit: 30.00
    tracking_enabled: true
    endpoint: "https://api.anthropic.com/v1"

  aws:
    access_key: "${AWS_ACCESS_KEY_ID}"
    secret_key: "${AWS_SECRET_ACCESS_KEY}"
    region: "us-east-1"
    budget_limit: 25.00
    tracking_enabled: true

  github:
    token: "${GITHUB_TOKEN}"
    budget_limit: 10.00
    tracking_enabled: true

  vercel:
    token: "${VERCEL_TOKEN}"
    budget_limit: 15.00
    tracking_enabled: true

local_alternatives:
  ollama:
    enabled: true
    track_usage: true
    model_costs: # Equivalent OpenAI costs for comparison
      "mistral:latest": 0.002  # per 1K tokens
      "llama2:7b": 0.002
      "codellama:7b": 0.002
      "llama2:13b": 0.004
    models_dir: "~/.ollama/models"

notifications:
  email:
    enabled: false
    smtp_server: "smtp.gmail.com"
    smtp_port: 587
    username: "${EMAIL_USERNAME}"
    password: "${EMAIL_PASSWORD}"
    from_address: "qoins@yourdomain.com"
    to_addresses: ["you@yourdomain.com"]

  slack:
    enabled: false
    webhook_url: "${SLACK_WEBHOOK_URL}"
    channel: "#dev-costs"
    username: "QOINs Bot"

  terminal:
    enabled: true
    color_output: true

reporting:
  daily_reports: true
  weekly_reports: true
  monthly_reports: true
  export_formats: ["json", "csv", "html"]

tracking:
  data_retention_days: 365
  backup_enabled: true
  backup_frequency: "daily"
EOF

    # Service definitions
    cat > "$QOINS_ROOT/config/services.yml" << 'EOF'
# Service Definitions for Cost Tracking

services:
  openai:
    name: "OpenAI"
    type: "ai"
    billing_cycle: "monthly"
    api_endpoint: "https://api.openai.com/v1/usage"
    cost_per_request: 0.002
    models:
      - name: "gpt-4"
        cost_per_1k_tokens: 0.03
      - name: "gpt-3.5-turbo"
        cost_per_1k_tokens: 0.002

  anthropic:
    name: "Anthropic Claude"
    type: "ai"
    billing_cycle: "monthly"
    api_endpoint: "https://api.anthropic.com/v1/usage"
    models:
      - name: "claude-3-opus"
        cost_per_1k_tokens: 0.015
      - name: "claude-3-sonnet"
        cost_per_1k_tokens: 0.003

  aws:
    name: "Amazon Web Services"
    type: "cloud"
    billing_cycle: "monthly"
    services:
      - "ec2"
      - "lambda"
      - "s3"
      - "rds"
      - "cloudfront"

  github:
    name: "GitHub"
    type: "development"
    billing_cycle: "monthly"
    services:
      - "copilot"
      - "actions"
      - "packages"
      - "codespaces"

  vercel:
    name: "Vercel"
    type: "hosting"
    billing_cycle: "monthly"
    services:
      - "hosting"
      - "serverless_functions"
      - "edge_functions"
      - "analytics"
EOF

    # Budget allocation template
    cat > "$QOINS_ROOT/config/budgets.yml" << 'EOF'
# Budget Allocation Configuration

monthly_budget: 110.00

allocations:
  ai_services: 60.00  # 55%
  cloud_services: 30.00  # 27%
  development_tools: 15.00  # 14%
  other: 5.00  # 4%

service_budgets:
  openai: 35.00
  anthropic: 25.00
  aws: 25.00
  github: 10.00
  vercel: 10.00
  other: 5.00

project_budgets:
  uroboro_ai: 40.00
  qry_zone: 30.00
  qoinbots_game: 20.00
  experiments: 15.00
  misc: 5.00

alert_thresholds:
  - level: "warning"
    percentage: 75
    action: "notify"
  - level: "critical"
    percentage: 90
    action: "notify_and_restrict"
  - level: "emergency"
    percentage: 98
    action: "emergency_mode"
EOF

    print_success "Configuration files created"
}

# Install Python dependencies
install_python_deps() {
    print_status "Installing Python dependencies..."

    cat > "$QOINS_ROOT/requirements.txt" << 'EOF'
requests>=2.31.0
pyyaml>=6.0
click>=8.1.0
tabulate>=0.9.0
colorama>=0.4.6
schedule>=1.2.0
matplotlib>=3.7.0
pandas>=2.0.0
boto3>=1.26.0
openai>=1.3.0
anthropic>=0.3.0
python-dotenv>=1.0.0
jinja2>=3.1.0
smtplib-ssl>=1.0.0
EOF

    pip3 install -r "$QOINS_ROOT/requirements.txt"
    print_success "Python dependencies installed"
}

# Create main monitoring script
create_monitor_script() {
    print_status "Creating monitoring script..."

    cat > "$QOINS_ROOT/monitor.sh" << 'EOF'
#!/bin/bash

# QOINs Cost Monitoring Script
# Runs continuous cost monitoring and alerts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"

print_header "QOINs Cost Monitor"
print_status "Starting cost monitoring..."

# Check if configuration exists
if [[ ! -f "$SCRIPT_DIR/config/config.yml" ]]; then
    print_error "Configuration file not found. Run ./setup.sh first."
    exit 1
fi

# Run data collection
print_status "Collecting cost data from services..."
python3 "$SCRIPT_DIR/collectors/collect_all.py"

# Run analysis
print_status "Analyzing cost trends..."
python3 "$SCRIPT_DIR/analyzers/analyze_costs.py"

# Check budget status
print_status "Checking budget status..."
python3 "$SCRIPT_DIR/analyzers/budget_tracker.py"

# Generate alerts if needed
python3 "$SCRIPT_DIR/alerts/check_alerts.py"

print_success "Monitoring cycle complete"
EOF

    chmod +x "$QOINS_ROOT/monitor.sh"
    print_success "Monitor script created"
}

# Create data collectors
create_collectors() {
    print_status "Creating data collectors..."

    # Main collector orchestrator
    cat > "$QOINS_ROOT/collectors/collect_all.py" << 'EOF'
#!/usr/bin/env python3
"""
QOINs Data Collection Orchestrator
Collects cost data from all configured services
"""

import sys
import os
import yaml
import json
import asyncio
from datetime import datetime
from pathlib import Path

# Add the project root to Python path
sys.path.append(str(Path(__file__).parent.parent))

from collectors.openai_collector import OpenAICollector
from collectors.aws_collector import AWSCollector
from collectors.github_collector import GitHubCollector
from collectors.local_usage import LocalUsageCollector

class DataCollector:
    def __init__(self, config_path="config/config.yml"):
        self.config_path = config_path
        self.config = self.load_config()
        self.data_dir = Path("data")
        self.data_dir.mkdir(exist_ok=True)

    def load_config(self):
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            print(f"❌ Configuration file not found: {self.config_path}")
            sys.exit(1)

    async def collect_all_data(self):
        """Collect data from all enabled services"""
        collectors = []

        # Initialize collectors based on config
        if self.config['services']['openai']['tracking_enabled']:
            collectors.append(OpenAICollector(self.config['services']['openai']))

        if self.config['services']['aws']['tracking_enabled']:
            collectors.append(AWSCollector(self.config['services']['aws']))

        if self.config['services']['github']['tracking_enabled']:
            collectors.append(GitHubCollector(self.config['services']['github']))

        # Always collect local usage
        collectors.append(LocalUsageCollector(self.config['local_alternatives']))

        # Run all collectors
        results = {}
        for collector in collectors:
            try:
                print(f"📊 Collecting data from {collector.service_name}...")
                data = await collector.collect()
                results[collector.service_name] = data
                print(f"✅ {collector.service_name}: {len(data)} records collected")
            except Exception as e:
                print(f"❌ Error collecting from {collector.service_name}: {e}")
                results[collector.service_name] = {"error": str(e)}

        # Save collected data
        timestamp = datetime.now().isoformat()
        output_file = self.data_dir / f"costs_{timestamp.split('T')[0]}.json"

        with open(output_file, 'w') as f:
            json.dump({
                "timestamp": timestamp,
                "data": results
            }, f, indent=2)

        print(f"💾 Data saved to {output_file}")
        return results

if __name__ == "__main__":
    collector = DataCollector()
    asyncio.run(collector.collect_all_data())
EOF

    # OpenAI collector
    cat > "$QOINS_ROOT/collectors/openai_collector.py" << 'EOF'
#!/usr/bin/env python3
"""
OpenAI API Cost Collector
Tracks OpenAI API usage and costs
"""

import os
import requests
import json
from datetime import datetime, timedelta

class OpenAICollector:
    def __init__(self, config):
        self.service_name = "openai"
        self.api_key = os.getenv("OPENAI_API_KEY") or config.get("api_key", "").replace("${OPENAI_API_KEY}", "")
        self.endpoint = config.get("endpoint", "https://api.openai.com/v1")

    async def collect(self):
        """Collect OpenAI usage data"""
        if not self.api_key or self.api_key.startswith("${"):
            return {"error": "OpenAI API key not configured"}

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        # Get usage for current month
        today = datetime.now()
        start_date = today.replace(day=1)

        try:
            # Note: OpenAI doesn't have a direct usage API, so this is a placeholder
            # In practice, you'd need to track usage through your application logs
            # or use OpenAI's billing dashboard data

            return {
                "service": "openai",
                "date": today.isoformat(),
                "usage": {
                    "requests": 0,  # Would come from your app logs
                    "tokens": 0,    # Would come from your app logs
                    "cost": 0.0     # Calculated from usage
                },
                "note": "Implement actual usage tracking in your applications"
            }

        except Exception as e:
            return {"error": f"Failed to collect OpenAI data: {e}"}
EOF

    # Local usage collector
    cat > "$QOINS_ROOT/collectors/local_usage.py" << 'EOF'
#!/usr/bin/env python3
"""
Local LLM Usage Collector
Tracks local model usage as cost savings
"""

import os
import json
import subprocess
from datetime import datetime
from pathlib import Path

class LocalUsageCollector:
    def __init__(self, config):
        self.service_name = "local_ollama"
        self.config = config
        self.models_dir = Path(config.get("models_dir", "~/.ollama/models")).expanduser()

    async def collect(self):
        """Collect local Ollama usage data"""
        try:
            # Check if Ollama is available
            result = subprocess.run(["ollama", "list"], capture_output=True, text=True)
            if result.returncode != 0:
                return {"error": "Ollama not available"}

            # Parse available models
            models = []
            lines = result.stdout.strip().split('\n')[1:]  # Skip header

            for line in lines:
                if line.strip():
                    parts = line.split()
                    if len(parts) >= 3:
                        name = parts[0]
                        size = parts[2]
                        models.append({
                            "name": name,
                            "size": size,
                            "cost_equivalent": self.config.get("model_costs", {}).get(name, 0.0)
                        })

            return {
                "service": "local_ollama",
                "date": datetime.now().isoformat(),
                "models": models,
                "usage": {
                    "note": "Track actual usage in your applications",
                    "savings_potential": sum(m["cost_equivalent"] for m in models) * 1000  # Example calculation
                }
            }

        except Exception as e:
            return {"error": f"Failed to collect local usage: {e}"}
EOF

    # Placeholder for other collectors
    for service in ["aws_collector.py", "github_collector.py"]:
        cat > "$QOINS_ROOT/collectors/$service" << 'EOF'
#!/usr/bin/env python3
"""
Placeholder collector - implement based on service API
"""

class CollectorTemplate:
    def __init__(self, config):
        self.service_name = "template"
        self.config = config

    async def collect(self):
        return {
            "service": self.service_name,
            "note": "Implement actual data collection",
            "status": "placeholder"
        }
EOF

    print_success "Data collectors created"
}

# Create analysis tools
create_analyzers() {
    print_status "Creating analysis tools..."

    # Budget tracker
    cat > "$QOINS_ROOT/analyzers/budget_tracker.py" << 'EOF'
#!/usr/bin/env python3
"""
Budget Tracking and Analysis
"""

import json
import yaml
from datetime import datetime
from pathlib import Path
from tabulate import tabulate
import sys

class BudgetTracker:
    def __init__(self, config_path="config/config.yml"):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        self.data_dir = Path("data")

    def get_current_spending(self):
        """Get current month's spending from data files"""
        # This is a placeholder - implement based on your data structure
        current_month = datetime.now().month
        spending = {
            "total": 95.94,  # Example current spending
            "services": {
                "openai": 45.20,
                "aws": 28.15,
                "github": 12.30,
                "vercel": 10.29
            }
        }
        return spending

    def analyze_budget_status(self):
        """Analyze current budget status"""
        spending = self.get_current_spending()
        budget_limit = self.config['budget']['monthly_limit']

        utilization = (spending['total'] / budget_limit) * 100
        remaining = budget_limit - spending['total']

        print(f"\n📊 Budget Status Report")
        print(f"{'='*50}")
        print(f"Budget Limit: ${budget_limit:.2f}")
        print(f"Current Spending: ${spending['total']:.2f}")
        print(f"Remaining: ${remaining:.2f}")
        print(f"Utilization: {utilization:.1f}%")

        # Status indicator
        if utilization >= 95:
            print("🚨 Status: CRITICAL - Emergency mode recommended")
        elif utilization >= 85:
            print("⚠️  Status: WARNING - High usage")
        elif utilization >= 75:
            print("🟡 Status: CAUTION - Monitor closely")
        else:
            print("✅ Status: NORMAL - Within budget")

        # Service breakdown
        print(f"\n💰 Service Breakdown")
        print(f"{'='*50}")

        table_data = []
        for service, amount in spending['services'].items():
            percentage = (amount / spending['total']) * 100
            table_data.append([service.title(), f"${amount:.2f}", f"{percentage:.1f}%"])

        print(tabulate(table_data, headers=["Service", "Amount", "% of Total"], tablefmt="grid"))

        return {
            "utilization": utilization,
            "remaining": remaining,
            "status": "critical" if utilization >= 95 else "warning" if utilization >= 85 else "normal"
        }

if __name__ == "__main__":
    tracker = BudgetTracker()
    tracker.analyze_budget_status()
EOF

    print_success "Analysis tools created"
}

# Create dashboard
create_dashboard() {
    print_status "Creating web dashboard..."

    cat > "$QOINS_ROOT/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QOINs - Cost Dashboard</title>
    <link rel="stylesheet" href="styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <header>
            <h1>💰 QOINs Cost Dashboard</h1>
            <div class="last-updated">Last Updated: <span id="lastUpdated">Loading...</span></div>
        </header>

        <div class="dashboard-grid">
            <!-- Budget Overview -->
            <div class="card budget-overview">
                <h2>Budget Overview</h2>
                <div class="budget-meter">
                    <div class="meter-background">
                        <div class="meter-fill" id="budgetMeter"></div>
                    </div>
                    <div class="budget-text">
                        <span id="currentSpending">$0.00</span> / <span id="budgetLimit">$0.00</span>
                    </div>
                </div>
                <div class="budget-status" id="budgetStatus">Loading...</div>
            </div>

            <!-- Service Breakdown -->
            <div class="card service-breakdown">
                <h2>Service Breakdown</h2>
                <canvas id="serviceChart"></canvas>
            </div>

            <!-- Daily Spending -->
            <div class="card daily-spending">
                <h2>Daily Spending (Last 30 Days)</h2>
                <canvas id="dailyChart"></canvas>
            </div>

            <!-- Quick Stats -->
            <div class="card quick-stats">
                <h2>Quick Stats</h2>
                <div class="stat-grid">
                    <div class="stat">
                        <div class="stat-value" id="todaySpending">$0.00</div>
                        <div class="stat-label">Today</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="avgDaily">$0.00</div>
                        <div class="stat-label">Avg Daily</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="projectedTotal">$0.00</div>
                        <div class="stat-label">Projected</div>
                    </div>
                    <div class="stat">
                        <div class="stat-value" id="daysRemaining">0</div>
                        <div class="stat-label">Days Left</div>
                    </div>
                </div>
            </div>

            <!-- Recommendations -->
            <div class="card recommendations">
                <h2>💡 Cost Optimization</h2>
                <ul id="recommendationsList">
                    <li>Loading recommendations...</li>
                </ul>
            </div>

            <!-- Local vs Cloud -->
            <div class="card local-vs-cloud">
                <h2>Local vs Cloud Usage</h2>
                <div class="usage-comparison">
                    <div class="usage-bar">
                        <label>Local Models</label>
                        <div class="bar">
                            <div class="bar-fill local" style="width: 60%"></div>
                        </div>
                        <span>60%</span>
                    </div>
                    <div class="usage-bar">
                        <label>Cloud APIs</label>
                        <div class="bar">
                            <div class="bar-fill cloud" style="width: 40%"></div>
                        </div>
                        <span>40%</span>
                    </div>
                </div>
                <div class="savings-indicator">
                    💰 Estimated Monthly Savings: <strong>$18.50</strong>
                </div>
            </div>
        </div>
    </div>

    <script src="dashboard.js"></script>
</body>
</html>
EOF

    cat > "$QOINS_ROOT/dashboard/styles.css" << 'EOF'
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    color: #333;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

header {
    text-align: center;
    margin-bottom: 30px;
    color: white;
}

header h1 {
    font-size: 2.5rem;
    margin-bottom: 10px;
}

.last-updated {
    opacity: 0.8;
    font-size: 0.9rem;
}

.dashboard-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
}

.card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    backdrop-filter: blur(10px);
}

.card h2 {
    margin-bottom: 16px;
    color: #333;
    font-size: 1.25rem;
}

/* Budget Overview */
.budget-overview {
    grid-column: span 2;
}

.budget-meter {
    margin: 20px 0;
}

.meter-background {
    width: 100%;
    height: 20px;
    background: #e0e0e0;
    border-radius: 10px;
    overflow: hidden;
}

.meter-fill {
    height: 100%;
    background: linear-gradient(90deg, #4CAF50, #FFC107, #f44336);
    border-radius: 10px;
    transition: width 0.5s ease;
}

.budget-text {
    text-align: center;
    font-size: 1.5rem;
    font-weight: bold;
    margin-top: 10px;
}

.budget-status {
    text-align: center;
    padding: 10px;
    border-radius: 8px;
    font-weight: bold;
    margin-top: 10px;
}

.budget-status.normal { background: #e8f5e8; color: #2e7d32; }
.budget-status.warning { background: #fff3e0; color: #f57c00; }
.budget-status.critical { background: #ffebee; color: #c62828; }

/* Quick Stats */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
}

.stat {
    text-align: center;
    padding: 16px;
    background: #f8f9fa;
    border-radius: 8px;
}

.stat-value {
    font-size: 1.5rem;
    font-weight: bold;
    color: #333;
}

.stat-label {
    font-size: 0.875rem;
    color: #666;
    margin-top: 4px;
}

/* Usage Comparison */
.usage-comparison {
    space-y: 12px;
}

.usage-bar {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.usage-bar label {
    min-width: 80px;
    font-size: 0.875rem;
}

.bar {
    flex: 1;
    height: 8px;
    background: #e0e0e0;
    border-radius: 4px;
    overflow: hidden;
}

.bar-fill {
    height: 100%;
    transition: width 0.5s ease;
}

.bar-fill.local { background: #4CAF50; }
.bar-fill.cloud { background: #2196F3; }

.savings-indicator {
    margin-top: 16px;
    padding: 12px;
    background: #e8f5e8;
    border-radius: 8px;
    text-align: center;
    color: #2e7d32;
}

/* Recommendations */
.recommendations ul {
    list-style: none;
}

.recommendations li {
    padding: 8px 0;
    border-bottom: 1px solid #eee;
}

.recommendations li:last-child {
    border-bottom: none;
}

/* Responsive */
@media (max-width: 768px) {
    .dashboard-grid {
        grid-template-columns: 1fr;
    }

    .budget-overview {
        grid-column: span 1;
    }

    .stat-grid {
        grid-template-columns: repeat(
