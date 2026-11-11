import java.io.FileInputStream;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.util.Scanner;
 
public class CRIMCOPApp1 {
 
    // ─── DB CONNECTION ────────────────────────────────────────
    private static Connection connection = null;
 
    private static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                Properties props = new Properties();
                FileInputStream fis = new FileInputStream("db.properties");
                props.load(fis);
                String url      = props.getProperty("db.url");
                String user     = props.getProperty("db.username");
                String password = props.getProperty("db.password");
                String driver   = props.getProperty("db.driver");
                Class.forName(driver);
                connection = DriverManager.getConnection(url, user, password);
                System.out.println("Database connected successfully.");
            } catch (IOException e) {
                throw new SQLException("Could not load db.properties: " + e.getMessage());
            } catch (ClassNotFoundException e) {
                throw new SQLException("JDBC Driver not found: " + e.getMessage());
            }
        }
        return connection;
    }
 
    private static void closeConnection() {
        if (connection != null) {
            try { connection.close(); System.out.println("Connection closed."); }
            catch (SQLException e) { System.err.println(e.getMessage()); }
        }
    }
 
    static Scanner sc = new Scanner(System.in);
 
    // ─── MAIN ─────────────────────────────────────────────────
    public static void main(String[] args) {
        System.out.println("============================================");
        System.out.println("   PoliceNet — Station Management System    ");
        System.out.println("============================================");
        boolean running = true;
        while (running) {
            printMenu();
            int choice = getIntInput("Enter choice: ");
            switch (choice) {
                case 1  -> viewAllFIRs();
                case 2  -> searchFIRsByPerson();
                case 3  -> registerPerson();
                case 4  -> updateCaseStatus();
                case 5  -> deleteOldNotices();
                case 6  -> fileFIRviaProcedure();
                case 7  -> recordArrestWithTransaction();
                case 8  -> viewOfficerCaseload();
                case 9  -> searchPersonByName();
                case 10 -> viewCaseDetails();
                case 11 -> viewAccusedInCase();
                case 12 -> issueNotice();
                case 13 -> { running = false; closeConnection(); }
                default -> System.out.println("Invalid choice. Try again.");
            }
        }
    }
 
    // ─── MENU ─────────────────────────────────────────────────
    static void printMenu() {
        System.out.println("\n─────────────────────────────────────────");
        System.out.println(" 1.  View All FIRs");
        System.out.println(" 2.  Search FIRs and Cases by Person");
        System.out.println(" 3.  Register New Person");
        System.out.println(" 4.  Update Case Status");
        System.out.println(" 5.  Delete Old Executed Notices");
        System.out.println(" 6.  File FIR  (Stored Procedure)");
        System.out.println(" 7.  Record Arrest + Bail  (Transaction)");
        System.out.println(" 8.  View Officer Caseload Report");
        System.out.println(" 9.  Search Person by Name");
        System.out.println(" 10. View Case Details");
        System.out.println(" 11. View Accused in a Case");
        System.out.println(" 12. Issue New Notice");
        System.out.println(" 13. Exit");
        System.out.println("─────────────────────────────────────────");
    }
 
    // ════════════════════════════════════════════════════════════
    //   HELPER — SHOW LISTS (called before every pick-by-ID op)
    // ════════════════════════════════════════════════════════════
 
    static void showAllPersons() {
        String sql = "SELECT p_id, p_name, p_type, crim_rec_count FROM Person ORDER BY p_id";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Available Persons:");
            System.out.printf("  %-6s  %-22s  %-10s  %s%n",
                    "ID", "Name", "Type", "CrimCount");
            System.out.println("  " + "─".repeat(55));
            while (rs.next())
                System.out.printf("  %-6d  %-22s  %-10s  %d%n",
                        rs.getInt("p_id"),
                        rs.getString("p_name"),
                        rs.getString("p_type"),
                        rs.getInt("crim_rec_count"));
            System.out.println("  " + "─".repeat(55));
        } catch (SQLException e) {
            System.err.println("Could not load persons: " + e.getMessage());
        }
    }
 
    static void showAllCases() {
        String sql = """
                SELECT cc.case_id, f.section, ps.ps_name AS station,
                       o.of_name AS officer, cc.status
                FROM   Crime_Case cc
                JOIN   FIR f           ON cc.fir_id       = f.fir_id
                JOIN   PoliceStation ps ON f.ps_id         = ps.ps_id
                JOIN   Officer o        ON cc.invest_off_id = o.of_id
                ORDER  BY cc.case_id
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Available Cases:");
            System.out.printf("  %-8s  %-12s  %-20s  %-18s  %s%n",
                    "Case_ID", "Section", "Station", "Officer", "Status");
            System.out.println("  " + "─".repeat(80));
            while (rs.next())
                System.out.printf("  %-8d  %-12s  %-20s  %-18s  %s%n",
                        rs.getInt("case_id"),
                        rs.getString("section"),
                        rs.getString("station"),
                        rs.getString("officer"),
                        rs.getString("status"));
            System.out.println("  " + "─".repeat(80));
        } catch (SQLException e) {
            System.err.println("Could not load cases: " + e.getMessage());
        }
    }
 
    static void showAllStations() {
        String sql = "SELECT ps_id, ps_name, district FROM PoliceStation ORDER BY ps_id";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Available Stations:");
            System.out.printf("  %-6s  %-25s  %s%n", "ID", "Station Name", "District");
            System.out.println("  " + "─".repeat(50));
            while (rs.next())
                System.out.printf("  %-6d  %-25s  %s%n",
                        rs.getInt("ps_id"),
                        rs.getString("ps_name"),
                        rs.getString("district"));
            System.out.println("  " + "─".repeat(50));
        } catch (SQLException e) {
            System.err.println("Could not load stations: " + e.getMessage());
        }
    }
 
    static void showAllOfficers() {
        String sql = """
                SELECT o.of_id, o.of_name, o.designation, ps.ps_name AS station
                FROM   Officer o
                JOIN   PoliceStation ps ON o.ps_id = ps.ps_id
                WHERE  o.status = 'Active'
                ORDER  BY o.of_id
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Active Officers:");
            System.out.printf("  %-6s  %-20s  %-14s  %s%n",
                    "ID", "Name", "Designation", "Station");
            System.out.println("  " + "─".repeat(65));
            while (rs.next())
                System.out.printf("  %-6d  %-20s  %-14s  %s%n",
                        rs.getInt("of_id"),
                        rs.getString("of_name"),
                        rs.getString("designation"),
                        rs.getString("station"));
            System.out.println("  " + "─".repeat(65));
        } catch (SQLException e) {
            System.err.println("Could not load officers: " + e.getMessage());
        }
    }
 
    static void showAllBeatAreas() {
        String sql = """
                SELECT b.bt_id, b.area, ps.ps_name AS station
                FROM   Beat_Area b
                JOIN   PoliceStation ps ON b.ps_id = ps.ps_id
                ORDER  BY b.bt_id
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Available Beat Areas:");
            System.out.printf("  %-6s  %-25s  %s%n", "ID", "Area", "Station");
            System.out.println("  " + "─".repeat(55));
            while (rs.next())
                System.out.printf("  %-6d  %-25s  %s%n",
                        rs.getInt("bt_id"),
                        rs.getString("area"),
                        rs.getString("station"));
            System.out.println("  " + "─".repeat(55));
        } catch (SQLException e) {
            System.err.println("Could not load beat areas: " + e.getMessage());
        }
    }
 
    static void showExecutedNotices() {
        String sql = """
                SELECT n.not_id, p.p_name AS accused_name,
                       ps.ps_name AS station, n.iss_date, n.status
                FROM   Notice n
                JOIN   Accused      a   ON n.accused_id      = a.acc_id
                JOIN   Person       p   ON a.person_id        = p.p_id
                JOIN   PoliceStation ps ON n.issued_station   = ps.ps_id
                WHERE  n.status   = 'Executed'
                AND    n.iss_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
                ORDER  BY n.iss_date
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n  Executed Notices Older Than 1 Year (eligible for deletion):");
            System.out.printf("  %-8s  %-20s  %-22s  %-12s  %s%n",
                    "ID", "Accused", "Station", "Date", "Status");
            System.out.println("  " + "─".repeat(75));
            boolean found = false;
            while (rs.next()) {
                found = true;
                System.out.printf("  %-8d  %-20s  %-22s  %-12s  %s%n",
                        rs.getInt("not_id"),
                        rs.getString("accused_name"),
                        rs.getString("station"),
                        rs.getDate("iss_date"),
                        rs.getString("status"));
            }
            if (!found)
                System.out.println("  No eligible notices found for deletion.");
            System.out.println("  " + "─".repeat(75));
        } catch (SQLException e) {
            System.err.println("Could not load notices: " + e.getMessage());
        }
    }
 
    // ════════════════════════════════════════════════════════════
    //   OPERATIONS
    // ════════════════════════════════════════════════════════════
 
    // ─── 1. View All FIRs ────────────────────────────────────
    static void viewAllFIRs() {
        String sql = """
                SELECT f.fir_id, ps.ps_name AS station,
                       o.of_name AS officer, p.p_name AS complainant,
                       f.section, f.incident_date, f.status
                FROM   FIR f
                JOIN   PoliceStation ps ON f.ps_id       = ps.ps_id
                JOIN   Officer        o  ON f.reg_off_id  = o.of_id
                JOIN   Person         p  ON f.comp_per_id = p.p_id
                ORDER  BY f.time_filed DESC
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n─── ALL FIRs ───────────────────────────────────────────────────────────────────────────────────────────────────");
            System.out.printf("%-6s  %-22s  %-18s  %-18s  %-12s  %-14s  %-20s%n",
                    "FIR_ID", "Station", "Officer", "Complainant", "Section", "Date", "Status");
            System.out.println("─".repeat(115));
            int count = 0;
            while (rs.next()) {
                count++;
                System.out.printf("%-6d  %-22s  %-18s  %-18s  %-12s  %-14s  %-20s%n",
                        rs.getInt("fir_id"),
                        rs.getString("station"),
                        rs.getString("officer"),
                        rs.getString("complainant"),
                        rs.getString("section"),
                        rs.getDate("incident_date"),
                        rs.getString("status"));
            }
            System.out.println("─".repeat(115));
            System.out.println("Total FIRs: " + count);
        } catch (SQLException e) {
            System.err.println("Error fetching FIRs: " + e.getMessage());
        }
    }
 
    // ─── 2. Search FIRs by Person ────────────────────────────
    static void searchFIRsByPerson() {
        showAllPersons();                                    // SHOW FIRST
        int personId = getIntInput("Enter Person ID   : ");
 
        String sql = """
                SELECT p.p_name, f.fir_id, f.section,
                       f.incident_date, cc.case_id, cc.status AS case_status
                FROM   Person p
                JOIN   FIR        f  ON p.p_id  = f.comp_per_id
                JOIN   Crime_Case cc ON f.fir_id = cc.fir_id
                WHERE  p.p_id = ?
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, personId);
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("\n─── FIRs and Cases for Person ID: " + personId + " ───");
                System.out.printf("%-20s  %-8s  %-12s  %-15s  %-10s  %-15s%n",
                        "Name", "FIR_ID", "Section", "Date", "Case_ID", "Case_Status");
                System.out.println("─".repeat(85));
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    System.out.printf("%-20s  %-8d  %-12s  %-15s  %-10d  %-15s%n",
                            rs.getString("p_name"),
                            rs.getInt("fir_id"),
                            rs.getString("section"),
                            rs.getDate("incident_date"),
                            rs.getInt("case_id"),
                            rs.getString("case_status"));
                }
                if (!found)
                    System.out.println("No FIRs found for Person ID: " + personId);
            }
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
 
    // ─── 3. Register New Person ──────────────────────────────
    static void registerPerson() {
        System.out.println("\n─── Register New Person ───");
        System.out.print("Full Name                     : "); String name    = sc.nextLine();
        System.out.print("Date of Birth (YYYY-MM-DD)    : "); String dob     = sc.nextLine();
        System.out.print("Gender (Male/Female/Other)    : "); String gender  = sc.nextLine();
        System.out.print("Aadhaar Number (12 digits)    : "); String aadhaar = sc.nextLine();
        System.out.print("Contact Number                : "); String contact = sc.nextLine();
        System.out.print("Type (Criminal/Victim/Witness): "); String ptype   = sc.nextLine();
 
        String sql = """
                INSERT INTO Person
                    (p_name, dob, gender, aadhaar_no, contact, p_type, crim_rec_count)
                VALUES (?, ?, ?, ?, ?, ?, 0)
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql,
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setDate  (2, Date.valueOf(dob));
            ps.setString(3, gender);
            ps.setString(4, aadhaar);
            ps.setString(5, contact);
            ps.setString(6, ptype);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next())
                        System.out.println("Person registered. Assigned Person ID: "
                                + keys.getInt(1));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error registering person: " + e.getMessage());
        }
    }
 
    // ─── 4. Update Case Status ───────────────────────────────
    static void updateCaseStatus() {
        showAllCases();                                      // SHOW FIRST
        int    caseId = getIntInput("Enter Case ID     : ");
        System.out.print("New Status (Active/Closed/Chargesheeted/Acquitted): ");
        String status = sc.nextLine();
 
        String sql = """
                UPDATE Crime_Case
                SET    status     = ?,
                       close_date = CASE
                                        WHEN ? IN ('Closed','Chargesheeted','Acquitted')
                                        THEN CURDATE() ELSE close_date
                                    END
                WHERE  case_id = ?
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt   (3, caseId);
            int rows = ps.executeUpdate();
            System.out.println(rows > 0
                    ? "Case " + caseId + " updated to: " + status
                    : "No case found with ID: " + caseId);
        } catch (SQLException e) {
            System.err.println("Error updating case: " + e.getMessage());
        }
    }
 
    // ─── 5. Delete Old Notices ───────────────────────────────
    static void deleteOldNotices() {
        showExecutedNotices();                               // SHOW FIRST
        System.out.print("\nConfirm deletion? (yes/no): ");
        String confirm = sc.nextLine();
        if (!confirm.equalsIgnoreCase("yes")) {
            System.out.println("Deletion cancelled.");
            return;
        }
        String sql = """
                DELETE FROM Notice
                WHERE  status   = 'Executed'
                AND    iss_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int rows = ps.executeUpdate();
            System.out.println(rows + " old notice(s) deleted.");
        } catch (SQLException e) {
            System.err.println("Error deleting notices: " + e.getMessage());
        }
    }
 
    // ─── 6. File FIR via Procedure ───────────────────────────
    static void fileFIRviaProcedure() {
        System.out.println("\n─── File FIR via Stored Procedure ───");
 
        showAllStations();
        int psId = getIntInput("Station ID              : ");
 
        showAllOfficers();
        int regOffId = getIntInput("Registering Officer ID  : ");
 
        showAllPersons();
        int compPerId = getIntInput("Complainant Person ID   : ");
 
        showAllBeatAreas();
        int beatId = getIntInput("Beat Area ID            : ");
 
        System.out.print("Incident Date (YYYY-MM-DD): "); String incDate  = sc.nextLine();
        System.out.print("Location                  : "); String location = sc.nextLine();
        System.out.print("IPC Section               : "); String section  = sc.nextLine();
        System.out.print("Description               : "); String descr    = sc.nextLine();
 
        showAllOfficers();
        int investOffId = getIntInput("Investigating Officer ID: ");
 
        String sql = "{CALL file_FIR(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        try (Connection con = getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt   (1, psId);
            cs.setInt   (2, regOffId);
            cs.setInt   (3, compPerId);
            cs.setInt   (4, beatId);
            cs.setDate  (5, Date.valueOf(incDate));
            cs.setString(6, location);
            cs.setString(7, section);
            cs.setString(8, descr);
            cs.setInt   (9, investOffId);
            boolean hasResults = cs.execute();
            if (hasResults) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        System.out.println("\n" + rs.getString("message"));
                        System.out.println("FIR Registered ID : " + rs.getInt("fir_registered"));
                        System.out.println("Case Opened    ID : " + rs.getInt("case_opened"));
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error filing FIR: " + e.getMessage());
        }
    }
 
    // ─── 7. Record Arrest + Bail (Transaction) ───────────────
    static void recordArrestWithTransaction() {
        System.out.println("\n─── Record Arrest and Bail (Transaction) ───");
 
        showAllCases();
        int caseId = getIntInput("Case ID                       : ");
 
        showAllPersons();
        int personId = getIntInput("Person ID                     : ");
 
        System.out.print("Arrest Date (YYYY-MM-DD)      : "); String arrestDate    = sc.nextLine();
        System.out.print("Charge Section                : "); String chargeSection = sc.nextLine();
        System.out.print("Remand Expiry (YYYY-MM-DD)    : "); String remandExpiry  = sc.nextLine();
        System.out.print("Bail Grounds                  : "); String grounds       = sc.nextLine();
        System.out.print("Grant Court                   : "); String court         = sc.nextLine();
        System.out.print("Bail Status (Granted/Rejected): "); String bailStatus    = sc.nextLine();
 
        String insertAccused = """
                INSERT INTO Accused
                    (case_id, person_id, arrest_date, status, charge_section, remand_expiry)
                VALUES (?, ?, ?, 'Arrested', ?, ?)
                """;
        String insertBail = """
                INSERT INTO Bail_Record
                    (accused_id, ground_list, grant_court, bail_amount, expiry_date, status)
                VALUES (?, ?, ?, NULL, NULL, ?)
                """;
 
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            int accId;
 
            try (PreparedStatement ps1 = con.prepareStatement(insertAccused,
                    Statement.RETURN_GENERATED_KEYS)) {
                ps1.setInt   (1, caseId);
                ps1.setInt   (2, personId);
                ps1.setDate  (3, Date.valueOf(arrestDate));
                ps1.setString(4, chargeSection);
                ps1.setDate  (5, Date.valueOf(remandExpiry));
                ps1.executeUpdate();
                con.setSavepoint("accused_inserted");
                System.out.println("[ SAVEPOINT ] accused_inserted");
                try (ResultSet keys = ps1.getGeneratedKeys()) {
                    keys.next();
                    accId = keys.getInt(1);
                    System.out.println("Accused inserted. acc_id = " + accId);
                }
            }
 
            try (PreparedStatement ps2 = con.prepareStatement(insertBail)) {
                ps2.setInt   (1, accId);
                ps2.setString(2, grounds);
                ps2.setString(3, court);
                ps2.setString(4, bailStatus);
                ps2.executeUpdate();
                con.setSavepoint("bail_recorded");
                System.out.println("[ SAVEPOINT ] bail_recorded");
                System.out.println("Bail inserted. Status: " + bailStatus);
            }
 
            con.commit();
            System.out.println("[ COMMIT ] Transaction completed successfully.");
 
        } catch (SQLException e) {
            System.err.println("Transaction failed: " + e.getMessage());
            try {
                if (con != null) { con.rollback(); System.out.println("[ ROLLBACK ]"); }
            } catch (SQLException ex) { System.err.println(ex.getMessage()); }
        } finally {
            try { if (con != null) con.setAutoCommit(true); }
            catch (SQLException e) { System.err.println(e.getMessage()); }
        }
    }
 
    // ─── 8. Officer Caseload Report ──────────────────────────
    static void viewOfficerCaseload() {
        String sql = """
                SELECT o.of_id, o.of_name, o.designation,
                       ps.ps_name AS station,
                       COUNT(cc.case_id)                                       AS total_cases,
                       SUM(CASE WHEN cc.status='Active' THEN 1 ELSE 0 END)    AS active_cases,
                       SUM(CASE WHEN cc.status='Closed' THEN 1 ELSE 0 END)    AS closed_cases
                FROM   Officer o
                JOIN   PoliceStation ps ON o.ps_id         = ps.ps_id
                LEFT JOIN Crime_Case cc ON o.of_id         = cc.invest_off_id
                GROUP  BY o.of_id, o.of_name, o.designation, ps.ps_name
                ORDER  BY active_cases DESC
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            System.out.println("\n─── OFFICER CASELOAD REPORT ──────────────────────────────────────────────────────────────");
            System.out.printf("%-5s  %-20s  %-14s  %-22s  %-8s  %-8s  %-8s%n",
                    "ID", "Officer", "Designation", "Station", "Total", "Active", "Closed");
            System.out.println("─".repeat(90));
            while (rs.next())
                System.out.printf("%-5d  %-20s  %-14s  %-22s  %-8d  %-8d  %-8d%n",
                        rs.getInt("of_id"),
                        rs.getString("of_name"),
                        rs.getString("designation"),
                        rs.getString("station"),
                        rs.getInt("total_cases"),
                        rs.getInt("active_cases"),
                        rs.getInt("closed_cases"));
            System.out.println("─".repeat(90));
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
 
    // ─── 9. Search Person by Name ────────────────────────────
    static void searchPersonByName() {
        System.out.print("\nEnter name to search (partial allowed): ");
        String name = sc.nextLine();
        String sql = """
                SELECT p_id, p_name, dob, gender, aadhaar_no,
                       contact, p_type, crim_rec_count
                FROM   Person
                WHERE  p_name LIKE ?
                ORDER  BY p_name
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + name + "%");
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("\n─── RESULTS FOR: \"" + name + "\" ─────────────────────────────────────────────────────────");
                System.out.printf("%-5s  %-20s  %-12s  %-8s  %-14s  %-13s  %-10s  %s%n",
                        "ID", "Name", "DOB", "Gender", "Aadhaar", "Contact", "Type", "CrimCount");
                System.out.println("─".repeat(100));
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    System.out.printf("%-5d  %-20s  %-12s  %-8s  %-14s  %-13s  %-10s  %d%n",
                            rs.getInt("p_id"),
                            rs.getString("p_name"),
                            rs.getDate("dob"),
                            rs.getString("gender"),
                            rs.getString("aadhaar_no"),
                            rs.getString("contact"),
                            rs.getString("p_type"),
                            rs.getInt("crim_rec_count"));
                }
                if (!found)
                    System.out.println("No person found matching: " + name);
            }
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
 
    // ─── 10. View Case Details ───────────────────────────────
    static void viewCaseDetails() {
        showAllCases();                                      // SHOW FIRST
        int caseId = getIntInput("Enter Case ID     : ");
        String sql = """
                SELECT cc.case_id, f.fir_id, f.section,
                       f.incident_date, f.location, f.descr AS fir_description,
                       ps.ps_name AS station, o.of_name AS investigating_officer,
                       cc.open_date, cc.close_date, cc.status, cc.summary
                FROM   Crime_Case   cc
                JOIN   FIR           f  ON cc.fir_id        = f.fir_id
                JOIN   Officer       o  ON cc.invest_off_id  = o.of_id
                JOIN   PoliceStation ps ON f.ps_id           = ps.ps_id
                WHERE  cc.case_id = ?
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, caseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("\n─── CASE DETAILS ──────────────────────────────────");
                    System.out.println(" Case ID             : " + rs.getInt("case_id"));
                    System.out.println(" FIR ID              : " + rs.getInt("fir_id"));
                    System.out.println(" IPC Section         : " + rs.getString("section"));
                    System.out.println(" Incident Date       : " + rs.getDate("incident_date"));
                    System.out.println(" Location            : " + rs.getString("location"));
                    System.out.println(" FIR Description     : " + rs.getString("fir_description"));
                    System.out.println(" Station             : " + rs.getString("station"));
                    System.out.println(" Investigating Off.  : " + rs.getString("investigating_officer"));
                    System.out.println(" Case Opened On      : " + rs.getDate("open_date"));
                    System.out.println(" Case Closed On      : " + rs.getDate("close_date"));
                    System.out.println(" Status              : " + rs.getString("status"));
                    System.out.println(" Summary             : " + rs.getString("summary"));
                    System.out.println("─".repeat(50));
                } else {
                    System.out.println("No case found with ID: " + caseId);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
 
    // ─── 11. View Accused in a Case ──────────────────────────
    static void viewAccusedInCase() {
        showAllCases();                                      // SHOW FIRST
        int caseId = getIntInput("Enter Case ID     : ");
        String sql = """
                SELECT a.acc_id, p.p_name AS accused_name,
                       p.contact, p.aadhaar_no,
                       a.arrest_date, a.status AS arrest_status,
                       a.charge_section, a.remand_expiry,
                       br.status AS bail_status, br.grant_court
                FROM   Accused      a
                JOIN   Person       p   ON a.person_id   = p.p_id
                LEFT JOIN Bail_Record br ON a.acc_id     = br.accused_id
                WHERE  a.case_id = ?
                ORDER  BY a.acc_id
                """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, caseId);
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("\n─── ACCUSED IN CASE ID: " + caseId + " ─────────────────────────────────────────────────────────");
                System.out.printf("%-6s  %-20s  %-13s  %-14s  %-12s  %-12s  %-14s  %-14s  %-12s%n",
                        "ACC_ID", "Name", "Contact", "Aadhaar",
                        "Arrest Date", "Status", "Charge", "Remand Expiry", "Bail Status");
                System.out.println("─".repeat(125));
                boolean found = false;
                while (rs.next()) {
                    found = true;
                    System.out.printf("%-6d  %-20s  %-13s  %-14s  %-12s  %-12s  %-14s  %-14s  %-12s%n",
                            rs.getInt("acc_id"),
                            rs.getString("accused_name"),
                            rs.getString("contact"),
                            rs.getString("aadhaar_no"),
                            rs.getDate("arrest_date"),
                            rs.getString("arrest_status"),
                            rs.getString("charge_section"),
                            rs.getDate("remand_expiry"),
                            rs.getString("bail_status") != null
                                    ? rs.getString("bail_status") : "No Record");
                }
                if (!found)
                    System.out.println("No accused found for Case ID: " + caseId);
            }
        } catch (SQLException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
 
    // ─── 12. Issue New Notice ──────────────────────────────────
    static void issueNotice() {
        System.out.println("\n─── Issue New Notice ───");

        // Display accused persons
        String accusedSQL = """
                SELECT a.acc_id, p.p_name, a.case_id
                FROM Accused a
                JOIN Person p ON a.person_id = p.p_id
                ORDER BY a.acc_id
                """;

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(accusedSQL);
             ResultSet rs = ps.executeQuery()) {

            System.out.printf("%-12s %-25s %-10s%n",
                    "Accused ID", "Name", "Case ID");
            System.out.println("-".repeat(50));
            boolean found = false;

            while (rs.next()) {
                found = true;
                System.out.printf("%-12d %-25s %-10d%n",
                        rs.getInt("acc_id"),
                        rs.getString("p_name"),
                        rs.getInt("case_id"));
            }

            if (!found) {
                System.out.println("No accused persons available.");
                return;
            }
        } catch (SQLException e) {
            System.err.println("Error fetching accused: " + e.getMessage());
            return;
        }

        int accusedId = getIntInput("Enter Accused ID: ");
        showAllStations();
        int stationId = getIntInput("Enter Issuing Station ID: ");

        System.out.print("Notice Issue Date (YYYY-MM-DD): ");
        String issueDate = sc.nextLine().trim();
        System.out.print("Notice Description: ");
        String description = sc.nextLine().trim();
        System.out.println("Status options: Active / Withdrawn / Executed");
        System.out.print("Enter Notice Status: ");
        String status = sc.nextLine().trim();

        if (!status.equalsIgnoreCase("Active")
                && !status.equalsIgnoreCase("Withdrawn")
                && !status.equalsIgnoreCase("Executed")) {
            System.out.println("Invalid status. Choose Active, Withdrawn, or Executed.");
            return;
        }

        String normalizedStatus = status.substring(0, 1).toUpperCase()
                + status.substring(1).toLowerCase();

        String insertSQL = """
                INSERT INTO Notice
                    (accused_id, issued_station, iss_date, descr, status)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                     insertSQL, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, accusedId);
            ps.setInt(2, stationId);
            ps.setDate(3, Date.valueOf(issueDate));
            ps.setString(4, description);
            ps.setString(5, normalizedStatus);

            if (ps.executeUpdate() > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        System.out.println("\nNotice issued successfully!");
                        System.out.println("Notice ID   : " + keys.getInt(1));
                        System.out.println("Accused ID  : " + accusedId);
                        System.out.println("Station ID  : " + stationId);
                        System.out.println("Issue Date  : " + issueDate);
                        System.out.println("Description : " + description);
                        System.out.println("Status      : " + normalizedStatus);
                    }
                }
            }
        } catch (IllegalArgumentException e) {
            System.err.println("Invalid date. Use YYYY-MM-DD.");
        } catch (SQLException e) {
            System.err.println("Error issuing notice: " + e.getMessage());
        }
    }

    // ─── UTILITY ──────────────────────────────────────────────
    static int getIntInput(String prompt) {
        System.out.print(prompt);
        while (!sc.hasNextInt()) {
            System.out.print("Enter a valid number: ");
            sc.next();
        }
        int val = sc.nextInt();
        sc.nextLine();
        return val;
    }
}
