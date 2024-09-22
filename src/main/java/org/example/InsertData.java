package org.example;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Random;

public class InsertData {
    private static final String URL = "jdbc:postgresql://localhost:5432/mydb";
    private static final String USER = "user";
    private static final String PASSWORD = "password";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            Random random = new Random();
            String[] types = {"INFO", "WARN"};

            while (true) {
                String type = types[random.nextInt(types.length)];
                String message = type.equals("INFO") ?
                        "Новое сообщение от " + LocalDateTime.now() :
                        "Произошла ошибка в " + LocalDateTime.now();

                String sql = "INSERT INTO notice (message, type, processed) VALUES (?, ?, false)";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setString(1, message);
                    statement.setString(2, type);
                    statement.executeUpdate();
                }

                Thread.sleep(1000);
            }
        } catch (SQLException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}

