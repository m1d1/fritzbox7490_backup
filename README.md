# fritzbox7490_backup v0.4

Bash script for creating backups remotely from a Fritz!Box 7490 (maybe 7590).
Backup phonebook/s, configuration and phone assets.
For restore use the FRITZ! webinterface.

-------------------------------------------
**Version history**:
- v0.4: fixes for Fritz!Os 7.27
	Added export_phoneassets. Exports custom ringtones and voicebox.
	Login Username must be set now. Export password should be set.
	Dropped lib_7390.sh.
- v0.3: fixes for Fritz!OS 7.21 
- v0.2: fixes for Fritz!OS 6.80:
	In case settings backup is empty:
	Uncheck "additional confirmations" 
	checkbox from
	http://fritz.box/?lp=userSet
	to make settings backup work again.
(For troubleshooting make a manual backup from the webinterface to get security prompts)
