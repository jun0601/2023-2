<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="EUC-KR">
    <title>Random Competition</title>
</head>
<body>
    <h1>Random Competition</h1>

    <% 
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            // JDBC ����
            String jdbcDriver = "jdbc:mariadb://localhost:3306/pokemon_world";
            String dbUser = "root";
            String dbPass = "dlwns4302!";

            // �����ͺ��̽� ����
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);
            
            // Ʈ���̳� Ȯ���ϱ�
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT COUNT(*) FROM Trainer;");
            rs.next();
            int trainerCount = rs.getInt(1);

            // ��ȸ�� ���� ������ Ʈ���̳� 2�� �����Ѵ�.
            Random random = new Random();
            int trainerId1 = random.nextInt(trainerCount) + 1; // 1���� trainerCount���� �� �ϳ� ����
            int trainerId2 = random.nextInt(trainerCount) + 1;
            
            // ��ȸ ��� �������� �����Ѵ�. (0: �й�, 1: ���, 2: �¸�)���� ���� ����
            int result = random.nextInt(3);

            // ��ȸ �� �������� ���õ� Ʈ���̳� ���� ����Ѵ�.
            out.println("<h2>Selected Trainers</h2>");
            
            // Ʈ���̳� 1 ���� ����Ѵ�.
            String trainer1Query = "SELECT TrainerName FROM Trainer WHERE TrainerID = " + trainerId1 + ";";
            rs = stmt.executeQuery(trainer1Query);
            if (rs.next()) {
                String trainerName1 = rs.getString("TrainerName");
                out.println("<p>Trainer 1: " + trainerName1 + "</p>");
            }

            // Ʈ���̳� 2 ���� ����Ѵ�.
            String trainer2Query = "SELECT TrainerName FROM Trainer WHERE TrainerID = " + trainerId2 + ";";
            rs = stmt.executeQuery(trainer2Query);
            if (rs.next()) {
                String trainerName2 = rs.getString("TrainerName");
                out.println("<p>Trainer 2: " + trainerName2 + "</p>");
            }

            // ��ȸ ��� ���
            out.println("<h2>Competition Result</h2>");
            out.println("<p>Result: " + result + "</p>");

            // ��ȸ ����� ���� ���� ���� �� ������Ʈ
            int winnerId, loserId;
            if (result == 2) {
                winnerId = trainerId1;
                loserId = trainerId2;
            } else if (result == 0) {
                winnerId = trainerId2;
                loserId = trainerId1;
            } else {
                // ��� ���
                out.println("<p>It's a draw!</p>");
                return;
            }

            // ������ Score ������Ʈ (���ǵ� ��������)
            String updateWinnerQuery = "UPDATE Trainer SET Score = COALESCE(Score, 0) + 3 WHERE TrainerID = " + winnerId + ";";
            int updatedRowsWinner = stmt.executeUpdate(updateWinnerQuery);

            // ������ Score ������Ʈ (���ǵ� ��������)
            String updateLoserQuery = "UPDATE Trainer SET Score = Score + 1 WHERE TrainerID = " + loserId + ";";
            int updatedRowsLoser = stmt.executeUpdate(updateLoserQuery);

            // ������Ʈ �� ����� ���
            out.println("<h2>Updated Trainer Data</h2>");

            // ������ ������ ��������
            String winnerQuery = "SELECT * FROM Trainer WHERE TrainerID = " + winnerId + ";";
            rs = stmt.executeQuery(winnerQuery);

            // ������ ������ ���
            if (rs.next()) {
                String winnerName = rs.getString("TrainerName");
                int winnerScore = rs.getInt("Score");
                out.println("<p>Winner: " + winnerName + ", Score Updated: " + winnerScore + "</p>");
            }

            // ������ ������ ��������
            String loserQuery = "SELECT * FROM Trainer WHERE TrainerID = " + loserId + ";";
            rs = stmt.executeQuery(loserQuery);

            // ������ ������ ���
            if (rs.next()) {
                String loserName = rs.getString("TrainerName");
                int loserScore = rs.getInt("Score");
                out.println("<p>Loser: " + loserName + ", Score Updated: " + loserScore + "</p>");
            }

         // ��ȸ ���� �������� ���õ� Ʈ���̳� ���� ��������
            int selectedTrainerId = (result == 2) ? winnerId : loserId;

            // ���õ� Ʈ���̳��� ���� ����Ѵ�.
            String selectedTrainerQuery = "SELECT * FROM Trainer WHERE TrainerID = " + selectedTrainerId + ";";
            rs = stmt.executeQuery(selectedTrainerQuery);
            if (rs.next()) {
                String selectedTrainerName = rs.getString("TrainerName");
                int selectedTrainerScore = rs.getInt("Score");
                out.println("<h2>Selected Trainer After Competition</h2>");
                out.println("<p>Selected Trainer: " + selectedTrainerName + ", Score: " + selectedTrainerScore + "</p>");

                // ���õ� Ʈ���̳��� ���ϸ� �� �ϳ��� �������� �����Ѵ�.
                String randomPokemonQuery = "SELECT * FROM Pokemon WHERE TrainerID = " + selectedTrainerId + " ORDER BY RAND() LIMIT 1;";
                rs = stmt.executeQuery(randomPokemonQuery);

                // ���õ� ���ϸ��� ���� ���
                if (rs.next()) {
                    int selectedPokemonId = rs.getInt("PokemonID");
                    String selectedPokemonNickname = rs.getString("Nickname");
                    out.println("<p>Selected Pokemon: " + selectedPokemonNickname + " (ID: " + selectedPokemonId + ")</p>");

                    // ���ϸ� ���¸� �������� ���� (����, �͵�, ����. ȭ��. ����. ȥ�� ������ �ϳ��� �����Ѵ�.)
                    List<String> statuses = new ArrayList<>();
                    statuses.add("����");
                    statuses.add("�͵�");
                    statuses.add("����");
                    statuses.add("ȭ��");
                    statuses.add("����");
                    statuses.add("ȥ��");

                    // �������� ���ϸ� ���� ����
                    String randomStatus = statuses.get(new Random().nextInt(statuses.size()));

                    // ���õ� ���ϸ��� ���� ������Ʈ
                    String updateStatusQuery = "UPDATE Pokemon SET Status = '" + randomStatus + "' WHERE PokemonID = " + selectedPokemonId + ";";
                    int updatedRowsStatus = stmt.executeUpdate(updateStatusQuery);
                    out.println("<p>Updated Status: " + randomStatus + " (Rows Updated: " + updatedRowsStatus + ")</p>");
                    
                    
                    
                }
                
            }
            
         // ��ȸ ���� �������� ���õ� Ʈ���̳� ���� ��������
            int selectedTrainerIdAfterCompetition = (result == 2) ? winnerId : loserId;


         // ���õ� Ʈ���̳��� ���� ����Ѵ�.
            String selectedTrainerQueryAfterCompetition = "SELECT * FROM Trainer WHERE TrainerID = " + selectedTrainerIdAfterCompetition + ";";
            rs = stmt.executeQuery(selectedTrainerQueryAfterCompetition);
            if (rs.next()) {
                String selectedTrainerName = rs.getString("TrainerName");
                int selectedTrainerScore = rs.getInt("Score");
                int selectedTrainerMoney = rs.getInt("Money");
                out.println("<h2>Selected Trainer After went to Pokemon Center </h2>");
                out.println("<p>Selected Trainer: " + selectedTrainerName + ", Score: " + selectedTrainerScore + ", Money: " + selectedTrainerMoney + "</p>");

                // ���õ� Ʈ���̳��� ���ϸ� �� �ϳ��� �������� ����
                String randomPokemonQuery = "SELECT * FROM Pokemon WHERE TrainerID = " + selectedTrainerIdAfterCompetition + " ORDER BY RAND() LIMIT 1;";
                rs = stmt.executeQuery(randomPokemonQuery);

                // �̹� ���õ� ���ϸ��� ���� ��� �� �λ� ���� Ȯ��
                if (rs.next()) {
                    int selectedPokemonId = rs.getInt("PokemonID");
                    String selectedPokemonNickname = rs.getString("Nickname");
                    String selectedPokemonStatus = rs.getString("Status");
                    out.println("<p>Selected Pokemon: " + selectedPokemonNickname + " (ID: " + selectedPokemonId + ", Status: " + selectedPokemonStatus + ")</p>");

                    // �λ� �������� Ȯ��
                    if (selectedPokemonStatus.equals("����") || selectedPokemonStatus.equals("�͵�") ||
                            selectedPokemonStatus.equals("����") || selectedPokemonStatus.equals("ȭ��") ||
                            selectedPokemonStatus.equals("����") || selectedPokemonStatus.equals("ȥ��")) {

                        // ���� ���Ÿ� ���� �ڵ� �߰� (�� ���¿� �´� ���Ÿ� �����Ѵ�.)
                        String fruitType;
                        int fruitPrice = 10;

                        switch (selectedPokemonStatus) {
                            case "����":
                                fruitType = "��ġ����";
                                break;
                            case "�͵�":
                                fruitType = "��������";
                                break;
                            case "����":
                                fruitType = "���翭��";
                                break;
                            case "ȭ��":
                                fruitType = "���п���";
                                break;
                            case "����":
                                fruitType = "��ź����";
                                break;
                            case "ȥ��":
                                fruitType = "������������";
                                break;
                            default:
                                fruitType = "Unknown Fruit";
                                break;
                        }

                        // ���� ���� ���� ���� Ȯ��
                        if (selectedTrainerMoney >= fruitPrice) {
                            // ���� ���� �� �λ� ġ��
                            selectedTrainerMoney -= fruitPrice;
                            String updateMoneyQuery = "UPDATE Trainer SET Money = " + selectedTrainerMoney + " WHERE TrainerID = " + selectedTrainerIdAfterCompetition + ";";
                            stmt.executeUpdate(updateMoneyQuery);

                            // ���� ���̺��� ��� ����
                            String updateStockQuery = "UPDATE Fruits SET StockQuantity = StockQuantity - 1 WHERE FruitType = '" + fruitType + "';";
                            int updatedRowsStock = stmt.executeUpdate(updateStockQuery);

                            // ���õ� ���ϸ��� ���� ������Ʈ
                            String updateStatusQuery = "UPDATE Pokemon SET Status = NULL WHERE PokemonID = " + selectedPokemonId + ";";
                            int updatedRowsStatus = stmt.executeUpdate(updateStatusQuery);

                            out.println("<p>Injury treated with " + fruitType + ". Remaining Money: " + selectedTrainerMoney + ", Stock Updated: " + updatedRowsStock + ", Status Updated: " + updatedRowsStatus + "</p>");
                        } else {
                            out.println("<p>Trainer does not have enough money to buy fruit.</p>");
                        }
                    } else {
                        out.println("<p>The selected Pokemon is not injured.</p>");
                    }
                } else {
                    out.println("<p>No Pokemon with changed status found.</p>");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>

