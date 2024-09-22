package org.example;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReadInfoMessages {
    private static final String URL = "jdbc:postgresql://localhost:5432/mydb";
    private static final String USER = "user";
    private static final String PASSWORD = "password";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            while (true) {
                String sql = "SELECT id, message, type, processed FROM notice WHERE type = 'INFO' AND processed = false";
                try (PreparedStatement statement = connection.prepareStatement(sql);
                     ResultSet resultSet = statement.executeQuery()) {

                    while (resultSet.next()) {
                        int id = resultSet.getInt("id");
                        String message = resultSet.getString("message");
                        System.out.println(message);

                        String deleteSql = "DELETE FROM notice WHERE id = ?";
                        try (PreparedStatement deleteStatement = connection.prepareStatement(deleteSql)) {
                            deleteStatement.setInt(1, id);
                            deleteStatement.executeUpdate();
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
