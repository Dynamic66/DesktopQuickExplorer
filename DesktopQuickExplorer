param (
	[parameter(Mandatory = $true)]
	[string]$name,
	[parameter(Mandatory = $true)]
	[string]$ContainerPath,
	[parameter(HelpMessage = '"$x,$y"')]
	[string]$StartLocation,
	[string]$UseIconFromFile,
	[string]$Theme
)

#----------------------------------------------
#region Import Assemblies
#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
#endregion Import Assemblies





$script:name = $name
$script:Containerpath = $Containerpath
$script:StartLocation = $StartLocation
$script:UseIconFromFile = $UseIconFromFile
$script:Theme = $Theme
$script:AddIconpath ############################## there need to be a path to a + looking icon its oved for drag and drop visual feedback
$script:AddIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($AddIconpath)
$script:explorerIconpath = "C:\Windows\explorer.exe"
$explorerIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($explorerIconpath)

$script:Container = Get-ChildItem -Path $Containerpath -ErrorAction SilentlyContinue

if ($Theme -eq 'Lightmode')
{
	$script:textcolor = [system.Drawing.Color]::Black
	$script:color1 = [system.Drawing.Color]::FromArgb(250, 250, 250)
	$script:color2 = [system.Drawing.Color]::FromArgb(228, 229, 241)
	$script:color3 = [system.Drawing.Color]::FromArgb(72, 75, 106)
}
else
{
	$Theme = 'Darkmode'
	$script:textcolor = [system.Drawing.Color]::White
	$script:color1 = [system.Drawing.Color]::FromArgb(50, 50, 50)
	$script:color2 = [system.Drawing.Color]::FromArgb(60, 60, 60)
	$script:color3 = [system.Drawing.Color]::FromArgb(70, 70, 70)
}

if ($UseIconFromFile)
{
	$script:defaultIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($UseIconFromFile)
}

function Main
{
	Add-Type -AssemblyName "System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
	Show-Container_psf
	$script:ExitCode = 0 #Set the exit code for the Packager
}

#endregion Source: Startup.pss

#region Source: Container.psf
function Show-Container_psf
{

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$button = New-Object 'System.Windows.Forms.Button'
	$timerDrag = New-Object 'System.Windows.Forms.Timer'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	$form1_Load = {
		if (-not (Test-Path -Path $Containerpath))
		{
			[system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`nNothing happend.`n($Containerpath)", 'Error', 'OK', 'Error', 'Button1', 'RightAlign', $false)
			$form1.Close()
		}
		$button.ForeColor = $textcolor
		$button.FlatAppearance.BorderColor = $color1
		$button.BackColor = $color2
		$form1.BackColor = $color2
		
		if ($StartLocation)
		{
			$form1.Location = New-Object System.Drawing.Point($StartLocation.split(','))
		}
		
		if ($UseIconFromFile)
		{
			$button.Text = $null
			$button.Image = $defaultIcon
		}
		else
		{
			$button.Text = $name
		}
		
		$script:form1 = $form1
		
		$script:Container = Get-ChildItem -path $Containerpath
	}
	
	
	
	$button_MouseEnter = {
		$form1.Opacity = 0.8
		Show-OpedContainer_psf
	}
	
	$button_DragEnter = [System.Windows.Forms.DragEventHandler]{
		
		if (-not (Test-Path -Path $Containerpath))
		{
			[system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`nNothing happend.`n($Containerpath)", 'Error', 'OK', 'Error', 'Button1', 'RightAlign', $false)
			$form1.Close()
		}
		
		$button.Image = $null
		$form1.Opacity = 1
		$button.Text = $null
		$button.BackgroundImage = $AddIcon
		$script:drag = $args[1]
	}
	
	$button_DragLeave = {
		$button.BackgroundImage = $null
		$form1.Opacity = 0.5
		if ($UseIconFromFile)
		{
			$button.Image = $defaultIcon
		}
		else
		{
			$button.Text = $name
		}
		Start-Sleep -Milliseconds 80 # else it is alsways true cuz its reads to fast
		
		if ($form1.ClientRectangle.Contains($button.PointToClient([System.Windows.Forms.Cursor]::Position)))
		{
			"inside" | oh
			foreach ($path in $drag.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop))
			{
				"drag: " + $path | oh
				Move-Item -Path $path -Destination $Containerpath -Force
			}
			'done' | oh
			$timerDrag.Enabled = $false
		}
	}
	
	$form1_FormClosed = [System.Windows.Forms.FormClosedEventHandler]{
		#$configpath = ($HostInvocation.MyCommand | Split-Path -Parent) + "\Containers\$name.ps1"
		#"$($HostInvocation.mycommand) -name '$name' -ContainerPath '$Containerpath' -StartLocation '$($form1.Location.X),$($form1.Location.y)' -UseIconFromFile '$UseIconFromFile' -Theme '$theme'" | Out-File -FilePath $configpath
	}
	
	
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$button.remove_DragEnter($button_DragEnter)
			$button.remove_DragLeave($button_DragLeave)
			$button.remove_MouseEnter($button_MouseEnter)
			$form1.remove_FormClosed($form1_FormClosed)
			$form1.remove_Load($form1_Load)
			$form1.remove_Load($Form_StateCorrection_Load)
			$form1.remove_Closing($Form_StoreValues_Closing)
			$form1.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
		$form1.Dispose()
		$button.Dispose()
		$timerDrag.Dispose()
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$form1.SuspendLayout()
	#
	# form1
	#
	$form1.Controls.Add($button)
	$form1.AllowDrop = $True
	$form1.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$form1.AutoScaleMode = 'Font'
	$form1.BackColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
	$form1.BackgroundImageLayout = 'Stretch'
	$form1.ClientSize = New-Object System.Drawing.Size(120, 80)
	$form1.ControlBox = $False
	$form1.ForeColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
	$form1.MaximizeBox = $False
	$form1.MinimizeBox = $False
	$form1.Name = 'form1'
	$form1.Opacity = 0.7
	$form1.Padding = '5, 5, 5, 5'
	$form1.ShowIcon = $False
	$form1.ShowInTaskbar = $False
	$form1.SizeGripStyle = 'Hide'
	$form1.StartPosition = 'CenterScreen'
	$form1.TransparencyKey = [System.Drawing.Color]::Lime 
	$form1.add_FormClosed($form1_FormClosed)
	$form1.add_Load($form1_Load)
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
	$form1.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$form1.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $form1.ShowDialog()

}
#endregion Source: Container.psf

#region Source: OpedContainer.psf
function Show-OpedContainer_psf
{
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form2 = New-Object 'System.Windows.Forms.Form'
	$flp = New-Object 'System.Windows.Forms.FlowLayoutPanel'
	$panel1 = New-Object 'System.Windows.Forms.Panel'
	$textbox1 = New-Object 'System.Windows.Forms.TextBox'
	$checkboxGrip = New-Object 'System.Windows.Forms.CheckBox'
	$timer1 = New-Object 'System.Windows.Forms.Timer'
	$contextmenustrip1 = New-Object 'System.Windows.Forms.ContextMenuStrip'
	$tsmReturn = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$toolstripmenuitem2 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$toolstripmenuitem3 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$toolstripseparator1 = New-Object 'System.Windows.Forms.ToolStripSeparator'
	$imagelist = New-Object 'System.Windows.Forms.ImageList'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
	function Load-Container
	{
		if (-not (Test-Path -Path $Containerpath))
		{
			[system.Windows.Forms.MessageBox]::Show("Containerpath does not Exist.`nThis Container will shutdown.`nNothing happend.`n($Containerpath)", 'Error', 'OK', 'Error', 'Button1', 'RightAlign', $false)
			$form1.Close()
			$form2.Close()
		}
		$textbox1.AutoCompleteCustomSource.Equals($null)
		$flp.controls.Clear()
		$panel1.SendToBack()
		$textbox1.ForeColor = $textcolor
		$checkboxGrip.ForeColor = $textcolor
		$form2.BackColor = $color1
		$flp.BackColor = $color2
		$panel1.BackColor = $color2
		$textbox1.BackColor = $color2
		$checkboxGrip.BackColor = $color2
		
		if ($form1.controlbox)
		{
			$checkboxGrip.Checked = $true
		}
		else
		{
			$checkboxGrip.Checked = $false
		}
		
		$script:Container = Get-ChildItem -path $Containerpath
		foreach ($file in $Container)
		{
			$textbox1.AutoCompleteCustomSource.Add($file.name)
			Add-Button -file $file
		}
	}
	
	function Add-Button ($file)
	{
		$button = New-Object System.Windows.Forms.button
		if ($file.psiscontainer)
		{
			$button.Image = $explorerIcon
		}
		else
		{
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
	$form2_Load = {
		Load-Container
	}
	
	$form2_Shown = {
		#DONE: 
		$bounds = [system.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
		$size = 500
		$form2.Size = New-Object System.Drawing.Size($size, $size)
		$form2.Refresh()
		$center = ($form1.size.Width / 2) - ($form2.size.Width / 2)
		[int]$x = $form1.location.x + $center
		[int]$y = $form1.location.y + $center
		
		#adjust loaction x
		if ($x + $size -ge $bounds.Right)
		{
			$x = $bounds.Right - $size
		}
		elseif ($x -le $bounds.Left)
		{
			$x = $bounds.Left
		}
		#adjust loaction y
		if ($y + $size -ge $bounds.Bottom)
		{
			$y = $bounds.bottom - $size
		}
		elseif ($y -le $bounds.top)
		{
			$y = $bounds.top
		}
		
		$form2.Location = New-Object System.Drawing.point($x, $y)
		foreach ($Opacity in (1 .. 9))
		{
			$form2.Opacity = $Opacity /10
			Start-Sleep -Milliseconds 1
		}
		
		$timer1.Enabled = $true
		$flp.add_MouseWheel({
				$flp.AutoScroll = $true
				$flp.Refresh()
			})
	}
	
	$timer1_Tick = {
		if (-not $form2.ClientRectangle.Contains($form2.PointToClient([System.Windows.Forms.Cursor]::Position)))
		{
			$flp.Visible = $false
			foreach ($size in (10 .. 0))
			{
				$form2.Opacity = $size /10
				Start-Sleep -Milliseconds 1
			}
			$form2.Close()
		}
	}
	
	$tsmReturn_Click = {
		Move-Item -Path $contextmenustrip1.SourceControl.Tag.fullname -Destination "$env:USERPROFILE\Desktop\"
		Load-Container
	}
	
	$toolstripmenuitem2_Click = {
		Invoke-Item -Path $Containerpath
	}
	
	$toolstripmenuitem3_Click = {
		$shell = new-object -comobject "Shell.Application"
		($shell.Namespace(0).ParseName($contextmenustrip1.SourceControl.Tag.fullname)).InvokeVerb("delete")
		Load-Container
		$shell = $null
	}
	
	$checkboxGrip_CheckedChanged = {
		if ($checkboxGrip.checked)
		{
			$form1.controlbox = $true
			$form1.SizeGripStyle = 'Show'
		#	$checkboxGrip.Text = "↕"
		}
		else
		{
			$form1.controlbox = $false
			$form1.SizeGripStyle = 'hide'
		#	$checkboxGrip.Text = "↕"
		}
	}
	
	$form2_MouseLeave = {
		if (-not $args[0].ClientRectangle.Contains($args[0].PointToClient([System.Windows.Forms.Cursor]::Position)))
		{
			$form2.Close()
		}
	}
	
	
	$textbox1_KeyDown = [System.Windows.Forms.KeyEventHandler]{
		if ($_.KeyValue -eq 13)
		{
			$flp.Controls.Clear()
			foreach ($item in ($Container | Where-Object name -match $textbox1.Text))
			{
				Add-Button -file $item
			}
		}
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form2.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
		$script:OpedContainer_textbox1 = $textbox1.Text
		$script:OpedContainer_checkboxGrip = $checkboxGrip.Checked
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$textbox1.remove_KeyDown($textbox1_KeyDown)
			$checkboxGrip.remove_CheckedChanged($checkboxGrip_CheckedChanged)
			$form2.remove_Load($form2_Load)
			$form2.remove_Shown($form2_Shown)
			$form2.remove_MouseLeave($form2_MouseLeave)
			$timer1.remove_Tick($timer1_Tick)
			$tsmReturn.remove_Click($tsmReturn_Click)
			$toolstripmenuitem2.remove_Click($toolstripmenuitem2_Click)
			$toolstripmenuitem3.remove_Click($toolstripmenuitem3_Click)
			$form2.remove_Load($Form_StateCorrection_Load)
			$form2.remove_Closing($Form_StoreValues_Closing)
			$form2.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
		$form2.Dispose()
		$flp.Dispose()
		$panel1.Dispose()
		$textbox1.Dispose()
		$checkboxGrip.Dispose()
		$timer1.Dispose()
		$contextmenustrip1.Dispose()
		$tsmReturn.Dispose()
		$toolstripmenuitem2.Dispose()
		$toolstripmenuitem3.Dispose()
		$toolstripseparator1.Dispose()
		$imagelist.Dispose()
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$form2.SuspendLayout()
	$panel1.SuspendLayout()
	$contextmenustrip1.SuspendLayout()
	#
	# form2
	#
	$form2.Controls.Add($flp)
	$form2.Controls.Add($panel1)
	$form2.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$form2.AutoScaleMode = 'Font'
	$form2.BackColor = [System.Drawing.Color]::FromArgb(255, 70, 70, 70)
	$form2.BackgroundImageLayout = 'None'
	$form2.ClientSize = New-Object System.Drawing.Size(205, 182)
	$form2.ControlBox = $False
	$form2.MaximizeBox = $False
	$form2.MinimizeBox = $False
	$form2.Name = 'form2'
	$form2.Opacity = 0
	$form2.ShowIcon = $False
	$form2.ShowInTaskbar = $False
	$form2.SizeGripStyle = 'Hide'
	$form2.StartPosition = 'CenterParent'
	$form2.TopMost = $True
	$form2.add_Load($form2_Load)
	$form2.add_Shown($form2_Shown)
	$form2.add_MouseLeave($form2_MouseLeave)
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
	[void]$contextmenustrip1.Items.Add($toolstripmenuitem2)
	[void]$contextmenustrip1.Items.Add($toolstripmenuitem3)
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
	# toolstripmenuitem2
	#
	$toolstripmenuitem2.ForeColor = [System.Drawing.SystemColors]::Control 
	$toolstripmenuitem2.Name = 'toolstripmenuitem2'
	$toolstripmenuitem2.ShortcutKeyDisplayString = ''
	$toolstripmenuitem2.Size = New-Object System.Drawing.Size(167, 22)
	$toolstripmenuitem2.Text = 'Open Container folder'
	$toolstripmenuitem2.add_Click($toolstripmenuitem2_Click)
	#
	# toolstripmenuitem3
	#
	$toolstripmenuitem3.ForeColor = [System.Drawing.SystemColors]::Control 
	$toolstripmenuitem3.Name = 'toolstripmenuitem3'
	$toolstripmenuitem3.Size = New-Object System.Drawing.Size(167, 22)
	$toolstripmenuitem3.Text = 'Deleat Item'
	$toolstripmenuitem3.add_Click($toolstripmenuitem3_Click)
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
	$form2.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form2.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form2.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form2.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$form2.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $form2.ShowDialog()

}
#endregion Source: OpedContainer.psf

#region Source: Settup.psf
function Show-Settup_psf
{

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}
	
	$Form_StoreValues_Closing=
	{
		#Store the control values
	}

	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$form1.remove_Load($form1_Load)
			$form1.remove_Load($Form_StateCorrection_Load)
			$form1.remove_Closing($Form_StoreValues_Closing)
			$form1.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
		$form1.Dispose()
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	#
	# form1
	#
	$form1.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$form1.AutoScaleMode = 'Font'
	$form1.BackColor = [System.Drawing.Color]::FromArgb(255, 50, 50, 50)
	$form1.ClientSize = New-Object System.Drawing.Size(470, 265)
	$form1.Name = 'form1'
	$form1.Text = 'Form'
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Store the control values when form is closing
	$form1.add_Closing($Form_StoreValues_Closing)
	#Show the Form
	return $form1.ShowDialog()

}
#endregion Source: Settup.psf

#Start the application
Main ($CommandLine)
