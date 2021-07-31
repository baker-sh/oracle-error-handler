/*
 cleanup table if it exists
*/
begin
  execute immediate 'drop table db_error_log';
exception
  when others then if sqlcode <> -942 then
    raise;
  end if;
end;
/

/*
 create the db_error_log table
*/
create table db_error_log (
   err_function varchar2(30)
  ,err_code varchar2(10)
  ,err_message varchar2(4000)
  ,call_stack varchar2(4000)
  ,back_trace varchar2(4000)
  ,schemaname varchar2(30)
  ,date_created date
  ,user_created varchar2(100)
);
/

/*
 create the package
*/
create or replace package error_handler is
  /* error_handler raises this exception if the user requests an abort. */
  e_abort_failure exception;
  en_abort_failure pls_integer := -20999;
  pragma exception_init ( e_abort_failure,-20999 );
  procedure log_db_error (i_err_function in db_error_log.err_function%type
                         ,i_err_message in db_error_log.err_message%type := null
                         ,i_abort in boolean := false
                         );

end error_handler;
/

create or replace package body error_handler is

  procedure log_db_error (i_err_function in db_error_log.err_function%type
                         ,i_err_message in db_error_log.err_message%type := null
                         ,i_abort in boolean := false
                         ) is

    procedure insert_row is
      pragma autonomous_transaction;
    begin
      insert into db_error_log (err_function
                               ,err_code
                               ,err_message
                               ,call_stack
                               ,back_trace
                               ,schemaname
                               ,date_created
                               ,user_created
                               ) 
      values (i_err_function
             ,sqlcode
             ,substr(nvl(i_err_message,dbms_utility.format_error_stack),1,4000)
             ,substr(dbms_utility.format_call_stack,1,4000)
             ,substr(dbms_utility.format_error_backtrace,1,4000)
             ,sys_context('USERENV','SESSION_USER')
             ,sysdate
             ,sys_context('USERENV','OS_USER') || '@' || sys_context('USERENV','HOST')
             );

      commit;
    exception
      when others then
        /* 
         Must rollback on exit from autonomous transaction.
         Display generic message to indicate problem.
        */
        rollback;
        dbms_output.put_line('Unable to write to error log!');
        dbms_output.put_line('Error:');
        dbms_output.put_line(dbms_utility.format_error_stack);
    end insert_row;

  begin
    insert_row;
    if i_abort then raise_application_error(en_abort_failure,'Abort exception invoked by developer!');
    end if;
  end log_db_error;

end error_handler;
/