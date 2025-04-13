! This procedure creates a unique index on a table in the declared database
! file.
! Be sure to change the filename and the table name and the indexname to
! suit the application.
!
DECLARE SCHEMA AUTHORIZATION FOR FILENAME JBRDBTST
               ;

ALTER TABLE PLANT_DETAILS
      ADD CONSTRAINT
      CHECK
      (
       SOIL_CODE IN  ( SELECT CODE_ID FROM CODE_DESCRIPTIONS )
      )
      DIAGNOSTIC  SOIL_CODE
               ;
