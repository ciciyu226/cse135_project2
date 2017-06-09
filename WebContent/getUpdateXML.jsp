<?xml version="1.0" encoding="ISO-8859-1"?>
<% response.setContentType("text/xml"); %>

<%@page import="ucsd.shoppingApp.*, java.util.*, java.sql.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.sql.Connection, ucsd.shoppingApp.ConnectionManager, ucsd.shoppingApp.*"%>
<%@ page import="ucsd.shoppingApp.models.* , java.util.*" %>

<% 
//Check to see if logged in or not.
if(session.getAttribute("personName")==null) {
	session.setAttribute("error","PLEASE LOG IN BEFORE ENTERING OTHER PAGES");
	response.sendRedirect("login.jsp");
	return;
}
//Check to see role
%>

  <%-- Import the java.sql package --%>
  <%@ page import="java.sql.*"%>
  <%
  	Connection conn = null;
    PreparedStatement pstmt = null;
    Statement statement = null;
    Statement statement2 = null;
    Statement statement4 = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    ResultSet rs4 = null;
    
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/postgres?" +
            "user=postgres&password=");
         
    
    //conn.setAutoCommit(false);
    String precomputed_log = "WITH state_added AS ("
    	    + " SELECT state_id,state_name,SUM(added) AS added FROM logs GROUP BY state_id, state_name),"
    	    + " product_added AS (SELECT product_id,product_name,SUM(added) AS added FROM logs GROUP BY product_id, product_name),"
    	    + " added_totals AS (SELECT state_id, state_name, product_id, product_name, SUM(added) AS added FROM logs GROUP BY state_id, state_name, product_id, product_name),"
    	    + " new_totals AS (SELECT p.state_id, p.state_name, p.product_id, p.product_name, p.category_id,"
    	        + " (p.cell_sum+l.added) AS cell_sum, (p.state_sum+sa.added) AS state_sum, (p.product_sum+pa.added) AS product_sum"
    	      + " FROM precomputed p, added_totals l, state_added sa, product_added pa"
    	      + " WHERE (l.state_id, l.product_id)=(p.state_id,p.product_id) AND p.state_id=sa.state_id AND p.product_id=pa.product_id)"
    	      + " SELECT * FROM new_totals UNION SELECT * FROM precomputed p WHERE (p.state_id,p.product_id)" 
    	      + " NOT IN (SELECT nt.state_id, nt.product_id FROM new_totals nt) ORDER BY state_sum DESC, product_sum DESC;";
    
    String product_header = "WITH T AS (" 
    		+ " WITH state_added AS ("
    	    + " SELECT state_id,state_name,SUM(added) AS added FROM logs GROUP BY state_id, state_name),"
    	    + " product_added AS (SELECT product_id,product_name,SUM(added) AS added FROM logs GROUP BY product_id, product_name),"
    	    + " new_totals AS (SELECT p.state_id, p.state_name, p.product_id, p.product_name, p.category_id,"
    	        + " (p.cell_sum+l.added) AS cell_sum, (p.state_sum+sa.added) AS state_sum, (p.product_sum+pa.added) AS product_sum"
    	      + " FROM precomputed p, logs l, state_added sa, product_added pa"
    	      + " WHERE (l.state_id, l.product_id)=(p.state_id,p.product_id) AND p.state_id=sa.state_id AND p.product_id=pa.product_id)"
    	      + " (SELECT * FROM new_totals UNION SELECT * FROM precomputed p WHERE (p.state_id,p.product_id)" 
    	      + " NOT IN (SELECT nt.state_id, nt.product_id FROM new_totals nt)) ORDER BY state_sum DESC, product_sum DESC)"
    	      + " SELECT product_id, product_name, MAX(product_sum) as product_sum FROM T GROUP BY product_id, product_name ORDER BY product_sum DESC;";
    	      //TODO: manually check the rank of each log table product after their sales in the precomputed table are updated
    
    statement = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
    	    ResultSet.CONCUR_READ_ONLY);
    statement2 = conn.createStatement();
    
    conn.setAutoCommit(false);
    rs = statement.executeQuery(precomputed_log);
    rs2 = statement2.executeQuery(product_header);
    conn.commit();
    conn.setAutoCommit(true);
    //statement2.execute(dropView);
    //conn.commit();
    //conn.setAutoCommit(true);
    %> <item> <% 
    while(rs.next()) { 
    %>
       	<currentRow>
       		<productHeaderCellID>0_<%= rs.getInt("product_id") %></productHeaderCellID>
			<productHeaderName><%= rs.getString("product_name") %></productHeaderName>
      		<productHeaderValue><%= rs.getInt("product_sum") %></productHeaderValue>
       	
			<stateHeaderCellID><%= rs.getInt("state_id")%>_0</stateHeaderCellID>
 			<stateHeaderName><%= rs.getString("state_name") %></stateHeaderName>
       		<stateHeaderValue><%= rs.getInt("state_sum") %></stateHeaderValue>
       	
       		<innerCellID><%= rs.getInt("state_id") %>_<%= rs.getInt("product_id") %></innerCellID>
       		<innerCellValue><%= rs.getInt("cell_sum") %></innerCellValue>
       	</currentRow>
 <%  }
    
    while(rs2.next()) { %>
    	<currentProduct>
    		<productHeaderCellID1>0_<%= rs2.getInt("product_id") %></productHeaderCellID1>
    		<productHeaderName1><%= rs2.getString("product_name") %></productHeaderName1>
    		<productHeaderValue1><%= rs2.getInt("product_sum") %></productHeaderValue1>
    	</currentProduct>
  <% }
    System.out.println("Sending response");   
  %>
</item>
  
  <%-- -------- Close Connection Code -------- --%>
    <%  
  	  conn.close();
    }catch (SQLException e) {
      throw new RuntimeException(e);
    
    }finally {
        // Release resources in a finally block in reverse-order of
        // their creation

        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) { } // Ignore
            rs = null;
        }
        
        if (rs1 != null) {
            try {
                rs1.close();
            } catch (SQLException e) { } // Ignore
            rs1 = null;
        }
        if (rs2 != null) {
            try {
                rs2.close();
            } catch (SQLException e) { } // Ignore
            rs2 = null;
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
    }
    %>
