@rem ****************************************************
@rem * (c) Laurent PERRET
@rem *  sysadmsy6@gmail.com - Version pour windows
@rem ****************************************************
@rem * Hotbackup Oracle
@rem * C'est une migration pour windows d'un hotbackup oracle 
@rem * réalisé sur un SUN 450 Solaris vers un DDS Distant
@rem ****************************************************
@rem * Right Reserved for Bruno Cirousele - Multilink
@rem * la société Millennium Informatix Groupe 	sarl
@rem ****************************************************
@echo off
setlocal
set ORACLE_SID=MEP
set O_CONNECT=internal/Oracle@%ORACLE_SID%
set O_INIT=C:\extraNETv1\bin\oracle\orant\DATABASE\Initorcl.ora
set O_SVRMGR=C:\extraNETv1\bin\oracle\orant\bin\Svrmgr23.exe
set O_EXPORT=C:\extraNETv1\bin\oracle\orant\bin\exp73.exe
set O_PLUS=C:\extraNETv1\bin\oracle\orant\bin\Plus33w.exe
set O_COPY=C:\extraNETv1\bin\oracle\orant\bin\Ocopy73.exe
set O_BACKPATH=Z:\oracle\ORABACK\hot
set O_BACKSVGR=SAV
set O_BACKDELE=Z:\oracle\ORABACK\SAV
set O_LOG_PATH=Z:\oracle\LOGFILES
echo Debut du HOT Backup
date/T
echo Traitement en cours...
echo  >%O_LOG_PATH%\hotback.log

rem echo déplace les fichiers du précédent backup>>%O_LOG_PATH%\hotback.log
rem RENAME %O_BACKPATH% %O_BACKSVGR% >>%O_LOG_PATH%\hotback.log
rem MKDIR %O_BACKPATH% >>%O_LOG_PATH%\hotback.log

echo Efface les fichiers du précédent backup >>%O_LOG_PATH%\hotback.log
DEL %O_BACKPATH%\*.*/Q >>%O_LOG_PATH%\hotback.log
RD %O_BACKPATH%>>%O_LOG_PATH%\hotback.log
echo Creation du répertoire \HOT>>%O_LOG_PATH%\hotback.log
MKDIR %O_BACKPATH% >>%O_LOG_PATH%\hotback.log
echo -------------------------------------------------------->>%O_LOG_PATH%\hotback.log
echo Heure de Debut:>>%O_LOG_PATH%\hotback.log
date/T >>%O_LOG_PATH%\hotback.log
time/T >>%O_LOG_PATH%\hotback.log
echo -------------------------------------------------------->>%O_LOG_PATH%\hotback.log
echo Copie du fichier OraINI>>%O_LOG_PATH%\hotback.log
copy %O_INIT% %O_BACKPATH%>>%O_LOG_PATH%\hotback.log
echo Creation des scripts pour le HOT Backup : >>%O_LOG_PATH%\hotback.log
echo set heading off; >%O_BACKPATH%\plus1.sql
echo set feedback off; >>%O_BACKPATH%\plus1.sql
echo spool %O_BACKPATH%\backup1.cmd; >>%O_BACKPATH%\plus1.sql
echo select 'set vminlog='^|^|min(sequence#) from v$log where UPPER(status) = UPPER('INACTIVE'); >>%O_BACKPATH%\plus1.sql
echo spool off; >>%O_BACKPATH%\plus1.sql
echo spool %O_BACKPATH%\svrmgr1.sql; >>%O_BACKPATH%\plus1.sql
echo select 'connect %O_CONNECT% as sysdba;' from dual; >>%O_BACKPATH%\plus1.sql
echo select 'alter tablespace '^|^|tablespace_name^|^|' begin backup;'^|^|' >>%O_BACKPATH%\plus1.sql
echo '^|^|'host start /wait %O_COPY% '^|^|file_name^|^|' %O_BACKPATH%;'^|^|' >>%O_BACKPATH%\plus1.sql
echo '^|^|'alter tablespace '^|^|tablespace_name^|^|' end backup;' from dba_data_files; >>%O_BACKPATH%\plus1.sql
echo select 'alter system switch logfile;' from dual; >>%O_BACKPATH%\plus1.sql
echo select 'exit;' from dual; >>%O_BACKPATH%\plus1.sql
echo exit; >>%O_BACKPATH%\plus1.sql
%O_PLUS% %O_CONNECT% @%O_BACKPATH%\plus1.sql>>%O_LOG_PATH%\hotback.log
call %O_BACKPATH%\backup1.cmd>>%O_LOG_PATH%\hotback.log
%O_SVRMGR% @%O_BACKPATH%\svrmgr1.sql>>%O_LOG_PATH%\hotback.log
echo set heading off; >%O_BACKPATH%\plus2.sql
echo set feedback off; >>%O_BACKPATH%\plus2.sql
echo spool %O_BACKPATH%\backup2.cmd; >>%O_BACKPATH%\plus2.sql
echo select 'set vmaxlog='^|^|max(sequence#) from v$log where UPPER(status) = UPPER('CURRENT'); >>%O_BACKPATH%\plus2.sql
echo spool off; >>%O_BACKPATH%\plus2.sql
echo spool %O_BACKPATH%\svrmgr2.sql; >>%O_BACKPATH%\plus2.sql
echo select 'connect %O_CONNECT% as sysdba;' from dual; >>%O_BACKPATH%\plus2.sql
echo select 'alter database backup controlfile to '''^|^|'%O_BACKPATH%\'^|^|substr(name,instr(name,'\',-1)+1)^|^|''' REUSE;' from v$controlfile; >>%O_BACKPATH%\plus2.sql
echo select 'alter database backup controlfile to trace' from dual; >>%O_BACKPATH%\plus2.sql
echo spool off; >>%O_BACKPATH%\plus2.sql
echo exit; >>%O_BACKPATH%\plus2.sql
%O_PLUS% %O_CONNECT% @%O_BACKPATH%\plus2.sql>>%O_LOG_PATH%\hotback.log
call %O_BACKPATH%\backup2.cmd>>%O_LOG_PATH%\hotback.log
%O_SVRMGR% @%O_BACKPATH%\svrmgr2.sql>>%O_LOG_PATH%\hotback.log
echo set heading off; >%O_BACKPATH%\plus3.sql
echo set feedback off; >>%O_BACKPATH%\plus3.sql
echo spool %O_BACKPATH%\backup3.cmd; >>%O_BACKPATH%\plus3.sql
echo select 'copy '^|^|archive_name^|^|' %O_BACKPATH%' from v$log_history where sequence# between %vminlog% and %vmaxlog% +1; >>%O_BACKPATH%\plus3.sql
echo select 'select v1.file#, v1.status,name, bytes/1024/1024 from v$backup v1, v$datafile v2 where v1.file#=v2.file#;' from dual; >>%O_BACKPATH%\plus3.sql
echo spool off; >>%O_BACKPATH%\plus3.sql
echo exit; >>%O_BACKPATH%\plus3.sql
%O_PLUS% %O_CONNECT% @%O_BACKPATH%\plus3.sql>>%O_LOG_PATH%\hotback.log
call %O_BACKPATH%\backup3.cmd>>%O_LOG_PATH%\hotback.log
rem echo Efface les fichiers du précédent backup déplacé>>%O_LOG_PATH%\hotback.log
rem DEL %O_BACKDELE%\*.*/Q >>%O_LOG_PATH%\hotback.log
rem RD %O_BACKDELE%>>%O_LOG_PATH%\hotback.log
echo Heure de Fin du backup:>>%O_LOG_PATH%\hotback.log
date/T >>%O_LOG_PATH%\hotback.log
time/T >>%O_LOG_PATH%\hotback.log
echo -------------------------------------------------------->>%O_LOG_PATH%\hotback.log
