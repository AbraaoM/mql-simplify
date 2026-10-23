//+------------------------------------------------------------------+
//|                                              TestReviewFixes.mq5 |
//|  Runtime tests (script, no account needed) for the code-review    |
//|  fixes. Writes MQL5\\Files\\mqlsimplify_review_results.txt.        |
//+------------------------------------------------------------------+
#include "../TimeManipulation.mqh"
#include "../Operations.mqh"
#include "../Limitations.mqh"
#include "../InputCheck.mqh"

int passed = 0, failed = 0, fileHandle = INVALID_HANDLE;

void Out(string s) {
  Print(s);
  if(fileHandle != INVALID_HANDLE)
    FileWriteString(fileHandle, s + "\r\n");
}
void Check(string name, bool ok, string detail = "") {
  if(ok) passed++;
  else { failed++; Out("FAIL " + name + " " + detail); }
}

void OnStart() {
  fileHandle = FileOpen("mqlsimplify_review_results.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
  CTimeManipulation tm;
  //--- same results as before for well-formed strings
  Check("hhmmss", tm.StringTimeToInt("01:02:03", HHMMSS) == 3723);
  Check("hhmm", tm.StringTimeToInt("12:30", HHMM) == 45000);
  Check("mmss", tm.StringTimeToInt("02:05", MMSS) == 125);
  Check("ss", tm.StringTimeToInt("42", SS) == 42);
  //--- malformed: 0 instead of stopping the script
  Check("hhmm_short", tm.StringTimeToInt("12", HHMM) == 0);
  Check("hhmmss_short", tm.StringTimeToInt("01:02", HHMMSS) == 0);
  Check("empty", tm.StringTimeToInt("", HH) == 0);

  COperations op;
  Check("past_ticket_out_of_range", op.PastOperationTicket(100000) == 0);
  Check("past_ticket_zero", op.PastOperationTicket(0) == 0);

  CLimitations lim;
  CLocalStorage *none = NULL;
  Check("accum_null_storage", !lim.OperationalTimeAccumReached("00:01", none));

  Out(StringFormat("RESULT %s: %d passed, %d failed", failed == 0 ? "PASS" : "FAIL", passed, failed));
  if(fileHandle != INVALID_HANDLE)
    FileClose(fileHandle);
}
