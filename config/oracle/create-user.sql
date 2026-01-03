-- create user
ACCEPT user_name CHAR PROMPT 'Set user name 1:'
ACCEPT _user_pass CHAR PROMPT 'Set user password 1:'

CREATE USER &user_name IDENTIFIED BY &user_password;
GRANT CONNECT TO &user_name;
GRANT CREATE SESSION TO &user_name;
GRANT ALL PRIVILEGES TO &user_name;

--
COMMIT;
