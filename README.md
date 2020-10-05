# fritzbox7490_backup v0.3

Bash script for creating backups remotely from a Fritz!Box 7490 (7390).
Backup phonebook/s and configuration.
Restore using the FRITZ! webinterface.

-------------------------------------------
**Version history**:
- v0.3: fixes for Fritz!OS 7.21 
- v0.2: fixes for Fritz!OS 6.80:
	In case settings backup is empty:
	Uncheck "additional confirmations" 
	checkbox from
	http://fritz.box/?lp=userSet
	to make settings backup work again.
(For troubleshooting make a manual backup from the webinterface to get security prompts)
