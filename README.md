
# Rolling SNMPv3 Credentials


## Basic steps to add snmp V3 user

These are the steps you would do manually:

<pre>
sudo systemctl stop snmpd

sudo vi /var/lib/net-snmp/snmpd.conf
# ALWAYS add to bottom, will be removed when snmpd re-started
# createUser "username" MD5 "password" DES "passphrase" 

sudo vi /etc/snmp/snmpd.conf 
# REPLACE or add to bottom (once)
# rwuser "username"

sudo systemctl start snmpd
</pre>


## Ansible

The following sections describe how to setup remote server ssh, and then how
to execute ansible.

## Copy ssh id first

For all servers, do something like:

<pre>
ssh-copy-id sysadmin@192.168.121.101
</pre>

## Update Inventory

Edit inventory file and add any additional addresses.

## Execute ansible-playbook with parameters

Use command line like the following:

<pre>
ansible-playbook -i inventory -u sysadmin add_snmpv3.yml -e user=snmpUser -e auth=MD5 -e password=mypassword -e priv=AES -e passphrase=mypassword
</pre>

<b>WARNING:</b> Inspect the .yml file and verify that 'prefix' is set to empty.


## Switch over global SNMPv3 Settings
TBD

## 'Test Credentials' and polling
TBD

## Remove old SNMPv3 user

TBD : create snmpv3.yml to remove lines
<pre>
service stop snmpd
$EDITOR  /var/lib/net-snmp/snmpd.conf
[find and remove line starting with "username"]
$EDITOR  /etc/snmp/snmpd.conf
[find and remove *rouser* and *rwuser* info for "username"]
service start snmpd
</pre>
