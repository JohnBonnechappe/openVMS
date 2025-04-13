! This procedure creates a unique index on a table in the declared database
! file.
! Be sure to change the filename and the table name and the indexname to
! suit the application.
!
DECLARE SCHEMA AUTHORIZATION FOR FILENAME JBRDBTST
               ;

CREATE UNIQUE INDEX CODE_INDEX
       ON           CODE_DESCRIPTIONS
               (
                 CODE_ID
               )
               ;
