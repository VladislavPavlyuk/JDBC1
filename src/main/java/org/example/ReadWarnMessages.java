package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReadWarnMessages {
    private static final String URL = "jdbc:postgresql://localhost:5439/jdbc1";
    private static final String USER = "sa";
    private static final String PASSWORD = "admin";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            while (true) {
                String sql = "SELECT serial_id, message, type, processed FROM notice WHERE type = 'WARN' AND processed = false";
                try (PreparedStatement statement = connection.prepareStatement(sql);
                     ResultSet resultSet = statement.executeQuery()) {

                    while (resultSet.next()) {
                        int id = resultSet.getInt("serial_id");
                        String message = resultSet.getString("message");
                        System.out.println(message);

                        String updateSql = "UPDATE notice SET processed = true WHERE serial_id = ?";
                        try (PreparedStatement updateStatement = connection.prepareStatement(updateSql)) {
                            updateStatement.setInt(1, id);
                            updateStatement.executeUpdate();
                        }
                    }
                }

                Thread.sleep(1000);
            }
        } catch (SQLException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}

