# DesktopQuickExplorer

A PowerShell script that creates a desktop form displaying files and folders at a specified path.

![closed container](https://github.com/user-attachments/assets/47428615-fcec-4fc4-bbc7-f701d542f894)

Hover over the form to expand and explore the Childitems for the Provided ContainerPath.

![openconatiener](https://github.com/user-attachments/assets/27db9468-9911-4f67-a857-decb66ab323b)

## About

DesktopQuickExplorer is a lightweight PowerShell script that provides quick access to files and folders on your desktop.

Simply provide a path as a parameter, and the script will create a compact form displaying the contents of that directory.

Hover over the form to expand it and explore the files and folders within.

## Features
- Creates a desktop form displaying files and folders at a specified path
- Hover-over expansion to view contents
- Quick access to files and folders
- does not overlay other programs by default
- Customizable path parameter
- Lightmode/Darkmode parameter
- Customizable icon parameter
- Customizable name parameter

## Usage

### parameter
```
-name "Title for Container"
-ContainerPath "c:\Folder\To\Display"
-StartLocation $X,$Y
-UseIconFromFile "c:\Path\To\Icon.ico"
-Theme "Lightmode"/"Darkmode"/"Black&Purple"
-Controlbox $true/$false
```


Clone the repository or download the script

Run the script in PowerShell, providing the desired path as a parameter 

The script will create a desktop form displaying the contents of the specified directory


### Example
```
.\DesktopQuickExplorer.ps1 -name "My Container" -ContainerPath "c:\"
```

### Requirements
PowerShell 3 or later
