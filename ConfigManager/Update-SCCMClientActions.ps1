
function Update-SCCMClientActions {
    param (
        [string[]]$TriggerSchedules = @(
            '{00000000-0000-0000-0000-000000000021}', # Machine policy retrieval & Evaluation Cycle
            '{00000000-0000-0000-0000-000000000022}', # Machine policy evaluation cycle
            '{00000000-0000-0000-0000-000000000003}', # Discovery Data Collection Cycle
            '{00000000-0000-0000-0000-000000000002}', # Software inventory cycle
            '{00000000-0000-0000-0000-000000000001}', # Hardware inventory cycle
            '{00000000-0000-0000-0000-000000000113}', # Software updates scan cycle
            '{00000000-0000-0000-0000-000000000114}', # Software updates deployment evaluation cycle
            '{00000000-0000-0000-0000-000000000031}', # Software metering usage report cycle
            '{00000000-0000-0000-0000-000000000121}', # Application deployment evaluation cycle
            '{00000000-0000-0000-0000-000000000026}', # User policy retrieval
            '{00000000-0000-0000-0000-000000000027}', # User policy evaluation cycle
            '{00000000-0000-0000-0000-000000000032}', # Windows installer source list update cycle
            '{00000000-0000-0000-0000-000000000010}'  # File collection 
        )
    )
    
    foreach ($triggerSchedule in $TriggerSchedules){
        Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule $triggerSchedule
    }
}
