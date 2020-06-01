# oracle-error-handler

Generic Error Handler for Oracle

```sql
error_handler.log_db_error(i_err_function   VARCHAR2 -- the function name
                          ,i_err_message    VARCHAR2 -- user defined message DEFAULT ORA-message
                          ,i_abort          BOOLEAN  -- abort application DEFAULT false  
                          );
```

## examples

```sql
-- basic call, the code will handle the rest
begin
  dbms_output.put_line(1/0);
exception
  when others then
    error_handler.log_db_error('mytestfunc');
    dbms_output.put_line('Log error with system message.');
end;
/
```

```sql
-- user defined message
begin
  dbms_output.put_line(1/0);
exception
  when others then
    error_handler.log_db_error('mytestfunc','Ooops, something went wrong');
    dbms_output.put_line('Log error with user message.');
end;
/
```

```sql
-- user defined message and abort the code
begin
  dbms_output.put_line(1/0);
exception
  when others then
    error_handler.log_db_error('mytestfunc','Wow this is bad, need to terminate',true);
    dbms_output.put_line('Will not get here.');
end;
/
```
