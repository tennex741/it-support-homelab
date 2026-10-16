# Runbook: New Device Deployment (Windows PC)

**Owner:** IT Support Officer
**Time:** about 60 minutes including updates

## 1. Receive and record

- [ ] Create the asset in GLPI: **Assets > Computers > Add**
  - Inventory number: next `MMG-PC-###` or `MMG-LT-###`
  - Status: **In stock**
  - Location: Server Room
  - Supplier, purchase date, warranty duration (**Management** tab)
- [ ] Put the asset tag sticker on the device

## 2. Build

- [ ] Connect to the **STAFF** network
- [ ] Complete Windows setup with the local emergency account (password stored in the password manager, not on the device)
- [ ] Confirm network: `ipconfig /all` shows a 10.10.20.x address, gateway 10.10.20.1, DNS 10.10.10.10
- [ ] Run Windows Update until no updates remain

## 3. Join the domain

In an elevated terminal:

```powershell
Add-Computer -DomainName "ad.moonlab.internal" -NewName "<WSxx>" -Credential "MOONLAB\adm.<you>" -Restart
```

- [ ] The computer appears in **MoonMotorGroup > Computers > Workstations** in ADUC (new joins are redirected there automatically)
- [ ] The **Moon Motor Group – Authorised Use Only** banner appears at the login screen (Workstation Security GPO applied)

## 4. Install the inventory agent

- [ ] Install GLPI Agent (x64 MSI) with server `http://helpdesk01.ad.moonlab.internal/`
- [ ] Set credentials in `HKLM:\SOFTWARE\GLPI-Agent` (`user`, `password`) and restart the `glpi-agent` service
- [ ] Force a first run from an **elevated** terminal:

```powershell
& "C:\Program Files\GLPI-Agent\glpi-agent.bat" --force
```

- [ ] The device appears in GLPI with hardware and software populated

Note: running the agent from a non-elevated terminal fails with *Permission denied* on the log file, even when logged in as an admin account (UAC).

## 5. Test as the user

- [ ] Sign in as the assigned user
- [ ] Drives correct for their department
- [ ] Printer present (Service and Parts)
- [ ] `gpresult /r` lists the MMG policies
- [ ] USB storage is blocked (expected)

## 6. Hand over

- [ ] GLPI asset: **User** set, **Location** set, **Status: In use**
- [ ] Link the asset to the onboarding ticket
