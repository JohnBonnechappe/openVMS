! This procedure creates a table in the declared database file.
! Be sure to change the filename and the table name and the fieldnames to
! suit the application.
!
DECLARE SCHEMA AUTHORIZATION FOR FILENAME JBRDBTST
               ;

CREATE TABLE   PLANT_DETAILS
               ( PLANT_NAME         CHAR(25)
               , HEIGHT_IN_METRES   SMALLINT
               , SPREAD_IN_METRES   SMALLINT
               , EVERGREEN          CHAR(1)
               , FLOWER_COLOUR      SMALLINT
               , AGE_TO_MATURITY    SMALLINT
               , ASPECT             CHAR(25)
               , SOIL               CHAR(1)
               , COMMENTS           CHAR(80)
               , REC_TMSTAMP        DATE
               )
               ;
