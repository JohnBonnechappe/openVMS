IDENTIFICATION DIVISION.
*
*******************************************************************************
*                                                                             *
*   Program ID   : EZITRAK0052                                                *
*   Program Name : Person Details Table                                       *
*   Summary      : On startup the search parameters screen is displayed. When *
*                  parameters are entered, the program searches the           *
*                  PROBLEM_DETAILS table in the EZITRAK database and          *
*                  displays the problem browse screen with the found problem  *
*                  details.                                                   *
*                                                                             *
*   SCREENS USED : EZITRAK051                                                 *
*                : EZITRAK052                                                 *
*                                                                             *
*   TABLES  USED : PERSON_DETAILS       (Input-Output                         *
*                                                                             *
*******************************************************************************
*
/
PROGRAM-ID. EZITRAK0052.
ENVIRONMENT DIVISION.
* DATE-WRITTEN. 16-02-92
* AUTHOR. JOHN
CONFIGURATION SECTION.
    SOURCE-COMPUTER. VAX-8650.
    OBJECT-COMPUTER. VAX-8650.
/
DATA DIVISION.
/
WORKING-STORAGE SECTION.
    copy "EZITRAK_CDD.EZITRAK051_REC"  from dictionary
          replacing EZITRAK051_REC BY OLD-EZITRAK051-REC.

    copy "EZITRAK_CDD.PERSON_DETAILS_REC"       from dictionary.
/
 01  TMP-FLAG                                    PIC X.
 01  STAGE-OF-PROCESSING                         PIC 99.
 01  PERSON-FOUND-FLAG                           PIC X.

 01  SQLCA.
     03  SQLCAID                                 PIC X(8) VALUE "SQLCA   ".
     03  SQLCABC                                 PIC S9(9) COMP  VALUE 128.
     03  SQLCODE                                 PIC S9(9) COMP.
         88  SQL_SUCCESS                         VALUE 0.
         88  SQL_NOT_FOUND                       VALUE 100.
         88  SQL_DUPLICATE_IDX                   VALUE -803.
         88  SQL_LOCKED_RECORD                   VALUE -1003.
     03  SQLERRML                                PIC S9(4) COMP VALUE 0.
     03  SQLERRMC                                PIC X(70).
     03  SQLERRD                                 PIC S9(9) COMP OCCURS 6.
     03  SQLWARN                                 PIC X(8).
     03  SQLEXT                                  PIC X(8).

 01 Rdb$MESSAGE_VECTOR EXTERNAL GLOBAL.
     03 Rdb$LU_NUM_ARGUMENTS                     PIC S9(9) COMP.
     03 Rdb$LU_STATUS                            PIC S9(9) COMP.
     03 Rdb$ALU_ARGUMENTS                        OCCURS 18.
         05 Rdb$LU_ARGUMENTS                     PIC S9(9) COMP.

 01  ERR_RET                                     PIC S9(9) COMP.
 01  ERR_SUB                                     PIC  9(9) COMP.
 01  ERR_FLAGS                                   PIC  9(9) COMP.
 01  ERR_LENGTH                                  PIC  9(9) COMP.
 01  ERR_BUFFER                                  PIC  X(80).
 01  SS$_NORMAL                                  PIC S9(9) COMP
     VALUE IS EXTERNAL SS$_NORMAL.

 01  JPI_USERNAME                                PIC S9(9) COMP VALUE 514.

 01  CURRENT_USER_ID                             PIC X(8).
 01  CURRENT_DATE_BIN                            PIC S9(11)V9(7) COMP.
 01  SAVED_PROBLEM_TMSTAMP                       PIC S9(11)V9(7) COMP.
 01  TRANSACTION_BEGUN_FLAG                      PIC X.

 01  EXIT_STATUS                                 PIC S9(9) COMP.

 01  SUB1                                        PIC S9(4) COMP.
 01  SUB1_MAX                                    PIC S9(4) COMP VALUE 20.
*
* ************ TEMP ITEM -- REMOVE AFTER PROG IS OK ***************
 01  TEMP-COUNTER                                PIC S9(9) COMP.


/
LINKAGE SECTION.
    copy "EZITRAK_CDD.EZITRAK051_REC"  from dictionary.
    copy "EZITRAK_CDD.EZITRAK052_REC"  from dictionary.

PROCEDURE DIVISION USING EZITRAK051_REC , EZITRAK052_REC
                   GIVING EXIT_STATUS.
MAIN-PARA.
    PERFORM 1000-INITIALISATION.

    PERFORM 5000_GET_PERSON_RECORDS.

*    PERFORM 8000-FINALISATION.

    GO TO 9900-EXIT.
*
1000-INITIALISATION.
    MOVE ZERO    TO SQLCODE.
    MOVE ZERO    TO EXIT_STATUS.
    MOVE "N"     TO TRANSACTION_BEGUN_FLAG.   
/
5000-GET-PERSON_RECORDS.
    INITIALIZE             EZITRAK052-REC.

    PERFORM 7000_START_TRAN_RO.

    MOVE PERSON_ID OF EZITRAK051-REC
      TO PERSON_ID OF PERSON_DETAILS_REC.

    CALL "ET_OC_PERSON_DETAILS" USING SQLCA
                                  PERSON_ID OF PERSON_DETAILS_REC.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF PERSON_OC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON OC" TO ERROR_MESSAGE OF EZITRAK051_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 3150_FETCH VARYING SUB1 FROM 1 BY 1
                               UNTIL NOT SQL_SUCCESS
                               OR SUB1 > SUB1_MAX.

    CALL "ET_CC_PERSON_DETAILS" USING SQLCA.
                  
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF CC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR ON CC" TO ERROR_MESSAGE OF EZITRAK051_REC
        GO TO 9900_EXIT
    END-EVALUATE.

    PERFORM 7800_CMT_TRAN.
*
3150_FETCH.
    CALL "ET_FC_PERSON_DETAILS" USING SQLCA
                                 PERSON_ID       OF PERSON_DETAILS_REC
                                 PERSON_DESC     OF PERSON_DETAILS_REC
                                 PERSON_PHONE    OF PERSON_DETAILS_REC
                                 REC_USER        OF PERSON_DETAILS_REC
                                 REC_TMSTAMP     OF PERSON_DETAILS_REC
    END-CALL.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TMP_FLAG
        PERFORM 7700_SETUP_REC
    WHEN SQL_NOT_FOUND
        CONTINUE
    WHEN OTHER
        DISPLAY "ERROR OF FC CODE=" SQLCODE WITH CONVERSION
        MOVE "ERROR FC" TO ERROR_MESSAGE OF EZITRAK051_REC
        GO TO 9900_EXIT
    END-EVALUATE.
/
7000-START_TRAN_RO.
    CALL "ET_ST_RO_PERSON" USING SQLCA.

    EVALUATE TRUE
    WHEN SQL_SUCCESS
        MOVE "Y" TO TRANSACTION_BEGUN_FLAG
    WHEN OTHER
        DISPLAY "ST_RO NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.

7700_SETUP_REC.
        MOVE PERSON_ID           OF PERSON_DETAILS_REC
          TO PERSON_ID           OF EZITRAK052_REC (SUB1).
        MOVE PERSON_DESC         OF PERSON_DETAILS_REC
          TO PERSON_DESC         OF EZITRAK052_REC (SUB1).
        MOVE PERSON_PHONE        OF PERSON_DETAILS_REC
          TO PERSON_PHONE        OF EZITRAK052_REC (SUB1).
/
7800-CMT_TRAN.
    CALL "ET_CMT_TRN" USING SQLCA.

    MOVE "N" TO TRANSACTION_BEGUN_FLAG.
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "CMT_TRN NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
/
7900-RLB_TRAN.
    CALL "ET_RLB_TRN" USING SQLCA.

    MOVE "N" TO TRANSACTION_BEGUN_FLAG.
    EVALUATE TRUE
    WHEN SQL_SUCCESS
        CONTINUE
    WHEN OTHER
        DISPLAY "RLB_TRN NG CODE=" SQLCODE WITH CONVERSION
        GO TO   9900-EXIT
    END-EVALUATE.
*
8600-GET-TIME.
    CALL "SYS$GETTIM" USING BY REFERENCE CURRENT_DATE_BIN.
*
8700-GET-USER.
    CALL "LIB$GETJPI" USING BY REFERENCE JPI_USERNAME
                             OMITTED
                             OMITTED
                             OMITTED
                             BY DESCRIPTOR CURRENT_USER_ID.
*
9900-EXIT.
    IF NOT SQL_SUCCESS
        MOVE 15 TO ERR_FLAGS
        PERFORM 9910_ERROR VARYING ERR_SUB FROM 1 BY 1
                           UNTIL ERR_SUB > Rdb$LU_NUM_ARGUMENTS.

    IF TRANSACTION_BEGUN_FLAG = "Y"
        PERFORM 7900_RLB_TRAN.

    EXIT PROGRAM.

9910_ERROR.
        call "sys$getmsg" using
                                 by value      Rdb$LU_ARGUMENTS(ERR_SUB)
                                 by reference  err_length
                                 by descriptor err_buffer
                                 by value      err_flags
                                 omitted
                          GIVING               ERR_RET.

         DISPLAY ERR_BUFFER.
*
* **************** END OF SOURCE EZITRAK001 ****************
