package org.example;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ReadInfoMessages {
    private static final String URL = "jdbc:postgresql://localhost:5439/jdbc1";
    private static final String USER = "sa";
    private static final String PASSWORD = "admin";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(URL, USER, PASSWORD)) {
            while (true) {
                String sql = "SELECT serial_id, message, type, processed FROM notice WHERE type = 'INFO' AND processed = false";
                try (PreparedStatement statement = connection.prepareStatement(sql);
                     ResultSet resultSet = statement.executeQuery()) {

                    while (resultSet.next()) {
                        int id = resultSet.getInt("serial_id");
                        String message = resultSet.getString("message");
                        System.out.println(message);

                        String deleteSql = "DELETE FROM notice WHERE serial_id = ?";
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
