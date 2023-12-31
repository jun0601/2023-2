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
            // JDBC 연결
            String jdbcDriver = "jdbc:mariadb://localhost:3306/pokemon_world";
            String dbUser = "root";
            String dbPass = "dlwns4302!";

            // 데이터베이스 연결
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);
            
            // 트레이너 확인하기
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT COUNT(*) FROM Trainer;");
            rs.next();
            int trainerCount = rs.getInt(1);

            // 대회를 위해 랜덤한 트레이너 2명 선택한다.
            Random random = new Random();
            int trainerId1 = random.nextInt(trainerCount) + 1; // 1부터 trainerCount까지 중 하나 선택
            int trainerId2 = random.nextInt(trainerCount) + 1;
            
            // 대회 결과 랜덤으로 생성한다. (0: 패배, 1: 비김, 2: 승리)으로 승점 정의
            int result = random.nextInt(3);

            // 대회 전 랜덤으로 선택된 트레이너 정보 출력한다.
            out.println("<h2>Selected Trainers</h2>");
            
            // 트레이너 1 정보 출력한다.
            String trainer1Query = "SELECT TrainerName FROM Trainer WHERE TrainerID = " + trainerId1 + ";";
            rs = stmt.executeQuery(trainer1Query);
            if (rs.next()) {
                String trainerName1 = rs.getString("TrainerName");
                out.println("<p>Trainer 1: " + trainerName1 + "</p>");
            }

            // 트레이너 2 정보 출력한다.
            String trainer2Query = "SELECT TrainerName FROM Trainer WHERE TrainerID = " + trainerId2 + ";";
            rs = stmt.executeQuery(trainer2Query);
            if (rs.next()) {
                String trainerName2 = rs.getString("TrainerName");
                out.println("<p>Trainer 2: " + trainerName2 + "</p>");
            }

            // 대회 결과 출력
            out.println("<h2>Competition Result</h2>");
            out.println("<p>Result: " + result + "</p>");

            // 대회 결과에 따라 승자 결정 및 업데이트
            int winnerId, loserId;
            if (result == 2) {
                winnerId = trainerId1;
                loserId = trainerId2;
            } else if (result == 0) {
                winnerId = trainerId2;
                loserId = trainerId1;
            } else {
                // 비긴 경우
                out.println("<p>It's a draw!</p>");
                return;
            }

            // 승자의 Score 업데이트 (정의된 승점적용)
            String updateWinnerQuery = "UPDATE Trainer SET Score = COALESCE(Score, 0) + 3 WHERE TrainerID = " + winnerId + ";";
            int updatedRowsWinner = stmt.executeUpdate(updateWinnerQuery);

            // 패자의 Score 업데이트 (정의된 승점적용)
            String updateLoserQuery = "UPDATE Trainer SET Score = Score + 1 WHERE TrainerID = " + loserId + ";";
            int updatedRowsLoser = stmt.executeUpdate(updateLoserQuery);

            // 업데이트 된 결과를 출력
            out.println("<h2>Updated Trainer Data</h2>");

            // 승자의 데이터 가져오기
            String winnerQuery = "SELECT * FROM Trainer WHERE TrainerID = " + winnerId + ";";
            rs = stmt.executeQuery(winnerQuery);

            // 승자의 데이터 출력
            if (rs.next()) {
                String winnerName = rs.getString("TrainerName");
                int winnerScore = rs.getInt("Score");
                out.println("<p>Winner: " + winnerName + ", Score Updated: " + winnerScore + "</p>");
            }

            // 패자의 데이터 가져오기
            String loserQuery = "SELECT * FROM Trainer WHERE TrainerID = " + loserId + ";";
            rs = stmt.executeQuery(loserQuery);

            // 패자의 데이터 출력
            if (rs.next()) {
                String loserName = rs.getString("TrainerName");
                int loserScore = rs.getInt("Score");
                out.println("<p>Loser: " + loserName + ", Score Updated: " + loserScore + "</p>");
            }

         // 대회 이후 랜덤으로 선택된 트레이너 정보 가져오기
            int selectedTrainerId = (result == 2) ? winnerId : loserId;

            // 선택된 트레이너의 정보 출력한다.
            String selectedTrainerQuery = "SELECT * FROM Trainer WHERE TrainerID = " + selectedTrainerId + ";";
            rs = stmt.executeQuery(selectedTrainerQuery);
            if (rs.next()) {
                String selectedTrainerName = rs.getString("TrainerName");
                int selectedTrainerScore = rs.getInt("Score");
                out.println("<h2>Selected Trainer After Competition</h2>");
                out.println("<p>Selected Trainer: " + selectedTrainerName + ", Score: " + selectedTrainerScore + "</p>");

                // 선택된 트레이너의 포켓몬 중 하나를 랜덤으로 선택한다.
                String randomPokemonQuery = "SELECT * FROM Pokemon WHERE TrainerID = " + selectedTrainerId + " ORDER BY RAND() LIMIT 1;";
                rs = stmt.executeQuery(randomPokemonQuery);

                // 선택된 포켓몬의 정보 출력
                if (rs.next()) {
                    int selectedPokemonId = rs.getInt("PokemonID");
                    String selectedPokemonNickname = rs.getString("Nickname");
                    out.println("<p>Selected Pokemon: " + selectedPokemonNickname + " (ID: " + selectedPokemonId + ")</p>");

                    // 포켓몬 상태를 랜덤으로 설정 (마비, 맹독, 수면. 화상. 얼음. 혼란 상태중 하나로 설정한다.)
                    List<String> statuses = new ArrayList<>();
                    statuses.add("마비");
                    statuses.add("맹독");
                    statuses.add("수면");
                    statuses.add("화상");
                    statuses.add("얼음");
                    statuses.add("혼란");

                    // 랜덤으로 포켓몬 상태 선택
                    String randomStatus = statuses.get(new Random().nextInt(statuses.size()));

                    // 선택된 포켓몬의 상태 업데이트
                    String updateStatusQuery = "UPDATE Pokemon SET Status = '" + randomStatus + "' WHERE PokemonID = " + selectedPokemonId + ";";
                    int updatedRowsStatus = stmt.executeUpdate(updateStatusQuery);
                    out.println("<p>Updated Status: " + randomStatus + " (Rows Updated: " + updatedRowsStatus + ")</p>");
                    
                    
                    
                }
                
            }
            
         // 대회 이후 랜덤으로 선택된 트레이너 정보 가져오기
            int selectedTrainerIdAfterCompetition = (result == 2) ? winnerId : loserId;


         // 선택된 트레이너의 정보 출력한다.
            String selectedTrainerQueryAfterCompetition = "SELECT * FROM Trainer WHERE TrainerID = " + selectedTrainerIdAfterCompetition + ";";
            rs = stmt.executeQuery(selectedTrainerQueryAfterCompetition);
            if (rs.next()) {
                String selectedTrainerName = rs.getString("TrainerName");
                int selectedTrainerScore = rs.getInt("Score");
                int selectedTrainerMoney = rs.getInt("Money");
                out.println("<h2>Selected Trainer After went to Pokemon Center </h2>");
                out.println("<p>Selected Trainer: " + selectedTrainerName + ", Score: " + selectedTrainerScore + ", Money: " + selectedTrainerMoney + "</p>");

                // 선택된 트레이너의 포켓몬 중 하나를 랜덤으로 선택
                String randomPokemonQuery = "SELECT * FROM Pokemon WHERE TrainerID = " + selectedTrainerIdAfterCompetition + " ORDER BY RAND() LIMIT 1;";
                rs = stmt.executeQuery(randomPokemonQuery);

                // 이미 선택된 포켓몬의 정보 출력 및 부상 상태 확인
                if (rs.next()) {
                    int selectedPokemonId = rs.getInt("PokemonID");
                    String selectedPokemonNickname = rs.getString("Nickname");
                    String selectedPokemonStatus = rs.getString("Status");
                    out.println("<p>Selected Pokemon: " + selectedPokemonNickname + " (ID: " + selectedPokemonId + ", Status: " + selectedPokemonStatus + ")</p>");

                    // 부상 상태인지 확인
                    if (selectedPokemonStatus.equals("마비") || selectedPokemonStatus.equals("맹독") ||
                            selectedPokemonStatus.equals("수면") || selectedPokemonStatus.equals("화상") ||
                            selectedPokemonStatus.equals("얼음") || selectedPokemonStatus.equals("혼란")) {

                        // 과일 구매를 위한 코드 추가 (각 상태에 맞는 열매를 연결한다.)
                        String fruitType;
                        int fruitPrice = 10;

                        switch (selectedPokemonStatus) {
                            case "마비":
                                fruitType = "비치열매";
                                break;
                            case "맹독":
                                fruitType = "복숭열매";
                                break;
                            case "수면":
                                fruitType = "유루열매";
                                break;
                            case "화상":
                                fruitType = "복분열매";
                                break;
                            case "얼음":
                                fruitType = "불탄열매";
                                break;
                            case "혼란":
                                fruitType = "쓴맛나무열매";
                                break;
                            default:
                                fruitType = "Unknown Fruit";
                                break;
                        }

                        // 과일 구매 가능 여부 확인
                        if (selectedTrainerMoney >= fruitPrice) {
                            // 과일 구매 및 부상 치료
                            selectedTrainerMoney -= fruitPrice;
                            String updateMoneyQuery = "UPDATE Trainer SET Money = " + selectedTrainerMoney + " WHERE TrainerID = " + selectedTrainerIdAfterCompetition + ";";
                            stmt.executeUpdate(updateMoneyQuery);

                            // 열매 테이블에서 재고 감소
                            String updateStockQuery = "UPDATE Fruits SET StockQuantity = StockQuantity - 1 WHERE FruitType = '" + fruitType + "';";
                            int updatedRowsStock = stmt.executeUpdate(updateStockQuery);

                            // 선택된 포켓몬의 상태 업데이트
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

