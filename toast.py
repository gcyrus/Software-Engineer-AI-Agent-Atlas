#!/usr/bin/env python3
import winrm

def send_toast_notification(host, username, password, sender="Linux Host", message="Hello from Linux!"):
    """Send a toast notification to a Windows machine via WinRM"""
    
    # Create WinRM session
    session = winrm.Session(f'http://{host}:5985/wsman', auth=(username, password))
    
    # PowerShell script to create toast notification
    ps_script = f'''
    $Sender = "{sender}"
    $Message = "{message}"
    
    Function New-ToastNotification {{
        Param($Sender,$Message)
        
        $AudioSource = "ms-winsoundevent:Notification.Default"
        
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        
        $app =  '{{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}}\\WindowsPowerShell\\v1.0\\powershell.exe'
        $AppID = "{{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}}\\\\WindowsPowerShell\\\\v1.0\\\\powershell.exe"
        $RegPath = 'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings'
        
        if (!(Test-Path -Path "$RegPath\\$AppId")) {{
            $null = New-Item -Path "$RegPath\\$AppId" -Force
            $null = New-ItemProperty -Path "$RegPath\\$AppId" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD'
        }}
        
        [xml]$ToastTemplate = @"
<toast duration="long">
    <visual>
    <binding template="ToastGeneric">
        <text>$Sender</text>
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >$Message</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <audio src="$AudioSource"/>
</toast>
"@
        
        $ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
        $ToastXml.LoadXml($ToastTemplate.OuterXml)
        
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)
    }}
    
    New-ToastNotification -Sender $Sender -Message $Message
    '''
    
    try:
        result = session.run_ps(ps_script)
        if result.status_code == 0:
            print(f"Toast notification sent successfully to {host}")
            return True
        else:
            print(f"Error: {result.std_err.decode()}")
            return False
    except Exception as e:
        print(f"Failed to send notification: {e}")
        return False

if __name__ == "__main__":
    # Configuration
    HOST = "192.168.212.3"
    USERNAME = "grant"
    PASSWORD = "ik3w9PHT"
    
    # Send notification
    send_toast_notification(HOST, USERNAME, PASSWORD, "Claude", "Done")
