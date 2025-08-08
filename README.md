# Runic Keyboard Layout for Linux

Here's a preview:
<img width="1793" height="563" alt="preview" src="https://github.com/user-attachments/assets/4c545e31-8e3e-44ac-a38f-2c7f7ab73970" />


## Automatic installation: 
- Download the install script
  ```bash
  wget https://raw.githubusercontent.com/itsHanibee/runic/refs/heads/main/install.sh
  ```
- Set it as executable
  ```bash
  chmod +x install.sh
  ```
- Run it as sudo
  ```bash
  sudo ./install.sh
  ```
  
## Manual install instructions (Advanced):
1. The runic layout file goes in `/usr/share/X11/xkb/symbols/`
- It's a write protected folder by default
 
2. Now we have to update the Layout list at `/etc/xkb/rules/evdev.xml`
- First make a template
```bash
    sudo cp /usr/share/X11/xkb/rules/evdev.xml /etc/xkb/rules/evdev.xml
```
- Find the `<layoutList>` section of the file and go down to the last entry in the nest. It should be the user-defined custom layout section. We will create a new one for ours right above so we are the second-to-last in the list. It should look like so.
<img width="1054" height="996" alt="example" src="https://github.com/user-attachments/assets/bec75a3b-c1cb-4086-93ef-d313479adcbd" />

Pasting the entry here so you'll have an easier time copying it.
```
    <layout>
      <configItem>
        <name>runic</name>
        <shortDescription>Runic</shortDescription>
        <description>Custom Runic Keyboard Layout</description>
        <languageList>
          <iso639Id>run</iso639Id>
        </languageList>
      </configItem>
      <variantList/>
    </layout>
```
> Once that's done you should be good to go!

#### Be sure to restart your system once and on KDE Plasma you can go to `Keyboard > Layouts` to add the new layout
<img width="1117" height="817" alt="howto" src="https://github.com/user-attachments/assets/84012078-c7ba-4604-8781-42441ecdd3f2" />

