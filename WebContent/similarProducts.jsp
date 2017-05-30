<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Similar Products</title>
</head>
<body>
	<% long startTime = System.currentTimeMillis();
//Check to see if logged in or not.
if(session.getAttribute("personName")==null) {
	session.setAttribute("error","PLEASE LOG IN BEFORE ENTERING OTHER PAGES");
	response.sendRedirect("login.jsp");
	return;
}
//Check to see role
%>
  <header>
  	<h2>Hello <%=session.getAttribute("personName") %>!</h2>
  </header>
    <%-- Import the java.sql package --%>
    <%@ page import="java.sql.*"%>
    <%-- -------- Open Connection Code -------- --%>
    <%
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    Statement st = null;
    ResultSet rs = null;
    
    try{
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
        
        System.out.println("BEFORE EXECUTE");
        conn.setAutoCommit(false);
        st = conn.createStatement();
        String query = "CREATE VIEW p_to_pd" +
        	" AS SELECT p.id AS person_id, pd.id AS product_id, 0 AS sum FROM person p, product pd";
        st.execute(query);
        st = conn.createStatement();
		query = "CREATE VIEW spendings AS" +
        	" (select p.id, pic.product_id, SUM(pic.price*pic.quantity) AS total" + 
        	" FROM person p, shopping_cart sc, products_in_cart pic" +
        	" WHERE p.id = sc.person_id AND pic.cart_id=sc.id AND sc.is_purchased='t'" +
        	" GROUP BY p.id, product_id ORDER BY p.id, pic.product_id )";
		st.execute(query);
		st = conn.createStatement();
        query = "WITH ptp_all AS " + 
        			"(SELECT * FROM spendings UNION " +
        			"SELECT * FROM p_to_pd ptp WHERE (ptp.person_id,ptp.product_id) " + 
        			"NOT IN (SELECT id, product_id FROM spendings) ORDER BY product_id, id) " +
        		"SELECT v1.product_id AS vid1,v2.product_id AS vid2," + 
        			"SUM(v1.total*v2.total)/(SQRT(SUM(v1.total*v1.total))*SQRT(SUM(v2.total*v2.total))) AS cosine " +
        		    "FROM ptp_all v1 INNER JOIN ptp_all v2 ON v1.id=v2.id AND v1.product_id<>v2.product_id " +
        			"WHERE v1.product_id<v2.product_id " + 
        			"GROUP BY v1.product_id,v2.product_id ORDER BY cosine DESC LIMIT 100";
        rs = st.executeQuery( query );
        st = conn.createStatement();
        st.executeUpdate("DROP VIEW spendings; DROP VIEW p_to_pd;");
        conn.commit();
        conn.setAutoCommit(true);
        System.out.println("AFTER EXECUTE");
        %>
        <tr><th>Similar Products(by ID)</th></tr>
        <table border="1">
        <tr>
        <td>Product 1</td>
        <td>Product 2</td>
        <td>Cos Similarity</td>
        </tr>
        <% 
        while ( rs.next() ){
        	//System.out.println("Check RS");
        	%>
        	<tr>
        	  <td><%=rs.getInt("vid1")%></td>
        	  <td><%=rs.getInt("vid2")%></td>
        	  <td><%=rs.getDouble("cosine")%></td>
        	</tr>
        	<%
        }
        %>
        </table>
        <%-- -------- Close Connection Code -------- --%>
   		<%
        if(rs.isAfterLast()){
        // Close the ResultSet
        rs.close();

        // Close the Statement
       // statement.close();

        // Close the Connection
        conn.close();
        }
    }
    catch(Exception e){
    	//System.out.println(e.getSQLState());
    	System.out.println("Exception Occurred");
        st = conn.createStatement();
        st.executeUpdate("DROP VIEW ptp_all;" +
        		"DROP VIEW spendings;" +
        		"DROP VIEW p_to_pd;");
    }
    finally {
        // Release resources in a finally block in reverse-order of
        // their creation

        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) { } // Ignore
            rs = null;
        }
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) { } // Ignore
            pstmt = null;
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) { } // Ignore
            conn = null;
        }
        long endTime   = System.currentTimeMillis();
    	long totalTime = endTime - startTime;
    	System.out.println("TOTAL RUNTIME IN MS WAS: " + totalTime);
    }
    %>
</body>
</html>