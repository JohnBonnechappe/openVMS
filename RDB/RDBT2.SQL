! This procedure creates a table in the declared database file.
! Be sure to change the filename and the table name and the fieldnames to
! suit the application.
!
DECLARE SCHEMA AUTHORIZATION FOR FILENAME JBRDBTST
               ;

CREATE TABLE   CODE_DESCRIPTIONS
               ( CODE_ID            CHAR(2)
               , CODE_DESCRIPTION   CHAR(40)
               , REC_TMSTAMP        DATE
               )
               ;
