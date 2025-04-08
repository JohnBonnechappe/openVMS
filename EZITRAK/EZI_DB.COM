$! This procedure creates the EZITRAK schema. It then sets up the required
$! tables.
$!
$SQL
SET VERIFY;
CREATE SCHEMA FILENAME      EZITRAK
               ;

CREATE TABLE   PROBLEM_DETAILS
               ( PROBLEM_NUMBER       SMALLINT
               , PROBLEM_STATUS       CHAR(1)
               , PRIORITY             CHAR(1)
               , APPLICATION_ID       CHAR(3)
               , PROBLEM_DESC         CHAR(75)
               , RECORDING_PERSON_ID  CHAR(4)
               , CONTACT_DATE         DATE
               , CONTACT_PERSON_ID    CHAR(4)
               , CONTACT_DEVICE       CHAR(1)
               , PERSON_ASSIGNED_ID   CHAR(4)
               , PERSON_REDIRECTED_ID CHAR(4)
               , EST_TO_COMPLETE_DAYS SMALLINT
               , PROGRESS_DESC        CHAR(75)
               , SOLVED_DATE          DATE
               , SOLUTION_DESC        CHAR(75)
               , REF_PROBLEM_NUMBER   SMALLINT
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;

CREATE TABLE   PERSON_DETAILS
               ( PERSON_ID            CHAR(4)
               , PERSON_DESC          CHAR(25)
               , PERSON_PHONE         CHAR(12)
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;

CREATE TABLE   PRIORITY_DETAILS
               ( PRIORITY_ID          CHAR(1)
               , PRIORITY_DESC        CHAR(25)
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;
CREATE TABLE   APPLICATION_DETAILS
               ( APPLICATION_ID       CHAR(3)
               , APPLICATION_DESC     CHAR(25)
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;

CREATE TABLE   STATUS_DETAILS
               ( STATUS_ID            CHAR(1)
               , STATUS_DESC          CHAR(25)
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;

CREATE TABLE   NEXT_PROBLEM_NUMBER
               ( NEXT_PROBLEM_KEY     CHAR(1)
               , PROBLEM_NUMBER       SMALLINT
               , REC_USER             CHAR(8)
               , REC_TMSTAMP          DATE
               )
               ;

CREATE UNIQUE INDEX PROBLEM_DETAILS_I1
       ON           PROBLEM_DETAILS
               (
                 PROBLEM_NUMBER
               )
               ;

CREATE        INDEX PROBLEM_DETAILS_I2
       ON           PROBLEM_DETAILS
               (
                 PROBLEM_STATUS
               )
               ;

CREATE        INDEX PROBLEM_DETAILS_I3
       ON           PROBLEM_DETAILS
               (
                 PRIORITY
               )
               ;

CREATE        INDEX PROBLEM_DETAILS_I4
       ON           PROBLEM_DETAILS
               (
                 APPLICATION_ID
               )
               ;

CREATE        INDEX PROBLEM_DETAILS_I5
       ON           PROBLEM_DETAILS
               (
                 CONTACT_DATE
               )
               ;

CREATE        INDEX PROBLEM_DETAILS_I6
       ON           PROBLEM_DETAILS
               (
                 PERSON_ASSIGNED_ID
               )
               ;

CREATE UNIQUE INDEX PERSON_DETAILS_I1
       ON           PERSON_DETAILS
               (
                 PERSON_ID
               )
               ;

CREATE UNIQUE INDEX PRIORITY_DETAILS_I1
       ON           PRIORITY_DETAILS
               (
                 PRIORITY_ID
               )
               ;

CREATE UNIQUE INDEX APPLICATION_DETAILS_I1
       ON           APPLICATION_DETAILS
               (
                 APPLICATION_ID
               )
               ;

CREATE UNIQUE INDEX STATUS_DETAILS_I1
       ON           STATUS_DETAILS
               (
                 STATUS_ID
               )
               ;

CREATE UNIQUE INDEX NEXT_PROBLEM_NUMBER_I1
       ON           NEXT_PROBLEM_NUMBER
               (
                 NEXT_PROBLEM_KEY
               )
               ;

