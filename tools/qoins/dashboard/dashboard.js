// QOINs Cost Dashboard JavaScript
// Handles data visualization and real-time updates

class QOINsDashboard {
    constructor() {
        this.data = null;
        this.charts = {};
        this.refreshInterval = 60000; // 1 minute
        this.init();
    }

    async init() {
        await this.loadData();
        this.setupCharts();
        this.updateDashboard();
        this.startAutoRefresh();
    }

    async loadData() {
        try {
            // In a real implementation, this would fetch from your backend
            // For now, using mock data based on the current situation
            this.data = {
                budget: {
                    limit: 110.00,
                    current: 95.94,
                    utilization: 87.2
                },
                services: {
                    openai: { amount: 45.20, percentage: 41 },
                    aws: { amount: 28.15, percentage: 26 },
                    github: { amount: 12.30, percentage: 11 },
                    vercel: { amount: 10.29, percentage: 9 },
                    other: { amount: 0.00, percentage: 0 }
                },
                dailySpending: this.generateDailyData(),
                localVsCloud: {
                    local: 60,
                    cloud: 40,
                    savings: 18.50
                },
                recommendations: [
                    "Switch to local LLM for 40% of OpenAI calls → Save ~$18/month",
                    "Optimize AWS Lambda memory allocation → Save ~$8/month",
                    "Use GitHub free tier more efficiently → Save ~$5/month",
                    "Consolidate Vercel deployments → Save ~$3/month"
                ],
                lastUpdated: new Date().toISOString()
            };
        } catch (error) {
            console.error('Failed to load data:', error);
            this.showError('Failed to load cost data');
        }
    }

    generateDailyData() {
        // Generate mock daily spending data for the last 30 days
        const days = 30;
        const data = [];
        const today = new Date();

        for (let i = days - 1; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);

            // Simulate realistic daily spending patterns
            const baseSpending = 3.2; // Average daily spend
            const randomVariation = (Math.random() - 0.5) * 2; // ±1
            const weekendReduction = date.getDay() === 0 || date.getDay() === 6 ? -1 : 0;

            const amount = Math.max(0, baseSpending + randomVariation + weekendReduction);

            data.push({
                date: date.toISOString().split('T')[0],
                amount: Math.round(amount * 100) / 100
            });
        }

        return data;
    }

    updateDashboard() {
        this.updateBudgetOverview();
        this.updateQuickStats();
        this.updateRecommendations();
        this.updateLocalVsCloud();
        this.updateLastUpdated();
    }

    updateBudgetOverview() {
        const { budget } = this.data;

        // Update budget meter
        const meterFill = document.getElementById('budgetMeter');
        const currentSpending = document.getElementById('currentSpending');
        const budgetLimit = document.getElementById('budgetLimit');
        const budgetStatus = document.getElementById('budgetStatus');

        if (meterFill) {
            meterFill.style.width = `${budget.utilization}%`;
        }

        if (currentSpending) {
            currentSpending.textContent = `$${budget.current.toFixed(2)}`;
        }

        if (budgetLimit) {
            budgetLimit.textContent = `$${budget.limit.toFixed(2)}`;
        }

        if (budgetStatus) {
            let status, statusClass;

            if (budget.utilization >= 95) {
                status = '🚨 CRITICAL - Emergency mode recommended';
                statusClass = 'critical';
            } else if (budget.utilization >= 85) {
                status = '⚠️ WARNING - High usage detected';
                statusClass = 'warning';
            } else if (budget.utilization >= 75) {
                status = '🟡 CAUTION - Monitor closely';
                statusClass = 'warning';
            } else {
                status = '✅ NORMAL - Within budget';
                statusClass = 'normal';
            }

            budgetStatus.textContent = status;
            budgetStatus.className = `budget-status ${statusClass}`;
        }
    }

    updateQuickStats() {
        const dailyData = this.data.dailySpending;
        const todaySpending = dailyData[dailyData.length - 1]?.amount || 0;
        const avgDaily = dailyData.reduce((sum, day) => sum + day.amount, 0) / dailyData.length;

        const today = new Date();
        const daysInMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
        const daysRemaining = daysInMonth - today.getDate();

        const projectedTotal = this.data.budget.current + (avgDaily * daysRemaining);

        this.updateElement('todaySpending', `$${todaySpending.toFixed(2)}`);
        this.updateElement('avgDaily', `$${avgDaily.toFixed(2)}`);
        this.updateElement('projectedTotal', `$${projectedTotal.toFixed(2)}`);
        this.updateElement('daysRemaining', daysRemaining.toString());
    }

    updateRecommendations() {
        const list = document.getElementById('recommendationsList');
        if (!list) return;

        list.innerHTML = '';
        this.data.recommendations.forEach(rec => {
            const li = document.createElement('li');
            li.textContent = rec;
            list.appendChild(li);
        });
    }

    updateLocalVsCloud() {
        const { localVsCloud } = this.data;

        // Update usage bars
        const localBar = document.querySelector('.bar-fill.local');
        const cloudBar = document.querySelector('.bar-fill.cloud');

        if (localBar) localBar.style.width = `${localVsCloud.local}%`;
        if (cloudBar) cloudBar.style.width = `${localVsCloud.cloud}%`;

        // Update savings indicator
        const savingsIndicator = document.querySelector('.savings-indicator strong');
        if (savingsIndicator) {
            savingsIndicator.textContent = `$${localVsCloud.savings.toFixed(2)}`;
        }
    }

    updateLastUpdated() {
        const element = document.getElementById('lastUpdated');
        if (element) {
            const date = new Date(this.data.lastUpdated);
            element.textContent = date.toLocaleString();
        }
    }

    updateElement(id, text) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = text;
        }
    }

    setupCharts() {
        this.setupServiceChart();
        this.setupDailyChart();
    }

    setupServiceChart() {
        const ctx = document.getElementById('serviceChart');
        if (!ctx) return;

        const services = this.data.services;
        const labels = Object.keys(services).map(key => key.charAt(0).toUpperCase() + key.slice(1));
        const amounts = Object.values(services).map(service => service.amount);
        const colors = [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF'
        ];

        this.charts.service = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: amounts,
                    backgroundColor: colors,
                    borderWidth: 2,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${label}: $${value.toFixed(2)} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });
    }

    setupDailyChart() {
        const ctx = document.getElementById('dailyChart');
        if (!ctx) return;

        const dailyData = this.data.dailySpending;
        const labels = dailyData.map(day => {
            const date = new Date(day.date);
            return `${date.getMonth() + 1}/${date.getDate()}`;
        });
        const amounts = dailyData.map(day => day.amount);

        this.charts.daily = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Daily Spending',
                    data: amounts,
                    borderColor: '#36A2EB',
                    backgroundColor: 'rgba(54, 162, 235, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `$${context.parsed.y.toFixed(2)}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return `$${value.toFixed(2)}`;
                            }
                        }
                    },
                    x: {
                        display: true,
                        ticks: {
                            maxTicksLimit: 10
                        }
                    }
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });
    }

    startAutoRefresh() {
        setInterval(async () => {
            await this.loadData();
            this.updateDashboard();
            this.updateCharts();
        }, this.refreshInterval);
    }

    updateCharts() {
        // Update service chart
        if (this.charts.service) {
            const services = this.data.services;
            const amounts = Object.values(services).map(service => service.amount);
            this.charts.service.data.datasets[0].data = amounts;
            this.charts.service.update();
        }

        // Update daily chart
        if (this.charts.daily) {
            const dailyData = this.data.dailySpending;
            const amounts = dailyData.map(day => day.amount);
            this.charts.daily.data.datasets[0].data = amounts;
            this.charts.daily.update();
        }
    }

    showError(message) {
        console.error(message);
        // You could add a toast notification or error banner here
    }

    // Public methods for debugging
    refreshData() {
        return this.loadData().then(() => {
            this.updateDashboard();
            this.updateCharts();
        });
    }

    getBudgetStatus() {
        return {
            current: this.data.budget.current,
            limit: this.data.budget.limit,
            utilization: this.data.budget.utilization,
            remaining: this.data.budget.limit - this.data.budget.current
        };
    }

    getTopServices() {
        return Object.entries(this.data.services)
            .sort(([,a], [,b]) => b.amount - a.amount)
            .slice(0, 3)
            .map(([name, data]) => ({ name, ...data }));
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.qoinsDashboard = new QOINsDashboard();

    // Expose debug functions to global scope
    window.qoinsDebug = {
        refreshData: () => window.qoinsDashboard.refreshData(),
        getBudgetStatus: () => window.qoinsDashboard.getBudgetStatus(),
        getTopServices: () => window.qoinsDashboard.getTopServices(),
        getData: () => window.qoinsDashboard.data
    };
});

// Handle visibility change to pause/resume updates
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible' && window.qoinsDashboard) {
        window.qoinsDashboard.refreshData();
    }
});
