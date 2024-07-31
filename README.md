# DesktopQuickExplorer
A PowerShell script that creates a desktop form displaying files and folders at a specified path. Hover over the form to expand and explore contents.
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
-name '$name' -ContainerPath $Containerpath -StartLocation $X,$Y -UseIconFromFile UseIconFromFile -Theme Lightmode/Darkmode
```

### Downlade
Clone the repository or download the script
Run the script in PowerShell, providing the desired path as a parameter (e.g., .\DesktopQuickExplorer.ps1 -Path "C:\Users\Username\Documents")
The script will create a desktop form displaying the contents of the specified directory

### Invoke over web
```


```

### Requirements
PowerShell 3 or later
Windows 7 or later
