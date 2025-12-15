Java JDBC

1.1 Запустить СУБД PostgreSQL (как делали на паре из docker)

1.2 В Init.sql создать таблицу notice с полями: serial id, string message, string type, boolean processed

1.3 Создать одну программу, которая будет писать в БД.

1.3.1 Создать Connection

1.3.2 Создать бесконечный цикл

1.3.3 Внутри цикла выполнять Insert. Поля name, type заполнять рандомно из списка. вариант 1. Message: “Новое сообщение от <текущее время, можно LocalDateTime.now()>” Type: “INFO” processed: false вариант 2. Message: “Произошла ошибка в <текущее время, можно LocalDateTime.now()>” Type: “WARN” processed: false

1.3.4 После віполнения запроса делать sleep на 1000мс

1.4 Создать программу которая будет читать INFO сообщения из БД.

1.4.1 Создать Connection

1.4.2 Создать бесконечный цикл

1.4.3 Внутри цикла выполнять Select id, message, type, processed, где type=INFO и processed=false

1.4.4 Пройтись циклом по всем строкам, для каждой строки вывести на экран message. После этого, выполнить DELETE для этого id

1.5 Создать еще одну программу, аналогично 1.4, но для работы с WARN.

1.5.1 Вместо удаления каждой записи, выполнить UPDATE для этого id и обновить processed на false
