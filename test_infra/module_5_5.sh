#Manually trigger alarm which will trigger sleep
aws cloudwatch set-alarm-state --alarm-name flowgate-alb-no-requests-for-1-hour --state-value ALARM --state-reason "Manual test of Idle Scheduler"

#Wake instance
Get-Content response.json
