CREATE TABLE notice (

                       serial_id        integer generated by default as identity,
                       message          String,
                       type             String,
                       age             integer,
                       primary key (serial_id)
)