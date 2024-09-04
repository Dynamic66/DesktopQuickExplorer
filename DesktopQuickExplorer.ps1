param (
    [parameter(Mandatory = $true)]
    [string]$name = 'new Container',
    [parameter(Mandatory = $true)]
    [string]$ContainerPath = 'C:\',
    [parameter(HelpMessage = '"$x,$y"')]
    [string]$StartLocation,
    [string]$UseIconFromFile,
    [string]$Theme = 'Back&Purple',
    [switch]$ControlBox = $true
)

[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][reflection.assembly]::Load('PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')

$script:name = $name
$script:StartLocation = $StartLocation
$script:UseIconFromFile = $UseIconFromFile
$script:Theme = $Theme
$script:Controlbox = $Controlbox
$script:Containerpath = $Containerpath
$script:Container = Get-ChildItem -Path $Containerpath -ErrorAction SilentlyContinue

$script:explorerIconpath = 'C:\Windows\explorer.exe'
if ($explorerIconpath) {
    $explorerIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($explorerIconpath)
}


$script:AddIconpath = $null ### change to a pwth with a + Symbol Icon file
if ($AddIconpath) {
    $script:AddIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($AddIconpath)
}

if ($Theme -eq 'Lightmode') {
    $script:textcolor = [system.Drawing.Color]::Black
    $script:color1 = [system.Drawing.Color]::FromArgb(250, 250, 250)
    $script:color2 = [system.Drawing.Color]::FromArgb(228, 229, 241)
    $script:color3 = [system.Drawing.Color]::FromArgb(72, 75, 106)
}
elseif ($Theme -eq 'Darkmode') {
    $Theme = 'Darkmode'
    $script:textcolor = [system.Drawing.Color]::White
    $script:color1 = [system.Drawing.Color]::FromArgb(500, 50, 50)
    $script:color2 = [system.Drawing.Color]::FromArgb(60, 60, 60)
    $script:color3 = [system.Drawing.Color]::FromArgb(70, 70, 70)
}
elseif ($Theme -eq 'Back&Purple') {
    $script:textcolor = [system.Drawing.Color]::MediumPurple
    $script:color1 = [system.Drawing.Color]::FromArgb(20, 20, 20)
    $script:color2 = [system.Drawing.Color]::FromArgb(20, 20, 20)
    $script:color3 = [system.Drawing.Color]::FromArgb(20, 20, 20)
    

}

if ($UseIconFromFile) {
    $script:defaultIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($UseIconFromFile)
}



function Show-Container {
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $fBase = New-Object 'System.Windows.Forms.Form'
    $button = New-Object 'System.Windows.Forms.Button'
    $timerDrag = New-Object 'System.Windows.Forms.Timer'
    $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

    $fBase_Load = {
        if (-not (Test-Path -Path $Containerpath)) {
            [system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`n`nContainerPath = '$Containerpath'", 'Error', 'OK', 'Error')
            $fBase.Close()
            return
        }
		
		
        if ($StartLocation) {
            $fBase.Location = New-Object System.Drawing.Point($StartLocation.split(','))
        }
		
        if ($UseIconFromFile) {
            $button.Text = $null
            $button.Image = $defaultIcon
        }
        else {
            $button.Text = $name
        }
		
        if ($Controlbox) {
            $fBase.controlbox = $true
        }
        else {
            $fBase.controlbox = $false
        }

        $button.ForeColor = $textcolor
        $button.FlatAppearance.BorderColor = $color1
        $button.BackColor = $color2
        $fBase.BackColor = $color2
        $script:form1 = $fBase
		
        $script:Container = Get-ChildItem -Path $Containerpath
    }
	
	
	
    $button_MouseEnter = {
        $fBase.Opacity = 0.8
        Show-OpedContainer
    }
	
    $button_DragEnter = [System.Windows.Forms.DragEventHandler] {
		
        if (-not (Test-Path -Path $Containerpath)) {
            [system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`n`nContainerPath = '$Containerpath'", 'Error', 'OK', 'Error')
            $fBase.Close()
            return
        }
		
        $button.Image = $null
        $fBase.Opacity = 1
        $button.Text = $null
        $button.BackgroundImage = $AddIcon
        $script:drag = $args[1]
    }
	
    $button_DragLeave = {
        $button.BackgroundImage = $null
        $fBase.Opacity = 0.5
        if ($UseIconFromFile) {
            $button.Image = $defaultIcon
        }
        else {
            $button.Text = $name
        }
        Start-Sleep -Milliseconds 80 # else it is alsways true cuz its reads to fast
		
        if ($fBase.ClientRectangle.Contains($button.PointToClient([System.Windows.Forms.Cursor]::Position))) {
            'inside' | oh
            foreach ($path in $drag.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)) {
                'drag: ' + $path | oh
                Move-Item -Path $path -Destination $Containerpath -Force
            }
            'done' | oh
            $timerDrag.Enabled = $false
        }
    }
	
    $fBase_FormClosed = [System.Windows.Forms.FormClosedEventHandler] {
        #$configpath = ($HostInvocation.MyCommand | Split-Path -Parent) + "\Containers\$name.ps1"
        #"$($HostInvocation.mycommand) -name '$name' -ContainerPath '$Containerpath' -StartLocation '$($fBase.Location.X),$($fBase.Location.y)' -UseIconFromFile '$UseIconFromFile' -Theme '$theme'" | Out-File -FilePath $configpath
    }
	
	
    $Form_StateCorrection_Load =
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $fBase.WindowState = $InitialFormWindowState
    }
	
    $Form_StoreValues_Closing =
    {
        #Store the control values
    }

	
    $Form_Cleanup_FormClosed =
    {
        #Remove all event handlers from the controls
        try {
            $button.remove_DragEnter($button_DragEnter)
            $button.remove_DragLeave($button_DragLeave)
            $button.remove_MouseEnter($button_MouseEnter)
            $fBase.remove_FormClosed($fBase_FormClosed)
            $fBase.remove_Load($fBase_Load)
            $fBase.remove_Load($Form_StateCorrection_Load)
            $fBase.remove_Closing($Form_StoreValues_Closing)
            $fBase.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
        $fBase.Dispose()
        $button.Dispose()
        $timerDrag.Dispose()
    }
 
    $fBase.SuspendLayout()
    #
    # form1
    #
    $fBase.Controls.Add($button)
    $fBase.AllowDrop = $True
    $fBase.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
    $fBase.AutoScaleMode = 'Font'
    $fBase.BackColor = $color1
    $fBase.BackgroundImageLayout = 'Stretch'
    $fBase.ClientSize = New-Object System.Drawing.Size(120, 80)
    $fBase.ForeColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
    $fBase.controlbox = $true
    $fBase.MaximizeBox = $False
    $fBase.MinimizeBox = $False
    $fBase.Name = 'form1'
    $fBase.Opacity = 0.7
    $fBase.Padding = '5, 5, 5, 5'
    $fBase.ShowIcon = $False
    $fBase.ShowInTaskbar = $False
    $fBase.SizeGripStyle = 'Hide'
    $fBase.StartPosition = 'CenterScreen'
    $fBase.TransparencyKey = [System.Drawing.Color]::Lime 
    $fBase.add_FormClosed($fBase_FormClosed)
    $fBase.add_Load($fBase_Load)
    #
    # button
    #
    $button.AllowDrop = $True
    $button.BackColor = [System.Drawing.SystemColors]::Control 
    $button.BackgroundImageLayout = 'Center'
    $button.Dock = 'Fill'
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 70, 70, 70)
    $button.FlatAppearance.BorderSize = 0
    $button.FlatStyle = 'Flat'
    $button.Font = [System.Drawing.Font]::new('Microsoft Sans Serif', '20.25')
    $button.ForeColor = [System.Drawing.SystemColors]::ControlLightLight 
    $button.Location = New-Object System.Drawing.Point(5, 5)
    $button.Margin = '0, 0, 0, 0'
    $button.Name = 'button'
    $button.Size = New-Object System.Drawing.Size(110, 70)
    $button.TabIndex = 0
    $button.TextImageRelation = 'ImageAboveText'
    $button.UseMnemonic = $False
    $button.UseVisualStyleBackColor = $False
    $button.add_DragEnter($button_DragEnter)
    $button.add_DragLeave($button_DragLeave)
    $button.add_MouseEnter($button_MouseEnter)
    #
    # timerDrag
    #
    $fBase.ResumeLayout()
    #endregion Generated Form Code

    #----------------------------------------------

    #Save the initial state of the form
    $InitialFormWindowState = $fBase.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $fBase.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $fBase.add_FormClosed($Form_Cleanup_FormClosed)
    #Store the control values when form is closing
    $fBase.add_Closing($Form_StoreValues_Closing)
    #Show the Form
    return $fBase.ShowDialog()

}


function Add-Button ($file) {
    $button = New-Object System.Windows.Forms.button
    if ($file.psiscontainer) {
        $button.Image = $explorerIcon
    }
    else {
        $button.Image = [System.Drawing.Icon]::ExtractAssociatedIcon($file.FullName)
    }
    $button.Text = $file.BaseName
    $button.TextImageRelation = 'ImageAboveText'
    $button.ForeColor = $textcolor
    $button.Tag = $file
    $button.Size = New-Object System.Drawing.Size(140, 70)
    $button.FlatStyle = 'Flat'
    $button.FlatAppearance.BorderSize = 0
    $button.add_Click({ Invoke-Item -Path $args[0].tag.fullname })
    $button.ContextMenuStrip = $contextmenustrip1
		
    $flp.controls.Add($button)
}


function Load-Container {

    if (-not (Test-Path -Path $Containerpath)) {
        [system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`n`nContainerPath = '$Containerpath'", 'Error', 'OK', 'Error')
        $fBase.Close()
        $fContainer.Close()
        return
    }

    $textbox1.AutoCompleteCustomSource.Equals($null)

    $flp.controls.Clear()

    $panel1.SendToBack()

    $textbox1.ForeColor = $textcolor
    $checkboxGrip.ForeColor = $textcolor
    $fContainer.BackColor = $color1
    $flp.BackColor = $color2
    $panel1.BackColor = $color2
    $textbox1.BackColor = $color2
    $checkboxGrip.BackColor = $color2
		
    if ($fBase.controlbox) {
        $checkboxGrip.Checked = $true
    }
    else {
        $checkboxGrip.Checked = $false
    }
		
    $script:Container = Get-ChildItem -Path $Containerpath
    foreach ($file in $Container) {
        $textbox1.AutoCompleteCustomSource.Add($file.name)
        Add-Button -file $file
    }
    
}


function Show-OpedContainer {
    $fContainer = New-Object 'System.Windows.Forms.Form'
    $flp = New-Object 'System.Windows.Forms.FlowLayoutPanel'
    $panel1 = New-Object 'System.Windows.Forms.Panel'
    $textbox1 = New-Object 'System.Windows.Forms.TextBox'
    $checkboxGrip = New-Object 'System.Windows.Forms.CheckBox'
    $timer1 = New-Object 'System.Windows.Forms.Timer'
    $contextmenustrip1 = New-Object 'System.Windows.Forms.ContextMenuStrip'
    $tsmReturn = New-Object 'System.Windows.Forms.ToolStripMenuItem'
    $OpenContainerFolder = New-Object 'System.Windows.Forms.ToolStripMenuItem'
    $DeleteItem = New-Object 'System.Windows.Forms.ToolStripMenuItem'
    $toolstripseparator1 = New-Object 'System.Windows.Forms.ToolStripSeparator'
    $imagelist = New-Object 'System.Windows.Forms.ImageList'
    $InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

    $fContainer_Load = {
        Load-Container
    }
	
    $fContainer_Shown = {
        $bounds = [system.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $size = 500
        $fContainer.Size = New-Object System.Drawing.Size($size, $size)
        $fContainer.Refresh()
        $center = ($fBase.size.Width / 2) - ($fContainer.size.Width / 2)
        [int]$x = $fBase.location.x + $center
        [int]$y = $fBase.location.y + $center
		
        #adjust loaction x
        if ($x + $size -ge $bounds.Right) {
            $x = $bounds.Right - $size
        }
        elseif ($x -le $bounds.Left) {
            $x = $bounds.Left
        }
        #adjust loaction y
        if ($y + $size -ge $bounds.Bottom) {
            $y = $bounds.bottom - $size
        }
        elseif ($y -le $bounds.top) {
            $y = $bounds.top
        }
		
        $fContainer.Location = New-Object System.Drawing.point($x, $y)
        foreach ($Opacity in (1 .. 9)) {
            $fContainer.Opacity = $Opacity / 10
            Start-Sleep -Milliseconds 1
        }
		
        $timer1.Enabled = $true
        $flp.add_MouseWheel({
                $flp.AutoScroll = $true
                $flp.Refresh()
            })
    }
	
    $timer1_Tick = {
        if (-not $fContainer.ClientRectangle.Contains($fContainer.PointToClient([System.Windows.Forms.Cursor]::Position))) {
            $flp.Visible = $false
            foreach ($size in (10 .. 0)) {
                $fContainer.Opacity = $size / 10
                Start-Sleep -Milliseconds 1
            }
            $fContainer.Close()
        }
    }
	
    $tsmReturn_Click = {
        Move-Item -Path $contextmenustrip1.SourceControl.Tag.fullname -Destination "$env:USERPROFILE\Desktop\"
        Load-Container
    }
	
    $OpenContainerFolder_Click = {
        Invoke-Item -Path $Containerpath
    }
	
    $DeleteItem_Click = {
        #Throws items in the Recycling bin 
        $shell = New-Object -ComObject 'Shell.Application'
		($shell.Namespace(0).ParseName($contextmenustrip1.SourceControl.Tag.fullname)).InvokeVerb('delete')
        Load-Container
        $shell = $null
    }
	
    $checkboxGrip_CheckedChanged = {
        if ($checkboxGrip.checked) {
            $fBase.controlbox = $true
            $fBase.SizeGripStyle = 'Show'
            $checkboxGrip.Text = '↕'
        }
        else {
            $fBase.controlbox = $false
            $fBase.SizeGripStyle = 'hide'
            $checkboxGrip.Text = '↕'
        }
    }
	
    $fContainer_MouseLeave = {
        if (-not $args[0].ClientRectangle.Contains($args[0].PointToClient([System.Windows.Forms.Cursor]::Position))) {
            $fContainer.Close()
        }
    }
	
	
    $textbox1_KeyDown = [System.Windows.Forms.KeyEventHandler] {
        if ($_.KeyValue -eq 13) {
            $flp.Controls.Clear()
            foreach ($item in ($Container | Where-Object name -Match $textbox1.Text)) {
                Add-Button -file $item
            }
        }
    }
	
    $Form_StateCorrection_Load =
    {
        #Correct the initial state of the form to prevent the .Net maximized form issue
        $fContainer.WindowState = $InitialFormWindowState
    }
	
    $Form_StoreValues_Closing =
    {
        #Store the control values
        $script:OpedContainer_textbox1 = $textbox1.Text
        $script:OpedContainer_checkboxGrip = $checkboxGrip.Checked
    }

	
    $Form_Cleanup_FormClosed =
    {
        #Remove all event handlers from the controls
        try {
            $textbox1.remove_KeyDown($textbox1_KeyDown)
            $checkboxGrip.remove_CheckedChanged($checkboxGrip_CheckedChanged)
            $fContainer.remove_Load($fContainer_Load)
            $fContainer.remove_Shown($fContainer_Shown)
            $fContainer.remove_MouseLeave($fContainer_MouseLeave)
            $timer1.remove_Tick($timer1_Tick)
            $tsmReturn.remove_Click($tsmReturn_Click)
            $OpenContainerFolder.remove_Click($OpenContainerFolder_Click)
            $DeleteItem.remove_Click($DeleteItem_Click)
            $fContainer.remove_Load($Form_StateCorrection_Load)
            $fContainer.remove_Closing($Form_StoreValues_Closing)
            $fContainer.remove_FormClosed($Form_Cleanup_FormClosed)
        }
        catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
        $fContainer.Dispose()
        $flp.Dispose()
        $panel1.Dispose()
        $textbox1.Dispose()
        $checkboxGrip.Dispose()
        $timer1.Dispose()
        $contextmenustrip1.Dispose()
        $tsmReturn.Dispose()
        $OpenContainerFolder.Dispose()
        $DeleteItem.Dispose()
        $toolstripseparator1.Dispose()
        $imagelist.Dispose()
    }
    #endregion Generated Events

 
    $fContainer.SuspendLayout()
    $panel1.SuspendLayout()
    $contextmenustrip1.SuspendLayout()
    #
    # fContainer
    #
    $fContainer.Controls.Add($flp)
    $fContainer.Controls.Add($panel1)
    $fContainer.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
    $fContainer.AutoScaleMode = 'Font'
    $fContainer.BackColor = [System.Drawing.Color]::FromArgb(255, 70, 70, 70)
    $fContainer.BackgroundImageLayout = 'None'
    $fContainer.ClientSize = New-Object System.Drawing.Size(205, 182)
    $fContainer.ControlBox = $False
    $fContainer.MaximizeBox = $False
    $fContainer.MinimizeBox = $False
    $fContainer.Name = 'fContainer'
    $fContainer.Opacity = 0
    $fContainer.ShowIcon = $False
    $fContainer.ShowInTaskbar = $False
    $fContainer.SizeGripStyle = 'Hide'
    $fContainer.StartPosition = 'CenterParent'
    $fContainer.TopMost = $True
    $fContainer.add_Load($fContainer_Load)
    $fContainer.add_Shown($fContainer_Shown)
    $fContainer.add_MouseLeave($fContainer_MouseLeave)
    #
    # flp
    #
    $flp.BackColor = [System.Drawing.Color]::FromArgb(255, 65, 65, 65)
    $flp.Dock = 'Fill'
    $flp.Location = New-Object System.Drawing.Point(0, 32)
    $flp.Margin = '0, 0, 0, 0'
    $flp.Name = 'flp'
    $flp.Padding = '20, 10, 0, 10'
    $flp.Size = New-Object System.Drawing.Size(205, 150)
    $flp.TabIndex = 1
    #
    # panel1
    #
    $panel1.Controls.Add($textbox1)
    $panel1.Controls.Add($checkboxGrip)
    $panel1.BackColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
    $panel1.Dock = 'Top'
    $panel1.Location = New-Object System.Drawing.Point(0, 0)
    $panel1.Margin = '0, 0, 0, 0'
    $panel1.Name = 'panel1'
    $panel1.Padding = '20, 0, 0, 0'
    $panel1.Size = New-Object System.Drawing.Size(205, 32)
    $panel1.TabIndex = 0
    #
    # textbox1
    #
    $textbox1.AutoCompleteMode = 'Suggest'
    $textbox1.AutoCompleteSource = 'CustomSource'
    $textbox1.BackColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
    $textbox1.BorderStyle = 'None'
    $textbox1.Cursor = 'Default'
    $textbox1.Font = [System.Drawing.Font]::new('Microsoft Tai Le', '9.75')
    $textbox1.ForeColor = [System.Drawing.SystemColors]::Control 
    $textbox1.Location = New-Object System.Drawing.Point(23, 9)
    $textbox1.Margin = '0, 0, 0, 0'
    $textbox1.Name = 'textbox1'
    $textbox1.Size = New-Object System.Drawing.Size(140, 17)
    $textbox1.TabIndex = 0
    $textbox1.add_KeyDown($textbox1_KeyDown)
    #
    # checkboxGrip
    #
    $checkboxGrip.Appearance = 'Button'
    $checkboxGrip.BackColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
    $checkboxGrip.Dock = 'Right'
    $checkboxGrip.FlatAppearance.BorderSize = 0
    $checkboxGrip.FlatStyle = 'Flat'
    $checkboxGrip.Font = [System.Drawing.Font]::new('Microsoft Sans Serif', '11.25')
    $checkboxGrip.ForeColor = [System.Drawing.Color]::White 
    $checkboxGrip.Location = New-Object System.Drawing.Point(172, 0)
    $checkboxGrip.Name = 'checkboxGrip'
    $checkboxGrip.Size = New-Object System.Drawing.Size(33, 32)
    $checkboxGrip.TabIndex = 3
    $checkboxGrip.TabStop = $False
    $checkboxGrip.Text = '↕'
    $checkboxGrip.TextAlign = 'MiddleCenter'
    $checkboxGrip.UseVisualStyleBackColor = $False
    $checkboxGrip.add_CheckedChanged($checkboxGrip_CheckedChanged)
    #
    # timer1
    #
    $timer1.add_Tick($timer1_Tick)
    #
    # contextmenustrip1
    #
    $contextmenustrip1.BackColor = [System.Drawing.Color]::FromArgb(255, 70, 70, 70)
    [void]$contextmenustrip1.Items.Add($tsmReturn)
    [void]$contextmenustrip1.Items.Add($toolstripseparator1)
    [void]$contextmenustrip1.Items.Add($OpenContainerFolder)
    [void]$contextmenustrip1.Items.Add($DeleteItem)
    $contextmenustrip1.Name = 'contextmenustrip1'
    $contextmenustrip1.RenderMode = 'System'
    $contextmenustrip1.ShowImageMargin = $False
    $contextmenustrip1.Size = New-Object System.Drawing.Size(168, 76)
    #
    # tsmReturn
    #
    $tsmReturn.ForeColor = [System.Drawing.SystemColors]::Control 
    $tsmReturn.Name = 'tsmReturn'
    $tsmReturn.Size = New-Object System.Drawing.Size(167, 22)
    $tsmReturn.Text = 'Move item to Desktop'
    $tsmReturn.add_Click($tsmReturn_Click)
    #
    # OpenContainerFolder
    #
    $OpenContainerFolder.ForeColor = [System.Drawing.SystemColors]::Control 
    $OpenContainerFolder.Name = 'OpenContainerFolder'
    $OpenContainerFolder.ShortcutKeyDisplayString = ''
    $OpenContainerFolder.Size = New-Object System.Drawing.Size(167, 22)
    $OpenContainerFolder.Text = 'Open Container folder'
    $OpenContainerFolder.add_Click($OpenContainerFolder_Click)
    #
    # DeleteItem
    #
    $DeleteItem.ForeColor = [System.Drawing.SystemColors]::Control 
    $DeleteItem.Name = 'DeleteItem'
    $DeleteItem.Size = New-Object System.Drawing.Size(167, 22)
    $DeleteItem.Text = 'Delete Item'
    $DeleteItem.add_Click($DeleteItem_Click)
    #
    # toolstripseparator1
    #
    $toolstripseparator1.Name = 'toolstripseparator1'
    $toolstripseparator1.Size = New-Object System.Drawing.Size(164, 6)
    #
    # imagelist
    #
    $imagelist.ColorDepth = 'Depth8Bit'
    $imagelist.ImageSize = New-Object System.Drawing.Size(24, 24)
    $imagelist.TransparentColor = [System.Drawing.Color]::Transparent 
    $contextmenustrip1.ResumeLayout()
    $panel1.ResumeLayout()
    $fContainer.ResumeLayout()


    #Save the initial state of the form
    $InitialFormWindowState = $fContainer.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $fContainer.add_Load($Form_StateCorrection_Load)
    #Clean up the control events
    $fContainer.add_FormClosed($Form_Cleanup_FormClosed)
    #Store the control values when form is closing
    $fContainer.add_Closing($Form_StoreValues_Closing)
    #Show the Form
    return $fContainer.ShowDialog()

}




function Main {
    Show-Container
    $script:ExitCode = 0 #Set the exit code for the Packager
}

#Start the application
Main ($CommandLine)
